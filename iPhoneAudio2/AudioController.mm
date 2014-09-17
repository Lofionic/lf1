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
    float osc2Freq;
}


-(void)initializeAUGraph {
    
    // initialize components
    if (USE_ANALOG > 0) {
        _osc1 = [[Analog_Oscillator alloc] initWithSampleRate:kGraphSampleRate];
        _osc2 = [[Analog_Oscillator  alloc] initWithSampleRate:kGraphSampleRate];
        
    } else {
        _osc1 = [[Oscillator alloc] initWithSampleRate:kGraphSampleRate];
        _osc2 = [[Oscillator alloc] initWithSampleRate:kGraphSampleRate];
                       
    }
    
    _filter = [[Filter alloc] initWithSampleRate:kGraphSampleRate];
    _vcoEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    _filterEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    _lfo1 = [[LFO alloc] initWithSampleRate:kGraphSampleRate];
    
    [_lfo1 setFreq:30];
    [_lfo1 setAmp:0.2];
    [_lfo1 setWaveform:LFOSin];
    
    [_filter setLfo:_lfo1];
    
    osc2Freq = 1.0f;
    _osc1vol = 0.5f;
    _osc2vol = 0.5f;
    
    // Error checking result
    // OSStatus result = noErr;
    
    // create a new AU graph
    NewAUGraph(&mGraph);
    
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
    AUGraphAddNode(mGraph, &converter_desc, &converterNode);
    AUGraphAddNode(mGraph, &output_desc, &outputNode);
    
    // Connect Converter Node's outout to the Output node's input
    AUGraphConnectNodeInput(mGraph, converterNode, 0, outputNode, 0);
    
    // Open the graph - AudioUnits are opened but not initialized
    AUGraphOpen(mGraph);
    
    // Get a link to the converter node
    AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter);

    // Get a link to the output AU so we can talk to it later
    AUGraphNodeInfo(mGraph, outputNode, NULL, &mOutput);
    
    // Set the converter callback struct
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderAudio;
    renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
    AUGraphSetNodeInputCallback(mGraph, converterNode, 0, &renderCallbackStruct);
    
    // Set up the converter input stream
    CAStreamBasicDescription desc;
    UInt32 size = sizeof(desc);
    AudioUnitGetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &size);
    
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
    AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, sizeof(desc));
    
    // Print graph setup
    CAShow(mGraph);
    AUGraphInitialize(mGraph);
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
    AUGraphIsRunning(mGraph, &isRunning);
    
    // If the graph is running, stop it
    if (isRunning) {
        AUGraphStop(mGraph);
    }

}

// the render callback procedure
static OSStatus renderAudio(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // DSP!
    // Renders synth
 
    // Get reference to audio controller from inRefCon
    AudioController *ac = (__bridge AudioController*)inRefCon;

    // Initialize buffer in render call since we don't know what the buffer size will be until now
    
    // Generate VCO envelope buffer
    ac.vcoEnvelope.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.vcoEnvelope fillBuffer:ac.vcoEnvelope.buffer samples:inNumberFrames];
    
    // Generate VCF envelope buffer
    ac.filterEnvelope.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.filterEnvelope fillBuffer:ac.filterEnvelope.buffer samples:inNumberFrames];
    
    ac.lfo1.buffer = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.lfo1 fillBuffer:ac.lfo1.buffer samples:inNumberFrames];
    
    // Generate buffer for oscillator 1
    AudioSignalType *osc1 = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.osc1 fillBuffer:osc1 samples:inNumberFrames];
    
    // Generate buffer for oscillator 2
    AudioSignalType *osc2 = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
    [ac.osc2 fillBuffer:osc2 samples:inNumberFrames];

    // Mix oscillator 1 + 2
    AudioSignalType *mixedSignal = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
    
    for (int i = 0; i < inNumberFrames;i++) {
        mixedSignal[i] = ((osc1[i] * ac.osc1vol) + (osc2[i] * ac.osc2vol) / 2.0);
        mixedSignal[i] = mixedSignal[i] * ac.vcoEnvelope.buffer[i];
    }
    
    // Filter
    [ac.filter processBuffer:mixedSignal samples:inNumberFrames envelope:ac.filterEnvelope];

    // Send signal to audio buffer
    // outA is a pointer to the buffer that will be filled
    AudioSampleType *outA = (AudioSampleType *)ioData->mBuffers[0].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        outA[i] = mixedSignal[i] * 32767.0f;
    }
    
    // Free up the buffers we have initialized to avoid memory leaks
    free (ac.vcoEnvelope.buffer);
    free (ac.filterEnvelope.buffer);
    free (ac.lfo1.buffer);
    free (osc1);
    free (osc2);
    free (mixedSignal);
    
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

-(void)noteOn:(float)frequency {

    [self setFrequencies:frequency];
    [_vcoEnvelope triggerNote];
    [_filterEnvelope triggerNote];
    [_lfo1 reset];
}


-(void)noteOff {
    [_vcoEnvelope releaseNote];
    [_filterEnvelope releaseNote];
}



-(void)setFrequencies:(float)frequency {

    noteFreq = frequency;

    [_osc1 setFreq:frequency];
    [_osc2 setFreq:frequency * osc2Freq];
    
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

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId FreqChangedTo:(float)value {
    
    float inValue = (value * 2.0) - 1.0;
    
    osc2Freq = (powf(powf(2, (1.0 / 12.0)), inValue * 7));
    
    [self setFrequencies:noteFreq];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId WaveformChangedTo:(int)value {
    if (oscillatorId == 0) {
        [_osc1 setWaveform:(OscillatorWaveform)value];
    } else {
        [_osc2 setWaveform:(OscillatorWaveform)value];
    }
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId OctaveChangedTo:(int)value {
    if (oscillatorId == 0) {
        [_osc1 setOctave:value];
    } else {
        [_osc2 setOctave:value];
    }
}

-(void)envelopeControlView:(EnvelopeControlView *)view didChangeParameter:(ADSRParameter)parameter forEnvelopeId:(int)envelopeId toValue:(float)value {

    if (envelopeId == 0) {
        switch (parameter) {
            case Attack:
                [_vcoEnvelope setEnvelopeAttack:powf(10000, value) + 10];
                break;
            case Decay:
                [_vcoEnvelope setEnvelopeDecay:powf(10000, value) + 10];
                break;
            case Release:
                [_vcoEnvelope setEnvelopeRelease:powf(10000, value) + 10];
                break;
            case Sustain:
                [_vcoEnvelope setEnvelopeSustain:value];

                break;
            default:
                break;
        }
    } else {
        switch (parameter) {
            case Attack:
                [_filterEnvelope setEnvelopeAttack:powf(10000, value) + 10];
                break;
            case Decay:
                [_filterEnvelope setEnvelopeDecay:powf(10000, value) + 10];
                break;
            case Release:
                [_filterEnvelope setEnvelopeRelease:powf(10000, value) + 10];
                break;
            case Sustain:
                [_filterEnvelope setEnvelopeSustain:value];
                break;
            default:
                break;
        }
    }
}

-(void)filterControlView:(FilterControlView *)view didChangeFrequencyTo:(float)value {
    _filter.cutoff = value;
}

-(void)filterControlView:(FilterControlView *)view didChangeResonanceTo:(float)value {
    _filter.resonance = value;
}

-(void)LFOControlView:(LFOControlView *)view LFOID:(NSInteger)id didChangeRateTo:(float)value {
    _lfo1.freq = (powf(1000, value) / 10);
}

-(void)LFOControlView:(LFOControlView *)view LFOID:(NSInteger)id didChangeAmountTo:(float)value {
    _lfo1.amp = (powf(value, 2));
}

-(void)LFOControlView:(LFOControlView *)view LFOID:(NSInteger)id didChangeDestinationTo:(NSInteger)value {
    _osc1.lfo = (value == 0) ? _lfo1 : 0;
    _osc2.lfo = (value == 0 || value == 1) ? _lfo1 : 0;
    _filter.lfo = (value = 2) ? _lfo1 : 0;
}

-(void)LFOControlView:(LFOControlView *)view LFOID:(NSInteger)id didChangeWaveformTo:(NSInteger)value {
    
    _lfo1.waveform = (LFOWaveform)value;
    
}

@end
