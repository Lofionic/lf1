//
//  AudioController.m
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "AudioController.h"


const Float64 kGraphSampleRate = 44100.0;
@implementation AudioController {
    float noteFreq;
}

#pragma mark INITIALIZATION
-(void)initializeAUGraph {
    
    [self initializeSynthComponents];
    
    // Error checking result
    OSStatus result = noErr;
    
    // create a new AU graph
    result = NewAUGraph(&mGraph);
    
    if (![self checkError:result withDescription:@"Cannot create new AUGraph" ]) {
        return;
    }
    
    // AUNodes represent Audio Units on the AUGraph
    AUNode outputNode;
    AUNode converterNode;
    
    // Set up converter component description
    AudioComponentDescription converter_desc;
    converter_desc.componentType = kAudioUnitType_FormatConverter;
    converter_desc.componentSubType = kAudioUnitSubType_AUConverter;
    converter_desc.componentFlags = 0;
    converter_desc.componentFlagsMask = 0;
    converter_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Setup output component description
    AudioComponentDescription output_desc;
    output_desc.componentType = kAudioUnitType_Output;
    output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
    output_desc.componentFlags = 0;
    output_desc.componentFlagsMask = 0;
    output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Add nodes to the graph to hold our AudioUnits
    result = AUGraphAddNode(mGraph, &converter_desc, &converterNode);
    if (![self checkError:result withDescription:@"Cannot add AUConverter node to AUGraph" ]) {
        return;
    }
    
    result = AUGraphAddNode(mGraph, &output_desc, &outputNode);
    if (![self checkError:result withDescription:@"Cannot add RemoteIO node to AUGraph" ]) {
        return;
    }
    
    // Connect Converter Node's outout to the Output node's input
    result = AUGraphConnectNodeInput(mGraph, converterNode, 0, outputNode, 0);
    if (![self checkError:result withDescription:@"Cannot connect AUConverter node to RemoteIO node" ]) {
        return;
    }
    
    // Open the graph - AudioUnits are opened but not initialized
    result = AUGraphOpen(mGraph);
    if (![self checkError:result withDescription:@"Cannot open AUGraph" ]) {
        return;
    }
    
    // Get a link to the converter node
    result = AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter);
    if (![self checkError:result withDescription:@"Cannot get info for AUConverter node" ]) {
        return;
    }
    
    // Get a link to the output AU so we can talk to it later
    AUGraphNodeInfo(mGraph, outputNode, NULL, &mOutput);
    result = AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter);
    if (![self checkError:result withDescription:@"Cannot get info for RemoteIO node" ]) {
        return;
    }
    
    // Set the converter callback struct
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderAudio;
    renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
    result = AUGraphSetNodeInputCallback(mGraph, converterNode, 0, &renderCallbackStruct);
    if (![self checkError:result withDescription:@"Cannot set AUConverter node input callback" ]) {
        return;
    }
    
    // Set up the converter input stream
    CAStreamBasicDescription desc;
    UInt32 size = sizeof(desc);
    
    result = AudioUnitGetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &size);
    if (![self checkError:result withDescription:@"Cannot get stream format from AUConverter" ]) {
        return;
    }
    
    // Initialize the structure to ensure there are no spurious values
    memset (&desc, 0, sizeof(desc));
    
    // Make modifications to the AudioStreamBasicDescription
    desc.mSampleRate = kGraphSampleRate;
    desc.mFormatID = kAudioFormatLinearPCM;
    desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    desc.mBitsPerChannel = sizeof(AudioSampleType) * 8; // AudioSampleType == 16 bit signed ints
    desc.mChannelsPerFrame = 1;
    desc.mFramesPerPacket = 1;
    desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
    desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
    
    // Apply the modified AudioStreamBasicDescription to the converter input bus
    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, sizeof(desc));
    if (![self checkError:result withDescription:@"Cannot set AUConverter audio stream property" ]) {
        return;
    }
    
    // Print graph setup
    CAShow(mGraph);
    result = AUGraphInitialize(mGraph);
    if (![self checkError:result withDescription:@"Cannot initialize AUGraph" ]) {
        return;
    }
}


-(void)initializeSynthComponents {

    // initialize oscillators
    if (USE_ANALOG > 0) {
        _osc1 = [[Analog_Oscillator alloc] initWithSampleRate:kGraphSampleRate];
        _osc2 = [[Analog_Oscillator  alloc] initWithSampleRate:kGraphSampleRate];
        
    } else {
        _osc1 = [[Oscillator alloc] initWithSampleRate:kGraphSampleRate];
        _osc2 = [[Oscillator alloc] initWithSampleRate:kGraphSampleRate];
    }
    
    // Initialize VCO envelope
    _vcoEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    
    // Initialize filter & vcf envelope
    _vcf = [[VCF alloc] initWithSampleRate:kGraphSampleRate];
    _vcfEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    [_vcf setEnvelope:_vcfEnvelope];
    
    // Initialize LFO
    _lfo1 = [[LFO alloc] initWithSampleRate:kGraphSampleRate];
    [_lfo1 setFreq:30];
    [_lfo1 setAmp:0.2];
    [_lfo1 setWaveform:LFOSin];
    
    // Initial settings
    
    // TODO: Create MIXER component to replace these ivars
    _osc1vol = 0.5f;
    _osc2vol = 0.5f;
   
    // Initialize CVController
    _cvController = [[CVController alloc] initWithSampleRate:kGraphSampleRate];
    // Plug CV controller into Oscillators
    _osc1.cvController = _cvController;
    _osc2.cvController = _cvController;
    
    // Plug CV controller into gate responders
    _cvController.gateComponents = @[_lfo1, _vcfEnvelope, _vcoEnvelope];
    
}

-(BOOL)checkError:(OSStatus)osstatus withDescription:(NSString*)description {
    
    if (osstatus != 0) {
        NSLog(@"AudioEngine Error:%@ OSStatus:%d", description, (int)osstatus);
        return false;
    }
    return true;
}

#pragma mark START & STOP
-(void)startAUGraph {
    // Start the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is not running
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    
    if (!isRunning) {
        // Start the graph
        result = AUGraphStart(mGraph);
        if (![self checkError:result withDescription:@"Cannot start AUGraph" ]) {
            return;
        }
        
        // Print the result
        if (result) { printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result); return; }
    }
}

-(void)stopAUGraph {
    
    // Stop the AUGraph
    Boolean isRunning = false;
    
    OSStatus result;
    
    // Check that the graph is running
    AUGraphIsRunning(mGraph, &isRunning);
    
    // If the graph is running, stop it
    if (isRunning) {
        result = AUGraphStop(mGraph);
        if (![self checkError:result withDescription:@"Cannot stop AUGraph" ]) {
            return;
        }
    }
}

#pragma mark RENDER
// the render callback procedure
static OSStatus renderAudio(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // DSP!
    // Renders synth
 
    // Get reference to audio controller from inRefCon
    AudioController *ac = (__bridge AudioController*)inRefCon;

    // Initialize buffer in render call since we don't know what the buffer size will be until now
    
    // Generate CV Controller buffer
    ac.cvController.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.cvController renderBuffer:ac.cvController.buffer samples:inNumberFrames];
    
    // Generate VCO envelope buffer
    ac.vcoEnvelope.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.vcoEnvelope renderBuffer:ac.vcoEnvelope.buffer samples:inNumberFrames];
    
    // Generate VCF envelope buffer
    ac.vcfEnvelope.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.vcfEnvelope renderBuffer:ac.vcfEnvelope.buffer samples:inNumberFrames];
    
    ac.lfo1.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.lfo1 renderBuffer:ac.lfo1.buffer samples:inNumberFrames];
    
    // Generate buffer for oscillator 1
    AudioSignalType *osc1 = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.osc1 renderBuffer:osc1 samples:inNumberFrames];
    
    // Generate buffer for oscillator 2
    AudioSignalType *osc2 = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.osc2 renderBuffer:osc2 samples:inNumberFrames];

    // Mix oscillator 1 + 2
    AudioSignalType *mixedSignal = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
    
    
    
    for (int i = 0; i < inNumberFrames;i++) {

        mixedSignal[i] = ((osc1[i] * ac.osc1vol) + (osc2[i] * ac.osc2vol) / 2.0);
        mixedSignal[i] = mixedSignal[i] * ac.vcoEnvelope.buffer[i];

    }
    
    // Filter
    [ac.vcf processBuffer:mixedSignal samples:inNumberFrames];

    // Send signal to audio buffer
    // outA is a pointer to the buffer that will be filled
    AudioSampleType *outA = (AudioSampleType *)ioData->mBuffers[0].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        outA[i] = mixedSignal[i] * 32767.0f;
    }
    
    // Free up the buffers we have initialized to avoid memory leaks
    free (ac.vcoEnvelope.buffer);
    free (ac.vcfEnvelope.buffer);
    free (ac.lfo1.buffer);
    free (osc1);
    free (osc2);
    free (mixedSignal);
    
    return noErr;
}

// ControllerProtocols
-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId VolumeChangedTo:(float)value {
    //[self setMixerInputChannel:oscillatorId toLevel:value];
    if (oscillatorId == 0) {
        _osc1vol = value;
    } else {
        _osc2vol = value;
    }
}


@end
