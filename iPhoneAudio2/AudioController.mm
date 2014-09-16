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
        _oscillators = @[
                        [[Analog_Oscillator alloc] initWithSampleRate:kGraphSampleRate],
                        [[Analog_Oscillator  alloc] initWithSampleRate:kGraphSampleRate]
                        ];
    } else {
        _oscillators = @[
                        [[Oscillator alloc] initWithSampleRate:kGraphSampleRate],
                        [[Oscillator alloc] initWithSampleRate:kGraphSampleRate]
                        ];
    }
    
    _filter = [[Filter alloc] initWithSampleRate:kGraphSampleRate];
    
    _vcoEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    _filterEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    
    osc2Freq = 1.0f;
    _osc1vol = 0.5f;
    _osc2vol = 0.5f;
    
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
    result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, outputNode, 0);
    
    // Connect Mixer Node's output to the Filter node's input
    // result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, converterNode, 0);
    
    // Connect Converter Node's outout to the Filter node's input
    // result = AUGraphConnectNodeInput(mGraph, converterNode, 0, filterNode, 0);
    
    // Connect FIlter Node's output to RemoteIO node's input
    // result = AUGraphConnectNodeInput(mGraph, filterNode, 0, outputNode, 0);
    
    // Open the graph - AudioUnits are opened but not initialized
    result = AUGraphOpen(mGraph);
    
    // Get a link to the mixer AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, mixerNode, NULL, &_mMixer);
    
    result = AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter);
    
    // Get a linke to the filter AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, filterNode, NULL, &_mFilter);
    
    // Get a link to the output AU so we can talk to it later
    result = AUGraphNodeInfo(mGraph, outputNode, NULL, &mOutput);
    
    // *** Make Connections to the Mixer Unit's INputs ***
    
    // Set the number of input busses on the mixer
    UInt32 numbuses = 1;
    UInt32 size = sizeof(numbuses);
    result = AudioUnitSetProperty(_mMixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, size);
    
    // Get a CAStreamBasicDescription from the mixer AudioUnit input
    CAStreamBasicDescription desc;
    
    // Setup callbacks for each source
    for (int i = 0; i < numbuses; i++) {
        
        // Setup render callback struct
        AURenderCallbackStruct renderCallbackStruct;
        renderCallbackStruct.inputProc = &renderAudio;
        
        switch (i) {
            case 0:
                renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
                break;
            case 1:
                renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
                break;
            default:
                break;
        }
        
        //Set the callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback(mGraph, mixerNode, i, &renderCallbackStruct);
        
        size = sizeof(desc);
        result = AudioUnitGetProperty(_mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &size);
        
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
        result = AudioUnitSetProperty(_mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, sizeof(desc));
    }
    
    // Apply the modified AudioStream description to the mixer output bus
    result = AudioUnitSetProperty(_mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, sizeof(desc));
    
    // Apply AudioStream description to convert input bus
    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, sizeof(desc));
    
    // *** Setup the Audio Output Stream **
    
    // Grab Filter's native stream
    AudioStreamBasicDescription filterStreamDesc = { 0 };
    size = sizeof(filterStreamDesc);
    result = AudioUnitGetProperty(_mFilter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,  0,  &(filterStreamDesc), &size);
    
    // Set stream of converter output
    result = AudioUnitSetProperty(mConverter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &(filterStreamDesc), size);
    
    // Get a stream description form the output audio unit
    result = AudioUnitGetProperty(_mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, &size);
    
    // Initialize the structure to 0
    memset(&desc, 0, sizeof(desc));
    
    // Make modifications
    desc.SetAUCanonical(1, true);
    desc.mSampleRate = kGraphSampleRate;
    
    // Set audiostream format of filter output
    result = AudioUnitSetProperty(_mFilter, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, sizeof(desc));
    
    // Print graph setup
    CAShow(mGraph);
    result = AUGraphInitialize(mGraph);
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
static OSStatus renderAudio(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // DSP!
    // Renders synth
    
    if (inBusNumber == 0) {
    
        // Get reference to audio controller from inRefCon
        AudioController *ac = (__bridge AudioController*)inRefCon;
        
        // Generate buffer for oscillator 1
        AudioSignalType *osc1 = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
        [ac.oscillators[0] fillBuffer:osc1 with:inNumberFrames];
        
        // Generate buffer for oscillator 2
        AudioSignalType *osc2 = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
        [ac.oscillators[1] fillBuffer:osc2 with:inNumberFrames];

        // Generate VCO envelope buffer
        AudioSignalType *vcoEnvelope = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
        [ac.vcoEnvelope fillEnvelopeBuffer:vcoEnvelope with:inNumberFrames];
        
        // Generate VCF envelope buffer
        AudioSignalType *filterEnvelope = (AudioSignalType*)malloc(inNumberFrames * sizeof(AudioSignalType));
        [ac.filterEnvelope fillEnvelopeBuffer:filterEnvelope with:inNumberFrames];
        
        // Mix oscillator 1 * 2
        AudioSignalType *mixedSignal = (AudioSignalType *)malloc(inNumberFrames * sizeof(AudioSignalType));
        
        for (int i = 0; i < inNumberFrames;i++) {
            mixedSignal[i] = ((osc1[i] * ac.osc1vol) + (osc2[i] * ac.osc2vol) / 2.0);
            mixedSignal[i] = mixedSignal[i] * vcoEnvelope[i];
        }
        
        // Filter
        [ac.filter processBuffer:mixedSignal with:inNumberFrames envelope:filterEnvelope];

        // Fill audio buffer
        
        // outA is a pointer to the buffer that will be filled
        AudioSampleType *outA = (AudioSampleType *)ioData->mBuffers[0].mData;
        
        for (int i = 0; i < inNumberFrames; i++) {
            //printf("%.3f\n", osc1[i]);
            outA[i] = mixedSignal[i] * 32767.0f;
        }
        
        free (osc1);
        free (osc2);
        free (vcoEnvelope);
        free (filterEnvelope);
        free (mixedSignal);
    }
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

}


-(void)noteOff {
    [_vcoEnvelope releaseNote];
    [_filterEnvelope releaseNote];
}



-(void)setFrequencies:(float)frequency {

    noteFreq = frequency;

    [_oscillators[0] setFreq:frequency];
    [_oscillators[1] setFreq:frequency * osc2Freq];
    
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
    osc2Freq = value;
    [self setFrequencies:noteFreq];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId WaveformChangedTo:(int)value {
    [_oscillators[oscillatorId] setWaveform:(Waveform)value];
}

-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId OctaveChangedTo:(int)value {
    [_oscillators[oscillatorId] setOctave:value];
}

-(void)envelopeControlView:(EnvelopeControlView *)view didChangeParameter:(ADSRParameter)parameter forEnvelopeId:(int)envelopeId toValue:(float)value {

    if (envelopeId == 0) {
        switch (parameter) {
            case Attack:
                [_vcoEnvelope setEnvelopeAttack:value];
                break;
            case Decay:
                [_vcoEnvelope setEnvelopeDecay:value];
                break;
            case Release:
                [_vcoEnvelope setEnvelopeRelease:value];
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
                [_filterEnvelope setEnvelopeAttack:value];
                break;
            case Decay:
                [_filterEnvelope setEnvelopeDecay:value];
                break;
            case Release:
                [_filterEnvelope setEnvelopeRelease:value];
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

@end
