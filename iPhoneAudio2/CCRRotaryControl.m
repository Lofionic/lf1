//
//  CCRRotaryControl.m
//  RotaryControl
//
//  Created by Chris on 09/09/2014.
//  Copyright (c) 2014 Chris RIvers. All rights reserved.
//

#import "CCRRotaryControl.h"
#import <QuartzCore/QuartzCore.h>

#define USE_ROTARY_MOTION 0

@implementation CCRRotaryControl {
    
    // Records the previou tracking location
    CGPoint previousTrackingTouchLocation;
    
    // is control tracking
    bool tracking;
    
    // is control in precision mode
    bool precisionMode;
    
    // address of tracking touch
    int trackingTouch;
    
    // address of precision touch
    int precisionTouch;
    
    // is control currently animating (disable tracking whilst animating)
    bool isAnimating;
    
    // is control currently zoomes
    bool zoomed;
    
    // frame for reverting to after zoom
    CGRect restoreFrame;
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
    _rotaryRange = 0.8;
    _rotaryOffset = (1.0 - _rotaryRange) / 2.0;
    _defaultValue = _value;
    _precisionModeScale = 4.0;

    _precisionModeEnabled = false;
    _zoomEnabled = true;
    
    _changeByRotating = USE_ROTARY_MOTION > 0;
    // style
    
    UIImage *moogA = [UIImage imageNamed:@"moog_a"];
    _spriteSheet = moogA;
    _spriteSize = CGSizeMake(140, 140);
    self.backgroundColor = [UIColor clearColor];
    
    self.userInteractionEnabled = true;
    self.multipleTouchEnabled = true;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longPressGesture setCancelsTouchesInView:false];
    [longPressGesture setMinimumPressDuration:0.5];
    [self addGestureRecognizer:longPressGesture];
}

-(void)doubleTap:(UIGestureRecognizer*)gesture {
    // Reset value to default on double tap

    // Precision mode must fail to register double tap
    if (gesture.state == UIGestureRecognizerStateEnded && !precisionMode) {
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

-(void)longPress:(UIGestureRecognizer*)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (_zoomEnabled) {
            // Save the frame to restore later
            restoreFrame = self.frame;
            
            // Calculate the zoomed rect
            CGFloat zoomSize = MIN(self.superview.bounds.size.width, self.superview.bounds.size.height);
            CGRect zoomRect = CGRectMake(self.superview.bounds.size.width / 2.0 - zoomSize / 2.0, self.superview.bounds.size.height / 2.0 - zoomSize / 2.0, zoomSize, zoomSize);

            // start the zoom animation
            
            //self.backgroundColor = [UIColor whiteColor];
            
            isAnimating = true;
            zoomed = true;
            [self.layer removeAllAnimations];
            [self becomeFirstResponder];
            [self.superview bringSubviewToFront:self];
            
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.frame = zoomRect;
            } completion:^(BOOL completed) {
                isAnimating = false;
                previousTrackingTouchLocation = [longPress locationInView:self];
                [self setNeedsDisplay];
            }];
        }
        
    } else if (longPress.state == UIGestureRecognizerStateEnded) {
        
        if (zoomed) {
            // Cancel zoomed mode
            isAnimating = true;
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.frame = restoreFrame;
            } completion:^(BOOL done) {
                isAnimating = false;
                zoomed = false;
                self.backgroundColor = [UIColor clearColor];
                [self setNeedsDisplay];
            }];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Begin tracking previous touch position
    for (UITouch *thisTouch in touches) {
        if (!tracking) {
            // Start tracking
            tracking = true;
            previousTrackingTouchLocation = [thisTouch locationInView:self];
        
            // Remember memory address of first touch so we can track it after second touch is made
            trackingTouch = (int)thisTouch;
            [self becomeFirstResponder];
            
        } else {
            // Already tracking - enter precision mode
                if (_precisionModeEnabled) {
                precisionMode = true;
                precisionTouch = (int)thisTouch;
            }
        }
        [self setNeedsDisplay];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (tracking && !isAnimating) {
        for (UITouch* thisTouch in touches) {

            if ((int)thisTouch == trackingTouch) {
                
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
                        if (precisionMode) {
                            delta /= _precisionModeScale;
                        }
                        _value += (delta / (M_PI * 2.0)) / _rotaryRange;

                    }
                }
                else {
                    
                    CGFloat delta = (thisTouchLocation.y - previousTrackingTouchLocation.y) / 200.0;
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
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    for (UITouch *thisTouch in touches) {
        if (tracking && (int)thisTouch == trackingTouch) {
            // Tracking touch has ended
            tracking = false;
        } else if ((int)thisTouch == precisionTouch) {
            // Precision touch has ended
            precisionMode = false;
        }
    }
    
    [self resignFirstResponder];
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Respond to all touches when tracking or precision mode is on
    return (tracking || precisionMode || [self pointInside:point withEvent:event]) ? self : nil;
}

- (void)drawRect:(CGRect)rect
{
    if (_spriteSheet) {
        // draw control
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        int sprites = (_spriteSheet.size.height / _spriteSize.height) - 1;
        int frame = (_value * sprites);
        CGRect sourceRect = CGRectMake(0, frame * _spriteSize.height, _spriteSize.width, _spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([_spriteSheet CGImage], sourceRect);
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}
@end
