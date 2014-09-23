//
//  controllerView.m
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "KeyboardView.h"
#import "BuildSettings.h"

@implementation KeyboardView {
    
    int octaves;
    CGRect keys[88];
    int keyValues[88];
    
    NSMutableDictionary *keyTouches;
    NSMutableArray *keyDownArray;
    
    BOOL keyDowns[88];
    BOOL gateOpen;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.backgroundColor = [UIColor redColor];
        [self initKeys];
    }
    return self;
}


-(void)awakeFromNib {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor redColor];
    [self initKeys];
}

-(void)initKeys {
    
    keyTouches = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    
    if (IS_IPAD()) {
        octaves = 2;
    } else {
        octaves = 1;
    }
    
    CGFloat keyWidth = 1.0 / ((octaves * 7.0) + 1);
    CGFloat keyHeight = 1;
    CGFloat blackKeyHeight = 1 * 0.6;
    CGFloat blackKeyWidth = keyWidth / 1.5;
    
    int thisKey = 0;
    
    for (int i = 0; i < octaves; i++ ) {
        
        CGFloat leftPoint = i * keyWidth * 7.0;
        keys[thisKey + 0] = CGRectMake(leftPoint, 0, keyWidth, keyHeight); // C
        keyValues[thisKey + 0] = thisKey + 0;
        
        keys[thisKey + 1] = CGRectMake(leftPoint + keyWidth, 0, keyWidth, keyHeight); // D
        keyValues[thisKey + 1] = thisKey + 2;
        
        keys[thisKey + 2] = CGRectMake(leftPoint + (keyWidth * 2.0), 0, keyWidth, keyHeight); // E
        keyValues[thisKey + 2] = thisKey + 4;
        
        keys[thisKey + 3] = CGRectMake(leftPoint + (keyWidth * 3.0), 0, keyWidth, keyHeight); // F
        keyValues[thisKey + 3] = thisKey + 5;
        
        keys[thisKey + 4] = CGRectMake(leftPoint + (keyWidth * 4.0), 0, keyWidth, keyHeight); // G
        keyValues[thisKey + 4] = thisKey + 7;
        
        keys[thisKey + 5] = CGRectMake(leftPoint + (keyWidth * 5.0), 0, keyWidth, keyHeight); // A
        keyValues[thisKey + 5] = thisKey + 9;
        
        keys[thisKey + 6] = CGRectMake(leftPoint + (keyWidth * 6.0), 0, keyWidth, keyHeight); // B
        keyValues[thisKey + 6] = thisKey + 11;
        
        keys[thisKey + 7] = CGRectMake(leftPoint + (keyWidth * 0.75), 0, blackKeyWidth, blackKeyHeight); // C#
        keyValues[thisKey + 7] = thisKey + 1;
        
        keys[thisKey + 8] = CGRectMake(leftPoint + (keyWidth * 1.75), 0, blackKeyWidth, blackKeyHeight); // Eb
        keyValues[thisKey + 8] = thisKey + 3;
        
        keys[thisKey + 9] = CGRectMake(leftPoint + (keyWidth * 3.75), 0, blackKeyWidth, blackKeyHeight); // F#
        keyValues[thisKey + 9] = thisKey + 6;
        
        keys[thisKey + 10] = CGRectMake(leftPoint + (keyWidth * 4.75), 0, blackKeyWidth, blackKeyHeight); // Ab
        keyValues[thisKey +10] = thisKey + 8;
        
        keys[thisKey + 11] = CGRectMake(leftPoint + (keyWidth * 5.75), 0, blackKeyWidth, blackKeyHeight); // Bb
        keyValues[thisKey + 11] = thisKey + 10;
        
        thisKey += 12;
    }
    
    keys[thisKey] = CGRectMake(octaves * keyWidth * 7.0, 0, keyWidth, keyHeight);
    keyValues[thisKey] = thisKey;
    
    keyDownArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i < 88; i++) {
        keyDowns[i] = false;
    }
    gateOpen = false;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch* thisTouch in touches) {
        
        NSNumber *thisTouchRef = [NSNumber numberWithInt:(int)thisTouch];
        
        CGPoint touchLocation = [thisTouch locationInView:self];
        CGPoint touchNormalized = CGPointMake(
                                              touchLocation.x / self.bounds.size.width,
                                              touchLocation.y / self.bounds.size.height);
        
        int keyCount = (octaves * 12) + 1;
        for (int i = 0; i < keyCount; i++){
            if (CGRectContainsPoint(keys[i], touchNormalized)) {
                [keyTouches setObject:thisTouch forKey:thisTouchRef];
            }
        }
    }
    
    [self updateCVController];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *thisTouch in touches) {
        
        NSNumber *thisTouchRef = [NSNumber numberWithInt:(int)thisTouch];
        [keyTouches removeObjectForKey:thisTouchRef];
    }
    
    [self updateCVController];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateCVController];
}

-(void)updateCVController {
    
    int keyCount = (octaves * 12) + 1;
    
    // reset all keys
    for (int i = 0; i < keyCount; i++) {
        keyDowns[i] = false;
    }
    
    // Process all touches and record which keys are pressed
    for (UITouch *thisTouch in [keyTouches allValues]) {
        CGPoint touchLocation = [thisTouch locationInView:self];
        CGPoint touchNormalized = CGPointMake(
                                              touchLocation.x / self.bounds.size.width,
                                              touchLocation.y / self.bounds.size.height);
        
        for (int i = keyCount; i >= 0; i--){
            if (CGRectContainsPoint(keys[i], touchNormalized)) {
                keyDowns[i] = true;
                break;
            }
        }
    }
    
    // update the array of pressed keys
    bool somethingChanged = false;
    
    for (int i = 0; i < keyCount; i ++) {
        
        NSNumber *t = [NSNumber numberWithInt:i];
        
        if (keyDowns[i]) {
            if (![keyDownArray containsObject:t]) {
                [keyDownArray addObject:t];
                somethingChanged = true;
            }
        } else {
            if ([keyDownArray containsObject:t]) {
                [keyDownArray removeObject:t];
                somethingChanged = true;
            }
        }
    }
    
    if (somethingChanged) {
        
        // something has changed with the keyboard
        
        if (keyDownArray.count > 0) {
            // keys are down
            [_cvController playNote:keyValues[[keyDownArray.lastObject integerValue]]];
        } else  {
            // no keys are down
            [_cvController closeGate];
        }
        
        [self setNeedsDisplay];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger totalKeys = (12 * octaves) + 1;
    
    for (int i = 0; i < totalKeys; i++) {
        
        UIImage *drawImage;
        
        if (i % 12 < 7) {
            if (keyDowns[i]) {
                drawImage = [UIImage imageNamed:@"white_key_down"];
            } else {
                drawImage = [UIImage imageNamed:@"white_key_up"];
            }
        } else {
            if (keyDowns[i]) {
                drawImage = [UIImage imageNamed:@"black_key_down"];
            } else {
                drawImage = [UIImage imageNamed:@"black_key_up"];
            }
        }
        
        if (keyDowns[i]) {
            [[UIColor redColor] setFill];
        }
        
        [[UIColor lightGrayColor] setStroke];
        
        CGRect thisKey = keys[i];
        CGRect drawRect = CGRectMake(
                                     thisKey.origin.x * self.frame.size.width,
                                     thisKey.origin.y * self.frame.size.height,
                                     thisKey.size.width * self.frame.size.width,
                                     -thisKey.size.height * self.frame.size.height);
        
        if (drawImage) {
            CGContextSaveGState(ctx);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextDrawImage(ctx, drawRect, [drawImage CGImage]);
            CGContextRestoreGState(ctx);
        } else {
            CGContextAddRect(ctx, drawRect);
            CGContextDrawPath(ctx, kCGPathFillStroke);
        }
    }
    
}

@end
