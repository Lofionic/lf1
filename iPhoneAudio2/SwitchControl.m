//
//  SwitchControl.m
//  iPhoneAudio2
//
//  Created by Chris on 22/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "SwitchControl.h"

@implementation SwitchControl

-(void)awakeFromNib {
    
    [self setBackgroundColor:[UIColor clearColor]];

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
    [self addGestureRecognizer:gesture];
    
}

@synthesize value = _value;

-(float)value {
    return _value;
}

-(void)setValue:(float)value {
    _value = value;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

-(void)toggle {
    
    if (_value == 0) {
        _value = 1;
    } else {
        _value = 0;
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIImage *switchImage;
    
    if (_value == 1) {
        switchImage = [UIImage imageNamed:@"Red_Switch_On"];
    } else {
        switchImage = [UIImage imageNamed:@"Red_Switch_Off"];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), [switchImage CGImage]);
    CGContextRestoreGState(ctx);
}


@end
