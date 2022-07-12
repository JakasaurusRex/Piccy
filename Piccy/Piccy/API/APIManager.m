//
//  APIManager.m
//  Piccy
//
//  Created by Jake Torres on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "APIManager.h"

@interface APIManager()
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *clientKey;
@end

@implementation APIManager


+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


- (instancetype)init {
    
    // TODO: fix code below to pull API Keys from your new Keys.plist file

    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

    self.apiKey = dict[@"api-key"];
    self.clientKey = @"Piccy";
    
    self.posts = [[NSMutableArray alloc] init];
    
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"api-key"]) {
        self.apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"api-key"];
    }
    
    return self;
}

//Returns a dictionary with the top **limit** gifs based on the search string given
-(void)getGifsWithSearchString:(NSString *)searchString limit:(int) limit completion:(void (^)(NSDictionary *, NSError *)) completion{
    NSString *UrlString = [NSString stringWithFormat:@"https://tenor.googleapis.com/v2/search?key=%@&client_key=%@&q=%@&limit=%d", self.apiKey, self.clientKey, searchString, limit];
    NSURL *searchUrl = [NSURL URLWithString:UrlString];
    NSURLRequest *searchRequest = [NSURLRequest requestWithURL:searchUrl];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:searchRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError = nil;
        NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        if(jsonError != nil) {
            completion(nil, jsonError);
        } else {
            completion(jsonResults, nil);
        }
    }];
    [task resume];
}


@end
