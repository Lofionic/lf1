//
//  CCRSegmentedRotaryControl.m
//  iPhoneAudio2
//
//  Created by Chris on 18/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

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
    _selectedSegmentIndex = 1;
    _segments = 3;
    
    UIImage *knobImage = [UIImage imageNamed:@"ChickenKnob_3way"];
    self.spriteSheet = knobImage;
    self.spriteSize = CGSizeMake(100 * SCREEN_SCALE, 100 * SCREEN_SCALE);
    self.backgroundColor = [UIColor clearColor];
    
    self.userInteractionEnabled = true;
}

@synthesize selectedSegmentIndex = _selectedSegmentIndex;

-(void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    
    NSInteger currentIndex = _selectedSegmentIndex;
    _selectedSegmentIndex = selectedSegmentIndex;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
    
}

-(NSInteger)selectedSegmentIndex {
    return _selectedSegmentIndex;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Begin tracking
    
    UITouch *thisTouch = [touches anyObject];
    tracking = true;
    firstTouchLocation = [thisTouch locationInView:self];
    firstTouchIndex = _selectedSegmentIndex;
    [self becomeFirstResponder];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (tracking) {
        UITouch *thisTouch = [touches anyObject];
        // Handle tracking touch
        CGPoint thisTouchLocation = [thisTouch locationInView:self];
        
        CGFloat delta = ((thisTouchLocation.y - firstTouchLocation.y)) / (100.0 / _segments);

        NSInteger currentIndex = _selectedSegmentIndex;

        _selectedSegmentIndex =  firstTouchIndex-(int)delta;
        
        // Clamp value
        if (_selectedSegmentIndex >= _segments) {
            _selectedSegmentIndex = _segments - 1;
        } else if (_selectedSegmentIndex < 0) {
            _selectedSegmentIndex = 0;
        }

        if (_selectedSegmentIndex != currentIndex) {
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
        if (_backgroundImage) {
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), [_backgroundImage CGImage]);
        }
        
        int sprites = ((_spriteSheet.size.height / _spriteSize.height) * SCREEN_SCALE);
        int frame = ((float)_selectedSegmentIndex / _segments) * sprites;
        CGRect sourceRect = CGRectMake(0, frame * _spriteSize.height, _spriteSize.width, _spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([_spriteSheet CGImage], sourceRect);
        
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}

@end
