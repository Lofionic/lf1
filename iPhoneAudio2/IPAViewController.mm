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
    
	// Do any additional setup after loading the view.
    self.audioController = [[AudioController alloc] init];

    [self.audioController initializeAUGraph];
    [self.audioController startAUGraph];
    
    _controller.delegate = self;

    // Create oscillator controller view
    NSArray *oscNib = [[NSBundle mainBundle] loadNibNamed:@"OscillatorControlView" owner:self options:nil];
    _oscView = oscNib[0];
    _oscView.delegate = _audioController;
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
        // iPhone - layout control views
        _oscView.frame = CGRectMake(0,
                                    0,
                                    _iPhoneControlsView.frame.size.width,
                                    _iPhoneControlsView.frame.size.height);
        
        _envView.frame = CGRectMake(_iPhoneControlsView.frame.size.width,
                                    0,
                                    _iPhoneControlsView.frame.size.width,
                                    _iPhoneControlsView.frame.size.height);
        _filterView.frame = CGRectMake(_iPhoneControlsView.frame.size.width * 2,
                                    0,
                                    _iPhoneControlsView.frame.size.width,
                                    _iPhoneControlsView.frame.size.height);
        
        _lfoView.frame = CGRectMake(_iPhoneControlsView.frame.size.width * 3,
                                       0,
                                       _iPhoneControlsView.frame.size.width,
                                       _iPhoneControlsView.frame.size.height);
        
        
        [_iPhoneControlsView setContentSize:CGSizeMake(_iPhoneControlsView.frame.size.width * 4, _iPhoneControlsView.frame.size.height)];
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

#pragma mark ControllerViewDelegates

-(void)noteOff {
    [_audioController noteOff];
}

-(void)noteOn:(float)frequency {
    [_audioController noteOn:frequency];
}

@end
