//
//  EN_AutoCompleteViewController.m
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/17/11. art@tapsquare.com
//

#import "EN_AutoCompleteViewController.h"
#import "ENAPI.h"
#import "ENAPIRequest.h"
#import "ENArtistAudioViewController.h"

@implementation EN_AutoCompleteViewController

- (void)dealloc
{
    [suggestResults release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    suggestResults = [[NSMutableArray alloc] initWithCapacity:15];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return the current number of `artist/suggest` results
    return suggestResults.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ENSuggestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	// Set up the cell with the artist's name.
    NSDictionary *artist = [suggestResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [artist valueForKey:@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // the user has tapped on an artist: create an artist view
    ENArtistAudioViewController *artistAudioController = [[ENArtistAudioViewController alloc] initWithNibName:@"ENArtistAudioViewController" bundle:nil];
    artistAudioController.artist = [suggestResults objectAtIndex:indexPath.row];;
    [self.navigationController pushViewController:artistAudioController animated:YES];
    [artistAudioController release];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // the user has changed the text in the search bar
    if (nil != suggestRequest && !suggestRequest.complete) {
		// we only want to have one request active at any time, so 
		// cancel the existing request if it hasn't completede. 
		// Note that we're threadsafe here, because everything's
		// happening on the main thread's runloop.
        [suggestRequest cancel];
        [suggestRequest release];
        suggestRequest = nil;
    }
    if ([searchText isEqualToString:@""]) {
		// if the searchBar has no text, we don't need to ask
		// the server for suggestions, just empty the results array.
        [suggestResults removeAllObjects];
        [self.tableView reloadData];
        return;
    }
	// ask the Echo Nest server for suggestions
    suggestRequest = [[ENAPIRequest alloc] initWithEndpoint:@"artist/suggest"];
    [suggestRequest setValue:searchText forParameter:@"name"];
    suggestRequest.delegate = self;
    [suggestRequest startAsynchronous];
}

#pragma mark - ENAPIRequestDelegate

- (void)requestFinished:(ENAPIRequest *)request {
	// The Echo Nest server has repsonded. 
	
	// There are handy accessors for the Echo Nest status
	// code and status message
	if (0 != request.echonestStatusCode) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Echo Nest Error", @"")
														message:request.echonestStatusMessage
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[request release];
		return;
	}
    NSArray *artists = [request.response valueForKeyPath:@"response.artists"];
    [suggestResults removeAllObjects];
    for (int ii=0; ii<artists.count; ++ii) {
        [suggestResults addObject:[artists objectAtIndex:ii]];        
    }
    [self.tableView reloadData];
    suggestRequest = nil;
    [request release];
}

- (void)requestFailed:(ENAPIRequest *)request {
    // The request or connection failed at a low level, use
	// the request's error property to get information on the
	// failure
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Error", @"")
													message:[request.error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK", @"")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
