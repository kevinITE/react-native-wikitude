//
//  ARViewController.m
//  RNWikitude
//
//  Created by Brave Digital Machine 7 on 2017/09/06.
//  Copyright © 2017 Brave Digital. All rights reserved.
//

#import "ARViewController.h"
/* Wikitude SDK debugging */
  #import <WikitudeSDK/WikitudeSDK.h>
/* Wikitude SDK debugging */
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>

@interface ARViewController () <WTArchitectViewDelegate, WTArchitectViewDebugDelegate, ARViewControllerDelegate>


@end

@implementation ARViewController

- (void)dealloc
{
    /* Remove this view controller from the default Notification Center so that it can be released properly */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    /* It might be the case that the device which is running the application does not fulfil all Wikitude SDK hardware requirements. To check for this and handle the situation properly, use the -isDeviceSupportedForRequiredFeatures:error class method. Required features specify in more detail what your Architect World intends to do. Depending on your intentions, more or less devices might be supported. e.g. an iPod Touch is missing some hardware components so that Geo augmented reality does not work, but 2D tracking does. NOTE: On iOS, an unsupported device might be an iPhone 3GS for image recognition or an iPod Touch 4th generation for Geo augmented reality. */
    NSError *deviceSupportError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_ImageTracking error:&deviceSupportError] ) {
        
        /* Standard WTArchitectView object creation and initial configuration */
        self.architectView = [[WTArchitectView alloc] initWithFrame:CGRectZero];
        self.architectView.delegate = self;
        self.architectView.debugDelegate = self;
        
        /* Use the -setLicenseKey method to unlock all Wikitude SDK features that you bought with your license. */
        [self.architectView setLicenseKey:@"M5bom7Zv4yI8eHToQNIwo6c/Qy/7Nk+V5BcZC2bH1CBwX83SMjMCPAdExA8ramU7/6Fqlp3kPcO4absuRcEZ+FlKlylyEmf7aaO+GLPze2XJDQlScXqLtn+VGBNY9qBQKvCmEVcFRensndHmr3FOuRh2/Dpe8Yn7Yebw0A6ztXZTYWx0ZWRfX53NIAQ8lfx1aU9vm8Xyg+ek4RREpU3ieyLf9DGWkkKKP5dloeTzWhg3KXFsphBhSvht8jh94F0IW3UPCwj7Yfdln3My12wgIXxFZjglh0VIc1QuZZkqsxNV4oq0pg2etxtI+iKNtCddcER0ly13uia3B5zOC88adj0K3iRxDW8Tgb/cHG90QqUYYN4C6H3MEyMlKHb50s07d8lv9IjAgioDmFXWbNY60445JRN08j2dDwa8rc5PgJIf7e5CnfH9AS3YISFO+P51jacFm2msH3l0RYpViKAe8NEXKaTrVSesfLNUfMQW1gBfYIu85TanDWJgs30o0bOHCNoMVV9XBjpxM5fIu7LEHKPJzF0GK/4AJlqTvkey2fv480Lv7O0hzojnhNwNx1PNbyJCxWYiMllFF10jn/ftQTaNyXZcAvGRomccN43m38sKSkgze1x2h2tV9o/kOYERn5YWZIM7/hwUOjO5H8X1enfD3c3o1i//9vsJru/SvOeyopZgv8OhoSkTEPGIQ7tMxfTSz3fHnaEw6kQ9BaQsKstkJg7gLMpY0iguppO0Bj2zG2rlAUXNHLBc6QwNVYsTmePQCwegTADdS+SNrOhSXLQoDNarEKUkpNogNeyrKZ0="];
        
        /* The Architect World can be loaded independently from the WTArchitectView rendering. NOTE: The architectWorldNavigation property is assigned at this point. The navigation object is valid until another Architect World is loaded. */
        self.architectWorldNavigation = [self.architectView loadArchitectWorldFromURL:[NSURL URLWithString:[self url]]];
        
        /* Because the WTArchitectView does some OpenGL rendering, frame updates have to be suspended and resumend when the application changes it's active state. Here, UIApplication notifications are used to respond to the active state changes. NOTE: Since the application will resign active even when an UIAlert is shown, some special handling is implemented in the UIApplicationDidBecomeActiveNotification. */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        /* Standard subview handling using Autolayout */
        [self.view addSubview:self.architectView];
        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];
        
//        Add the close button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(closeARClicked)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Exit AR" forState:UIControlStateNormal];
        
        button.frame = CGRectMake(
                                  self.view.frame.origin.x,
                                  self.view.frame.size.height - 80.0,
                                  self.view.frame.size.width,
                                  80.0);
        button.backgroundColor = [UIColor blackColor];
        button.tintColor = [UIColor whiteColor];
        [self.view addSubview:button];
    }
    else {
        NSLog(@"This device is not supported. Show either an alert or use this class method even before presenting the view controller that manages the WTArchitectView. Error: %@", [deviceSupportError localizedDescription]);
    }
}

#pragma mark - View Lifecycle
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    
//    /* WTArchitectView rendering is started once the view controllers view will appear */
//    [self startWikitudeSDKRendering];
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    /* WTArchitectView rendering is started once the view controllers view will appear */
    [self startWikitudeSDKRendering];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    /* WTArchitectView rendering is stopped once the view controllers view did disappear */
    [self stopWikitudeSDKRendering];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Rotation
- (BOOL)shouldAutorotate {
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    /* When the device orientation changes, specify if the WTArchitectView object should rotate as well */
    [self.architectView setShouldRotate:YES toInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Private Methods

/* Convenience methods to manage WTArchitectView rendering. */
- (void)startWikitudeSDKRendering{
    
    /* To check if the WTArchitectView is currently rendering, the isRunning property can be used */
    if ( ![self.architectView isRunning] ) {
        
        /* To start WTArchitectView rendering and control the startup phase, the -start:completion method can be used */
        [self.architectView start:^(WTStartupConfiguration *configuration) {
            
            /* Use the configuration object to take control about the WTArchitectView startup phase */
            /* You can e.g. start with an active front camera instead of the default back camera */
            
            // configuration.captureDevicePosition = AVCaptureDevicePositionFront;
            
        } completion:^(BOOL isRunning, NSError *error) {
            
            /* The completion block is called right after the internal start method returns. NOTE: In case some requirements are not given, the WTArchitectView might not be started and returns NO for isRunning. To determine what caused the problem, the localized error description can be used. */
            if ( !isRunning ) {
                NSLog(@"WTArchitectView could not be started. Reason: %@", [error localizedDescription]);
            }
        }];
    }
}

- (void)stopWikitudeSDKRendering {
    
    /* The stop method is blocking until the rendering and camera access is stopped */
    if ( [self.architectView isRunning] ) {
        [self.architectView stop];
    }
}

/* The WTArchitectView provides two delegates to interact with. */
#pragma mark - Delegation

/* The standard delegate can be used to get information about: * The Architect World loading progress * The method callback for AR.platform.sendJSONObject caught by -architectView:receivedJSONObject: * Managing view capturing * Customizing view controller presentation that is triggered from the WTArchitectView */
#pragma mark WTArchitectViewDelegate
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation {
    /* Architect World did finish loading */
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"Architect World from URL '%@' could not be loaded. Reason: %@", navigation.originalURL, [error localizedDescription]);
}

/* The debug delegate can be used to respond to internal issues, e.g. the user declined camera or GPS access. NOTE: The debug delegate method -architectView:didEncounterInternalWarning is currently not used. */
#pragma mark WTArchitectViewDebugDelegate
- (void)architectView:(WTArchitectView *)architectView didEncounterInternalWarning:(WTWarning *)warning {
    
    /* Intentionally Left Blank */
}

- (void)architectView:(WTArchitectView *)architectView didEncounterInternalError:(NSError *)error {
    
    NSLog(@"WTArchitectView encountered an internal error '%@'", [error localizedDescription]);
}

#pragma mark - Notifications
/* UIApplication specific notifications are used to pause/resume the architect view rendering */
- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        /* Standard WTArchitectView rendering suspension when the application resignes active */
        [self stopWikitudeSDKRendering];
    });
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /* When the application starts for the first time, several UIAlert's might be shown to ask the user for camera and/or GPS access. Because the WTArchitectView is paused when the application resigns active (See line 86), also Architect JavaScript evaluation is interrupted. To resume properly from the inactive state, the Architect World has to be reloaded if and only if an active Architect World load request was active at the time the application resigned active. This loading state/interruption can be detected using the navigation object that was returned from the -loadArchitectWorldFromURL:withRequiredFeatures method. */
//        if ( self.architectWorldNavigation.wasInterrupted )
//        {
//            [self.architectView reloadArchitectWorld];
//        }
        
        /* Standard WTArchitectView rendering resuming after the application becomes active again */
        [self startWikitudeSDKRendering];
    });
}

#pragma mark - Actions
-(void)closeARClicked
{
    [self stopWikitudeSDKRendering];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end