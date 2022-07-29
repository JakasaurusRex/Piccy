#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CKAddress.h"
#import "CKAddressBook.h"
#import "CKContact.h"
#import "CKDate.h"
#import "CKEmail.h"
#import "CKLabel.h"
#import "CKMessenger.h"
#import "CKPhone.h"
#import "CKSocialProfile.h"
#import "CKURL.h"
#import "ContactsKit.h"

FOUNDATION_EXPORT double ContactsKitVersionNumber;
FOUNDATION_EXPORT const unsigned char ContactsKitVersionString[];

