
#import "SearchTestController.h"
#import "MockDataSource.h"
#import "ContactDataSource.h"

@implementation SearchTestController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _delegate = nil;

    self.title = @"Contact Search";
    self.dataSource = [[[ContactDataSource alloc] init] autorelease];
  }
  return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  TTTableViewController* searchController = [[[TTTableViewController alloc] init] autorelease];
  searchController.dataSource = [[[ContactSearchDataSource alloc] initWithDuration:1.5] autorelease];
  self.searchViewController = searchController;
  self.tableView.tableHeaderView = _searchController.searchBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  [_delegate searchTestController:self didSelectObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchTextFieldDelegate

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
  [_delegate searchTestController:self didSelectObject:object];
}

@end
