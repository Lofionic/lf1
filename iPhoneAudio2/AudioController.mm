//
//  AudioController.m
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "AudioController.h"
#import "BuildSettings.h"

const Float64 kGraphSampleRate = 44100.0;

@implementation AudioController {
    
    NSArray *oscillators;
    float noteFreq;
    float osc2Freq;
    
    float osc1octave;
    float osc2octave;

    float filterFreq;
}

-(void)startAUGraph {
    
    LFOFreq = 1;

    // Start the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is not running
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    
    if (!isRunning) {
        result = AUGraphStart(mGraph);
        
        // Print the result
        if (result) { printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result); return; }
    }
}

-(void)stopAUGraph {
    
    // Stop the AUGraph
    Boolean isRunning = false;
    
    // Check that the graph is running
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    
    // If the graph is running, stop it
    if (isRunning) {
        result = AUGraphStop(mGraph);
    }
}

// the render callback procedure
static OSStatus renderOscillator(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // Renders Oscillator object that has been passed in inRefCon
    
    // Get the oscillator from inRefCon
    Oscillator *osc = (__bridge Oscillator*)inRefCon;
        
    // outA is a pointer to the buffer that will be filled
    AudioSampleType *outA = (AudioSampleType *)ioData->mBuffers[0].mData;
    
    // Fill the Output buffer
    for (UInt32 i = 0; i < inNumberFrames; ++i) {
        outA[i] = [osc getNextSampleForSampleRate:kGraphSampleRate];
    }

    // Prevent oscillator overflow
    [osc avoidOverflow];
    
    return noErr;
}

/*
OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags *ioActionFlags,
                    const AudioTimeStamp *inTimeStamp,
                    UInt32 inBusNumber,
                    UInt32 inNumberFrames,
                    AudioBufferList *ioData)

{
    // Fixed amplitude is good enough for our purposes
    const double amplitude = 0.25;
    
    // Get the tone parameters out of the view controller
    oscillator *osc = (__bridge oscillator *)inRefCon;
    double theta = osc.sinPhase;
    double theta_increment =
    2.0 * M_PI * osc.freq / kGraphSampleRate;
    
    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        buffer[frame] = (SInt16)(sin(theta) * 32767.0f);
        
        theta += theta_increment;
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
    
    // Store the updated theta back in the view controller
    osc.sinPhase = theta;
    
    return noErr;
}
*/

-(void)initializeAUGraph {
    
    // Create components
    
    if (USE_ANALOG > 0) {
        oscillators = @[
            [[analog_oscillator alloc] init],
            [[analog_oscillator  alloc] init]
            ];
    } else {
        oscillators = @[
            [[Oscillator alloc] init],
            [[Oscillator alloc] init]
        ];
    }
    
    osc2Freq = 1.0f;
    
    // Error checking result
    OSStatus result = noErr;
    
    // create a new AU graph
    result = NewAUGraph(&mGraph);
    
    // AUNodes represent Audio Units on the AUGraph
    AUNode outputNode;
    AUNode mixerNode;
    AUNode converterNode;
    AUNode filterNode;
    
    // Setup Mixer component description
    AudioComponentDescription mixer_desc;
    mixer_desc.componentType = kAudioUnitType_Mixer;
    mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixer_desc.componentFlags = 0;
    mixer_desc.componentFlagsMask = 0;
    mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Set up converter component description
    AudioComponentDescription converter_desc;
    converter_desc.componentType = kAudioUnitType_FormatConverter;
    converter_desc.componentSubType = kAudioUnitSubType_AUConverter;
    converter_desc.componentFlags = 0;
    converter_desc.componentFlagsMask = 0;
    converter_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Setup Filter component description
    AudioComponentDescription filter_desc;
    filter_desc.componentType = kAudioUnitType_Effect;
    filter_desc.componentSubType = kAudioUnitSubType_LowPassFilter;
    filter_desc.componentFlags = 0;
    filter_desc.componentFlagsMask = 0;
    filter_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Setup output component description
    AudioComponentDescription output_desc;
    output_desc.componentType = kAudioUnitType_Output;
    output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
    output_desc.componentFlags = 0;
    output_desc.componentFlagsMask = 0;
    output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Add nodes to the graph to hold our AudioUnits
    result = AUGraphAddNode(mGraph, &mixer_desc, &mixerNode);
    result = AUGraphAddNode(mGraph, &converter_desc, &converterNode);
    result = AUGraphAddNode(mGraph, &filter_desc, &filterNode);
    result = AUGraphAddNode(mGraph, &output_desc, &outputNode);
    
    
    // Connect Mixer Node's output to the RemoteIO node's input
    // result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, outputNode, 0);

    // Connect Mixer Node's output to the Filter node's input
    result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, converterNode, 0);
    
    // Connect Converter Node's outout to the Filter node's input
    result = AUGraphConnectNodeInput(mGraph, converterNode, 0, filterNode, 0);
    
    // Connect FIlter Node's output to RemoteIO node's input
    result = AUGraphConnectNodeInput(mGraph, filterNode, 0, outputNode, 0);
    
    // Open the graph - AudioUnits are opened but not initialized
    result = AUGraphOpen(mGraph);
    
    // Get a link to the mixer AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, mixerNode, NULL, &mMixer);
    
    result = AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter);
    
    // Get a linke to the filter AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, filterNode, NULL, &mFilter);
    
    // Get a link to the output AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, outputNode, NULL, &mOutput);
    
    // *** Make Connections to the Mixer Unit's INputs ***
    
    // Set the number of input busses on the mixer
    UInt32 numbuses = 2;
    UInt32 size = sizeof(numbuses);
    result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, size);

    // Get a CAStreamBasicDescription from the mixer AudioUnit input
    CAStreamBasicDescription desc;
    
    // Setup callbacks for each source
    for (int i = 0; i < numbuses; i++) {
        
        // Setup render callback struct
        AURenderCallbackStruct renderCallbackStruct;
        renderCallbackStruct.inputProc = &renderOscillator;
        
        switch (i) {
            case 0:
                renderCallbackStruct.inputProcRefCon = (__bridge void*)oscillators[0];
                break;
            case 1:
                renderCallbackStruct.inputProcRefCon = (__bridge void*)oscillators[1];
                break;
            default:
                break;
        }
        
        //Set the callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback(mGraph, mixerNode, i, &renderCallbackStruct);
        
        size = sizeof(desc);
        result = AudioUnitGetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &size);
        
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
  
        // Apply the modified AudioStreamBasicDescription to the mixer input bus
        result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, sizeof(desc));
    }
    
    // Apply the modified AudioStream description to the mixer output bus
    result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, sizeof(desc));
    
    // Apply AudioStream description to convert input bus
    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, sizeof(desc));

    // *** Setup the Audio Output Stream **
    
    // Grab Filter's native stream
    AudioStreamBasicDescription filterStreamDesc = { 0 };
    size = sizeof(filterStreamDesc);
    
    result = AudioUnitGetProperty(mFilter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,  0,  &(filterStreamDesc), &size);
    
    // Set stream of converter output
    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &(filterStreamDesc), size);
    

    // Get a stream description form the output audio unit
    result = AudioUnitGetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, &size);
    
    // Initialize the structure to 0
    memset(&desc, 0, sizeof(desc));
    
    // Make modifications
    desc.SetAUCanonical(1, true);
    desc.mSampleRate = kGraphSampleRate;
    
    // Set audiostream format of filter output
    result = AudioUnitSetProperty(mFilter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, sizeof(desc));
    
    // Print graph setup
    CAShow(mGraph);
    
    result = AudioUnitSetParameter(mFilter, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, 200, 0);
    
    result = AUGraphAddRenderNotify(mGraph, renderNotify, (__bridge void*)self);
    
    result = AUGraphInitialize(mGraph);
}


float LFOPhase;
float LFOFreq;

static OSStatus renderNotify (void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    
    AudioController *ac = (__bridge AudioController*)inRefCon;
 
    
    float result = sin(LFOPhase);
    [ac setLfo:result];
    
    float phaseIncrement = M_PI * LFOFreq * (1.5 / 44.1);
    LFOPhase += phaseIncrement;
    
    return noErr;
}

-(void)setLfo:(float)value {
    
    //[self setFrequencies:220 + (110 * value)];
    value += 1;
    value /= 2;
    AudioUnitSetParameter(mFilter, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, (value * 8000) + filterFreq, 0);
}

-(void)setMixerInputChannel:(int)channel toLevel:(float)level {

    AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, channel, level, 0);
    
}

-(void)setMixerOutputLevel:(float)level {
    
    AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, level, 0);
    
}

-(void)noteOn:(float)frequency {

    [self setFrequencies:frequency];

    [oscillators[0] trigger];
    [oscillators[1] trigger];
    
    LFOPhase = 0;
}


-(void)noteOff {
    [oscillators[0] noteRelease];
    [oscillators[1] noteRelease];
}



-(void)setFrequencies:(float)frequency {

    noteFreq = frequency;

    [oscillators[0] setFreq:frequency];
    [oscillators[1] setFreq:frequency * osc2Freq];
    
}

// ControllerProtocols
-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId VolumeChangedTo:(float)value {
    [self setMixerInputChannel:oscillatorId toLevel:value];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId FreqChangedTo:(float)value {
    osc2Freq = value;
    [self setFrequencies:noteFreq];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId WaveformChangedTo:(int)value {
    [oscillators[oscillatorId] setWaveform:(Waveform)value];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId OctaveChangedTo:(int)value {
    [oscillators[oscillatorId] setOctave:value];
}

-(void)envelopeControlView:(EnvelopeControlView *)view didChangeParameter:(ADSRParameter)parameter toValue:(float)value {

    switch (parameter) {
        case Attack:
            [oscillators[0] setEnvelopeAttack:value];
            [oscillators[1] setEnvelopeAttack:value];
            break;
        case Decay:
            [oscillators[0] setEnvelopeDecay:value];
            [oscillators[1] setEnvelopeDecay:value];
            break;
        case Release:
            [oscillators[0] setEnvelopeRelease:value];
            [oscillators[1] setEnvelopeRelease:value];
            break;
        case Sustain:
            [oscillators[0] setEnvelopeSustain:value];
            [oscillators[1] setEnvelopeSustain:value];
            break;
        default:
            break;
    }
}

-(void)filterControlView:(FilterControlView *)view didChangeFrequencyTo:(float)value {
    AudioUnitSetParameter(mFilter, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, (value * 15980) + 20, 0);
    filterFreq = (value * 15980);
}

-(void)filterControlView:(FilterControlView *)view didChangeResonanceTo:(float)value {
    AudioUnitSetParameter(mFilter, kLowPassParam_Resonance, kAudioUnitScope_Global, 0, (value * 60.0) - 20, 0);
}

@end
