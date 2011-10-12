#import <AddressBook/AddressBook.h>

#import "ContactDataSource.h"

@implementation Contact

@synthesize name;
@synthesize email;

- (id)initWithName:(NSString *)aName email:(NSString *)aEmail {
  if (self = [super init]) {
    self.name = aName;
    self.email = aEmail;
  }
  return self;
}

- (void)dealloc
{
  [name release];
  [email release];
  [super dealloc];
}

@end

@interface ContactAddressBook ()
- (void) loadNames;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ContactAddressBook

@synthesize contacts = _contacts;
@synthesize allContacts = _allContacts;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (NSArray *)allSystemContacts
{
  ABAddressBookRef addressBook = ABAddressBookCreate();
  CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);

  //NSMutableArray *allPeople = (NSMutableArray *) CFArrayRef;
  //emailPredicate
  //allPeople = [allPeople filteredArrayUsingPredicate: emailPredicate];

  NSMutableArray *tempContacts = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(people)];
  for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
    ABRecordRef person = CFArrayGetValueAtIndex(people, i);
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);

    NSString* name = (NSString *)ABRecordCopyCompositeName(person);

    for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
      NSString* email = (NSString*)ABMultiValueCopyValueAtIndex(emails, j);

      Contact *contact = [[Contact alloc] initWithName: name
                                                 email: email];

      [tempContacts addObject: contact];

      [contact release];
      [email release];
      // Break because we only want one email.
      break; 
    }
    [name release];
    CFRelease(emails);
  }
  CFRelease(addressBook);
  CFRelease(people);

  return tempContacts;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)fakeSearch:(NSString*)text {
  self.contacts = [NSMutableArray array];

  if (text.length) {
    text = [text lowercaseString];

    //for (NSString* name in _allNames) {
    for (Contact *contact in self.allContacts) {
      NSString *name = contact.name;
      if ([[name lowercaseString] rangeOfString:text].location == 0) {
        [self.contacts addObject: contact];
      }
    }
  }

  //[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)fakeSearchReady:(NSTimer*)timer {
  //_fakeSearchTimer = nil;

  NSString* text = timer.userInfo;
  [self fakeSearch:text];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithContacts:(NSArray*)contacts {
  if (self = [super init]) {
    self.allContacts = contacts;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = [[NSMutableArray alloc] init];
  }
  return _delegates;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return NO;
}

- (BOOL)isLoaded {
  return !!_contacts;
}

- (BOOL)isLoading {
  return !!_fakeSearchTimer || !!_fakeLoadingTimer;
}

- (BOOL)isEmpty {
  return !_contacts.count;
}

- (void) fakeLoadingReady {
  _fakeLoadingTimer = nil;
    
  [self loadNames];

  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
  if (_fakeLoadingDuration) {
    TT_INVALIDATE_TIMER(_fakeLoadingTimer);
    _fakeLoadingTimer = [NSTimer scheduledTimerWithTimeInterval:_fakeLoadingDuration target:self
                                                       selector:@selector(fakeLoadingReady) userInfo:nil repeats:NO];
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
  } else {
    [self loadContacts];
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
  }
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
  if (_fakeSearchTimer) {
    TT_INVALIDATE_TIMER(_fakeSearchTimer);
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
  } else if(_fakeLoadingTimer) {
    TT_INVALIDATE_TIMER(_fakeLoadingTimer);
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];    
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)loadContacts {
  TT_RELEASE_SAFELY(_contacts);
  _contacts = [_allContacts mutableCopy];
}

- (void)search:(NSString*)text {
  [self cancel];

  TT_RELEASE_SAFELY(_contacts);
  if (text.length) {    
      [self fakeSearch:text];
      [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];    
  } else {
    [_delegates perform:@selector(modelDidChange:) withObject:self];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ContactDataSource

@synthesize addressBook = _addressBook;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    NSArray *systemContacts = [ContactAddressBook allSystemContacts];
    //_addressBook = [[ContactAddressBook alloc] initWithContacts:[ContactAddressBook allSystemContacts]];
    _addressBook = [[ContactAddressBook alloc] initWithContacts: systemContacts ];
    self.model = _addressBook;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_addressBook);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return [TTTableViewDataSource lettersForSectionsWithSearch:YES summary:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
  self.sections = [NSMutableArray array];

  NSMutableDictionary* groups = [NSMutableDictionary dictionary];

  //for (NSString* name in _addressBook.names) {
  for (Contact* contact in _addressBook.contacts) {
    NSString *name = contact.name;
    NSString* letter = [NSString stringWithFormat:@"%C", [name characterAtIndex:0]];
    NSMutableArray* section = [groups objectForKey:letter];
    if (!section) {
      section = [NSMutableArray array];
      [groups setObject:section forKey:letter];
    }

    TTTableItem* item = [TTTableTextItem itemWithText:name URL:nil];
    //item.userInfo = contact.email;
    item.userInfo = contact;
    [section addObject:item];
  }

  NSArray* letters = [groups.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString* letter in letters) {
    NSArray* items = [groups objectForKey:letter];
    [_sections addObject:letter];
    [_items addObject:items];
  }
}

- (id<TTModel>)model {
  return _addressBook;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ContactSearchDataSource

@synthesize addressBook = _addressBook;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithDuration:(NSTimeInterval)duration {
  if (self = [super init]) {
    NSArray *systemContacts = [ContactAddressBook allSystemContacts];
    _addressBook = [[ContactAddressBook alloc] initWithContacts: systemContacts ];
    self.model = _addressBook;
  }
  return self;
}

- (id)init {
  return [self initWithDuration:0];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_addressBook);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];

  //for (NSString* name in _addressBook.names) {
  for (Contact* contact in _addressBook.contacts) {
    NSString *name = contact.name;
    TTTableItem* item = [TTTableTextItem itemWithText:name URL:@"http://google.com"];
    item.userInfo = contact;
    [_items addObject:item];
  }
}

- (void)search:(NSString*)text {
  [_addressBook search:text];
}

- (NSString*)titleForLoading:(BOOL)reloading {
  return @"Searching...";
}

- (NSString*)titleForNoData {
  return @"No names found";
}

@end
