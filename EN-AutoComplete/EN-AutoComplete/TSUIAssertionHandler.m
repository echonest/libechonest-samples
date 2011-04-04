//
//  TSUIAssertionHandler.m
//
//  Created by Art Gillespie on 3/19/11. art@tapsquare.com
//  Copyright 2011 tapsquare, llc. All rights reserved.
//

#import "TSUIAssertionHandler.h"

void TSInstallUIAssertionHandler() {
    // NSAssertionHandlerKey
    NSAssertionHandler *handler = [[[NSThread currentThread] threadDictionary] valueForKey:NSAssertionHandlerKey];
    if (nil == handler) {
        [[[NSThread currentThread] threadDictionary] setObject:[[[TSUIAssertionHandler alloc] init] autorelease] forKey:NSAssertionHandlerKey];
    } else {
        
    }
}

void TSUinstallUIAssertionHandler() {
    [[[NSThread currentThread] threadDictionary] removeObjectForKey:NSAssertionHandlerKey];
}

@implementation TSUIAssertionHandler

- (void)showAssertUIAlert:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format args:(va_list) args {
    
    NSString *desc = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    // grab just the file name, we don't need the whole flippin' path
    NSString *justFileName = [fileName lastPathComponent];
    NSString *fullMsg = [NSString stringWithFormat:@"%@:%d:%@\n\n%@", justFileName, line, functionName, desc];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Assert Failed", @"AssertHandler Alert") 
                                                    message:fullMsg
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") 
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format, ...  {
    va_list args;
    va_start(args, format);
    [self showAssertUIAlert:functionName file:fileName lineNumber:line description:format args:args];
}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *methodName = NSStringFromSelector(selector);
    [self showAssertUIAlert:methodName file:fileName lineNumber:line description:format args:args];
}

@end
