//
//  Piccy.m
//  Piccy
//
//  Created by Jake Torres on 7/12/22.
//

#import "Piccy.h"

@implementation Piccy

+ (nonnull NSString *)parseClassName {
    return @"Piccy";
}

+ (void) postPiccy: ( NSString * _Nullable )postGifUrl withCaption: ( NSString * _Nullable )caption withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Piccy *newPiccy = [Piccy new];
    
    //convert url string to gif and image
}

@end
