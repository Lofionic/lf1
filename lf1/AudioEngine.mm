//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "BuildSettings.h"
#import "Defines.h"
#import "AudioEngine.h"
#import <AVFoundation/AVFoundation.h>

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

    checkError(AUGraphAddNode(mGraph, &output_desc, &ioNode), "Cannot add RemoteIO node to AUGraph");
    
    // Connect Converter Node's outout to the Output node's input
    checkError(AUGraphConnectNodeInput(mGraph, converterNode, 0, ioNode, 0), "Cannot connect AUConverter node to RemoteIO node");
    
    // Open the graph - AudioUnits are opened but not initialized
    checkError(AUGraphOpen(mGraph), "Cannot open AUGraph");
    
    // Get a link to the converter node
    checkError(AUGraphNodeInfo(mGraph, converterNode, NULL, &mConverter), "Cannot get info for AUConverter node");

    // Get a link to the output AU so we can talk to it later
    checkError(AUGraphNodeInfo(mGraph, ioNode, NULL, &mOutput), "Cannot get info for RemoteIO node");
    
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

    // Add property listeners for inter app audio
    checkError(AudioUnitAddPropertyListener(mOutput, kAudioUnitProperty_IsInterAppConnected, AudioUnitPropertyChangeDispatcher, (__bridge void*)self), "Error setting IsInterAppConnected property listener");
    
    checkError(AudioUnitAddPropertyListener(mOutput, kAudioOutputUnitProperty_HostTransportState, AudioUnitPropertyChangeDispatcher, (__bridge void*)self), "Error setting IsInterAppConnected property listener");
    
    // Publish as inter-app audio node
    [self publishAsNode];
    [self registerNotifications];
    
    // Print graph setup
    CAShow(mGraph);
    
    // Start AUGraph
    // checkError(AUGraphInitialize(mGraph), "Cannot initialize AUGraph");
    
    [self checkStartStopGraph];
    [self setupMidiCallBacks:&mOutput userData:(__bridge void*)self];
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

#pragma mark MIDI

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
                                sizeof(callBackStruct)),
               "Error setting MIDI callbacks");
    
    MIDIClientRef client;
    checkError(MIDIClientCreate(CFSTR("LF1 Monosynth"), MyMIDINotifyProc, (__bridge void*)self, &client), "Couldn't create MIDI Client");

    MIDIPortRef inPort;
    checkError(MIDIInputPortCreate(client, CFSTR("MIDI In"), MyMIDIReadProc, (__bridge void*)self, &inPort), "Couldn't create MIDI In port");
    
    unsigned long sourceCount = MIDIGetNumberOfSources();
    printf("%ld MIDI source(s)\n", sourceCount);
    for (int i = 0; i < sourceCount; ++i) {
        MIDIEndpointRef src = MIDIGetSource(i);
        CFStringRef endPointName = NULL;
        checkError(MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endPointName), "Couldn't get endpoint name");
        char endpointNameC[255];
        CFStringGetCString(endPointName, endpointNameC, 255, kCFStringEncodingUTF8);
        printf(" source %d: %s\n", i, endpointNameC);
        checkError(MIDIPortConnectSource(inPort, src, NULL), "Couldn't connect MIDI port");
    }
}

void MyMIDINotifyProc (const MIDINotification *message, void *refCon) {
    printf("MIDI Notify, messageId=%d,", (int)message->messageID);
    
}

static void MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
    printf("MIDI Received...");
    AudioEngine *ae = (__bridge AudioEngine*) refCon;
    
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet; for (int i=0; i < pktlist->numPackets; i++) {
        Byte midiStatus = packet->data[0]; Byte midiCommand = midiStatus >> 4;
        Byte inData1 = packet->data[1] & 0x7F;
        Byte inData2 = packet->data[2] & 0x7F;
        
        printf("MIDI in: %i %i %i", midiStatus, inData1, inData2);
        
        if (midiCommand == 0x09) {
            [ae.cvController noteOn:inData1];
        } else if (midiCommand == 0x08) {
            [ae.cvController noteOff:inData1];
        }
            packet = MIDIPacketNext(packet);
        }
}
void MIDIEventProcCallBack(void *userData, UInt32 inStatus, UInt32 inData1, UInt32 inData2, UInt32 inOffsetSampleFrame){
    AudioEngine *ae = (__bridge AudioEngine*)userData;
    
    if (inStatus == 144) {
        // Note on command
        [ae.cvController noteOn:inData1];
    } else if (inStatus == 128) {
        // Note off command
        [ae.cvController noteOff:inData1];
    } else if (inStatus == 224) {
        float pitchbendValue = inData1  / 126.0;
        [ae.cvController setPitchbend:pitchbendValue];
    }
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
    // Stops and starts AUGraph with respect in background
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
        [self stopAUGraph];
        [self setAudioSessionInActive];
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
        
        AudioSignalType output = mixedSignal[i];
        
        outA[i] = output * 32767.0f;
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
    
    checkError(AudioOutputUnitPublish(&desc, CFSTR("LF1 Monosynth"), 1, mOutput) , "Cannot publish to inter-app audio" );
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
    if (self.connected && self.inForeground) {
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

#pragma mark Utility

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
