//
//  ENArtistAudioView.m
//  EN-AutoComplete
//
//  Created by Art Gillespie on 3/19/11. art@tapsquare.com
//

#import "ENArtistAudioViewController.h"

@implementation ENArtistAudioViewController
@synthesize artist;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)dealloc
{
    [audioResults release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    audioResults = [[NSMutableArray alloc] initWithCapacity:10];
    self.title = [self.artist valueForKey:@"name"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [audioResults release];
}

- (void)viewWillAppear:(BOOL)animated
{
    // start the request for the artist's audio
    ENAPIRequest *request = [[ENAPIRequest alloc] initWithEndpoint:@"artist/audio"];
    [request setValue:[self.artist valueForKey:@"id"] forParameter:@"name"];
    request.delegate = self;
    [request startAsynchronous];
	// you'll get a clang analyzer result here for 'Potential leak'
	// as long as you release the request in the delegate methods, it's all good.
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return audioResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArtistAudioCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *audio = [audioResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [audio valueForKey:@"title"];
    cell.detailTextLabel.text = [audio valueForKey:@"release"];
    
    return cell;
}

#pragma mark - ENAPIRequestDelegate

- (void)requestFinished:(ENAPIRequest *)request {

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
	
    [self.tableView beginUpdates];
        // copy the received results and animate the change in the table
        int oldCount = audioResults.count;
        [audioResults removeAllObjects];
        // build a delete array
        NSMutableArray *deletePaths = [[NSMutableArray alloc] initWithCapacity:oldCount];
        for (int ii = 0; ii < oldCount; ++ii) {
            [deletePaths addObject:[NSIndexPath indexPathForRow:ii inSection:0]];
        }
        [self.tableView deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationTop];
        [deletePaths release];
        [audioResults addObjectsFromArray:[request.response valueForKeyPath:@"response.audio"]];
        // build an insert array
        NSMutableArray *insertPaths = [[NSMutableArray alloc] initWithCapacity:audioResults.count];
        for (int ii = 0; ii < audioResults.count; ++ii) {
            [insertPaths addObject:[NSIndexPath indexPathForRow:ii inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationTop];
        [insertPaths release];
    [self.tableView endUpdates];
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

@end
