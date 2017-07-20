//
// Created by Hammer on 1/31/16.
//

#import "SKHTTPSessionManager.h"
#import "SKErrorResponseModel.h"
#import "SKSessionConfiguration.h"
#import "SKNetworkConfig.h"

@implementation SKHTTPSessionManager

//@synthesize params = _params;

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
                 sessionConfiguration:[[SKSessionConfiguration new] defaultSessionConfigurationWithParams:parameters]]) {
        _params = parameters;
    }
    
    return self;
}


+ (OVC_NULLABLE Class)errorModelClassesByResourcePath {
  return @{@"**": [SKErrorResponseModel class]};
}

@end
