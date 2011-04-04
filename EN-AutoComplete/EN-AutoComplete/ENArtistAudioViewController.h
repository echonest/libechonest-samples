//
//  ENArtistAudioView.h
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/19/11. art@tapsquare.com
//

#import <UIKit/UIKit.h>
#import "ENAPIRequest.h"

@interface ENArtistAudioViewController : UITableViewController <ENAPIRequestDelegate> {
	// stores the results of the artist/audio Echo Nest API calls
    NSMutableArray *audioResults;
}

@property (nonatomic, retain) NSDictionary *artist;

@end
