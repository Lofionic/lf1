//
//  PitchbendWheelControl.m
//  Ogre
//
//  Created by Chris on 10/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "BuildSettings.h"
#import "PitchbendWheelControl.h"
#import "Defines.h"

@implementation PitchbendWheelControl {
    
    CGFloat trackingY;
    bool tracking;
    
}

-(void)awakeFromNib {
    
    self.spriteSheet = [UIImage imageNamed:@"pitchwheel"];
    self.spriteSize = CGSizeMake(60 * SCREEN_SCALE, 150 * SCREEN_SCALE);
    self.value = 0.5;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    if (_spriteSheet) {
        // draw control
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        int sprites = ((self.spriteSheet.size.height / self.spriteSize.height) * SCREEN_SCALE) - 1;
        int frame = (self.value * sprites);
        CGRect sourceRect = CGRectMake(0, frame * self.spriteSize.height, self.spriteSize.width, self.spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([self.spriteSheet CGImage], sourceRect);
        
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    trackingY = [touch locationInView:self].y;
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGFloat newPosition = [touch locationInView:self].y;
    CGFloat delta = trackingY - newPosition;

    self.value = 0.5 + (delta / self.frame.size.height);
    
    if (self.value < 0) {
        self.value = 0;
    } else if (self.value > 1) {
        self.value = 1;
    }
    
    [self setNeedsDisplay];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    self.value = 0.5;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}

@end
