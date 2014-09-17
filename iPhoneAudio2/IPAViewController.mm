//
//  IPAViewController.m
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "IPAViewController.h"
#import "AudioController.h"

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
    [self.audioController startAUGraph];
    
    _controller.delegate = self;

    // Create oscillator controller view
    NSArray *oscNib = [[NSBundle mainBundle] loadNibNamed:@"OscillatorControlView" owner:self options:nil];
    _oscView = oscNib[0];
    _oscView.delegate = _audioController;
    //_oscView.backgroundView.image = controlViewFrameImage;
    [_oscView initializeParameters];
    
    NSArray *envNib = [[NSBundle mainBundle] loadNibNamed:@"EnvelopeControlView" owner:self options:nil];
    _envView = envNib[0];
    _envView.delegate = _audioController;
    [_envView initializeParameters];
    
    NSArray *filterNib = [[NSBundle mainBundle] loadNibNamed:@"FilterControlView" owner:self options:nil];
    _filterView = filterNib[0];
    _filterView.delegate = _audioController;
    [_filterView initializeParameters];
    
    NSArray *lfoNib = [[NSBundle mainBundle] loadNibNamed:@"LFOControlView" owner:self options:nil];
    _lfoView = lfoNib[0];
    _lfoView.delegate = _audioController;
    [_lfoView initializeParameters];
    
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
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.audioController stopAUGraph];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return true;
}

#pragma mark ControllerViewDelegates

-(void)noteOff {
    [_audioController noteOff];
}

-(void)noteOn:(float)frequency {
    [_audioController noteOn:frequency];
}

@end
