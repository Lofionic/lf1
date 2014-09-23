//
//  IPAViewController.m
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "AudioController.h"
#import "IPAViewController.h"

@interface IPAViewController ()

@end

@implementation IPAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.audioController = [[AudioController alloc] init];

    [self.audioController initializeAUGraph];
    [self setupControllers];
    [self.audioController startAUGraph];
       
    _presetController = [[PresetController alloc] initWithViewController:self];

    [_presetController restorePresetAtIndex:0];
    
    UIButton *savePresetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64.0, 32.0)];
    [savePresetButton setTitle:@"Save" forState:UIControlStateNormal];
    [savePresetButton addTarget:self action:@selector(savePreset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:savePresetButton];

}

-(void)savePreset {
    
    [_presetController storePresetAtIndex:0];
    
}

-(void)setupControllers {
    
    // Connect keyboard controller to CVController
    _keyboardView.cvController = _audioController.cvController;
    
    // Create oscillator controller view
    _oscView = [[OscillatorControlView alloc] initWithFrame:CGRectZero];
    _oscView.delegate = _audioController;
    _oscView.osc1 = _audioController.osc1;
    _oscView.osc2 = _audioController.osc2;
    [_oscView initializeParameters];
    
    _envView = [[EnvelopeControlView alloc] initWithFrame:CGRectZero];
    _envView.VCFEnvelope = _audioController.vcfEnvelope;
    _envView.VCOEnvelope = _audioController.vcoEnvelope;
    [_envView initializeParameters];
    
    _filterView = [[FilterControlView alloc] initWithFrame:CGRectZero];
    _filterView.vcf = _audioController.vcf;
    [_filterView initializeParameters];
    
    _lfoView = [[LFOControlView alloc] initWithFrame:CGRectZero];
    _lfoView.lfo = _audioController.lfo1;
    _lfoView.osc1 = _audioController.osc1;
    _lfoView.osc2 = _audioController.osc2;
    _lfoView.vcf = _audioController.vcf;
    [_lfoView initializeParameters];
    
    _keyboardControlView = [[KeyboardControlView alloc] initWithFrame:CGRectZero];
    _keyboardControlView.cvController = _audioController.cvController;
    [_keyboardControlView initializeParameters];

    if (_iPhoneControlsView) {
        // iPhone - add control views
        [_iPhoneControlsView setContentInset:UIEdgeInsetsZero];
        [_iPhoneControlsView addSubview:_oscView];
        [_iPhoneControlsView addSubview:_envView];
        [_iPhoneControlsView addSubview:_filterView];
        [_iPhoneControlsView addSubview:_lfoView];
        [_iPhoneControlsView setContentSize:CGSizeMake(_iPhoneControlsView.frame.size.width * 4, _iPhoneControlsView.frame.size.height)];
        [_iPhoneControlsView setClipsToBounds:NO];
    } else {
        // iPad - add control views
        [_iPadControlsView1 addSubview:_oscView];
        [_iPadControlsView2 addSubview:_envView];
        [_iPadControlsView3 addSubview:_filterView];
        [_iPadControlsView4 addSubview:_lfoView];
        [_iPadControlsView5 addSubview:_keyboardControlView];
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
        _oscView.frame = CGRectMake(-20.0,
                                    0,
                                    _iPhoneControlsView.frame.size.width,
                                    _iPhoneControlsView.frame.size.height);
        _oscView.backgroundView.image = controlViewFrameImageLeft;
        
        _envView.frame = CGRectMake(_iPhoneControlsView.frame.size.width - 20,
                                    0,
                                    _iPhoneControlsView.frame.size.width,
                                    _iPhoneControlsView.frame.size.height);
        _envView.backgroundView.image = controlViewFrameImage;
        
        _filterView.frame = CGRectMake((_iPhoneControlsView.frame.size.width * 2) - 20,
                                    0,
                                    _iPhoneControlsView.frame.size.width,
                                    _iPhoneControlsView.frame.size.height);
        _filterView.backgroundView.image = controlViewFrameImage;
        
        _lfoView.frame = CGRectMake((_iPhoneControlsView.frame.size.width * 3) - 20,
                                       0,
                                       _iPhoneControlsView.frame.size.width,
                                       _iPhoneControlsView.frame.size.height);
        _lfoView.backgroundView.image = controlViewFrameImageRight;
        
        [_iPhoneControlsView setContentSize:CGSizeMake((_iPhoneControlsView.frame.size.width * 4) - 20, _iPhoneControlsView.frame.size.height)];
    } else {
        // iPad - layout control views
        _oscView.frame = [_oscView superview].bounds;
        _envView.frame = [_envView superview].bounds;
        _filterView.frame = [_filterView superview].bounds;
        _lfoView.frame = [_lfoView superview].bounds;
        _keyboardControlView.frame = [_keyboardControlView superview].bounds;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [self.audioController stopAUGraph];
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


@end
