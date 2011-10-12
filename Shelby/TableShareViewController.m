#import "TableShareViewController.h"

#import "Video.h"
#import "User.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableShareViewController

@synthesize delegate;
@synthesize video = _video;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

#pragma mark - Switches

#pragma mark - Buttons

- (IBAction)cancelWasPressed:(id)sender {
  //[self dismissModalViewControllerAnimated: YES];
	if (self.delegate) {
		[self.delegate tableShareViewClosePressed: self];
	}
}

- (IBAction)doneWasPressed:(id)sender {
	if (self.delegate) {
		// Grab the social networks

		NSMutableArray *networks = [NSMutableArray array];
		//for (UISwitch *switchy in _switches) {
		for (TTTableControlItem *item in _switches) {
			NSString *caption = item.caption;
			[networks addObject: [caption lowercaseString]];
			//NSInteger tag = switchy.tag;
			//if (tag == 1) {
			//	[networks addObject: @"twitter"];
			//} else if (tag == 2) {
			//	[networks addObject: @"facebook"];
			//}
		}

		// Grab the text
		NSString *message = _editor.text;

		[self.delegate tableShareView: self 
											sentMessage: message
										 withNetworks: networks 
										andRecipients: nil
		];
		//[BroadcastApi share: self.video
		//						comment: message
		//					 networks: networks
		//					recipient: nil];

	}
	//[self dismissModalViewControllerAnimated: YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel 
                                                                                  target: self
                                                                                  action: @selector(cancelWasPressed:)
                                                                                  ];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                                  target: self
                                                                                  action: @selector(doneWasPressed:)
                                                                                  ];

    self.navigationItem.leftBarButtonItem  = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    
		self.navigationItem.title = @"Share";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.tableViewStyle = UITableViewStyleGrouped;
    self.autoresizesForKeyboard = YES;
    self.variableHeightRows = YES;

    _editor = [[TTTextEditor alloc] init];
    _editor.font = TTSTYLEVAR(font);
    _editor.backgroundColor = TTSTYLEVAR(backgroundColor);
    _editor.autoresizesToText = NO;
    _editor.minNumberOfLines = 3;
    //editor.placeholder = @"TTTextEditor";

		_switches = [[NSMutableArray alloc] init];

    //self.dataSource = [TTListDataSource dataSourceWithObjects:
    //  //textField,
    //  //textView,
    //  //textFieldItem,
    //  //sliderItem,
    //  editor,
    //  switchItem,
    //  facebookSwitch,
    //  nil];
  }
  return self;
}

#pragma mark - Setters / Getters

- (void)setVideo:(Video *)video {
		[_video release];
		_video = [video retain];
		_editor.text = [NSString stringWithFormat: @"great video via %@: %@", video.sharer, video.shortPermalink];
}

#pragma mark - 

- (void)updateAuthorizations:(User *)user {
		NSMutableArray *captions = [NSMutableArray array];
    // Set twitter view visible
    if ([user.auth_twitter boolValue]) {
			[captions addObject: @"Twitter"];
    }
    if ([user.auth_facebook boolValue]) {
			[captions addObject: @"Facebook"];
    }

		NSMutableArray *items = [NSMutableArray array];

		[items addObject: _editor];

		for (NSString *caption in captions) {
			UISwitch* switchy = [[[UISwitch alloc] init] autorelease];
			switchy.on = YES;

			//if ([caption isEqualToString: @"Twitter"]) {
			//	switchy.tag = 1;
			//} else if ([caption isEqualToString: @"Facebook"]) {
			//	switchy.tag = 2;
			//} else {
			//}

			TTTableControlItem* toggleItem = [TTTableControlItem itemWithCaption:caption control:switchy];
			[items addObject: toggleItem];

			[_switches addObject: toggleItem];
		}
    self.dataSource = [TTListDataSource dataSourceWithItems: items];
}

#pragma mark - Cleanup

- (void) dealloc
{
	[_switches release];
	[_video release];
	[super dealloc];
}

@end
