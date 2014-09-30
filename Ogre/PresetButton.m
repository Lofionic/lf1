//
//  PresetButton.m
//  Ogre
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "PresetButton.h"
#import "BuildSettings.h"

@implementation PresetButton

-(void)awakeFromNib {
    
    _spriteSheet = [UIImage imageNamed:@"buttonA"];
    
}

-(void)drawRect:(CGRect)rect {
    
    if (_spriteSheet) {
        // draw control
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);

        CGRect sourceRect = CGRectMake(60.0 * SCREEN_SCALE, 0, 60.0 * SCREEN_SCALE, 40.0 * SCREEN_SCALE);
        if (_LEDOn) {
                sourceRect = CGRectMake(0 * SCREEN_SCALE, 0, 60.0 * SCREEN_SCALE, 40.0 * SCREEN_SCALE);
        }
        CGImageRef drawImage = CGImageCreateWithImageInRect([_spriteSheet CGImage], sourceRect);
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.frame.size.width, -self.frame.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}

@end
