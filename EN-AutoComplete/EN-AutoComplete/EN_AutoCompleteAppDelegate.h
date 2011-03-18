//
//  EN_AutoCompleteAppDelegate.h
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EN_AutoCompleteViewController;

@interface EN_AutoCompleteAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet EN_AutoCompleteViewController *viewController;

@end
