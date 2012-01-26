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
#import "ShareView.h"
#import "VideoGetter.h"
#import "ShelbyAppDelegate.h"
#import "ApiHelper.h"
#import "UserAccountView.h"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(screenDidConnect:)
                                                     name:UIScreenDidConnectNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(screenDidDisconnect:)
                                                     name:UIScreenDidDisconnectNotification
                                                   object:nil];

        _authorizations = [[NSSet alloc] initWithObjects:
            @"auth_twitter",
            @"auth_facebook",
            @"auth_tumblr",
            nil];
        
        _userAccountView = [UserAccountView userAccountViewFromNibWithFrame:settingsHolder.bounds withDelegate:self];
        [settingsHolder addSubview:_userAccountView];
         
        self.shareView = [ShareView shareViewFromNib];
        self.shareView.delegate = self;
        [self.shareView updateAuthorizations: [ShelbyApp sharedApp].loginHelper.user];
        self.shareView.frame = self.view.bounds;
        self.shareView.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _remoteModeView = [[RemoteModeViewController alloc] initWithNibName:@"RemoteMode_iPad" bundle:nil];
        } else {
            _remoteModeView = [[RemoteModeViewController alloc] initWithNibName:@"RemoteMode_iPhone" bundle:nil];
        }
        _remoteModeView.view.hidden = YES;
        _remoteModeView.delegate = self;
        [self.view addSubview:_remoteModeView.view];
        
        [self.view addSubview:self.shareView];
        
        [self.view addSubview:[[VideoGetter singleton] getView]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _fullscreenWebView = [[FullscreenWebViewController alloc] initWithNibName:@"FullscreenWebViewController_iPad" bundle:[NSBundle mainBundle]];
        } else {
            _fullscreenWebView = [[FullscreenWebViewController alloc] initWithNibName:@"FullscreenWebViewController_iPhone" bundle:[NSBundle mainBundle]];
        }
        [_fullscreenWebView loadView];
        [_fullscreenWebView setDelegate:self];  
        
        _fullscreenWebView.view.hidden = YES;
        [self.view addSubview:_fullscreenWebView.view];
    }
    return self;
}


#pragma mark - 

- (void)updateAuthorizations:(User *)user
{
    userTwitter.highlighted = [user.auth_twitter boolValue];
    userFacebook.highlighted = [user.auth_facebook boolValue];
    userTumblr.highlighted = [user.auth_tumblr boolValue];

    [_userAccountView updateUserAuthorizations:user];
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

- (void)enableDemoMode
{
    [_userAccountView performSelectorOnMainThread:@selector(setDemoModeButtonDisabled) withObject:nil waitUntilDone:NO];
    
    NSLog(@"########## Setting demoModeEnabled = TRUE");
    
    // hmm... do i need to store this to a user preference?
    [ShelbyApp sharedApp].demoModeEnabled = TRUE;
    
    NSLog(@"########## Pausing player");
    
    // pause any playing video
    [_videoPlayer pause];
    
    [_userAccountView setDemoModeButtonTitle:@"Waiting..."];

    NSLog(@"########## Waiting for network ops to finish");
    
    // hacky, but whatevs, it's demo mode - wait for other network activity to stop
    while ([ShelbyApp sharedApp].isNetworkBusy) {
        sleep(1);
    }
    
    NSLog(@"########## Double check that we're paused.");
    
    // double-check that we're still paused
    [_videoPlayer pause];
    
    NSLog(@"########## Switch to Timeline view.");
    
    // switch to timeline view
    [self listButtonPressed:self];
        
    NSLog(@"########## Tell videoTable to enableDemoMode.");
    
    // download videos
    [_userAccountView setDemoModeButtonTitle:@"Downloading..."];
    [videoTable enableDemoMode];
    
    [_userAccountView setDemoModeButtonTitle:@"Demo Mode On"];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Since we only have one alertview, let's be lazy and assume we have the right one.
    
    if (buttonIndex == 1) {
        [self performSelectorInBackground:@selector(enableDemoMode) withObject:nil];
    }
}

#pragma mark - User Button Methods

- (void)userAccountViewDemoMode
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo mode?" message:@"Would you like to turn demo mode on?"
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    [alert show];
    [alert release];
}

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

- (void)showLogoutAlert {

}

- (void)userAccountViewBackToVideos
{
    [self toggleSettings];
}

- (IBAction)userViewWasPressed:(id)sender
{
    [self toggleSettings];
}

#pragma mark - ShareViewDelegate Methods

- (void)shareViewClosePressed:(ShareView*)shareView
{
    self.shareView.hidden = YES;
    [_videoPlayer resumeAfterCloseShareView];
}

- (void)shareView:(ShareView *)shareView 
      sentMessage:(NSString *)message
     withNetworks:(NSArray *)networks
    andRecipients:(NSString *)recipients
{
    Video *video = [shareView getVideo];

    [BroadcastApi share:video
                comment:message
               networks:networks
              recipient:recipients];
    
    self.shareView.hidden = YES;
}

- (void)shareViewWasTouched
{
    self.touched = TRUE;
}

- (void)userAccountViewLogOut
{
    self.shareView.hidden = YES;
    if (_settingsVisible) {
        [self toggleSettings];
    }
    
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         
        NSError *error = nil;
        NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                if ([path hasPrefix:@"youtube"] || [path hasPrefix:@"vimeo"]) {
                    NSString *fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
                    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
                }
            }
        } else {
            // Error handling
        }
    }
    [[ShelbyApp sharedApp].loginHelper logout];
    [_userAccountView setDemoModeButtonTitle:@"Demo Mode"];
    [_userAccountView setDemoModeButtonEnabled];
}

- (void)showWebPage:(NSString *)urlString
{   
    if ([[UIScreen screens] count] == 1) {
        [_videoPlayer pause];
    }
    
    [_fullscreenWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                 timeoutInterval:60.0]];
    self.networkCounter = 1;
}

- (void)userAccountViewAddFacebook
{
    LOG(@"Showing %@", [NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=facebook&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]);
    [self showWebPage:[NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=facebook&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]];
}

- (void)userAccountViewAddTwitter
{
    LOG(@"Showing %@", [NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=twitter&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]);
    [self showWebPage:[NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=twitter&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]];
}

- (void)userAccountViewAddTumblr
{
    LOG(@"Showing %@", [NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=tumblr&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]);
    [self showWebPage:[NSString stringWithFormat:@"http://dev.shelby.tv/auth/add?provider=tumblr&token=%@", [ShelbyApp sharedApp].apiHelper.accessToken]];
}

- (void)userAccountViewTermsOfUse
{
    [self showWebPage:@"http://shelby.tv/tou.html"];
}

- (void)userAccountViewPrivacyPolicy
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

    self.shareView.hidden = NO;

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

- (void)videoPlayerShowRemoteView
{
    _remoteModeView.view.hidden = FALSE;
}

#pragma mark - Button Handling

- (void)hideSearchBar
{
    if (!_searchBarVisible) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = searchBar.frame;
        temp.origin.y -= temp.size.height;
        searchBar.frame = temp;
        
        temp = videoTableHolder.frame;
        temp.origin.y -= searchBar.frame.size.height;
        temp.size.height += searchBar.frame.size.height;
        videoTableHolder.frame = temp;
    }
                     completion:^(BOOL finished){
                         _searchBarVisible = NO;
                     }]; 
}

- (void)showSearchBar
{
    if (_searchBarVisible) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = searchBar.frame;
        temp.origin.y += temp.size.height;
        searchBar.frame = temp;
        
        temp = videoTableHolder.frame;
        temp.origin.y += searchBar.frame.size.height;
        temp.size.height -= searchBar.frame.size.height;
        videoTableHolder.frame = temp;
    }
                     completion:^(BOOL finished){
                         _searchBarVisible = YES;
                     }];
}

- (IBAction)listButtonPressed:(id)sender
{
    [favoritesButton setSelected:NO];
    [watchLaterButton setSelected:NO];
    [listButton setSelected:YES];
    
    [self hideSearchBar];
    
    [videoTable changeVideoMode:0];
    [_videoPlayer setVideoMode:0];
}

- (IBAction)favoritesButtonPressed:(id)sender
{
    [listButton setSelected:NO];
    [watchLaterButton setSelected:NO];
    [favoritesButton setSelected:YES];
    
    [self hideSearchBar];
    
    [videoTable changeVideoMode:1];
    [_videoPlayer setVideoMode:1];
}

- (IBAction)watchLaterButtonPressed:(id)sender
{
    [listButton setSelected:NO];
    [favoritesButton setSelected:NO];
    [watchLaterButton setSelected:YES];
    
    [self hideSearchBar];
    
    [videoTable changeVideoMode:2];
    [_videoPlayer setVideoMode:2];
}

- (IBAction)searchButtonPressed:(id)sender
{
    [listButton setSelected:NO];
    [favoritesButton setSelected:NO];
    [watchLaterButton setSelected:NO];
    
    [self showSearchBar];

    [videoTable changeVideoMode:3];
    [_videoPlayer setVideoMode:3];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == timelineTabBarItem) {
        NSLog(@"Timeline Tab Bar Item pressed");
        [self listButtonPressed:self];
    } else if (item == favoritesTabBarItem) {
        [self favoritesButtonPressed:self];
    } else if (item == watchLaterTabBarItem) {
        [self watchLaterButtonPressed:self];
    } else if (item == searchTabBarItem) {
        [self searchButtonPressed:self];
    }
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
    

    [tabBar setSelectedItem:timelineTabBarItem];
    
    // loop around subviews of UISearchBar
    for (UIView *searchBarSubview in [searchBar subviews]) {    
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {    
            @try {
                // set style of keyboard
                //[(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                
                // always force return key to be enabled
                [(UITextField *)searchBarSubview setEnablesReturnKeyAutomatically:NO];
            }
            @catch (NSException * e) {        
                // ignore exception
            }
        }
    }
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && _videoPlayer.hidden) {
        [self zoomInToVideoPlayerWithCompletionBlock:(^(void){})];
    }
    [_videoPlayer playVideo: video];
    
    [ [UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}


// FullscreenWebViewControllerDelegate
- (void)fullscreenWebViewCloseWasPressed:(id)sender
{
    _fullscreenWebView.view.hidden = YES;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
}

- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView
{
    _fullscreenWebView.view.hidden = NO;
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] lowerShelbyWindow];
}

- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    _fullscreenWebView.view.hidden = YES;
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

- (void) screenDidConnect:(NSNotification *)notification
{
    [_videoPlayer screenDidConnect];
}

- (void) screenDidDisconnect:(NSNotification *)notification
{
    [_videoPlayer screenDidDisconnect];
    _remoteModeView.view.hidden = YES;
}

#pragma mark - RemoteModeDelegate

- (void)remoteModePreviousVideo
{
    [_videoPlayer recordButtonPressOrControlsVisible:YES];
    [self videoPlayerPrevButtonWasPressed:_videoPlayer];
}

- (void)remoteModeNextVideo
{
    [_videoPlayer recordButtonPressOrControlsVisible:YES];
    [self videoPlayerNextButtonWasPressed:_videoPlayer];
}

- (void)remoteModeLikeVideo
{
    [_videoPlayer drawControls];
    [_videoPlayer recordButtonPressOrControlsVisible:YES];
    [_videoPlayer controlBarFavoriteButtonWasPressed:nil];
}

- (void)remoteModeWatchLaterVideo
{
    [_videoPlayer drawControls];
    [_videoPlayer recordButtonPressOrControlsVisible:YES];
    [_videoPlayer controlBarWatchLaterButtonWasPressed:nil];
}

- (void)remoteModeNextChannel
{
    [_videoPlayer drawControls];
    [_videoPlayer recordButtonPressOrControlsVisible:YES];

    if ([videoTable currentVideoMode] == 0) {
        [self favoritesButtonPressed:self];
    } else if ([videoTable currentVideoMode] == 1) {
        [self watchLaterButtonPressed:self];
    } else if ([videoTable currentVideoMode] == 2) {
        [self listButtonPressed:self];
    }
}

- (void)remoteModePreviousChannel
{    
    [_videoPlayer drawControls];
    [_videoPlayer recordButtonPressOrControlsVisible:YES];

    if ([videoTable currentVideoMode] == 0) {
        [self watchLaterButtonPressed:self];
    } else if ([videoTable currentVideoMode] == 1) {
        [self listButtonPressed:self];
    } else if ([videoTable currentVideoMode] == 2) {
        [self favoritesButtonPressed:self];
    }
}

- (void)remoteModeScanForward
{
    [_videoPlayer drawControls];
    [_videoPlayer recordButtonPressOrControlsVisible:YES];

    [_videoPlayer scanForward];
}

- (void)remoteModeScanBackward
{
    [_videoPlayer drawControls];
    [_videoPlayer recordButtonPressOrControlsVisible:YES];

    [_videoPlayer scanBackward];
}

- (void)remoteModeShowInfo
{
    [_videoPlayer recordButtonPressOrControlsVisible:YES];

    [_videoPlayer drawControls];
}

- (void)remoteModeHideInfo
{
    [_videoPlayer hideControlsIfNotPaused];
}

- (void)remoteModeTogglePlayPause
{
    [_videoPlayer recordButtonPressOrControlsVisible:YES];

    [_videoPlayer controlBarPlayButtonWasPressed:nil];
}

- (void)remoteModeShowSharing
{
    [self videoPlayerShareButtonWasPressed:_videoPlayer];
}

- (int)videoPlayerGetCurrentMode
{
    if (listButton.selected) {
        return 0;
    } else if (favoritesButton.selected) {
        return 1;
    } else if (watchLaterButton.selected) {
        return 2;
    }

    // otherwise we're in search
    return 3;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBarClicked
{
    [searchBar resignFirstResponder];
    [videoTable performSearch:searchBarClicked.text];
}


- (void)zoomInToVideoPlayerWithCompletionBlock:(void (^)(void))block
{
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    
    [_videoPlayer.layer setAffineTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    _videoPlayer.hidden = FALSE;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [_videoPlayer.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                     }
                     completion:^(BOOL finished){
                         dispatch_async( currentQueue, ^{
                             block();  
                         });
                     }
     ];
}

- (void)zoomOutToGuideWithCompletionBlock:(void (^)(void))block
{
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    
    [_videoPlayer.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [_videoPlayer.layer setAffineTransform:CGAffineTransformMakeScale(0.01, 0.01)];
                     }
                     completion:^(BOOL finished){
                         _videoPlayer.hidden = YES;
                         [_videoPlayer.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                         dispatch_async( currentQueue, ^{
                             block();  
                         });
                     }
     ];
}



@end
