//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "AudioEngine.h"
#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    
	// Do any additional setup after loading the view.
    self.audioEngine = [[AudioEngine alloc] init];

    [self.audioEngine initializeAUGraph];
    [self setupControllers];
    [self.audioEngine startAUGraph];

    /*
    UIButton *savePresetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64.0, 32.0)];
    [savePresetButton setTitle:@"Save" forState:UIControlStateNormal];
    [savePresetButton addTarget:self action:@selector(savePreset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:savePresetButton];
     */

}

-(void)savePreset {
    
    [self.presetController storePresetAtIndex:0];
    
    [self.presetController exportBankToFileNamed:@"test.bnk"];
}

-(void)setupControllers {
    
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
    self.keyboardControlView = [[KeyboardControlView alloc] initWithFrame:CGRectZero];
    self.keyboardControlView.cvComponent = self.audioEngine.cvController;
    [self.keyboardControlView initializeParameters];
    
    // Create presets controller view
    self.presetControlView = [[PresetControlView alloc] initWithFrame:CGRectZero];
    self.presetControlView.presetController = self.presetController;
    [self.presetControlView initializeParameters];
    
    if (self.iPhoneControlsView) {
        // iPhone - add control views
        [self.iPhoneControlsView setContentInset:UIEdgeInsetsZero];
        [self.iPhoneControlsView addSubview:self.oscView];
        [self.iPhoneControlsView addSubview:self.envView];
        [self.iPhoneControlsView addSubview:self.filterView];
        [self.iPhoneControlsView addSubview:self.lfoView];
        [self.iPhoneControlsView setContentSize:CGSizeMake(self.iPhoneControlsView.frame.size.width * 4, self.iPhoneControlsView.frame.size.height)];
        [self.iPhoneControlsView setClipsToBounds:NO];
    } else {
        // iPad - add control views
        [self.iPadControlsView1 addSubview:_oscView];
        [self.iPadControlsView2 addSubview:_envView];
        [self.iPadControlsView3 addSubview:_filterView];
        [self.iPadControlsView4 addSubview:_lfoView];
        [self.iPadControlsView5 addSubview:_keyboardControlView];
        [self.iPadControlsView6 addSubview:_presetControlView];
    }
}

-(void)viewWillLayoutSubviews {
    
    if (_iPhoneControlsView) {
        UIImage *controlViewFrameImage = [UIImage imageNamed:@"control_view_frame"];
        UIEdgeInsets insets = UIEdgeInsetsMake(16.0, 36.0, 16.0, 24.0);
        controlViewFrameImage = [controlViewFrameImage resizableImageWithCapInsets:insets];

        UIImage *controlViewFrameImageLeft = [UIImage imageNamed:@"control_view_frame_left"];
        insets = UIEdgeInsetsMake(16.0, 36.0, 16.0, 24.0);
        controlViewFrameImageLeft = [controlViewFrameImageLeft resizableImageWithCapInsets:insets];
        
        UIImage *controlViewFrameImageRight = [UIImage imageNamed:@"control_view_frame_right"];
        insets = UIEdgeInsetsMake(16.0, 36.0, 16.0, 24.0);
        controlViewFrameImageRight = [controlViewFrameImageRight resizableImageWithCapInsets:insets];
        
        // iPhone - layout control views
        self.oscView.frame = CGRectMake(-20.0,
                                    0,
                                    self.iPhoneControlsView.frame.size.width,
                                    self.iPhoneControlsView.frame.size.height);
        self.oscView.backgroundView.image = controlViewFrameImageLeft;
        
        self.envView.frame = CGRectMake(self.iPhoneControlsView.frame.size.width - 20,
                                    0,
                                    self.iPhoneControlsView.frame.size.width,
                                    self.iPhoneControlsView.frame.size.height);
        self.envView.backgroundView.image = controlViewFrameImage;
        
        self.filterView.frame = CGRectMake((self.iPhoneControlsView.frame.size.width * 2) - 20,
                                    0,
                                    self.iPhoneControlsView.frame.size.width,
                                    self.iPhoneControlsView.frame.size.height);
        self.filterView.backgroundView.image = controlViewFrameImage;
        
        self.lfoView.frame = CGRectMake((self.iPhoneControlsView.frame.size.width * 3) - 20,
                                       0,
                                       self.iPhoneControlsView.frame.size.width,
                                       self.iPhoneControlsView.frame.size.height);
        self.lfoView.backgroundView.image = controlViewFrameImageRight;
        
        [self.iPhoneControlsView setContentSize:CGSizeMake((self.iPhoneControlsView.frame.size.width * 4) - 20, self.iPhoneControlsView.frame.size.height)];
    } else {
        // iPad - layout control views
        self.oscView.frame = [self.oscView superview].bounds;
        self.envView.frame = [self.envView superview].bounds;
        self.filterView.frame = [self.filterView superview].bounds;
        self.lfoView.frame = [self.lfoView superview].bounds;
        self.keyboardControlView.frame = [self.keyboardControlView superview].bounds;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [self.audioEngine stopAUGraph];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return true;
}

//Interruption handler
-(void)handleInterruption: (NSNotification*) aNotification
{
    NSLog(@"Handle Interrupt...");
    NSDictionary *interuptionDict = aNotification.userInfo;
    
    NSNumber* interuptionType = (NSNumber*)[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    
    if([interuptionType intValue] == AVAudioSessionInterruptionTypeBegan) {
        
        [self stopAUGraph];
    } else if ([interuptionType intValue] == AVAudioSessionInterruptionTypeEnded) {
        [self startAUGraph];
    }
}

-(void)stopAUGraph {
    NSLog(@"Stopping AUGraph...");
    [_audioEngine stopAUGraph];
}

-(void)startAUGraph {
    NSLog(@"Start AUGraph...");
    [_audioEngine startAUGraph];
}


@end
