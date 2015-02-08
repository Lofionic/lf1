//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "Defines.h"
#import "AudioEngine.h"
#import "MainViewController.h"
#import "AppDelegate.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface MainViewController ()

@end

@implementation MainViewController {
    
    NSTimer *pollPlayerTimer;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.presetController = [[PresetController alloc] initWithViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Hide status bar in IOS6.1 and prior
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    // Setup settings popover
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    self.settingsNavigationController = [storyboard instantiateInitialViewController];
    
    self.settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.settingsNavigationController];
    [self.settingsPopoverController setBackgroundColor:[UIColor whiteColor]];
    
    self.audioEngine = ((AppDelegate *)[UIApplication sharedApplication].delegate).audioEngine;

    [self setupControllerViews];
    
    // Prepare notifications for app state
    UIApplicationState appstate = [UIApplication sharedApplication].applicationState;
    self.inForeground = (appstate != UIApplicationStateBackground);
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appHasGoneInBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appHasGoneForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateTransportControls)
                                                 name: TRANSPORT_CHANGE_NOTIFICATION_STRING
                                               object: self.audioEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTransportControls)
                                                 name:ABConnectionsChangedNotification
                                               object:nil];
    
    [self updateUndoStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(undoStateChanged:)
                                                 name:UNDO_STATE_CHANGE_NOTIFICATON
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leftHandModeChanged:)
                                                 name:LEFT_HAND_MODE_CHANGE_NOTIFICATION
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leftHandModeChanged:)
                                                 name:LEFT_HAND_MODE_CHANGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userRequestedTwitterFollowNotification:)
                                                 name:USER_REQUEST_TWITTER_FOLLOW_NOTIFICATION
                                               object:nil];
    
    UITapGestureRecognizer *hostIconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoHost)];
    [self.hostIcon addGestureRecognizer:hostIconTap];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![userDefaults valueForKey:USER_DEFAULTS_HAS_LAUNCHED_1_3]) {
        self.shouldShowTwitterPrompt = YES;
    }
    
    [userDefaults setValue:@YES forKey:USER_DEFAULTS_HAS_LAUNCHED_1_3];
    [userDefaults synchronize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldShowTwitterPrompt) {
        [self promptForTwitter];
        self.shouldShowTwitterPrompt = NO;
    }
}

-(void)leftHandModeChanged:(NSNotification*)note {
    NSDictionary *dictionary = [note userInfo];
    self.leftHandMode = [[dictionary valueForKey:@"LeftHandModeOn"] boolValue];
    [self updateLeftHandModeAnimated:YES];
}

-(void)dealloc {
    [self.audioEngine removeObserver:self forKeyPath:TRANSPORT_CHANGE_NOTIFICATION_STRING];
    [self removeObserver:self forKeyPath:UIApplicationDidEnterBackgroundNotification];
    [self removeObserver:self forKeyPath:UIApplicationWillEnterForegroundNotification];
}

-(void)savePreset {
    [self.presetController storePresetAtIndex:0];
    [self.presetController exportBankToFileNamed:@"test.bnk"];
}

-(void)setupControllerViews {
    
    // Connect keyboard controller to CVController
    self.keyboardView.cvController = self.audioEngine.cvController;
    
    // Create oscillator controller view
    self.oscView = [[OscillatorControlView alloc] init];
    self.oscView.osc1 = self.audioEngine.osc1;
    self.oscView.osc2 = self.audioEngine.osc2;
    self.oscView.mixer = self.audioEngine.mixer;
    [self.oscView initializeParameters];
    
    // Create envelope controller view
    self.envView = [[EnvelopeControlView alloc] initWithFrame:CGRectZero];
    self.envView.VCFEnvelope = self.audioEngine.vcfEnvelope;
    self.envView.VCOEnvelope = self.audioEngine.vcoEnvelope;
    [self.envView initializeParameters];
    
    // Create filter controller view
    self.filterView = [[FilterControlView alloc] initWithFrame:CGRectZero];
    self.filterView.vcf = self.audioEngine.vcf;
    [self.filterView initializeParameters];
    
    // Create lfo controller view
    self.lfoView = [[LFOControlView alloc] initWithFrame:CGRectZero];
    self.lfoView.lfo = self.audioEngine.lfo1;
    self.lfoView.osc1 = self.audioEngine.osc1;
    self.lfoView.osc2 = self.audioEngine.osc2;
    self.lfoView.vcf = self.audioEngine.vcf;
    [self.lfoView initializeParameters];

    // Create keyboard controller view
    self.performanceControlView = [[PerformanceControlView alloc] initWithFrame:CGRectZero];
    self.performanceControlView.cvComponent = self.audioEngine.cvController;
    [self.performanceControlView initializeParameters];
    
    // Create presets controller view
    //self.presetControlView = [[PresetControlView alloc] initWithFrame:CGRectZero];
    self.presetControlView = [[NewPresetControlView alloc] initWithFrame:CGRectZero];
    
    self.presetControlView.presetController = self.presetController;
    [self.presetController restorePresetAtIndex:0];
    [self.presetControlView initializeParameters];
    
    // iPad - add control views
    [self.iPadControlsView1 addSubview:_oscView];
    [self.iPadControlsView2 addSubview:_envView];
    [self.iPadControlsView3 addSubview:_filterView];
    [self.iPadControlsView4 addSubview:_lfoView];
    [self.iPadControlsView5 addSubview:_performanceControlView];
    [self.iPadControlsView6 addSubview:_presetControlView];
    
    self.leftHandMode = [[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_KEY_LEFTHANDMODE] boolValue];
    [self updateLeftHandModeAnimated:NO];
}

-(void)updateLeftHandModeAnimated:(BOOL)animated {
    
    CGRect controlViewRect = self.iPadControlsView5.frame;
    CGRect keyboardViewRect = self.keyboardView.frame;
    if (self.leftHandMode) {
        controlViewRect = CGRectMake(keyboardViewRect.size.width, controlViewRect.origin.y, controlViewRect.size.width, controlViewRect.size.height);
        keyboardViewRect = CGRectMake(8, keyboardViewRect.origin.y, keyboardViewRect.size.width, keyboardViewRect.size.height);
    } else {
        controlViewRect = CGRectMake(8, controlViewRect.origin.y, controlViewRect.size.width, controlViewRect.size.height);
        keyboardViewRect = CGRectMake(controlViewRect.size.width, keyboardViewRect.origin.y, keyboardViewRect.size.width, keyboardViewRect.size.height);
    }
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^ {
            [self.iPadControlsView5 setFrame:controlViewRect];
            [self.keyboardView setFrame:keyboardViewRect];
        }];
    } else {
        [self.iPadControlsView5 setFrame:controlViewRect];
        [self.keyboardView setFrame:keyboardViewRect];
    }
}

-(void)viewWillLayoutSubviews {
    // Layout subviews
    self.oscView.frame = [self.oscView superview].bounds;
    self.envView.frame = [self.envView superview].bounds;
    self.filterView.frame = [self.filterView superview].bounds;
    self.lfoView.frame = [self.lfoView superview].bounds;
    self.performanceControlView.frame = [self.performanceControlView superview].bounds;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) appHasGoneInBackground {
    self.inForeground = NO;
}

-(void) appHasGoneForeground {
    [self setNeedsStatusBarAppearanceUpdate];
    self.inForeground = YES;
    [self updateTransportControls];
}

#pragma mark InterApp Audio

-(void)updateTransportControls {
    if (self.audioEngine) {
        if ([self.audioEngine isHostConnected] && ![self.audioEngine.audiobusController audiobusConnected]) {
            // We are connected to an IAP host but NOT audiobus
            self.transportView.hidden = NO;
            self.hostIcon.image = [self.audioEngine getAudioUnitIcon];
            self.rewindButon.enabled = !self.audioEngine.isHostPlaying;
            [self.playButton setImage:(self.audioEngine.isHostPlaying ? [UIImage imageNamed:@"pause_button.png"] : [UIImage imageNamed:@"play_button.png"]) forState:UIControlStateNormal];
            [self.recordButton setImage:(self.audioEngine.isHostRecording ? [UIImage imageNamed:@"record_button_on.png"] : [UIImage imageNamed:@"record_button.png"]) forState:UIControlStateNormal];
        } else {
            self.transportView.hidden = YES;
        }
        [self.view setNeedsDisplay];
    }
}

-(IBAction)transportRecord:(id)sender {
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine toggleRecord];
        }
    }
}

-(IBAction)transportPlay:(id)sender {
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine togglePlay];
        }
    }
}

-(IBAction)transportRewind:(id)sender {
    
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine rewind];
        }
    }
}

-(void)gotoHost {
    if (self.audioEngine) {
        if (self.audioEngine.connected) {
            [self.audioEngine gotoHost];
        }
    }
}

-(IBAction)settingsButton:(id)sender {
    [self.settingsNavigationController popToRootViewControllerAnimated:NO];
    [self.settingsPopoverController presentPopoverFromRect:((UIView*)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

-(IBAction)undoTapped:(id)sender {
    if ([self.presetController canUndo]) {
        [self.presetController recallUndo];
    }
}

-(void)updateUndoStatus {
    [self.undoButton setEnabled:[self.presetController canUndo]];
}

-(void)undoStateChanged:(NSNotification*)notification {
    [self updateUndoStatus];
}

-(void)userRequestedTwitterFollowNotification:(NSNotification*)notification {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    [self promptForTwitter];
}

-(void)promptForTwitter {
    
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Follow On Twitter?"
                                                                                     message:@"Stay informed all the latest news on app updates and new releases by following @Lofionic on Twitter.\n\n(This will require temporary access to your Twitter account.)"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self followOnTwitterWithSuccess: ^{
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setValue:@YES forKey:USER_DEFAULTS_HAS_ADDED_TWITTTER];
                    [userDefaults synchronize];
                }];
            }];
            
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No, thanks" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

            }];
            
            [alertController addAction:okAction];
            [alertController addAction:noAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else {
            //load and show ios7 storyboard
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Follow On Twitter?"
                                                                message:@"Stay informed all the latest news on app updates and new releases by following @Lofionic on Twitter.\n\n(This will require temporary access to your Twitter account.)"
                                                               delegate:self
                                                      cancelButtonTitle:@"No, thanks"
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self followOnTwitterWithSuccess: ^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:@YES forKey:USER_DEFAULTS_HAS_ADDED_TWITTTER];
            [userDefaults synchronize];
        }];
    }
}

-(void)followOnTwitterWithSuccess:(void(^)())successBlock {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (granted) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
                
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                
                if ([accountsArray count] > 0) {
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    NSDictionary *requestDictionary = @{ @"screen_name" : @"lofionic",
                                                         @"follow" : @"true" };
                    
                    SLRequest *followRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                  requestMethod:SLRequestMethodPOST
                                                                            URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"]
                                                                     parameters:requestDictionary];
                    
                    
                    [followRequest setAccount:twitterAccount];
                    [followRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString *output = [NSString stringWithFormat:@"HTTP response status %li", (long)[urlResponse statusCode]];
                        NSLog(@"%@", output);
                        if (error) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Fail" message:@"Unfortunately there was a problem connecting to Twitter.\n\nPlease check your account details and network connection, then try again next time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                [alertView show];
                            });
                        } else {
                            // Success
                            if (successBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^ {
                                    NSLog(@"Twitter follow request sent succesfully");
                                    successBlock();
                                });
                            }
                        }
                    }];
                }
            });
        } else {

        }
    }];
}


@end
