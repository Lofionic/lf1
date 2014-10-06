//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "AudioEngine.h"


const Float64 kGraphSampleRate = 44100.0;
@implementation AudioEngine
    
AudioSignalType prevOut;

#pragma mark INITIALIZATION
-(void)initializeAUGraph {

    [self initializeSynthComponents];
    
    // create a new AU graph
    checkError(NewAUGraph(&mGraph), "Cannot create new AUGraph");
    
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
    checkError(AUGraphAddNode(mGraph, &converter_desc, &converterNode), "Cannot add AUConverter node to AUGraph");

    
    checkError(AUGraphAddNode(mGraph, &output_desc, &outputNode), "Cannot add RemoteIO node to AUGraph");
    
    // Connect Converter Node's outout to the Output node's input
    checkError(AUGraphConnectNodeInput(mGraph, converterNode, 0, outputNode, 0), "Cannot connect AUConverter node to RemoteIO node");
    
    // Open the graph - AudioUnits are opened but not initialized
    checkError(AUGraphOpen(mGraph), "Cannot open AUGraph");
    
    // Get a link to the converter node
    checkError(AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter), "Cannot get info for AUConverter node");

    // Get a link to the output AU so we can talk to it later
    checkError(AUGraphNodeInfo(mGraph, outputNode, NULL, &mOutput), "Cannot get info for RemoteIO node");
    
    // Set the converter callback struct
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderAudio;
    renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
    checkError(AUGraphSetNodeInputCallback(mGraph, converterNode, 0, &renderCallbackStruct), "Cannot set AUConverter node input callback" );

    // Set up the converter input stream
    AudioStreamBasicDescription desc;
    UInt32 size = sizeof(desc);
    
    checkError(AudioUnitGetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &size), "Cannot get stream format from AUConverter");
        // Initialize the structure to ensure there are no spurious values
    memset (&desc, 0, sizeof(desc));
    
    // Make modifications to the AudioStreamBasicDescription
    desc.mSampleRate = kGraphSampleRate;
    desc.mFormatID = kAudioFormatLinearPCM;
    desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    desc.mBitsPerChannel = sizeof(SInt16) * 8; // AudioSampleType == 16 bit signed ints
    desc.mChannelsPerFrame = 1;
    desc.mFramesPerPacket = 1;
    desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
    desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
    
    // Apply the modified AudioStreamBasicDescription to the converter input bus
    checkError(AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, sizeof(desc)), "Cannot set AUConverter audio stream property");

    // Print graph setup
    CAShow(mGraph);
    
    // Start AUGraph
    checkError(AUGraphInitialize(mGraph), "Cannot initialize AUGraph");
    
    prevOut = 0;
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
    
    // Initialize Mixer component
    _mixer = [[Mixer2 alloc] initWithSampleRate:kGraphSampleRate];
    _mixer.source1 = _osc1;
    _mixer.source2 = _osc2;
    _mixer.envelope = _vcoEnvelope;
   
    // Initialize CVController
    _cvController = [[CVController alloc] initWithSampleRate:kGraphSampleRate];
    
    // Plug CV controller into Oscillators
    _osc1.cvController = _cvController;
    _osc2.cvController = _cvController;
    
    // Plug CV controller into gate responders
    _cvController.gateComponents = @[_lfo1, _vcfEnvelope, _vcoEnvelope];
    
}

#pragma mark START & STOP
-(void)startAUGraph {
    // Start the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is not running
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    
    if (!isRunning) {
        // Start the graph
        checkError(AUGraphStart(mGraph), "Cannot start AUGraph");
        
        // Print the result
        if (result) { printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result); return; }
    }
}

-(void)stopAUGraph {
    
    // Stop the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is running
    AUGraphIsRunning(mGraph, &isRunning);
    
    // If the graph is running, stop it
    if (isRunning) {
            checkError(AUGraphStop(mGraph),"Cannot stop AUGraph");
    }
}

#pragma mark RENDER
// the render callback procedure
static OSStatus renderAudio(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // DSP!
    // Renders synth
 
    // Get reference to audio controller from inRefCon
    AudioEngine *ac = (__bridge AudioEngine*)inRefCon;

    
    
    // Generate CV Controller buffer
    // prepare the buffer in case its size has changed
    [ac.cvController prepareBufferWithBufferSize:inNumberFrames];
    [ac.cvController renderBuffer:ac.cvController.buffer samples:inNumberFrames];
    
    
    // Generate VCO envelope buffer
    [ac.vcoEnvelope prepareBufferWithBufferSize:inNumberFrames];
    [ac.vcoEnvelope renderBuffer:ac.vcoEnvelope.buffer samples:inNumberFrames];
    
    
    // Generate VCF envelope buffer
    [ac.vcfEnvelope prepareBufferWithBufferSize:inNumberFrames];
    [ac.vcfEnvelope renderBuffer:ac.vcfEnvelope.buffer samples:inNumberFrames];
    
    
    // Generate LFO buffer
    [ac.lfo1 prepareBufferWithBufferSize:inNumberFrames];
    [ac.lfo1 renderBuffer:ac.lfo1.buffer samples:inNumberFrames];
    
    
    // Generate buffer for oscillator 1
    [ac.osc1 prepareBufferWithBufferSize:inNumberFrames];
    [ac.osc1 renderBuffer:ac.osc1.buffer samples:inNumberFrames];
    
    // Generate buffer for oscillator 2
    [ac.osc2 prepareBufferWithBufferSize:inNumberFrames];
    [ac.osc2 renderBuffer:ac.osc2.buffer samples:inNumberFrames];

    // Generate Mixer buffer
    [ac.mixer prepareBufferWithBufferSize:inNumberFrames];
    [ac.mixer renderBuffer:ac.mixer.buffer samples:inNumberFrames];
    
    // Filter
    AudioSignalType *mixedSignal = ac.mixer.buffer;
    
    [ac.vcf processBuffer:mixedSignal samples:inNumberFrames];

    // Send signal to audio buffer
    // outA is a pointer to the buffer that will be filled
    SInt16 *outA = (SInt16 *)ioData->mBuffers[0].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        
        outA[i] = mixedSignal[i] * 32767.0f; 
 
    }
    
    
    return noErr;
}

static void checkError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else {
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    }
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString); exit(1);
}


@end
