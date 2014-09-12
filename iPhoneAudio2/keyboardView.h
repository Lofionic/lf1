//
//  controllerView.h
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ControllerViewDelegate <NSObject>

@optional
-(void)noteOn:(float)frequency;
-(void)noteOff;

@end

@interface keyboardView : UIView

@property (nonatomic, weak) id<ControllerViewDelegate> delegate;

@end