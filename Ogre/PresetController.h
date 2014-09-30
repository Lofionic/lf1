//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "BuildSettings.h"
#import <Foundation/Foundation.h>

@interface PresetController : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) NSArray *keyPaths;

-(instancetype)initWithViewController:(UIViewController*)viewController;
-(void)storePresetAtIndex:(NSInteger)index;
-(void)restorePresetAtIndex:(NSInteger)index;

@end
