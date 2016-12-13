//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "BuildSettings.h"
#import "Defines.h"
#import "AudioEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <mach/mach_time.h>
#import "AppDelegate.h"


const Float64 kGraphSampleRate = [[AVAudioSession sharedInstance] sampleRate];
@implementation AudioEngine {
    
    HostCallbackInfo *callBackInfo;
    
}

#pragma mark INITIALIZATION
-(void)initializeAUGraph {

    [self initializeSynthComponents];
    
    // create a new AU graph
    checkError(NewAUGraph(&mGraph), "Cannot create new AUGraph");
    
    // AUNodes represent Audio Units on the AUGraph
    AUNode ioNode;
    
    // Setup output component description
    AudioComponentDescription output_desc;
    output_desc.componentType = kAudioUnitType_Output;
    output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
    output_desc.componentFlags = 0;
    output_desc.componentFlagsMask = 0;
    output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Add nodes to the graph to hold our AudioUnits
    checkError(AUGraphAddNode(mGraph, &output_desc, &ioNode), "Cannot add RemoteIO node to AUGraph");
    
    // Open the graph - AudioUnits are opened but not initialized
    checkError(AUGraphOpen(mGraph), "Cannot open AUGraph");
    
    // Get a link to the output AU so we can talk to it later
    checkError(AUGraphNodeInfo(mGraph, ioNode, NULL, &mOutput), "Cannot get info for RemoteIO node");
    
    // Set the render callback struct
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = &renderAudio;
    renderCallbackStruct.inputProcRefCon = (__bridge void*)self;
    checkError(AUGraphSetNodeInputCallback(mGraph, ioNode, 0, &renderCallbackStruct), "Cannot set AUConverter node input callback" );
    
    // Setup the IO stream format
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = kGraphSampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    
    // Apply the modified AudioStreamBasicDescription to the converter input bus
    checkError(AudioUnitSetProperty(mOutput, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat)), "Cannot set AUConverter audio stream property");

    // Add property listeners for inter app audio
    checkError(AudioUnitAddPropertyListener(mOutput, kAudioUnitProperty_IsInterAppConnected, AudioUnitPropertyChangeDispatcher, (__bridge void*)self), "Error setting IsInterAppConnected property listener");
    
    checkError(AudioUnitAddPropertyListener(mOutput, kAudioOutputUnitProperty_HostTransportState, AudioUnitPropertyChangeDispatcher, (__bridge void*)self), "Error setting IsInterAppConnected property listener");
    
    // Publish as inter-app audio node
    [self publishAsNode];
    [self registerNotifications];
    
    // Start AUGraph
    [self checkStartStopGraph];
    
    // Start MIDI
    [self initializeMidi];
    
    // Start Audiobus
    [self initializeAudiobus];
    
    // Print graph setup
    CAShow(mGraph);
}


-(void)initializeSynthComponents {

    // initialize oscillators
    if (USE_ANALOG > 0) {
        self.osc1 = [[Analog_Oscillator alloc] initWithSampleRate:kGraphSampleRate];
        self.osc2 = [[Analog_Oscillator  alloc] initWithSampleRate:kGraphSampleRate];
        
    } else {
        self.osc1 = [[Oscillator alloc] initWithSampleRate:kGraphSampleRate];
        self.osc2 = [[Oscillator alloc] initWithSampleRate:kGraphSampleRate];
    }
    
    // Initialize VCO envelope
    self.vcoEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    
    // Initialize filter & vcf envelope
    self.vcf = [[VCF alloc] initWithSampleRate:kGraphSampleRate];
    self.vcfEnvelope = [[Envelope alloc] initWithSampleRate:kGraphSampleRate];
    [self.vcf setEnvelope:self.vcfEnvelope];
    
    // Initialize LFO
    self.lfo1 = [[LFO alloc] initWithSampleRate:kGraphSampleRate];
    [self.lfo1 setFreq:30];
    [self.lfo1 setAmp:0.2];
    [self.lfo1 setWaveform:LFOSin];
    
    // Initialize Mixer component
    self.mixer = [[Mixer2 alloc] initWithSampleRate:kGraphSampleRate];
    self.mixer.source1 = self.osc1;
    self.mixer.source2 = self.osc2;
    self.mixer.envelope = self.vcoEnvelope;
   
    // Initialize CVController
    self.cvController = [[CVComponent alloc] initWithSampleRate:kGraphSampleRate];
    
    // Plug CV controller into Oscillators
    self.osc1.cvController = self.cvController;
    self.osc2.cvController = self.cvController;
    
    // Plug CV controller into gate responders
    self.cvController.gateComponents = @[self.lfo1, self.vcfEnvelope, self.vcoEnvelope];
}

//Callback for audio units bouncing from c to objective c
void AudioUnitPropertyChangeDispatcher(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    AudioEngine *SELF = (__bridge AudioEngine *)inRefCon;
    [SELF audioUnitPropertyChangedListener:inRefCon unit:inUnit propID:inID scope:inScope element:inElement];
}

#pragma mark PGMidi

-(void)initializeMidi {
    self.midi = MIDI_ENGINE;
    self.midi.delegate = self;
    
    if (self.midi.sources.count > 0) {
        PGMidiSource *source = self.midi.sources[0];
        self.midiSource = source;
    }
}

-(void)setMidiSource:(PGMidiSource *)midiSource {
    for (id thisDelegate in [self.midiSource delegates]) {
        [self.midiSource removeDelegate:thisDelegate];
    }
    
    if (midiSource) {
        [midiSource addDelegate:self];
    }
    
    _midiSource = midiSource;
}

-(void)midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList {
    
    MIDIPacket *packet = (MIDIPacket *)packetList->packet;
    
    for (int i=0; i < packetList->numPackets; i++) {
        
        Byte midiStatus = packet->data[0]; Byte midiCommand = midiStatus >> 4;
        Byte inData1 = packet->data[1] & 0x7F;
        Byte inData2 = packet->data[2] & 0x7F;
        
        if (midiCommand == 0x09) {
            if (inData2 == 0x00) {
                // Midi notes of velocity 0 should be considered note-offs
                [self.cvController noteOff:inData1];
            } else {
                [self.cvController noteOn:inData1];
            }
        } else if (midiCommand == 0x08) {
            [self.cvController noteOff:inData1];
        } else if (midiCommand == 0x0E) {
            int value = ((inData2 << 7)) + inData1;
            [self.cvController setPitchbend:value / 16383.0];
        }
        packet = MIDIPacketNext(packet);
    }
}

-(void)midi:(PGMidi *)midi destinationAdded:(PGMidiDestination *)destination {
    
}

-(void)midi:(PGMidi *)midi destinationRemoved:(PGMidiDestination *)destination {
    
}

-(void)midi:(PGMidi *)midi sourceAdded:(PGMidiSource *)source {
    [self postMidiChangeNotification];
}

-(void)midi:(PGMidi *)midi sourceRemoved:(PGMidiSource *)source {
    if (source == self.midiSource) {
        self.midiSource = nil;
    }
    
    [self performSelector:@selector(postMidiChangeNotification) withObject:nil afterDelay:1];
}

-(void)postMidiChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MIDI_CHANGE_NOTIFICATION object:nil];
    
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

-(void) checkStartStopGraph {
    // Stops and starts AUGraph with respect to in background
    if (self.connected || self.inForeground ) {
        [self setAudioSessionActive];
        //Initialize the graph if it hasn't been already
        if (mGraph) {
            Boolean initialized = YES;
            checkError(AUGraphIsInitialized(mGraph, &initialized), "Error checking initializing of AUGraph");
            if (!initialized)
                checkError(AUGraphInitialize (mGraph), "Error initializing AUGraph");
        }
        [self startAUGraph];
    } else if(!self.inForeground){
        // v1.2 - do not stop audio when in background
        //[self stopAUGraph];
        //[self setAudioSessionInActive];
    }
}

-(void) setAudioSessionActive {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setPreferredSampleRate: [[AVAudioSession sharedInstance] sampleRate] error: nil];
    [session setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error: nil];
    [session setActive: YES error: nil];
}

-(void) setAudioSessionInActive {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive: NO error: nil];
}

#pragma mark RENDER
// the render callback procedure
static OSStatus renderAudio(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
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
    AudioSignalType *outA = (AudioSignalType *)ioData->mBuffers[0].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        
        AudioSignalType output = mixedSignal[i];
        outA[i] = output;
        //printf("%.2f\n", output);
        //outA[i] = output * 32767.0f;
    }
    
    
    return noErr;
}

#pragma mark Housekeeping
-(void)registerNotifications {

    UIApplicationState appstate = [UIApplication sharedApplication].applicationState;
    self.inForeground = (appstate != UIApplicationStateBackground);
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appHasGoneInBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appHasGoneForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(cleanup)
                                                 name: UIApplicationWillTerminateNotification
                                               object: nil];
}

-(void)cleanup {
    [self stopAUGraph];
    AUGraphClose(mGraph);
    DisposeAUGraph(mGraph);
    mGraph = nil;
}

-(void)appHasGoneInBackground {
    self.inForeground = NO;
    [self checkStartStopGraph];
}

-(void) appHasGoneForeground {
    self.inForeground = YES;
    [self isHostConnected];
    [self checkStartStopGraph];
    [self updateStatefromTransportCallBack];
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:UIApplicationDidEnterBackgroundNotification];
    [self removeObserver:self forKeyPath:UIApplicationWillEnterForegroundNotification];
    [self removeObserver:self forKeyPath:UIApplicationWillTerminateNotification];
}


#pragma mark InterApp Audio
// Publish the interapp node
- (void)publishAsNode {
    AudioComponentDescription desc = {
        kAudioUnitType_RemoteInstrument, 'iasp',
        'lfnc',
        0,
        1};
    
    checkError(AudioOutputUnitPublish(&desc, CFSTR("LF1 Monosynth"), 3, mOutput) , "Cannot publish to inter-app audio" );
    
    [self setupMidiCallBacks:&mOutput userData:(__bridge void*)self];
}

// Checks host connection, and handles transitions between states
- (BOOL) isHostConnected {
    if (mOutput) {
        UInt32 connect;
        UInt32 dataSize = sizeof(UInt32);
        checkError(AudioUnitGetProperty(mOutput, kAudioUnitProperty_IsInterAppConnected, kAudioUnitScope_Global, 0, &connect, &dataSize), "Error checking host status");
        if (connect != self.connected) {
            self.connected = connect;
            //Transition is from not connected to connected
            if (self.connected) {
                [self checkStartStopGraph];
                //Get the appropriate callback info
                [self getHostCallBackInfo];
                [self getAudioUnitIcon];
            }
            //Transition is from connected to not connected;
            else {
                //If the graph is started stop it.
                [self stopAUGraph];
                //Attempt to restart the graph
                [self checkStartStopGraph];
            }
        }
    }
    return self.connected;
}

// Send transport state to remote host
-(void)sendStateToRemoteHost:(AudioUnitRemoteControlEvent)state {
    // Send a remote control message back to host
    if (mOutput) {
        UInt32 controlEvent = state;
        UInt32 dataSize = sizeof(controlEvent);
        checkError(AudioUnitSetProperty(mOutput, kAudioOutputUnitProperty_RemoteControlToHost, kAudioUnitScope_Global, 0, &controlEvent, dataSize), "Failed sendStateToRemoteHost");
    }
}

-(void)toggleRecord {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_ToggleRecord];
    [[NSNotificationCenter defaultCenter] postNotificationName:TRANSPORT_CHANGE_NOTIFICATION_STRING object:self];
}

-(void)togglePlay {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_TogglePlayPause];
    [[NSNotificationCenter defaultCenter] postNotificationName:TRANSPORT_CHANGE_NOTIFICATION_STRING object:self];
}

-(void)rewind {
    [self sendStateToRemoteHost:kAudioUnitRemoteControlEvent_Rewind];
    [[NSNotificationCenter defaultCenter] postNotificationName:TRANSPORT_CHANGE_NOTIFICATION_STRING object:self];
}


// Respond to changes from host
-(void) audioUnitPropertyChangedListener:(void *) inObject unit:(AudioUnit )inUnit propID:(AudioUnitPropertyID) inID scope:( AudioUnitScope )inScope  element:(AudioUnitElement )inElement {
    if (inID == kAudioUnitProperty_IsInterAppConnected) {
        [self isHostConnected];
        [self postUpdateStateNotification];
    } else if (inID == kAudioOutputUnitProperty_HostTransportState) {
        [self updateStatefromTransportCallBack];
        [self postUpdateStateNotification];
    }
}

// Update the current transport state
-(void)updateStatefromTransportCallBack{
    if (self.connected && self.inForeground && ![self.audiobusController audiobusConnected]) {
        if (!callBackInfo) {
            [self getHostCallBackInfo];
        }
        if (callBackInfo) {
            Boolean isPlaying  = self.isHostPlaying;
            Boolean isRecording = self.isHostRecording;
            Float64 outCurrentSampleInTimeLine = 0;
            void * hostUserData = callBackInfo->hostUserData;
            OSStatus result =  callBackInfo->transportStateProc2( hostUserData,
                                                                 &isPlaying,
                                                                 &isRecording, NULL,
                                                                 &outCurrentSampleInTimeLine,
                                                                 NULL, NULL, NULL);
            if (result == noErr) {
                self.isHostPlaying = isPlaying;
                self.isHostRecording = isRecording;
                self.playTime = outCurrentSampleInTimeLine;
            } else
                NSLog(@"Error occured fetching callBackInfo->transportStateProc2 : %d", (int)result);
        }
    }
}

// Get callback info for host
-(void)getHostCallBackInfo {
    if (self.connected) {
        if (callBackInfo)
            free(callBackInfo);
        UInt32 dataSize = sizeof(HostCallbackInfo);
        callBackInfo = (HostCallbackInfo*) malloc(dataSize);
        OSStatus result = AudioUnitGetProperty(mOutput, kAudioUnitProperty_HostCallbacks, kAudioUnitScope_Global, 0, callBackInfo, &dataSize);
        if (result != noErr) {
            NSLog(@"Error occured fetching kAudioUnitProperty_HostCallbacks : %d", (int)result);
            free(callBackInfo);
            callBackInfo = NULL;
        }
    }
}

-(UIImage *) getAudioUnitIcon {
    if (mOutput) {
        self.hostAppIcon = AudioOutputUnitGetHostIcon(mOutput, 114);
    }
    return self.hostAppIcon;
}

// Notification when the transport state has changed
-(void) postUpdateStateNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TRANSPORT_CHANGE_NOTIFICATION_STRING object:self];
    });
}

-(void)gotoHost {
    if (mOutput) {
        CFURLRef instrumentUrl;
        UInt32 dataSize = sizeof(instrumentUrl);
        OSStatus result = AudioUnitGetProperty(mOutput, kAudioUnitProperty_PeerURL, kAudioUnitScope_Global, 0, &instrumentUrl, &dataSize);
        if (result == noErr) {
            [[UIApplication sharedApplication] openURL:(__bridge NSURL*)instrumentUrl];
        }
    }
}

-(void) setupMidiCallBacks:(AudioUnit*)output userData:(void*)inUserData {
    AudioOutputUnitMIDICallbacks callBackStruct;
    callBackStruct.userData = inUserData;
    callBackStruct.MIDIEventProc = MIDIEventProcCallBack;
    callBackStruct.MIDISysExProc = NULL;
    checkError(AudioUnitSetProperty (*output,
                                kAudioOutputUnitProperty_MIDICallbacks,
                                kAudioUnitScope_Global,
                                0,
                                &callBackStruct,
                                sizeof(callBackStruct)), "Can't setup Inter App MIDI Callback");
}

void MIDIEventProcCallBack(void *userData, UInt32 inStatus, UInt32 inData1, UInt32 inData2, UInt32 inOffsetSampleFrame){
    AudioEngine *ae = (__bridge AudioEngine*)userData;

    printf("%u",(unsigned int)inOffsetSampleFrame);
    Byte midiCommand = inStatus >> 4;
    Byte data1 = inData1 & 0x7F;
    Byte data2 = inData2 & 0x7F;
    
    if (midiCommand == 0x09) {
        [ae.cvController noteOn:inData1];
    } else if (midiCommand == 0x08) {
        [ae.cvController noteOff:data1];
    } else if (midiCommand == 0x0E) {
        int value = ((data2 << 7)) + data1;
        [ae.cvController setPitchbend:value / 16383.0];
    }
}

#pragma mark Audiobus

-(void)initializeAudiobus {
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:AUDIOBUS_API_KEY];
    [self.audiobusController setStateIODelegate:APP_DELEGATE];
    [self.audiobusController setConnectionPanelPosition:ABConnectionPanelPositionLeft];
    
    AudioComponentDescription audioComponentDescription;
    audioComponentDescription.componentType = kAudioUnitType_RemoteInstrument;
    audioComponentDescription.componentSubType = 'iasp';
    audioComponentDescription.componentManufacturer = 'lfnc';
    audioComponentDescription.componentFlags = 0;
    audioComponentDescription.componentFlagsMask = 0;
    
    self.audiobusSenderPort = [[ABSenderPort alloc] initWithName:@"LF1 Monosynth"
                                                           title:@"LF1 Out"
                                       audioComponentDescription:audioComponentDescription
                                                       audioUnit:mOutput];
    
    [self.audiobusSenderPort setIcon:[UIImage imageNamed:@"audiobus_icon"]];
    
    [self.audiobusController addSenderPort:self.audiobusSenderPort];
    
}

#pragma mark Utility

static void checkError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString); exit(1);
}

@end
