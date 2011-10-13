#import <Three20UI/Three20UI.h>

@protocol SearchContactControllerDelegate;
@class MockDataSource;

@interface SearchContactController : TTTableViewController <TTSearchTextFieldDelegate> {
  id<SearchContactControllerDelegate> _delegate;
}

@property(nonatomic,assign) id<SearchContactControllerDelegate> delegate;

@end

@protocol SearchContactControllerDelegate <NSObject>

- (void)searchTestController:(SearchContactController*)controller didSelectObject:(id)object;

@end
