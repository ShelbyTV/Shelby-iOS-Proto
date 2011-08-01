//
//  NavigationViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NavigationViewController.h"
#import "VideoTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation NavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        videoTable = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain
                                                      callbackObject:self callbackSelector:@selector(playContentURL:)];
    }
    return self;
}

- (void)playContentURL:(NSURL *)url
{
    if (url == nil) {
        return;
    }
    
    /*
     * This is pretty ghetto, but it's a quick way to display a video. Eventually this should load the contentURL into
     * the custom Shelby movie view, etc. Not sure if moviePlayer will get properly cleaned up when user hits "Done" -- 
     * definitely bad that it randomly disappears on user hitting minimize.
     *
     * Plus, because of ways views are currently set up, MoviePlayer doesn't autorotate properly.
     *
     * And, finally, if the iPad/iPhone differences get more complicated (almost guaranteed), should definitely
     * put this method implementation in the device-specific subclasses.
     */
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [videoHolder addSubview:[moviePlayer view]];
    [videoHolder setHidden:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [moviePlayer setFullscreen:YES];
    } else {
        moviePlayer.view.frame = videoHolder.bounds;
    }
}

- (void)loadUserData
{
    [videoTable loadVideos];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundStripes" ofType:@"png"]]]];
    [header setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ForegroundStripes" ofType:@"png"]]]];

    videoTable.tableView.frame = videoTableHolder.bounds;
    [videoTable.tableView setBackgroundColor:[UIColor darkGrayColor]];
    [videoTableHolder addSubview:[videoTable tableView]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
