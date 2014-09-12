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

    [_controlsView setContentInset:UIEdgeInsetsZero];
    
    // Create oscillator controller view
    NSArray *oscNib = [[NSBundle mainBundle] loadNibNamed:@"OscillatorControlView" owner:self options:nil];
    _oscView = oscNib[0];
    _oscView.delegate = _audioController;
    [_oscView initializeParameters];

    [_controlsView addSubview:_oscView];
    
    NSArray *envNib = [[NSBundle mainBundle] loadNibNamed:@"EnvelopeControlView" owner:self options:nil];
    _envView = envNib[0];
    _envView.delegate = _audioController;
    [_envView initializeParameters];

    [_controlsView addSubview:_envView];
    
    [_controlsView setContentSize:CGSizeMake(_controlsView.frame.size.width * 2, _controlsView.frame.size.height)];
}
-(void)viewWillLayoutSubviews {
    _oscView.frame = CGRectMake(0,
                                0,
                                _controlsView.frame.size.width,
                                _controlsView.frame.size.height);
    
    _envView.frame = CGRectMake(_controlsView.frame.size.width,
                                0,
                                _controlsView.frame.size.width,
                                _controlsView.frame.size.height);
    
    [_controlsView setContentSize:CGSizeMake(_controlsView.frame.size.width * 2, _controlsView.frame.size.height)];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)swipe:(UIGestureRecognizer*)gesture {
    NSLog(@"swipe");
}

-(void)changeControlsView:(UIView *)newControlsView {
    
    if ([_controlsView.subviews count] > 0) {
        [_controlsView.subviews[0] removeFromSuperview];
    }
    
    [newControlsView setFrame:_controlsView.bounds];
    [_controlsView addSubview:newControlsView];
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
