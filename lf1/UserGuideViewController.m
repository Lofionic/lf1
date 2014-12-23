//
//  UserGuideViewController.m
//  LF1
//
//  Created by Chris on 12/23/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "UserGuideViewController.h"

@interface UserGuideViewController ()

@end

@implementation UserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *userGuideURL = [[NSBundle mainBundle] URLForResource:@"userguide" withExtension:@"html"];
    
    NSStringEncoding stringEncoding;
    NSError *error;
    NSString *html = [NSString stringWithContentsOfURL:userGuideURL usedEncoding:&stringEncoding error:&error];
    
    [self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
