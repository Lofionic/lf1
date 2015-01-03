//
//  PresetButton.m
//  Ogre
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "PresetButton.h"
#import "BuildSettings.h"
#import "Defines.h"

@implementation PresetButton {
    
    NSOperationQueue *flashLEDQueue;
    bool ledSavedStatus;
    int flashCount;
}

@synthesize LEDOn = _ledOn;

-(BOOL)LEDOn {
    return _ledOn;
}

-(void)setLEDOn:(BOOL)LEDOn {
    _ledOn = LEDOn;
    [self setNeedsDisplay];
}

-(void)awakeFromNib {
    
    self.spriteSheet = [UIImage imageNamed:@"buttonA"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer: tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [longPressGesture setMinimumPressDuration:2];
    [self addGestureRecognizer:longPressGesture];

}

-(void)flash {
    
    // Start flashing
    ledSavedStatus = self.LEDOn;
    self.LEDOn = false;
    _flashing = true;
    
    flashCount = 0;
    
    [self performSelector:@selector(toggleFlash) withObject:self afterDelay:0.1];
    
}


-(void)toggleFlash {
    
    self.LEDOn = !self.LEDOn;
    
    flashCount ++;
    if (flashCount < 12) {
        // Continue to flash
        [self performSelector:@selector(toggleFlash) withObject:self afterDelay:0.1];
    } else {
        // End flashing
        self.LEDOn = ledSavedStatus;
        _flashing = false;
    }
    [self setNeedsDisplay];
}

-(void)onTap:(UIGestureRecognizer*)gesture {
    if (!self.flashing && gesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate presetButtonWasTapped:self];
    }
}

-(void)onLongPress:(UIGestureRecognizer*)gesture {
    if (!self.flashing && gesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate presetButtonWasLongPressed:self];
    }
}

-(void)drawRect:(CGRect)rect {
    
    if (_spriteSheet) {
        // draw control
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);

        CGRect sourceRect = CGRectMake(60.0 * SCREEN_SCALE, 0, 60.0 * SCREEN_SCALE, 40.0 * SCREEN_SCALE);
        if (self.LEDOn) {
                sourceRect = CGRectMake(0 * SCREEN_SCALE, 0, 60.0 * SCREEN_SCALE, 40.0 * SCREEN_SCALE);
        }
        CGImageRef drawImage = CGImageCreateWithImageInRect([self.spriteSheet CGImage], sourceRect);
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.frame.size.width, -self.frame.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}



@end
