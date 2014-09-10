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
    
	// Do any additional setup after loading the view.
    self.audioController = [[AudioController alloc] init];

    [self.audioController initializeAUGraph];
    [self.audioController startAUGraph];
    
    _controller.delegate = self;
    
    _osc1Vol.value = 0.5;
    _osc2Vol.value = 0.5;
    
    _masterVolume.value = 1.0;
    
    [self updateParameters:nil];
    
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

-(IBAction)updateParameters:(id)sender {
       
    if (sender == self.osc1Wave || !sender) {
        [_audioController.osc1 setWaveform:(Waveform)_osc1Wave.selectedSegmentIndex];
    }
    
    if (sender == _osc2Wave || !sender) {
        [_audioController.osc2 setWaveform:(Waveform)_osc2Wave.selectedSegmentIndex];
    }
    
    [_audioController setMixerInputChannel:0 toLevel:_osc1Vol.value];
    [_audioController setMixerInputChannel:1 toLevel:_osc2Vol.value];
    
    [_audioController setMixerOutputLevel:self.masterVolume.value];
    
}

-(IBAction)engineSwitch:(id)sender {

    if (self.engineSwitch.on) {
     
        [_audioController startAUGraph];
        
    } else {
    
        [_audioController stopAUGraph];
    }
}

#pragma mark ControllerViewDelegates

-(void)noteOff {
    [_audioController noteOff];
}

-(void)noteOn:(float)frequency {
    [_audioController noteOn:frequency];
}

@end
