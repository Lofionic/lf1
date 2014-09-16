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
    _lineWidth = 2.0;
    _rotaryHighlightSegments = 0.0;

    _precisionModeEnabled = false;
    _zoomEnabled = true;
    
    _changeByRotating = USE_ROTARY_MOTION > 0;
    // style
    self.backgroundColor = [UIColor clearColor];
    self.dialBackgroundColor = [UIColor darkGrayColor];
    self.dialSelectedBackgroundColor = [UIColor lightGrayColor];
    
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
                    
                    CGFloat delta = (thisTouchLocation.y - previousTrackingTouchLocation.y) / 400.0;
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
    // draw control
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(self.frame.size.width  / 2, self.frame.size.height / 2);
    
    CGFloat offsetAngle = (_rotaryOffset + 0.25) * (M_PI * 2.0);
    CGFloat angleInRadians = ((M_PI * 2.0 * _value) * _rotaryRange) + offsetAngle;
    
    CGFloat radius = center.y;
    if (center.x < center.y) {
        radius = center.x;
    }
    
    if (!_dialImage && !_spriteSheet) {
        
        // draw vector based representation
        _lineWidth = radius / 16.0;
        
        // draw background highlight if tracking

        CGContextAddArc(ctx,
                        center.x,
                        center.y,
                        radius,
                        0,
                        M_PI * 2.0,
                        0);
        

        
        if (precisionMode && _dialPrecisionBackroundColor) {
            // make background yellow in precision mode
           [_dialPrecisionBackroundColor setFill];
        } else if (tracking && _dialSelectedBackgroundColor) {
            // grey in tracking mode
            [_dialSelectedBackgroundColor setFill];
        } else {
            [_dialBackgroundColor setFill];
        }
        
        CGContextFillPath(ctx);

        // draw black inner arc
        CGContextAddArc(ctx,
                        center.x,
                        center.y,
                        radius - (_lineWidth * 2.0) - 1,
                        offsetAngle,
                        (M_PI * 2.0 * _rotaryRange) + offsetAngle,
                        0);
        
        [self.tintColor setStroke];
        [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] setFill];
        CGContextSetLineWidth(ctx, _lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapButt);

        CGContextDrawPath(ctx, kCGPathStroke);
        
        // draw tinted outer arc
        CGContextAddArc(ctx,
                        center.x,
                        center.y,
                        radius - _lineWidth,
                        offsetAngle,
                        angleInRadians,
                        0);
        
        [self.tintColor setStroke];
        CGContextSetLineWidth(ctx, _lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        // draw indicator needle
        CGPoint point1 = CGPointMake(
                                     center.x + ((radius - (_lineWidth * 2.0)) * cos(angleInRadians)),
                                     center.y + ((radius - (_lineWidth * 2.0)) * sin(angleInRadians))
                                     );
        CGContextMoveToPoint(ctx, point1.x, point1.y);
        
        CGPoint point2 = center;
        CGContextAddLineToPoint(ctx, point2.x, point2.y);
        
        [self.tintColor setStroke];
        CGContextSetLineWidth(ctx, _lineWidth);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        // draw center
        CGContextAddArc(ctx,
                        center.x,
                        center.y,
                        _lineWidth * 2.0,
                        0,
                        (M_PI * 2.0),
                        0);
        CGContextDrawPath(ctx, kCGPathFillStroke);

    } else if (_spriteSheet) {
        int sprites = (_spriteSheet.size.height / _spriteSize.height) - 1;
        int frame = (_value * sprites);
        CGRect sourceRect = CGRectMake(0, frame * _spriteSize.height, _spriteSize.width, _spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([_spriteSheet CGImage], sourceRect);
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    } else {
    
        // draw bitmap representation
        CGContextSaveGState(ctx);
        
        CGContextTranslateCTM(ctx, center.x, center.y);
        
        CGContextRotateCTM(ctx, angleInRadians + M_PI_2);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGRect dialImageRect = CGRectMake(-radius, -radius, radius * 2.0, radius * 2.0);

        //CGContextDrawImage(ctx, dialImageRect, dialImage);
        CGContextRestoreGState(ctx);
        
        if (_dialHighlightImage) {
            // Draw fading highlight rotated to match segment offset
            CGContextSaveGState(ctx);
            CGContextTranslateCTM(ctx, center.x, center.y);
            
            if (_rotaryHighlightSegments > 0) {
                double rotationalDivision = (M_PI * 2.0) / _rotaryHighlightSegments;
                double highlightRotationalOffset = fmod(angleInRadians, rotationalDivision);
                
                CGContextRotateCTM(ctx, highlightRotationalOffset);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextSetAlpha(ctx, 1 - (highlightRotationalOffset / rotationalDivision));
                CGContextDrawImage(ctx, dialImageRect, [_dialHighlightImage CGImage]);
                
                CGContextSetAlpha(ctx, (highlightRotationalOffset / rotationalDivision));
                CGContextRotateCTM(ctx, rotationalDivision);
                CGContextDrawImage(ctx, dialImageRect, [_dialHighlightImage CGImage]);
                CGContextRestoreGState(ctx);
            }
            } else {
                CGContextRotateCTM(ctx, angleInRadians + M_PI_2);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextDrawImage(ctx, dialImageRect, [_dialHighlightImage CGImage]);
                CGContextRestoreGState(ctx);
            }
        }
    
}

@end