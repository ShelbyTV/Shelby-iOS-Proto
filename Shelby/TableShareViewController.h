#import <Three20/Three20.h>

@class Video;
@class User;
@class TableShareViewController;

@protocol TableShareViewDelegate 

- (void)tableShareViewClosePressed:(TableShareViewController*)shareView;
- (void)tableShareView:(TableShareViewController*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients;

@end

@interface TableShareViewController : TTTableViewController {
  Video *_video;
  TTTextEditor *_editor;
  NSArray *_switches;
}

@property (nonatomic, assign) id <TableShareViewDelegate> delegate;
@property (nonatomic, retain) Video *video;

- (void)updateAuthorizations:(User *)user;

@end
