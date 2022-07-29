//
//  MagicalEnums.h
//  Piccy
//
//  Created by Jake Torres on 7/29/22.
//

#ifndef MagicalEnums_h
#define MagicalEnums_h

typedef NS_ENUM (int, ParseError){
    UsernameTaken = 209,
    EmailInvalid = 125,
    EmailTaken = 203
};

typedef NS_ENUM (int, RegistrationRequirements) {
    UsernameLength = 3,
    PasswordLength = 8
};

#endif /* MagicalEnums_h */
