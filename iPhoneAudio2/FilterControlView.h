//
//  FilterControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 14/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRRotaryControl.h"

@class FilterControlView;
@protocol FilterControlViewDelegate <NSObject>

-(void)filterControlView:(FilterControlView*)view didChangeFrequencyTo:(float)value;
-(void)filterControlView:(FilterControlView*)view didChangeResonanceTo :(float)value;

@end

@interface FilterControlView : UIView

@property (nonatomic, weak) id<FilterControlViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *freqControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *resControl;

-(void)initializeParameters;

@end
