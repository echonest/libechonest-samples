//
//  CatalogBuilderAppDelegate.h
//  CatalogBuilder
//
//  Created by Art Gillespie on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CatalogBuilderViewController;

@interface CatalogBuilderAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet CatalogBuilderViewController *viewController;

/**
 * The EN catalog ID. Stores in defaults.
 */
@property (assign) NSString *catalogID;

@end
