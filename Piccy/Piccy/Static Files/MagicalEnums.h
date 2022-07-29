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

#endif /* MagicalEnums_h */
