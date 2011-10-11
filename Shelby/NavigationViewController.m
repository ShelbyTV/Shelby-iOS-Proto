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
    [BroadcastApi watch:video];
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

- (CGRect)centerFrame:(CGRect)frame inFrame:(CGRect)parent
{
    frame.origin.x = (parent.size.width / 2) - (frame.size.width / 2);
    frame.origin.y = (parent.size.height / 2) - (frame.size.height / 2);

    return frame;
}

- (CGRect)centerFrame:(CGRect)frame
{
    return [self centerFrame:frame
                     inFrame:self.view.bounds];
}

- (BOOL)keyboardIsShown 
{
    if (CGRectIsNull(_keyboardFrame)) {
        return NO;
    }
    return YES;
}

#pragma mark - Logout Functionality

- (void)showLogoutAlert {
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

#pragma mark - STVShareView Methods

- (void)centerShareViewInRect:(CGRect)parentRect withAnimationDuration:(double)duration {
    CGRect centerFrame = [self centerFrame: self.shareView.frame inFrame: parentRect];
    CGRect newFrame = CGRectNull;
    if ([self keyboardIsShown]) {
        CGRect frame = centerFrame;
        CGRect intersect = CGRectIntersection(
                _keyboardFrame,
                frame
                );
        if (!CGRectEqualToRect(intersect, CGRectNull)) {
            // Move the shareView up out of the way
            frame.origin.y = (_keyboardFrame.origin.y - frame.size.height);
        } 
        newFrame = frame;
    } else {
        newFrame = centerFrame;
    }

    if (duration == 0) {
        self.shareView.frame = newFrame;
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration: duration];

        // move the shareView
        self.shareView.frame = newFrame;

        [UIView commitAnimations];
    }
}

- (void)centerShareViewWithAnimationDuration:(double)duration {
    [self centerShareViewInRect: _videoPlayer.bounds
          withAnimationDuration: duration];
}

- (void)centerShareViewAnimated:(double)animated {
    double duration = (animated) ? 0.3 : 0.0;
    [self centerShareViewWithAnimationDuration: duration];
}

- (void)closeShareView {
    if (self.shareView) {
        [self.shareView removeFromSuperview];
        self.shareView = nil;
    }
}

#pragma mark - STVShareViewDelegate Methods

- (void)shareViewClosePressed:(STVShareView*)shareView {
    [self closeShareView];
}

//- (void)shareView:(STVShareView *)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks {
  - (void)shareView:(STVShareView *)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients {

    //Video *video = [videoTable getCurrentVideo];
    Video *video = shareView.video;

    // POST message to API
    [BroadcastApi share:video
                comment:message
               networks:networks
              recipient:recipients];
    [shareView removeFromSuperview];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Since we only have one alertview, let's be lazy and assume we have the right one.

    if (buttonIndex == 1) {
        // close the shareview, if visible
        [self closeShareView];
        // actually log out
        [[ShelbyApp sharedApp].loginHelper logout];
    }
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
    if ([videoPlayer isFavoriteButtonSelected]) {
        [BroadcastApi dislike:video];
    } else {
        [BroadcastApi like:video];
    }
}

- (void)videoPlayerShareButtonWasPressed:(VideoPlayer *)videoPlayer {
    if (!self.shareView) {
        // show share UI
        STVShareView *shareView = [STVShareView viewFromNib];
        shareView.delegate = self;

        // Set up the shareView with the video info.
        Video *video = [videoTable getCurrentVideo];
        shareView.video = video;

        [shareView updateAuthorizations: [ShelbyApp sharedApp].loginHelper.user];

        shareView.frame = [self centerFrame: shareView.frame inFrame: _videoPlayer.bounds];

        //[self.view addSubview: shareView];
        [_videoPlayer addSubview: shareView];

        self.shareView = shareView;

        // Use this to reveal the keyboard.
        [shareView.socialTextView becomeFirstResponder];
    }
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
    //keyboardIsShown = NO;
    _keyboardFrame = CGRectNull;
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
    [videoTable clearVideoTableData];
}

#pragma mark - Keyboard Handlers

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    double animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    // get the size of the keyboard
    //NSValue* endValue   = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
    //NSValue* beginValue = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];

    //CGRect endRect      = [endValue CGRectValue];
    //CGRect beginRect    = [beginValue CGRectValue];

    //CGRect convertedRect = [self.view convertRect: endRect fromView: nil];
    //CGSize keyboardSize = convertedRect.size;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration: animationDuration];

    // move the shareView
    self.shareView.frame = [self centerFrame: self.shareView.frame inFrame: _videoPlayer.bounds];

    [UIView commitAnimations];

    //keyboardIsShown = NO;
    _keyboardFrame = CGRectNull;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if ([self keyboardIsShown]) {
        return;
    }

    NSDictionary* userInfo = [n userInfo];

    //double animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    // get the size of the keyboard
    NSValue* endValue   = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
    //NSValue* beginValue = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];

    CGRect endRect      = [endValue CGRectValue];
    //CGRect beginRect    = [beginValue CGRectValue];

    CGRect convertedRect = [self.view convertRect: endRect fromView: nil];
    _keyboardFrame = convertedRect;
    //keyboardIsShown = YES;
    [self centerShareViewAnimated: YES];
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

#pragma mark - Layout

//- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [super willAnimateFirstHalfOfRotationToInterfaceOrientation: toInterfaceOrientation duration: duration];
//}
//
//- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    [super didAnimateFirstHalfOfRotationToInterfaceOrientation: toInterfaceOrientation];
//    
//}
//
//- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
//    [super willAnimateSecondHalfOfRotationFromInterfaceOrientation: fromInterfaceOrientation duration: duration];
//    
//    // Center in the NEW frame.
//    CGRect rotatedFrame = [self.view.window convertRect: self.view.bounds toView: nil];
//    [self centerShareViewInRect: rotatedFrame
//          withAnimationDuration: 0.0];
//}


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
