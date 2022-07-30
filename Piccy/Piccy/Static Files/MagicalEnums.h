//
//  MagicalEnums.h
//  Piccy
//
//  Created by Jake Torres on 7/29/22.
//

#ifndef MagicalEnums_h
#define MagicalEnums_h

typedef NS_ENUM (int, ParseError){
    ParseErrorUsernameTaken = 209,
    ParseErrorEmailInvalid = 125,
    ParseErrorEmailTaken = 203
};

typedef NS_ENUM (int, RegistrationRequirements) {
    RegistrationRequirementsUsernameLength = 3,
    RegistrationRequirementsPasswordLength = 8
};

typedef NS_ENUM(int, FriendTabMode) {
    FriendTabModeAddFriends = 0,
    FriendTabModeUserFriends = 1,
    FriendTabModeFriendRequests = 2
};

typedef NS_ENUM(int, CommentsTabMode) {
    CommentsTabModeComments = 0,
    CommentsTabModeReactions = 1
};

typedef NS_ENUM(int, UIIntValues) {
    UIIntValuesPillButtonCornerRadius = 15,
    UIIntValuesCircularIconDivisor = 2,
    UIIntValuesRoundedCornerDivisor = 12
};

typedef NS_ENUM(int, UserProfile) {
    UserProfileLayoutDimensions = 260,//260 x 260 since its a square
    UserProfileItemSpacing = 40,
};

typedef NS_ENUM(int, SegueDirections) {
    SegueDirectionsFromBottom = 1,
    SegueDirectionsFromTop = 2,
    SegueDirectionsFromLeft = 3,
    SegueDirectionsFromRight = 4
};

#endif /* MagicalEnums_h */
