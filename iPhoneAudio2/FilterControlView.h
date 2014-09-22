//
//  FilterControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 14/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"
#import "VCF.h"

@class FilterControlView;

@interface FilterControlView : ControlView

@property (nonatomic, weak) VCF* vcf;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *freqControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *resControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *egControl;
@end
