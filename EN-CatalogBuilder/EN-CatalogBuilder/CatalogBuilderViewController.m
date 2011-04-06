//
//  CatalogBuilderViewController.m
//  CatalogBuilder
//
//  Created by Art Gillespie on 3/23/11. art@tapsquare.com
//  Copyright 2011 tapsquare, llc. All rights reserved.
//

#import "CatalogBuilderViewController.h"
#import "CatalogBuilderAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ENAPI.h"
#import "ENAPIPostRequest.h"
#import "NSArray+ENAPI.h"

#define APP ((CatalogBuilderAppDelegate *)[UIApplication sharedApplication].delegate)

enum {
    kENCatalogState_None = 0,
    kENCatalogState_Creating,
    kENCatalogState_Updating,
    kENCatalogState_Waiting,
    kENCatalogState_Complete
};

@interface CatalogBuilderViewController ()

- (void)createCatalogForDevice;
- (void)updateCatalog;
- (void)buildCatalog;
- (void)setupPlaylist;
- (void)logMediaItem:(MPMediaItem *)item;

@property (assign) int state;
@property (retain) NSString *updateTicket;
@property (retain) ENAPIPostRequest *createCatalogRequest;
@property (retain) ENAPIPostRequest *updateCatalogRequest;
@property (retain) ENAPIRequest *checkTicketRequest;
@property (retain) ENAPIRequest *playlistRequest;

@end

@implementation CatalogBuilderViewController
@synthesize statusLabel, state, updateTicket, createCatalogRequest, updateCatalogRequest, checkTicketRequest, playlistRequest;

- (void)dealloc
{
    [updateTicket release];
    [createCatalogRequest release];
    [updateCatalogRequest release];
    [checkTicketRequest release];
    [playlistRequest release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)createCatalogForDevice {
    self.createCatalogRequest = [ENAPIPostRequest catalogCreateWithName:[[UIDevice currentDevice] uniqueIdentifier] type:@"song"];
    self.createCatalogRequest.delegate = self;
    self.state = kENCatalogState_Creating;
    self.statusLabel.text = NSLocalizedString(@"Creating New Catalog...", @"");
    [self.createCatalogRequest startAsynchronous];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    if (nil == APP.catalogID) {
        [self createCatalogForDevice];
    } else {
        [self updateCatalog];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - actions

- (void)logMediaItem:(MPMediaItem *)item {
    uint64_t uuid = [[item valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
    NSString *s_uuid = [NSString stringWithFormat:@"%qu", uuid];
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
    NSUInteger playCount = [[item valueForProperty:MPMediaItemPropertyPlayCount] unsignedLongLongValue];
    NSUInteger skipCount = [[item valueForProperty:MPMediaItemPropertySkipCount] unsignedLongLongValue];
    NSLog(@"uid: %@", s_uuid);
    NSLog(@"title: %@", title);
    NSLog(@"artist: %@", artist);
    NSLog(@"playCount: %d", playCount);
    NSLog(@"skipCount: %d", skipCount);    
}

- (void)updateCatalog {
    // update with iPod library
    self.state = kENCatalogState_Updating;
    self.statusLabel.text = NSLocalizedString(@"Updating Catalog with Contents of iPod Library...", @"");
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    /*
     * We can use the MPMediaItemPropertyPersistentID property for EN's item_id parameter
     */
    NSString *json = [query.items catalogUpdateBlockWithAction:nil];
    ENAPIPostRequest *request = [ENAPIPostRequest catalogUpdateWithID:APP.catalogID data:json];
    request.delegate = self;
    [request startAsynchronous];
}

- (void)buildCatalog {
    // first check to see if we already have a catalog
    if (nil == (APP).catalogID) {
        self.statusLabel.text = NSLocalizedString(@"Creating New Catalog...", @"");
        // first-run
        self.state = kENCatalogState_Creating;
        ENAPIPostRequest *request = [ENAPIPostRequest catalogCreateWithName:@"My Awesome Playlist"
                                                                       type:@"song"];
        request.delegate = self;
        [request startAsynchronous];
        return;
    } else {
        [self updateCatalog];
    }
    
}

- (void)checkTicket {
    ENAPIRequest *request = [ENAPIRequest requestWithEndpoint:@"catalog/status"];
    [request setValue:self.updateTicket forParameter:@"ticket"];
    request.delegate = self;
    [request retain];
    [request startAsynchronous];
}

- (void)setupPlaylist {
    ENAPIRequest *request = [ENAPIRequest requestWithEndpoint:@"playlist/dynamic"];
    [request setBoolValue:YES forParameter:@"limit"];
    [request setValue:[NSString stringWithFormat:@"id:%@", APP.catalogID] forParameter:@"bucket"];
    [request setFloatValue:0.5f forParameter:@"min_danceability"];
    [request setFloatValue:95.f forParameter:@"max_tempo"];
    [request retain];
    [request startAsynchronous];
}

#pragma mark ENAPIPostRequestDelegate

- (void)requestFinished:(NSObject *)request_ {
    if ([request_ isKindOfClass:[ENAPIPostRequest class]]) {
        ENAPIPostRequest *request = (ENAPIPostRequest *)request_;
        NSAssert(200 == request.responseStatusCode, @"Expected status code == 200");
        NSAssert(request.echonestStatusCode == 0, @"Expected EN response.status.code == 0");
        if (0 != request.echonestStatusCode) {
            self.statusLabel = [NSString stringWithFormat:NSLocalizedString(@"Error: %d : %@", @""), request.echonestStatusCode, request.echonestStatusMessage];
            self.state = kENCatalogState_None;
            return;
        }
        self.statusLabel.text = NSLocalizedString(@"Request finished", @"");
        switch (self.state) {
            case kENCatalogState_Creating: 
            {
                NSString *newID = [request.response valueForKeyPath:@"response.id"];
                APP.catalogID = newID;
                [self updateCatalog];
                break;
            }
            case kENCatalogState_Updating:
                self.statusLabel.text = NSLocalizedString(@"Updating complete... waiting for server to process...", @"");
                self.updateTicket = [request.response valueForKeyPath:@"response.ticket"];
                [self checkTicket];
                break;
            default:
                NSAssert(false, @"Unexpected self.state");
        }
    } else if ([request_ isKindOfClass:[ENAPIRequest class]]) {
        ENAPIRequest *request = (ENAPIRequest *)request_;
        [request autorelease];
        
        NSAssert(200 == request.responseStatusCode, @"Expected status code == 200");
        NSAssert(request.echonestStatusCode == 0, @"Expected EN response.status.code == 0");
        if (0 != request.echonestStatusCode) {
            self.statusLabel = [NSString stringWithFormat:NSLocalizedString(@"Error: %d : %@", @""), request.echonestStatusCode, request.echonestStatusMessage];
            self.state = kENCatalogState_None;
            return;
        }
        NSString *ticketStatus = [request.response valueForKeyPath:@"response.ticket_status"];
        if ([ticketStatus isEqualToString:@"pending"]) {
            //TODO: check this on a timer, not in an asynchronous tight loop like this
            [self checkTicket];
            return;
        } else if ([ticketStatus isEqualToString:@"error"]) {
            self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Error updating catalog: %@", @""), 
                                     [request.response valueForKeyPath:@"response.details"]];
            self.state = kENCatalogState_None;
            return;
        } else if ([ticketStatus isEqualToString:@"complete"]) {
            self.state = kENCatalogState_Complete;
            self.statusLabel.text = NSLocalizedString(@"Update Complete!", @"");
            [self setupPlaylist];
        } else if ([ticketStatus isEqualToString:@"unknown"]) {
            self.state = kENCatalogState_None;
            self.statusLabel.text = NSLocalizedString(@"Error: Unknown Catalog", @"");
        }
    }
}

- (void)requestFailed:(NSObject *)request_ {
    if ([request_ isKindOfClass:[ENAPIPostRequest class]]) {
        [request_ autorelease];
        ENAPIPostRequest *request = (ENAPIPostRequest *)request_;
        self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", @""), [request.error localizedDescription]];
    } else {
        ENAPIRequest *request = (ENAPIRequest *)request_;
        self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Request failed: %@", @""), [request.error localizedDescription]];
    }
}

- (void)request:(ENAPIPostRequest *)request progress:(long long)progress {
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%qu bytes uploaded", @""), progress];
}

@end
