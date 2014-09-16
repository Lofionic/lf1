//
//  LFOControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 16/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRRotaryControl.h"

@class LFOControlView;

@protocol LFOControlViewDelegate <NSObject>

-(void)LFOControlView:(LFOControlView*)view LFOID:(NSInteger)id didChangeRateTo:(float)value;
-(void)LFOControlView:(LFOControlView*)view LFOID:(NSInteger)id didChangeAmountTo:(float)value;
-(void)LFOControlView:(LFOControlView*)view LFOID:(NSInteger)id didChangeDestinationTo:(NSInteger)value;
-(void)LFOControlView:(LFOControlView*)view LFOID:(NSInteger)id didChangeWaveformTo:(NSInteger)value;

@end

@interface LFOControlView : UIView

@property (nonatomic, weak) id<LFOControlViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *rateControl1;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *amountControl1;
@property (nonatomic, strong) IBOutlet UISegmentedControl *destinationControl1;
@property (nonatomic, strong) IBOutlet UISegmentedControl *waveformControl1;

-(void)initializeParameters;

@end
