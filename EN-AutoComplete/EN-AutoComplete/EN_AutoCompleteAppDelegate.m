//
//  EN_AutoCompleteAppDelegate.m
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/17/11. art@tapsquare.com
//

#import "EN_AutoCompleteAppDelegate.h"
#import "EN_AutoCompleteViewController.h"
#import "ENAPI.h"
#import "TSUIAssertionHandler.h"

#pragma error "Set this to your Echo Nest API Key"
static NSString *TEST_API_KEY = @"2J12S2GOSDBV2KC6V";

@implementation EN_AutoCompleteAppDelegate

@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //CUSTOM ASSERTION HANDLER
    TSInstallUIAssertionHandler();
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    /*
	 * You only have to do this once, so in your app delegate's `didFinishLanchingWithOptions`
	 * is a good place.
	 */
    [ENAPI initWithApiKey:TEST_API_KEY];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
