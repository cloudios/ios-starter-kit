//
// Created by Hammer on 1/31/16.
//

#import "SKHTTPSessionManager.h"
#import "SKErrorResponseModel.h"
#import "SKSessionConfiguration.h"
#import "SKNetworkConfig.h"

@implementation SKHTTPSessionManager

- (instancetype)init {

    //NSLog(@"---init base url %@",[NSURL URLWithString:[SKNetworkConfig sharedInstance].baseUrl]);
//  if (self = [super initWithBaseURL:[NSURL URLWithString:[SKNetworkConfig sharedInstance].baseUrl]
//               sessionConfiguration:[SKSessionConfiguration  defaultSessionConfiguration]]) {
//
//  }
    if (self = [super init]) {
    }
  return self;
}

- (instancetype)initWithParams:(NSDictionary *)parameters {
    NSLog(@"---initWithParams url %@",[NSURL URLWithString:[SKNetworkConfig sharedInstance].baseUrl]);
    if (self = [super initWithBaseURL:[NSURL URLWithString:[SKNetworkConfig sharedInstance].baseUrl]
                 sessionConfiguration:[SKSessionConfiguration defaultSessionConfigurationWithParams:parameters]]) {
        
    }
    return self;
}


+ (OVC_NULLABLE Class)errorModelClassesByResourcePath {
  return @{@"**": [SKErrorResponseModel class]};
}

@end
