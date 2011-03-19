//
//  TSUIAssertionHandler.h
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/19/11.
//  Copyright 2011 tapsquare, llc. All rights reserved.
//

/**
 * Call this function to install the UI Assertion Handler on the calling thread. 
 * When this handler is installed, it shows a UIAlertView with the assertion information
 * instead of logging to console.
 */

void TSInstallUIAssertionHandler();

/**
 * Call this function to uninstall a previously installed UI AssertionHandler on
 * the calling thread.
 */
void TSUninstallUIAssertionHandler();

@interface TSUIAssertionHandler : NSAssertionHandler {
    
}

@end
