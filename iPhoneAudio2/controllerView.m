//
//  controllerView.m
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "controllerView.h"

@implementation controllerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(void)awakeFromNib {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor redColor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegate) {
        
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        CGFloat touchNormalized = touchLocation.x / self.bounds.size.width;
        
        NSInteger key = floor(touchNormalized * 25);

        float frequency = (powf(powf(2, (1.0 / 12.0)), key)) * 220.0;
        
        NSLog(@"Key %i Freq %.2f", key, frequency);
        
        [_delegate noteOn:frequency];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegate) {
        [_delegate noteOff];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self touchesBegan:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
