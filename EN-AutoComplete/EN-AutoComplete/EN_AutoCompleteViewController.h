//
//  EN_AutoCompleteViewController.h
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/17/11. art@tapsquare.com
//

#import <UIKit/UIKit.h>
#import "ENAPIRequest.h"

/*
 * This view implements a "live-search" against Echo Nest's `artist/suggest` method
 * using standard UISearchBar interface. Tapping on an artist pushes an `ENArtistAudioView`
 * onto the navigation controller.
 */
@interface EN_AutoCompleteViewController : UITableViewController <UISearchBarDelegate, ENAPIRequestDelegate> {
    @private
	// Stores results of `artist/suggest` calls—serves data to the view's table view.
    NSMutableArray *suggestResults;
	// The currently-active Echo Nest API request.
    ENAPIRequest *suggestRequest;
}

@end
