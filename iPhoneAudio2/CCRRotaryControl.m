//
//  CCRRotaryControl.m
//  RotaryControl
//
//  Created by Chris on 09/09/2014.
//  Copyright (c) 2014 Chris RIvers. All rights reserved.
//

#import "CCRRotaryControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation CCRRotaryControl {
    // Records the previou tracking location
    CGPoint previousTrackingTouchLocation;
    
    // is control tracking
    bool tracking;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib {
    [self initialize];
}

-(void)initialize {
    
    // Initialize default properties
    _value = 0.0;
    _defaultValue = _value;
    
    _changeByRotating = ROTARY_CONTROLS > 0;
    _sensitivity = 3;
    _enableDefaultValue = false;
    
    // style
    UIImage *knobImage = [UIImage imageNamed:@"SmallKnob"];
    _spriteSheet = knobImage;
    _spriteSize = CGSizeMake(86 * SCREEN_SCALE, 86 * SCREEN_SCALE);
    self.backgroundColor = [UIColor clearColor];
    
    self.userInteractionEnabled = true;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGesture];
}

-(void)doubleTap:(UIGestureRecognizer*)gesture {
    // Reset value to default on double tap

    // Precision mode must fail to register double tap
    if (gesture.state == UIGestureRecognizerStateEnded && _enableDefaultValue) {
        _value = _defaultValue;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self setNeedsDisplay];
    }
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

-(void)layoutSubviews {
    // Square up frame
    CGPoint center = self.center;
    CGFloat size = MIN(self.frame.size.width, self.frame.size.height);
    self.frame = CGRectMake(0, 0, size, size);
    self.center = center;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Begin tracking
    
    UITouch *thisTouch = [touches anyObject];
    tracking = true;
    previousTrackingTouchLocation = [thisTouch locationInView:self];
    
    [self becomeFirstResponder];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (tracking) {
        UITouch *thisTouch = [touches anyObject];
        // Handle tracking touch
        CGPoint thisTouchLocation = [thisTouch locationInView:self];
        
        if (_changeByRotating) {
            CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height /2);
            
            // Only update if touch is not too close to center
            CGVector vectorFromCenter = CGVectorMake(thisTouchLocation.x - center.x, thisTouchLocation.y - center.y);
            double distanceFromCenter = sqrt((vectorFromCenter.dx * vectorFromCenter.dx) + (vectorFromCenter.dy * vectorFromCenter.dy));
            
            if (distanceFromCenter > center.x / 4.0) {
            
                // Calculate vectors from center to previous touch and new touch
                CGVector prevVector = CGVectorMake(previousTrackingTouchLocation.x - center.x, previousTrackingTouchLocation.y - center.y);
                CGVector thisVector = CGVectorMake(thisTouchLocation.x - center.x, thisTouchLocation.y - center.y);
                
                // Rotation is equivalent to signed angle the between two vectors
                double delta = -atan2(thisVector.dx * prevVector.dy - prevVector.dx * thisVector.dy, prevVector.dx * thisVector.dx + prevVector.dy * thisVector.dy);
                
                // Normalize rotation and adjust value accordingly
                _value += (delta / (M_PI * 2.0)) / 1.0;

            }
        }
        else {
            CGFloat delta = ((thisTouchLocation.y - previousTrackingTouchLocation.y) * _sensitivity) / 500.0;
            _value -= delta;
        }
        
        // Clamp value
        if (_value > 1.0) {
            _value = 1.0;
        } else if (_value < 0.0) {
            _value = 0.0;
        }
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self setNeedsDisplay];
        
        previousTrackingTouchLocation = [thisTouch locationInView:self];

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
        if (_backgroundImage) {
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), [_backgroundImage CGImage]);
        }
        
        int sprites = ((_spriteSheet.size.height / _spriteSize.height) * SCREEN_SCALE) - 1;
        int frame = (_value * sprites);
        CGRect sourceRect = CGRectMake(0, frame * _spriteSize.height, _spriteSize.width, _spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([_spriteSheet CGImage], sourceRect);

        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}

@end
