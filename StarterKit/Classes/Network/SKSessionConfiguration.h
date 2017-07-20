//
// Created by Hammer on 2/2/16.
//

#import <Foundation/Foundation.h>


@interface SKSessionConfiguration : NSObject

- (instancetype)init;

+ (NSURLSessionConfiguration *)defaultSessionConfiguration;

- (NSURLSessionConfiguration *)defaultSessionConfigurationWithParams:(NSDictionary *)parameters;

@end
