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
    
    NSArray *oscillators;
    float noteFreq;
    float osc2Freq;
    
}

-(void)startAUGraph {
    
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
static OSStatus renderOsc(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // Renders Oscillator object that has been passed in inRefCon
    
    // Get the oscillator from inRefCon
    oscillator *osc = (__bridge oscillator*)inRefCon;
        
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
    
    oscillators = @[
                   [[oscillator alloc] initWithFrequency:440 withWaveform:Sin],
                   [[oscillator alloc] initWithFrequency:440 withWaveform:Sin]
                   ];

    osc2Freq = 1.0f;
    
    // Error checking result
    OSStatus result = noErr;
    
    // create a new AU graph
    result = NewAUGraph(&mGraph);
    
    // AUNodes represent Audio Units on the AUGraph
    AUNode outputNode;
    AUNode mixerNode;
    
    // Setup Mixer component description
    AudioComponentDescription mixer_desc;
    mixer_desc.componentType = kAudioUnitType_Mixer;
    mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixer_desc.componentFlags = 0;
    mixer_desc.componentFlagsMask = 0;
    mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Setup output component description
    AudioComponentDescription output_desc;
    output_desc.componentType = kAudioUnitType_Output;
    output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
    output_desc.componentFlags = 0;
    output_desc.componentFlagsMask = 0;
    output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Add nodes to the graph to hold our AudioUnits
    result = AUGraphAddNode(mGraph, &mixer_desc, &mixerNode);
    result = AUGraphAddNode(mGraph, &output_desc, &outputNode);
    
    // Connect Mixer Node's output to the RemoteIO node's input
    result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, outputNode, 0);
    
    // Open the graph - AudioUnits are opened but not initialized
    result = AUGraphOpen(mGraph);
    
    // Get a link to the mixer AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, mixerNode, NULL, &mMixer);
    
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
        renderCallbackStruct.inputProc = &renderOsc;
        
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
    
    // *** Setup the Audio Output Stream **
    
    // Get a stream description form the output audio unit
    result = AudioUnitGetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, &size);
    
    // Initialize the structure to 0
    memset(&desc, 0, sizeof(desc));
    
    // Make modifications
    desc.SetAUCanonical(1, true);
    desc.mSampleRate = kGraphSampleRate;
    
    result= AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, sizeof(desc));
    
    result = AUGraphInitialize(mGraph);
}

-(void)setMixerInputChannel:(int)channel toLevel:(float)level {

    AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, channel, level, 0);
    
}

-(void)setMixerOutputLevel:(float)level {
    
    AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, level, 0);
    
}

-(void)noteOn:(float)frequency {
    
    noteFreq = frequency;
    
    [oscillators[0] setFreq:noteFreq];
    [oscillators[1] setFreq:noteFreq * osc2Freq];
    
    [oscillators[0] setAmp:1.0];
    [oscillators[1] setAmp:1.0];
    
    [oscillators[0] trigger];
    [oscillators[1] trigger];
}

-(void)noteOff {
    [oscillators[0] setAmp:0.0];
    [oscillators[1] setAmp:0.0];
}

// ControllerProtocols
-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId VolumeChangedTo:(float)value {
    [self setMixerInputChannel:oscillatorId toLevel:value];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId FreqChangedTo:(float)value {
    osc2Freq = value;
    [oscillators[1] setFreq:noteFreq * osc2Freq];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId WaveformChangedTo:(int)value {
    [oscillators[oscillatorId] setWaveform:(Waveform)value];
}

@end
