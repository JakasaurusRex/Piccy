//
//  AppMethods.h
//  Piccy
//
//  Created by Jake Torres on 8/1/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppMethods : NSObject
//Sets up activity indicators throughout the app to inform user information is loading
+(UIActivityIndicatorView *) setupActivityIndicator:(UIActivityIndicatorView *) activityIndicator onView:(UIView *) view;


@end

NS_ASSUME_NONNULL_END
