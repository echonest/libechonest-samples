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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    suggestResults = [[NSMutableArray alloc] initWithCapacity:15];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return the current number of results
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
    NSDictionary *artist = [suggestResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [artist valueForKey:@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // create an artist view
    ENArtistAudioViewController *artistAudioController = [[ENArtistAudioViewController alloc] initWithNibName:@"ENArtistAudioViewController" bundle:nil];
    artistAudioController.artist = [suggestResults objectAtIndex:indexPath.row];;
    [self.navigationController pushViewController:artistAudioController animated:YES];
    [artistAudioController release];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (nil != suggestRequest && !suggestRequest.complete) {
        [suggestRequest cancel];
        [suggestRequest release];
        suggestRequest = nil;
    }
    if ([searchText isEqualToString:@""]) {
        [suggestResults removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    suggestRequest = [[ENAPIRequest alloc] initWithEndpoint:@"artist/suggest"];
    [suggestRequest setValue:searchText forParameter:@"name"];
    suggestRequest.delegate = self;
    [suggestRequest startAsynchronous];
}

#pragma mark - ENAPIRequestDelegate

- (void)requestFinished:(ENAPIRequest *)request {
    NSDictionary *response = [request.response valueForKey:@"response"];
    NSArray *artists = [response valueForKey:@"artists"];
    [suggestResults removeAllObjects];
    for (int ii=0; ii<artists.count; ++ii) {
        [suggestResults addObject:[artists objectAtIndex:ii]];        
    }
    [self.tableView reloadData];
    suggestRequest = nil;
    [request release];
}

- (void)requestFailed:(ENAPIRequest *)request {
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
