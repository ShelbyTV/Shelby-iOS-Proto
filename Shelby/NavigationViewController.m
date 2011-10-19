//
//  NavigationViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "NavigationViewController.h"

#import "VideoTableViewController.h"
#import "VideoPlayer.h"
#import "User.h"
#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "BroadcastApi.h"
#import "Video.h"
#import "ShareViewController.h"

@implementation NavigationViewController

@synthesize shareView = _shareView;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        videoTable = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain
                                                      //callbackObject:self callbackSelector:@selector(playContentURL:)];
                                                      callbackObject:self callbackSelector:@selector(playVideo:)];
        videoTable.delegate = self;

        // This is a dirty hack, because for some reason, the NIB variables aren't bound immediately, so the following code doesn't work alone:
        // _videoPlayer.delegate = self;
        // So instead, we pull the view out via its tag.
        _videoPlayer = (VideoPlayer *) [self.view viewWithTag: 1];
        _videoPlayer.delegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedOut:)
                                                     name:@"UserLoggedOut"
                                                   object:nil];

        // Network Activity
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkActiveNotification:)
                                                     name:@"ShelbyAppNetworkActive"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkInactiveNotification:)
                                                     name:@"ShelbyAppNetworkInactive"
                                                   object:nil];


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(likeVideoFailed:)
                                                     name:@"LikeBroadcastFailed"
                                                   object:nil];

        _authorizations = [[NSSet alloc] initWithObjects:
            @"auth_twitter",
            @"auth_facebook",
            @"auth_tumblr",
            nil];
        
        ShareViewController *shareView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            shareView = [[[ShareViewController alloc] initWithNibName:@"ShareView_iPad" bundle:nil] autorelease];
        } else {
            shareView = [[[ShareViewController alloc] initWithNibName:@"ShareView_iPhone" bundle:nil] autorelease];
        }
        shareView.delegate = self;
        [shareView updateAuthorizations: [ShelbyApp sharedApp].loginHelper.user];
        shareView.view.frame = self.view.bounds;
        
        self.shareView = shareView;
        self.shareView.view.hidden = YES;
        [self.view addSubview:self.shareView.view];
    }
    return self;
}


#pragma mark - 

- (void)playVideo:(Video *)video
{
    LOG(@"playVideo: %@", video);
    if (video == nil) {
        return;
    }
    
    // Make videoPlayer visible. Really only does something on iPhone.
    _videoPlayer.hidden = NO;
    
    [_videoPlayer playVideo: video];
}

- (void)updateAuthorizations:(User *)user
{
    userTwitter.highlighted = [user.auth_twitter boolValue];
    userFacebook.highlighted = [user.auth_facebook boolValue];
    userTumblr.highlighted = [user.auth_tumblr boolValue];
}

- (void)loadUserData
{
    User *user = [ShelbyApp sharedApp].loginHelper.user;

    for (NSString *auth in _authorizations) {
        [user addObserver:self forKeyPath:auth options:0 context:NULL];
    }

    [self updateAuthorizations: user];

    // Draw user image & name.
    userName.text = user.nickname;
    if (user.image) {
        userImage.image = [UIImage imageWithData: user.image];
    } else {
        userImage.image = [UIImage imageNamed: @"PlaceholderFace"];
    }

    // Refresh Video list.
    [videoTable loadVideos];
}

#pragma mark - Logout Functionality

- (void)showLogoutAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log out?" message:@"Would you like to log out?"
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    [alert show];
    [alert release];
}

#pragma mark - User Button Methods

- (IBAction)userViewWasPressed:(id)sender
{
    // Override in subclass.
}

#pragma mark - ShareViewDelegate Methods

- (void)shareViewClosePressed:(ShareViewController*)shareView
{
    self.shareView.view.hidden = YES;
    [_videoPlayer resumeAfterCloseShareView];
}

- (void)shareView:(ShareViewController *)shareView 
      sentMessage:(NSString *)message
     withNetworks:(NSArray *)networks
    andRecipients:(NSString *)recipients
{
    Video *video = [shareView getVideo];

    [BroadcastApi share:video
                comment:message
               networks:networks
              recipient:recipients];
    
    self.shareView.view.hidden = YES;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Since we only have one alertview, let's be lazy and assume we have the right one.
    if (buttonIndex == 1) {
        // close the shareview, if visible
        self.shareView.view.hidden = YES;
        // actually log out
        [[ShelbyApp sharedApp].loginHelper logout];
    }
}

#pragma mark - VideoTableViewControllerDelegate Methods

- (void)videoTableViewControllerFinishedRefresh:(VideoTableViewController *)controller
{
    // Override in subclass.
    // TODO: Convert to optional method in protocol using respondsToSelector:
}

#pragma mark - VideoPlayerDelegate Methods

- (void)videoPlayerPlayButtonWasPressed:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerPlayButtonWasPressed]");
}

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerFullscreenButtonWasPressed]");
}

- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerNextButtonWasPressed]");
    Video *video = [videoTable getNextVideo];

    // Tell player to start playing new video.
    [self playVideo: video];
}

- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerPrevButtonWasPressed]");
    Video *video = [videoTable getPreviousVideo];
    // Tell player to start playing new video.
    [self playVideo: video];
}

- (void)videoPlayerLikeButtonWasPressed:(VideoPlayer *)videoPlayer
{
    Video *video = _videoPlayer.currentVideo;
    if ([videoPlayer isFavoriteButtonSelected]) {
        [BroadcastApi dislike:video];
    } else {
        [BroadcastApi like:video];
    }
}

- (void)videoPlayerShareButtonWasPressed:(VideoPlayer *)videoPlayer
{
    // Set up the shareView with the video info.
    Video *video = _videoPlayer.currentVideo;
    [self.shareView setVideo:video];
    
    [self.shareView updateAuthorizations: [ShelbyApp sharedApp].loginHelper.user];

    self.shareView.view.hidden = NO;

    // Use this to reveal the keyboard.
    [self.shareView.socialTextView becomeFirstResponder];
}

- (void)videoPlayerVideoDidFinish:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerVideoDidFinish]");

    // Fetch the video next in queue.
    Video *url = [videoTable getNextVideo];
    // Tell player to start playing new video.
    [self playVideo: url];
}

#pragma mark - Button Handling

- (IBAction)listButtonPressed:(id)sender
{
    [favoritesButton setSelected:NO];
    [watchLaterButton setSelected:NO];
    [listButton setSelected:YES];
    [videoTable changeVideoMode:0];
}

- (IBAction)favoritesButtonPressed:(id)sender
{
    [listButton setSelected:NO];
    [watchLaterButton setSelected:NO];
    [favoritesButton setSelected:YES];
    [videoTable changeVideoMode:1];
}

- (IBAction)watchLaterButtonPressed:(id)sender
{
    [listButton setSelected:NO];
    [favoritesButton setSelected:NO];
    [watchLaterButton setSelected:YES];
    [videoTable changeVideoMode:2];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _networkActivityViewParent = activityHolder;

    videoTable.tableView.frame = videoTableHolder.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        videoTable.tableView.rowHeight = 118;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        videoTable.tableView.rowHeight = 232;
    }

    // this color matches the bottom color of the table cell gradient
    [videoTable.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
    [videoTable.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [videoTableHolder addSubview:videoTable.tableView];

    [buttonsFiller setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ButtonBackground"]]];
}

#pragma mark - Notification Handlers

- (void)likeVideoFailed:(NSNotification *)notification
{
    // open an alert to inform the user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aaawww… " message:@"I know you love that video, but it seems our heart is broken right now. Maybe try to like me again later?"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)userLoggedOut:(NSNotification*)aNotification
{
    // Stop video playback.
    [_videoPlayer stop];
    [_videoPlayer reset];

    // Clear out the video table
    [videoTable clearVideoTableData];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isKindOfClass: [User class]] && [_authorizations containsObject: keyPath]) {
        User *user = (User *) object;
        [self updateAuthorizations: user];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

#pragma mark - Layout

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.shareView) {
        [self.shareView adjustViewsForOrientation:interfaceOrientation];
    }
}


#pragma mark - Cleanup

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [_videoPlayer release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
