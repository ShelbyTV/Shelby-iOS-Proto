//
//  COPeoplePickerViewController.m
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//
//  Modified by Mark Johnson on Dec. 2, 2011.
//  Granted permission by Erik Aigner by email to "feel free to use it anywhere you want (credit somewhere would be appreciated, but not required)."
//

#import "COPeoplePickerViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <objc/runtime.h>


#pragma mark - COToken

@class COTokenField;

@interface COToken : UIButton
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id associatedObject;
@property (nonatomic, strong) COTokenField *container;

+ (COToken *)tokenWithTitle:(NSString *)title associatedObject:(id)obj container:(COTokenField *)container;

@end

#pragma mark - COEmailTableCell

@interface COEmailTableCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *emailLabelLabel;
@property (nonatomic, strong) UILabel *emailAddressLabel;

- (void)adjustLabels;

@end

#pragma mark - COTokenField Interface & Delegate Protocol

@protocol COTokenFieldDelegate <NSObject>
@required

- (void)numberOfEmailTokensChanged;
- (ABAddressBookRef)addressBookForTokenField:(COTokenField *)tokenField;
- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults:(NSArray *)records;

@end

#define kTokenFieldFontSize 14.0
#define kTokenFieldPaddingX 6.0
#define kTokenFieldPaddingY 4.0 // 6.0
#define kTokenFieldTokenHeight (kTokenFieldFontSize + 8.0)
#define kTokenFieldMaxTokenWidth 260.0
#define kTokenFieldFrameKeyPath @"frame"
#define kTokenFieldShadowHeight 14.0

@interface COTokenField : UIView <UITextFieldDelegate>
@property (nonatomic, strong) id<COTokenFieldDelegate> tokenFieldDelegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) COToken *selectedToken;
@property (nonatomic, readonly) CGFloat computedRowHeight;
@property (nonatomic, readonly) NSString *textWithoutDetector;

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows;
- (void)selectToken:(COToken *)token;
- (void)modifyToken:(COToken *)token;
- (void)modifySelectedToken;
- (void)processToken:(NSString *)tokenText;
- (void)tokenInputChanged:(id)sender;
- (void)clear;

@end

#pragma mark - Data Structures

@interface CORecord : NSObject {
    @package
    ABRecordRef record_;
}
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *namePrefix;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *middleName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *nameSuffix;
@property (nonatomic, readonly) NSArray *emailAddresses;
@end

@interface CORecordEmail : NSObject {
    @package
    ABMultiValueRef         emails_;
    ABMultiValueIdentifier  identifier_;
}
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *address;
@end

#pragma mark - COPeoplePickerViewController

@interface COPeoplePickerViewController () <UITableViewDelegate, UITableViewDataSource, COTokenFieldDelegate> {
    @package
    ABAddressBookRef addressBook_;
    CGRect           keyboardFrame_;
}
@property (nonatomic, strong) COTokenField *tokenField;
@property (nonatomic, strong) UIScrollView *tokenFieldScrollView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSArray *discreteSearchResults;
@end

@implementation COPeoplePickerViewController
@synthesize tokenField = tokenField_;
@synthesize tokenFieldScrollView = tokenFieldScrollView_;
@synthesize searchTableView = searchTableView_;
@synthesize discreteSearchResults = discreteSearchResults_;
@synthesize tableViewHolder;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {

        NSLog(@"init with frame height: %f", frame.size.height);
        
        self.view = [[UIView alloc] initWithFrame:frame];
        [self viewDidLoad];
        
        // DEVNOTE: A workaround to force initialization of ABPropertyIDs.
        // If we don't create the address book here and try to set |displayedProperties| first
        // all ABPropertyIDs will default to '0'.
        //
        // TODO: file RDAR
        //
        addressBook_ = ABAddressBookCreate();
    }
    return self;
}

- (void)dealloc {
    if (addressBook_ != NULL) {
        CFRelease(addressBook_);
        addressBook_ = NULL;
    }
}

- (void)viewDidLoad {  
    // Configure content view
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.859 green:0.886 blue:0.925 alpha:1.0];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Configure token field
    CGRect viewBounds = self.view.bounds;
    CGRect tokenFieldFrame = viewBounds;
    
    NSLog(@"init tokenField with frame height: %f", tokenFieldFrame.size.height);
    
    self.tokenField = [[COTokenField alloc] initWithFrame:tokenFieldFrame];
    self.tokenField.tokenFieldDelegate = self;
    self.tokenField.textField.textColor = [UIColor whiteColor];
    self.tokenField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.tokenField addObserver:self forKeyPath:kTokenFieldFrameKeyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    // Configure search table
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                         CGRectGetMaxY(self.tokenField.bounds),
                                                                         CGRectGetWidth(viewBounds),
                                                                         CGRectGetHeight(viewBounds) - CGRectGetHeight(tokenFieldFrame))
                                                        style:UITableViewStylePlain];
    self.searchTableView.opaque = YES;
    self.searchTableView.backgroundColor = [UIColor whiteColor];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    self.searchTableView.hidden = YES;
    self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.searchTableView.userInteractionEnabled = YES;
    
    // Create the scroll view
    self.tokenFieldScrollView = [[UIScrollView alloc] initWithFrame:viewBounds];
    self.tokenFieldScrollView.backgroundColor = [UIColor clearColor]; // [UIColor blueColor];
    self.tokenFieldScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tokenFieldScrollView];
    [self.tokenFieldScrollView addSubview:self.tokenField];
    
    // Subscribe to keyboard notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)layoutTokenFieldAndSearchTable 
{
    CGRect bounds = self.view.bounds;
    CGRect tokenFieldBounds = self.tokenField.bounds;
    CGRect tokenScrollBounds = tokenFieldBounds;
    
    self.tokenFieldScrollView.contentSize = tokenFieldBounds.size;
    
    tokenScrollBounds = CGRectMake(0, 0, CGRectGetWidth(bounds), [self.tokenField heightForNumberOfRows:1]);
    
    CGFloat contentOffset = MAX(0, CGRectGetHeight(tokenFieldBounds) - CGRectGetHeight(self.tokenFieldScrollView.bounds));
    [self.tokenFieldScrollView setContentOffset:CGPointMake(0, contentOffset) animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kTokenFieldFrameKeyPath]) {
        [self layoutTokenFieldAndSearchTable];
    }
}

- (void)numberOfEmailTokensChanged
{
    if (self.delegate) {
        [self.delegate numberOfEmailTokensChanged];
    }
}

- (int)tokenCount {
    return [self.tokenField.tokens count];
}

- (NSString *)concatenatedEmailAddresses
{
    NSString *cat = @"";
    BOOL firstToken = TRUE;
    
    for (COToken *token in self.tokenField.tokens) {
        if (firstToken) {
            cat = token.title;
            firstToken = FALSE;
        } else {
            cat = [NSString stringWithFormat:@"%@,%@", cat, token.title];
        }
    }
    
    return cat;
}

- (void)resignFirstResponders
{
    [self.tokenField.textField resignFirstResponder];
}

- (void)clearTokenField
{
    [self.tokenField clear];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tokenField removeObserver:self forKeyPath:kTokenFieldFrameKeyPath];
}

- (void)keyboardDidShow:(NSNotification *)note {
    keyboardFrame_ = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self layoutTokenFieldAndSearchTable];
}

#pragma mark - COTokenFieldDelegate 

- (ABAddressBookRef)addressBookForTokenField:(COTokenField *)tokenField {
    return addressBook_;
}

static NSString *kCORecordFullName = @"fullName";
static NSString *kCORecordEmailLabel = @"emailLabel";
static NSString *kCORecordEmailAddress = @"emailAddress";

- (void)tokenField:(COTokenField *)tokenField updateAddressBookSearchResults:(NSArray *)records {
    //  NSLog(@"matches:");
    //  for (CORecord *record in records) {
    //    NSLog(@"\t%@:", record.fullName);
    //    for (CORecordEmail *email in record.emailAddresses) {
    //      NSLog(@"\t\t-> %@: %@", email.label, email.address);
    //    }
    //  }
    
    // Split the search results into one email value per row
    NSMutableArray *results = [NSMutableArray new];
//#if TARGET_IPHONE_SIMULATOR
//    for (int i=0; i<4; i++) {
//        NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
//                               [NSString stringWithFormat:@"Name %i", i], kCORecordFullName,
//                               [NSString stringWithFormat:@"label%i", i], kCORecordEmailLabel,
//                               [NSString stringWithFormat:@"fake%i@address.com", i], kCORecordEmailAddress,
//                               nil];
//        [results addObject:entry];
//    }
//#else
    for (CORecord *record in records) {
        for (CORecordEmail *email in record.emailAddresses) {
            NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [record.fullName length] == 0 ? email.address : record.fullName , kCORecordFullName,
                                   email.label, kCORecordEmailLabel,
                                   email.address, kCORecordEmailAddress,
                                   nil];
            if (![results containsObject:entry]) {
                [results addObject:entry];
            }
        }
    }
//#endif
    self.discreteSearchResults = [NSArray arrayWithArray:results];
    
    // Update the table
    [self.searchTableView reloadData];
    
    if (self.searchTableView.superview == nil) {
        self.searchTableView.frame = self.tableViewHolder.bounds;
        [self.tableViewHolder addSubview:self.searchTableView];
    }
    
    if (self.discreteSearchResults.count > 0) {
        self.tableViewHolder.hidden = NO;
        self.searchTableView.hidden = NO;  
    }
    else {
        self.tableViewHolder.hidden = YES;
        self.searchTableView.hidden = YES;
    }
    [self layoutTokenFieldAndSearchTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.discreteSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *result = [self.discreteSearchResults objectAtIndex:indexPath.row];
    
    static NSString *ridf = @"resultCell";
    COEmailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ridf];
    if (cell == nil) {
        cell = [[COEmailTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ridf];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.nameLabel.text = [result objectForKey:kCORecordFullName];
    cell.emailLabelLabel.text = [result objectForKey:kCORecordEmailLabel];
    cell.emailAddressLabel.text = [result objectForKey:kCORecordEmailAddress];
    
    [cell adjustLabels];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    COEmailTableCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    [self.tokenField processToken:cell.emailAddressLabel.text];
}

@end

#pragma mark - COTokenField Implementation

// XXX token memory leaked? needs dealloc.

@implementation COTokenField
@synthesize tokenFieldDelegate = tokenFieldDelegate_;
@synthesize textField = textField_;
@synthesize tokens = tokens_;
@synthesize selectedToken = selectedToken_;

static NSString *kCOTokenFieldDetectorString = @"\u200B";

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tokens = [NSMutableArray new];
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor]; // [UIColor greenColor];

        // Setup text field
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kTokenFieldPaddingX,
                                                                       //(CGRectGetHeight(self.bounds) - textFieldHeight) / 2.0,
                                                                       kTokenFieldPaddingY,
                                                                       CGRectGetWidth(self.bounds) - kTokenFieldPaddingX * 3.0,
                                                                       22)]; // XXX hack for now
        
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.opaque = YES;
        self.textField.backgroundColor = [UIColor clearColor]; //[UIColor redColor];
        self.textField.font = [UIFont systemFontOfSize:kTokenFieldFontSize];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.text = kCOTokenFieldDetectorString;
        self.textField.delegate = self;
        
        [self.textField addTarget:self action:@selector(tokenInputChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [self addSubview:self.textField];
                
        [self setNeedsLayout];
    }
    return self;
}

- (void)clear
{
    while ([self.tokens count] > 0) {
        
        COToken *token = [self.tokens objectAtIndex:0];
        
        [self selectToken:token];
        [self modifyToken:token];
    }
}

- (CGFloat)computedRowHeight
{
    return kTokenFieldPaddingY * 2.0 + kTokenFieldTokenHeight;
}

- (CGFloat)heightForNumberOfRows:(NSUInteger)rows {
    return (CGFloat)rows * self.computedRowHeight + kTokenFieldPaddingY * 2.0;
}

- (void)layoutSubviews {
    NSUInteger row = 0;
    NSInteger tokenCount = self.tokens.count;
    
    CGFloat left = kTokenFieldPaddingX;
    CGFloat maxLeft = CGRectGetWidth(self.bounds) - kTokenFieldPaddingX;
    CGFloat rowHeight = self.computedRowHeight;
    
    for (NSInteger i=0; i<tokenCount; i++) {
        COToken *token = [self.tokens objectAtIndex:i];
        CGFloat right = left + CGRectGetWidth(token.bounds);
        if (right > maxLeft) {
            row++;
            left = kTokenFieldPaddingX;
        }
        
        // Adjust token frame
        CGRect tokenFrame = token.frame;
        tokenFrame.origin = CGPointMake(left, (CGFloat)row * rowHeight + (rowHeight - CGRectGetHeight(tokenFrame)) / 2.0 + kTokenFieldPaddingY);
        token.frame = tokenFrame;
        
        left += CGRectGetWidth(tokenFrame) + kTokenFieldPaddingX;
        
        [self addSubview:token];
    }
    
    CGFloat maxLeftWithButton = maxLeft - kTokenFieldPaddingX; // - CGRectGetWidth(self.addContactButton.frame);
    if (maxLeftWithButton - left < 50) {
        row++;
        left = kTokenFieldPaddingX;
    }
    
    CGRect textFieldFrame = self.textField.frame;
    textFieldFrame.origin = CGPointMake(left, (CGFloat)row * rowHeight + (rowHeight - CGRectGetHeight(textFieldFrame)) / 2.0 + kTokenFieldPaddingY);
    textFieldFrame.size = CGSizeMake(maxLeftWithButton - left, CGRectGetHeight(textFieldFrame));
    self.textField.frame = textFieldFrame;
    
    CGRect tokenFieldFrame = self.frame;
    CGFloat minHeight = MAX(rowHeight + kTokenFieldPaddingY, 24 + kTokenFieldPaddingY * 2.0);
    tokenFieldFrame.size.height = MAX(minHeight, CGRectGetMaxY(textFieldFrame) + kTokenFieldPaddingY);
    
    self.frame = tokenFieldFrame;
    NSLog(@"frame height: %f", self.frame.size.height);
}

- (void)selectToken:(COToken *)token {
    @synchronized (self) {
        if (token != nil) {
            self.textField.hidden = YES;
        }
        else {
            self.textField.hidden = NO;
            [self.textField becomeFirstResponder];
        }
        self.selectedToken = token;
        for (COToken *t in self.tokens) {
            t.highlighted = (t == token);
            [t setNeedsDisplay];
        }
    }
}

- (void)modifyToken:(COToken *)token {
    if (token != nil) {
        if (token == self.selectedToken) {
            [token removeFromSuperview];
            [self.tokens removeObject:token];
            if (self.tokenFieldDelegate) {
                [self.tokenFieldDelegate numberOfEmailTokensChanged];
            }
            self.textField.hidden = NO;
            self.selectedToken = nil;
        }
        else {
            [self selectToken:token];
        }
        [self setNeedsLayout];
    }
}

- (void)modifySelectedToken {
    COToken *token = self.selectedToken;
    if (token == nil) {
        token = [self.tokens lastObject];
    }
    [self modifyToken:token];
}

- (void)processToken:(NSString *)tokenText {
    COToken *token = [COToken tokenWithTitle:tokenText associatedObject:tokenText container:self];
    [token addTarget:self action:@selector(selectToken:) forControlEvents:UIControlEventTouchUpInside];
    [self.tokens addObject:token];
    if (self.tokenFieldDelegate) {
        [self.tokenFieldDelegate numberOfEmailTokensChanged];
    }
    self.textField.text = kCOTokenFieldDetectorString;
    [self setNeedsLayout];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self selectToken:nil];
}

- (NSString *)textWithoutDetector {
    NSString *text = self.textField.text;
    if (text.length > 0) {
        return [text substringFromIndex:1];
    }
    return text;
}

static BOOL containsString(NSString *haystack, NSString *needle) {
    return ([haystack rangeOfString:needle options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound);
}

- (void)tokenInputChanged:(id)sender
{
    NSString *searchText = self.textWithoutDetector;
    NSArray *matchedRecords = [NSArray array];
    if ([searchText length] != 0) {
        static NSMutableArray *records = nil;
        ABAddressBookRef ab = [self.tokenFieldDelegate addressBookForTokenField:self];
        NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(ab));
        records = [NSMutableArray new];
        for (id obj in people) {
            ABRecordRef recordRef = (__bridge CFTypeRef)obj;
            CORecord *record = [CORecord new];
            record->record_ = CFRetain(recordRef);
            [records addObject:record];
        }
            
        NSIndexSet *resultSet = [records indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            CORecord *record = (CORecord *)obj;
            if ([record.fullName length] != 0 && containsString(record.fullName, searchText)) {
                return YES;
            }
            for (CORecordEmail *email in record.emailAddresses) {
                if (containsString(email.address, searchText)) {
                    return YES;
                }
            }
            return NO;
        }];
        
        // Generate results to pass to the delegate
        matchedRecords = [records objectsAtIndexes:resultSet];
    }
    [self.tokenFieldDelegate tokenField:self updateAddressBookSearchResults:matchedRecords];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{    
    if (string.length == 0 && [textField.text isEqualToString:kCOTokenFieldDetectorString]) {
        [self modifySelectedToken];
        return NO;
    }
    else if (textField.hidden) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.hidden) {
        return NO;
    }
    NSString *text = self.textField.text;
    if ([text length] > 1) {
        [self processToken:[text substringFromIndex:1]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.hidden) {
        return NO;
    }
    NSString *text = self.textField.text;
    if ([text length] > 1) {
        [self processToken:[text substringFromIndex:1]];
    }
    return YES;
}

@end

#pragma mark - COToken

@implementation COToken
@synthesize title = title_;
@synthesize associatedObject = associatedObject_;
@synthesize container = container_;

+ (COToken *)tokenWithTitle:(NSString *)title associatedObject:(id)obj container:(COTokenField *)container {
    COToken *token = [self buttonWithType:UIButtonTypeCustom];
    token.associatedObject = obj;
    token.container = container;
    token.backgroundColor = [UIColor clearColor];
    
    UIFont *font = [UIFont systemFontOfSize:kTokenFieldFontSize];
    CGSize tokenSize = [title sizeWithFont:font];
    tokenSize.width = MIN(kTokenFieldMaxTokenWidth, tokenSize.width);
    tokenSize.width += kTokenFieldPaddingX * 2.0;
    
    tokenSize.height = MIN(kTokenFieldFontSize, tokenSize.height);
    tokenSize.height += kTokenFieldPaddingY * 2.0;
    
    token.frame = (CGRect){CGPointZero, tokenSize};
    token.titleLabel.font = font;
    token.title = title;
    
    return token;
}

- (void)drawRect:(CGRect)rect {
    CGFloat radius = CGRectGetHeight(self.bounds) / 2.0;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    
    NSArray *colors = nil;
    if (self.highlighted) {
        colors = [NSArray arrayWithObjects:
                  (__bridge id)[UIColor colorWithRed:0.322 green:0.541 blue:0.976 alpha:1.0].CGColor,
                  (__bridge id)[UIColor colorWithRed:0.235 green:0.329 blue:0.973 alpha:1.0].CGColor,
                  nil];
    }
    else {
        colors = [NSArray arrayWithObjects:
                  (__bridge id)[UIColor colorWithRed:0.863 green:0.902 blue:0.969 alpha:1.0].CGColor,
                  (__bridge id)[UIColor colorWithRed:0.741 green:0.808 blue:0.937 alpha:1.0].CGColor,
                  nil];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFTypeRef)colors, NULL);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, CGRectGetHeight(self.bounds)), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
    
    if (self.highlighted) {
        [[UIColor colorWithRed:0.275 green:0.478 blue:0.871 alpha:1.0] set];
    }
    else {
        [[UIColor colorWithRed:0.667 green:0.757 blue:0.914 alpha:1.0] set];
    }
    
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.5, 0.5) cornerRadius:radius];
    [path setLineWidth:1.0];
    [path stroke];
    
    if (self.highlighted) {
        [[UIColor whiteColor] set];
    }
    else {
        [[UIColor blackColor] set];
    }
    
    UIFont *titleFont = [UIFont systemFontOfSize:kTokenFieldFontSize];
    CGSize titleSize = [self.title sizeWithFont:titleFont];
    CGRect titleFrame = CGRectMake((CGRectGetWidth(self.bounds) - titleSize.width) / 2.0,
                                   (CGRectGetHeight(self.bounds) - titleSize.height) / 2.0,
                                   titleSize.width,
                                   titleSize.height);
    
    [self.title drawInRect:titleFrame withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
}

@end

#pragma mark - CORecord

@implementation CORecord

- (void)dealloc {
    if (record_) {
        CFRelease(record_);
        record_ = NULL;
    }
}

- (NSString *)fullName {
    return CFBridgingRelease(ABRecordCopyCompositeName(record_));
}

- (NSString *)namePrefix {
    return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonPrefixProperty));
}

- (NSString *)firstName {
    return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonFirstNameProperty));
}

- (NSString *)middleName {
    return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonMiddleNameProperty));
}

- (NSString *)lastName {
    return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonLastNameProperty));
}

- (NSString *)nameSuffix {
    return CFBridgingRelease(ABRecordCopyValue(record_, kABPersonSuffixProperty));
}

- (NSArray *)emailAddresses {
    NSMutableArray *addresses = [NSMutableArray new];
    ABMultiValueRef multi = ABRecordCopyValue(record_, kABPersonEmailProperty);
    CFIndex multiCount = ABMultiValueGetCount(multi);
    for (CFIndex i=0; i<multiCount; i++) {
        CORecordEmail *email = [CORecordEmail new];
        email->emails_ = CFRetain(multi);
        email->identifier_ = ABMultiValueGetIdentifierAtIndex(multi, i);
        [addresses addObject:email];
    }
    CFRelease(multi);
    return [NSArray arrayWithArray:addresses];
}

@end

@implementation CORecordEmail

- (void)dealloc {
    if (emails_ != NULL) {
        CFRelease(emails_);
        emails_ = NULL;
    }
}

- (NSString *)label {
    CFStringRef label = ABMultiValueCopyLabelAtIndex(emails_, ABMultiValueGetIndexForIdentifier(emails_, identifier_));
    if (label != NULL) {
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(label);
        CFRelease(label);
        return CFBridgingRelease(localizedLabel);
    }

    // no label - use this as the default
    return @"email";
}

- (NSString *)address {
    return CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails_, ABMultiValueGetIndexForIdentifier(emails_, identifier_)));
}

@end

#pragma mark - COEmailTableCell

@implementation COEmailTableCell
@synthesize nameLabel = nameLabel_;
@synthesize emailLabelLabel = emailLabelLabel_;
@synthesize emailAddressLabel = emailAddressLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.emailLabelLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.emailLabelLabel.font = [UIFont boldSystemFontOfSize:14];
        self.emailLabelLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        self.emailLabelLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        self.emailAddressLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.emailAddressLabel.font = [UIFont systemFontOfSize:14];
        self.emailAddressLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        self.emailAddressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.emailLabelLabel];
        [self addSubview:self.emailAddressLabel];
        
        [self adjustLabels];
    }
    return self;
}

- (void)adjustLabels
{
    CGSize emailLabelSize = [self.emailLabelLabel.text sizeWithFont:self.emailLabelLabel.font];
    CGFloat leftInset = 8;
    CGFloat yInset = 4;
    CGFloat labelWidth = emailLabelSize.width;
    self.nameLabel.frame = CGRectMake(leftInset, yInset, CGRectGetWidth(self.bounds) - leftInset * 2, CGRectGetHeight(self.bounds) / 2.0 - yInset);
    self.emailLabelLabel.frame = CGRectMake(leftInset, CGRectGetMaxY(self.nameLabel.frame), labelWidth, CGRectGetHeight(self.bounds) / 2.0 - yInset);
    self.emailAddressLabel.frame = CGRectMake(labelWidth + leftInset * 2, CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.bounds) - labelWidth - leftInset * 3, CGRectGetHeight(self.bounds) / 2.0 - yInset);
}

@end
