//
//  ENArtistAudioView.h
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/19/11.
//  Copyright 2011 tapsquare, llc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENAPIRequest.h"

@interface ENArtistAudioViewController : UITableViewController <ASIHTTPRequestDelegate> {
    NSMutableArray *audioResults;
}

@property (nonatomic, retain) NSDictionary *artist;

@end
