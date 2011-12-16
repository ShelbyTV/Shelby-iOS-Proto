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
#import "VideoGetter.h"
#import "ShelbyAppDelegate.h"
#import "ApiHelper.h"

@interface NavigationViewController ()
@property (readwrite) NSInteger networkCounter;
@end

@implementation NavigationViewController

@synthesize shareView = _shareView;
@synthesize networkCounter;
@synthesize touched;

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
        [self.view addSubview:[[VideoGetter singleton] getView]];
        
        _fullscreenWebView = [FullscreenWebView fullscreenWebViewFromNib];
        _fullscreenWebView.hidden = YES;
        [_fullscreenWebView setDelegate:self];
        [self.view addSubview:_fullscreenWebView];
    }
    return self;
}


#pragma mark - 


- (void)updateAuthorizations:(User *)user
{
    userTwitter.highlighted = [user.auth_twitter boolValue];
    userFacebook.highlighted = [user.auth_facebook boolValue];
//    userTumblr.highlighted = [user.auth_tumblr boolValue];
    
    addTwitterButton.enabled = ![user.auth_twitter boolValue];
    addFacebookButton.enabled = ![user.auth_facebook boolValue];
//    addTumblrButton.enabled = ![user.auth_tumblr boolValue];
}

- (void)loadUserData
{
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
    
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

#pragma mark - User Button Methods

- (void)toggleSettings
{
    if (!_settingsSliding) {
        _settingsSliding = YES;
        [UIView animateWithDuration:0.25 animations:^{
            [self slideSettings:!_settingsVisible];
        }
                         completion:^(BOOL finished){
                             _settingsSliding = NO;
                         }];
        _settingsVisible = !_settingsVisible;
    }
}

- (IBAction)backToVideos:(id)sender
{
    [self toggleSettings];
}

- (IBAction)userViewWasPressed:(id)sender
{
    [self toggleSettings];
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

- (void)shareViewWasTouched
{
    self.touched = TRUE;
}

- (void)logOut:(id)sender
{
    self.shareView.view.hidden = YES;
    if (_settingsVisible) {
        [self toggleSettings];
    }
    [[ShelbyApp sharedApp].loginHelper logout];
}

- (void)showWebPage:(NSString *)urlString
{    
    [_videoPlayer pause];
    [_fullscreenWebView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                         timeoutInterval:60.0]];
    self.networkCounter = 1;
}

- (void)addFacebook:(id)sender
{
    LOG(@"Showing %@", [NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=facebook&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]);
    [self showWebPage:[NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=facebook&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]];
}

- (void)addTwitter:(id)sender
{
    LOG(@"Showing %@", [NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=twitter&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]);
    [self showWebPage:[NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=twitter&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]];
}

- (void)addTumblr:(id)sender
{
    LOG(@"Showing %@", [NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=tumblr&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]);
    [self showWebPage:[NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=tumblr&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]];
}

- (void)termsOfUse:(id)sender
{
    [self showWebPage:@"http://shelby.tv/tou.html"];
}

- (void)privacyPolicy:(id)sender
{
    [self showWebPage:@"http://shelby.tv/privacy.html"];
}

#pragma mark - VideoTableViewControllerDelegate Methods

- (void)videoTableViewControllerFinishedRefresh:(VideoTableViewController *)controller
{
    // Override in subclass.
    // TODO: Convert to optional method in protocol using respondsToSelector:
}

- (void)videoTableWasTouched
{
    self.touched = TRUE;
}

#pragma mark - VideoPlayerDelegate Methods

- (void)videoPlayerWasTouched
{
    self.touched = TRUE;
}

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
    [self playVideo:video];
}

- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerPrevButtonWasPressed]");
    Video *video = [videoTable getPreviousVideo];
    // Tell player to start playing new video.
    [self playVideo:video];
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

- (void)videoPlayerWatchLaterButtonWasPressed:(VideoPlayer *)videoPlayer
{
    Video *video = _videoPlayer.currentVideo;
    if ([videoPlayer isWatchLaterButtonSelected]) {
        [BroadcastApi unwatchLater:video];
    } else {
        [BroadcastApi watchLater:video];
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
    [self.shareView.bodyTextView becomeFirstResponder];
}

- (void)videoPlayerVideoDidFinish:(VideoPlayer *)videoPlayer
{
    LOG(@"[NavigationViewController videoPlayerVideoDidFinish]");

    // Fetch the video next in queue.
    Video *url = [videoTable getNextVideo];
    // Tell player to start playing new video.
    [self playVideo:url];
}

- (void)updateVideoTableCell:(Video *)video
{
    [videoTable updateVideoTableCell:video];
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
    
    [ [UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
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
    // we don't seem to be able to handle unloading / reloading from NIB
    //[super didReceiveMemoryWarning];
}

- (void)pauseCurrentVideo
{
    [_videoPlayer pause];
}

- (void)playVideo:(Video *)video
{
    LOG(@"playVideo: %@", video);
    if (video == nil) {
        return;
    }
    
    // Make videoPlayer visible. Really only does something on iPhone.
    _videoPlayer.hidden = NO;
    [_videoPlayer playVideo: video];
    
    [ [UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}


// FullscreenWebViewDelegate
- (void)fullscreenWebViewCloseWasPressed:(id)sender
{
    _fullscreenWebView.hidden = YES;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
}

- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView
{
    _fullscreenWebView.hidden = NO;
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] lowerShelbyWindow];
}

- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    _fullscreenWebView.hidden = YES;
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
}

- (void)slideSettings:(BOOL)becomingVisible
{
    // implemented in subclasses
}

- (BOOL) canBecomeFirstResponder 
{
    return YES;
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (![self isVideoPlaying]) {
                    [_videoPlayer play];
                } else {
                    [_videoPlayer pause];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self videoPlayerNextButtonWasPressed:_videoPlayer];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self videoPlayerPrevButtonWasPressed:_videoPlayer];
                break;
            default:
                NSLog(@" ######## Received remote control event subtype: %d", receivedEvent.subtype);
                break;
        }
    }
}

- (BOOL)isVideoPlaying
{
    return [_videoPlayer isVideoPlaying];
}

@end
