//
//  ControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 9/17/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"

@implementation ControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initializeParameters {
}

-(void)awakeFromNib {
    
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_backgroundView];
    
    UIImage *frame = [UIImage imageNamed:@"control_frame"];
    frame = [frame resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 15, 15)];
    [_backgroundView setImage:frame];
}

-(void)layoutSubviews {
    
    _backgroundView.frame = self.bounds;
    [self sendSubviewToBack:_backgroundView];

}

@end
