//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "Defines.h"
#import "AppDelegate.h"
#import "CCRSegmentedRotaryControl.h"

@implementation CCRSegmentedRotaryControl {
    // Records the initial tracking location
    CGPoint firstTouchLocation;
    NSInteger firstTouchIndex;
    
    // is control tracking
    bool tracking;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib {
    [self initialize];
}

-(void) initialize {
    
    // Initialize default properties
    self.index = 0;
    self.segments = 3;
    
    UIImage *knobImage = [UIImage imageNamed:@"ChickenKnob_3way"];
    self.spriteSheet = knobImage;
    self.spriteSize = CGSizeMake(100 * SCREEN_SCALE, 100 * SCREEN_SCALE);
    self.backgroundColor = [UIColor clearColor];
    
    self.userInteractionEnabled = true;

}

@synthesize index = _index;

-(void)setIndex:(NSInteger)index {
    
    _index = index;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
    
}

-(NSInteger)index {
    return _index;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Begin tracking
    
    UITouch *thisTouch = [touches anyObject];
    tracking = true;
    firstTouchLocation = [thisTouch locationInView:self];
    firstTouchIndex = self.index;
    [self becomeFirstResponder];
    
    // Store undo
    [MAIN_VIEW_CONTROLLER.presetController storeUndo];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (tracking) {
        UITouch *thisTouch = [touches anyObject];
        // Handle tracking touch
        CGPoint thisTouchLocation = [thisTouch locationInView:self];
        
        CGFloat delta = ((thisTouchLocation.y - firstTouchLocation.y)) / (100.0 / self.segments);

        NSInteger currentIndex = self.index;

        self.index =  firstTouchIndex-(int)delta;
        
        // Clamp value
        if (self.index >= self.segments) {
            self.index = self.segments - 1;
        } else if (self.index < 0) {
            self.index = 0;
        }

        if (self.index != currentIndex) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [self setNeedsDisplay];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    tracking = false;
    
    [self resignFirstResponder];
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect
{
    if (_spriteSheet) {
        // draw control
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        if (self.backgroundImage) {
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), [self.backgroundImage CGImage]);
        }
        
        int sprites = ((self.spriteSheet.size.height / self.spriteSize.height) * SCREEN_SCALE);
        int frame = ((float)self.index / self.segments) * sprites;
        CGRect sourceRect = CGRectMake(0, frame * self.spriteSize.height, self.spriteSize.width, self.spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([self.spriteSheet CGImage], sourceRect);
        
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}

@end
