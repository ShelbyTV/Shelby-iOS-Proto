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
#import "STVShareView.h"

#define kKeyboardAnimationDuration 1.0

@implementation NavigationViewController

@synthesize shareView = _shareView;

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
    }
    return self;
}

- (void)playVideo:(Video *)video
{
    LOG(@"playVideo: %@", video);
    if (video == nil) {
        return;
    }
    // Cue it up
    [_videoPlayer playVideo: video];
    // Notify the api it's been watched
    [BroadcastApi watch:video.shelbyId];
    // Mark it as watched locally
    //video.watched = YES;
}

- (void)updateAuthorizations:(User *)user
{
    if ([user.auth_twitter boolValue]) {
        // Set twitter view visible
        LOG(@"Authed into twitter!");
        userTwitter.highlighted = YES;
    } else {
        // Set twitter view invisible
        LOG(@"No go twitter!");
        userTwitter.highlighted = NO;
    }

    if ([user.auth_facebook boolValue]) {
        // Set facebook view visible
        LOG(@"Authed into facebook!");
        userFacebook.highlighted = YES;
    } else {
        // Set facebook view invisible
        LOG(@"No go facebook!");
        userFacebook.highlighted = NO;
    }

    if ([user.auth_tumblr boolValue]) {
        // Set tumblr view visible
        LOG(@"Authed into tumblr!");
        userTumblr.highlighted = YES;
    } else {
        // Set facebook view invisible
        LOG(@"No go tumblr!");
        userTumblr.highlighted = NO;
    }
}

- (void)loadUserData
{
    User *user = [ShelbyApp sharedApp].loginHelper.user;

    for (NSString *auth in _authorizations) {
        //[user removeObserver:self forKeyPath:auth];
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

#pragma mark - Layout

- (CGRect)centerFrame:(CGRect)frame
{
    frame.origin.x = (self.view.bounds.size.width / 2) - (frame.size.width / 2);
    frame.origin.y = (self.view.bounds.size.height / 2) - (frame.size.height / 2);

    //frame.origin.y = 0;
    return frame;
}

#pragma mark - Logout Functionality

- (void)showLogoutAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log out?" message:@"Would you like to log out?"
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    [alert show];
    [alert release];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Since we only have one alertview, let's be lazy and assume we have the right one.

    if (buttonIndex == 1) {
        [[ShelbyApp sharedApp].loginHelper logout];
    }
}

#pragma mark - STVShareViewDelegate Methods

- (void)shareViewClosePressed:(STVShareView*)shareView {
    [shareView removeFromSuperview];
    self.shareView = nil;
}

//- (void)shareView:(STVShareView *)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks {
  - (void)shareView:(STVShareView *)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients {

    //Video *video = [videoTable getCurrentVideo];
    Video *video = shareView.video;
    // get ID from the video
    NSString *videoId = video.shelbyId;

    // POST message to API
    [BroadcastApi share:videoId
                comment:message
               networks:networks
              recipient:recipients];
    [shareView removeFromSuperview];
}

#pragma mark - User Button Methods

- (IBAction)userViewWasPressed:(id)sender
{
    // Override in subclass.
}

#pragma mark - VideoTableViewControllerDelegate Methods

- (void)videoTableViewControllerFinishedRefresh:(VideoTableViewController *)controller {
    // Override in subclass.
    // TODO: Convert to optional method in protocol using respondsToSelector:
}

#pragma mark - VideoPlayerDelegate Methods

- (void)videoPlayerPlayButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerPlayButtonWasPressed]");

}

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerFullscreenButtonWasPressed]");

}

- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerNextButtonWasPressed]");
    // Tell player to pause playing.
    [_videoPlayer pause];
    // Fetch the video next in queue.
    Video *video = [videoTable getNextVideo];

    // Tell player to start playing new video.
    [_videoPlayer playVideo: video];

}

- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerPrevButtonWasPressed]");
    // Tell player to pause playing.
    [_videoPlayer pause];
    // Fetch the video next in queue.
    Video *video = [videoTable getPreviousVideo];
    // Tell player to start playing new video.
    [_videoPlayer playVideo: video];
}

- (void)videoPlayerLikeButtonWasPressed:(VideoPlayer *)videoPlayer {

    Video *video = [videoTable getCurrentVideo];

    // get ID from the video
    NSString *videoId = video.shelbyId;

    // PUT our like to the API
    [BroadcastApi like:videoId];
}

- (void)videoPlayerShareButtonWasPressed:(VideoPlayer *)videoPlayer {

    // show share UI
    //[[ShelbyApp sharedApp].networkManager likeVideoWithId: videoId];

    // Show an action sheet for now.
    //UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Facebook" otherButtonTitles:@"Twitter", @"Tumblr", nil];
    //popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    //[popupQuery showInView: self.view];
    //[popupQuery release];

    //ShareViewController *controller = [ShareViewController viewController];
    //[self presentModalViewController: controller
    //                        animated: YES];

    STVShareView *shareView = [STVShareView viewFromNib];
    shareView.delegate = self;

    // Set up the shareView with the video info.
    Video *video = [videoTable getCurrentVideo];
    shareView.video = video;

    [shareView updateAuthorizations: [ShelbyApp sharedApp].loginHelper.user];

    //CGRect frame = shareView.frame;
    //frame.origin.x = (self.view.bounds.size.width / 2) - (shareView.bounds.size.width / 2);
    //frame.origin.y = (self.view.bounds.size.height / 2) - (shareView.bounds.size.height / 2);
    shareView.frame = [self centerFrame: shareView.frame];
    [self.view addSubview: shareView];

    self.shareView = shareView;
}

- (void)videoPlayerVideoDidFinish:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerVideoDidFinish]");

    // Fetch the video next in queue.
    Video *url = [videoTable getNextVideo];
    // Tell player to start playing new video.
    [_videoPlayer playVideo: url];
}

#pragma mark - Touch Handling

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    LOG(@"NavigationViewController handleSingleTap: %@", recognizer);
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];

    //Do stuff here...
}

- (IBAction)listButtonPressed:(id)sender
{
    [favoritesButton setSelected:NO];
    [listButton setSelected:YES];
    [videoTable changeVideoMode:0];
}

- (IBAction)favoritesButtonPressed:(id)sender
{
    [listButton setSelected:NO];
    [favoritesButton setSelected:YES];
    [videoTable changeVideoMode:1];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    _networkActivityViewParent = activityHolder;

    //DEBUG ONLY
    //UITapGestureRecognizer *singleFingerTap =
    //    [[UITapGestureRecognizer alloc] initWithTarget:self
    //                                            action:@selector(handleSingleTap:)];
    //[_videoPlayer.moviePlayer.view addGestureRecognizer:singleFingerTap];

    //VideoTable.
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

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    keyboardIsShown = NO;
}


#pragma mark - Notification Handlers

- (void)likeVideoFailed:(NSNotification *)notification {
    // open an alert to inform the user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Like Error" message:@"Couldn't Like the video. Try again soon."
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
    [videoTable clearVideos];
}

#pragma mark Keyboard Handlers

- (void)keyboardWillHide:(NSNotification *)n
{
    //NSDictionary* userInfo = [n userInfo];

    // get the size of the keyboard
    //NSValue* endValue   = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
    //NSValue* beginValue = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];

    //CGRect endRect      = [endValue CGRectValue];
    //CGRect beginRect    = [beginValue CGRectValue];

    //CGRect convertedRect = [self.view convertRect: endRect fromView: nil];
    //CGSize keyboardSize = convertedRect.size;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];

    // move the shareView
    self.shareView.frame = [self centerFrame: self.shareView.frame];

    [UIView commitAnimations];

    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }

    NSDictionary* userInfo = [n userInfo];

    // get the size of the keyboard
    NSValue* endValue   = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
    //NSValue* beginValue = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];

    CGRect endRect      = [endValue CGRectValue];
    //CGRect beginRect    = [beginValue CGRectValue];

    CGRect convertedRect = [self.view convertRect: endRect fromView: nil];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kKeyboardAnimationDuration];

    if (self.shareView) {
        CGRect frame = self.shareView.frame;
        CGRect intersect = CGRectIntersection(
                convertedRect,
                frame
        );
        if (!CGRectEqualToRect(intersect, CGRectNull)) {
            // Move the shareView up out of the way
            //frame.origin.y -= intersect.size.height;
            frame.origin.y = (convertedRect.origin.y - frame.size.height);
            self.shareView.frame = frame;
        } else {

        }
    }
    [UIView commitAnimations];

    keyboardIsShown = YES;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    //if ([object isKindOfClass: [NSManagedObject class] && [_authorizations containsObject: keyPath]) {
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
//    for (NSString *auth in _authorizations) {
//        [user removeObserver:self forKeyPath:auth];
//    }

    [_videoPlayer release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

@end
