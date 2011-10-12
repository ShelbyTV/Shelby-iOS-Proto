#import <Three20UI/Three20UI.h>

@interface Contact : NSObject {

}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *email;

@end

/*
 * a searchable model which can be configured with a 
 * loading and/or search time
 */
@interface ContactAddressBook : NSObject <TTModel> {
  NSArray* _allContacts;
  NSArray* _contacts;
  NSMutableArray* _delegates;
  
  NSTimer* _fakeSearchTimer;
  NSTimeInterval _fakeSearchDuration;
  NSTimer* _fakeLoadingTimer;
  NSTimeInterval _fakeLoadingDuration;
}

@property(nonatomic,retain) NSArray* allContacts;
@property(nonatomic,retain) NSArray* contacts;

+ (NSArray *)allSystemContacts;

- (id)initWithContacts:(NSArray*)contacts;


- (void)search:(NSString*)text;

@end

@interface ContactDataSource : TTSectionedDataSource {
  ContactAddressBook* _addressBook;
}

@property(nonatomic,readonly) ContactAddressBook* addressBook;

@end

@interface ContactSearchDataSource : TTSectionedDataSource {
  ContactAddressBook* _addressBook;
}

@property(nonatomic,readonly) ContactAddressBook* addressBook;

- (id)initWithDuration:(NSTimeInterval)duration;

@end
