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
    
}

-(void)layoutSubviews {

    UIImage *controlViewFrameImage = [UIImage imageNamed:@"control_view_frame"];
    UIEdgeInsets insets = UIEdgeInsetsMake(16.0, 36.0, 16.0, 24.0);
    controlViewFrameImage = [controlViewFrameImage resizableImageWithCapInsets:insets];
    _backgroundView.image = controlViewFrameImage;
    
    _backgroundView.frame = self.bounds;
    [self sendSubviewToBack:_backgroundView];

}

@end
