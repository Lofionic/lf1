//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "Defines.h"
#import "AudioEngine.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController {
    
    NSTimer *pollPlayerTimer;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.presetController = [[PresetController alloc] initWithViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Hide status bar in IOS6.1 and prior
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    self.audioEngine = ((AppDelegate *)[UIApplication sharedApplication].delegate).audioEngine;
    
    
    [self setupControllerViews];
    
    // Prepare notifications for app state
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
                                             selector: @selector(updateTransportControls)
                                                 name: TRANSPORT_CHANGE_NOTIFICATION_STRING
                                               object: self.audioEngine];
    
    UITapGestureRecognizer *hostIconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoHost)];
    [self.hostIcon addGestureRecognizer:hostIconTap];
}

-(void)dealloc {
    [self.audioEngine removeObserver:self forKeyPath:TRANSPORT_CHANGE_NOTIFICATION_STRING];
    [self removeObserver:self forKeyPath:UIApplicationDidEnterBackgroundNotification];
    [self removeObserver:self forKeyPath:UIApplicationWillEnterForegroundNotification];
}

-(void)savePreset {
    [self.presetController storePresetAtIndex:0];
    [self.presetController exportBankToFileNamed:@"test.bnk"];
}

-(void)setupControllerViews {
    
    // Connect keyboard controller to CVController
    self.keyboardView.cvController = self.audioEngine.cvController;
    
    // Create oscillator controller view
    self.oscView = [[OscillatorControlView alloc] init];
    self.oscView.osc1 = self.audioEngine.osc1;
    self.oscView.osc2 = self.audioEngine.osc2;
    self.oscView.mixer = self.audioEngine.mixer;
    [self.oscView initializeParameters];
    
    // Create envelope controller view
    self.envView = [[EnvelopeControlView alloc] initWithFrame:CGRectZero];
    self.envView.VCFEnvelope = self.audioEngine.vcfEnvelope;
    self.envView.VCOEnvelope = self.audioEngine.vcoEnvelope;
    [self.envView initializeParameters];
    
    // Create filter controller view
    self.filterView = [[FilterControlView alloc] initWithFrame:CGRectZero];
    self.filterView.vcf = self.audioEngine.vcf;
    [self.filterView initializeParameters];
    
    // Create lfo controller view
    self.lfoView = [[LFOControlView alloc] initWithFrame:CGRectZero];
    self.lfoView.lfo = self.audioEngine.lfo1;
    self.lfoView.osc1 = self.audioEngine.osc1;
    self.lfoView.osc2 = self.audioEngine.osc2;
    self.lfoView.vcf = self.audioEngine.vcf;
    [self.lfoView initializeParameters];

    // Create keyboard controller view
    self.performanceControlView = [[PerformanceControlView alloc] initWithFrame:CGRectZero];
    self.performanceControlView.cvComponent = self.audioEngine.cvController;
    [self.performanceControlView initializeParameters];
    
    // Create presets controller view
    self.presetControlView = [[PresetControlView alloc] initWithFrame:CGRectZero];
    self.presetControlView.presetController = self.presetController;
    [self.presetControlView initializeParameters];
    
    // iPad - add control views
    [self.iPadControlsView1 addSubview:_oscView];
    [self.iPadControlsView2 addSubview:_envView];
    [self.iPadControlsView3 addSubview:_filterView];
    [self.iPadControlsView4 addSubview:_lfoView];
    [self.iPadControlsView5 addSubview:_performanceControlView];
    [self.iPadControlsView6 addSubview:_presetControlView];

}

-(void)viewWillLayoutSubviews {
    // Layout subviews
    self.oscView.frame = [self.oscView superview].bounds;
    self.envView.frame = [self.envView superview].bounds;
    self.filterView.frame = [self.filterView superview].bounds;
    self.lfoView.frame = [self.lfoView superview].bounds;
    self.performanceControlView.frame = [self.performanceControlView superview].bounds;
}

-(BOOL)prefersStatusBarHidden {
    return true;
}

-(void) appHasGoneInBackground {
    self.inForeground = NO;

}

-(void) appHasGoneForeground {
    self.inForeground = YES;
    
    [self updateTransportControls];
}

#pragma mark InterApp Audio

-(void)updateTransportControls {
    if (self.audioEngine) {
        if ([self.audioEngine isHostConnected]) {
            self.transportView.hidden = NO;
            self.hostIcon.image = [self.audioEngine getAudioUnitIcon];
            self.rewindButon.enabled = !self.audioEngine.isHostPlaying;
            [self.playButton setImage:(self.audioEngine.isHostPlaying ? [UIImage imageNamed:@"pause_button.png"] : [UIImage imageNamed:@"play_button.png"]) forState:UIControlStateNormal];
            [self.recordButton setImage:(self.audioEngine.isHostRecording ? [UIImage imageNamed:@"record_button_on.png"] : [UIImage imageNamed:@"record_button.png"]) forState:UIControlStateNormal];


        } else {
            self.transportView.hidden = YES;
        }
        
        [self.view setNeedsDisplay];
    }
}

-(IBAction)transportRecord:(id)sender {
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine toggleRecord];
        }
    }
}

-(IBAction)transportPlay:(id)sender {
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine togglePlay];
        }
    }
}

-(IBAction)transportRewind:(id)sender {
    
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine rewind];
        }
    }
}

-(void)gotoHost {
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine gotoHost];
        }
    }
}


@end
