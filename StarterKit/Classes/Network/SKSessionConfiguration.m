//
// Created by Hammer on 2/2/16.
//

#import "SKSessionConfiguration.h"
#import "SKAccountManager.h"
#import "SKNetworkConfig.h"
#import "SKLocalizableUtils.h"
#import "UIDevice+SKDeviceModel.h"
#import "NSString+ExtUtils.h"

#define SCAPI_APP_SECRET  @"APP_SECRET"
@implementation SKSessionConfiguration

+ (NSDictionary *)commonHeader {
  return @{
      @"Content-Encoding" : @"gzip",
      @"X-Client-Build" : [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *) kCFBundleVersionKey],
      @"X-Client-Version" : [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *) kCFBundleVersionKey],
      @"X-Client" : [[[UIDevice currentDevice] identifierForVendor] UUIDString],
      @"X-Client-Type" : @"iOS",
      @"X-Client-Channel" : @"channel", // 待定
      @"X-Language-Code" : [SKLocalizableUtils getPreferredLanguagesString],
      @"X-Client-System" : [NSString stringWithFormat:@"%.1f", [[[UIDevice currentDevice] systemVersion] floatValue]],
      @"X-Client-Model" : [[UIDevice currentDevice] deviceModel],
      @"X-JXC-APPID" : @"APP_ID",
  };
}

+ (NSURLSessionConfiguration *)defaultSessionConfiguration {
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSDictionary *headers = [[self class] commonHeader];
  NSMutableDictionary *mutableDictionary = [headers mutableCopy];

  if ([SKNetworkConfig sharedInstance].accept) {
    mutableDictionary[@"Accept"] = [SKNetworkConfig sharedInstance].accept;
  }

  SKAccountManager *manager = [SKAccountManager defaultAccountManager];
  if ([manager isLoggedIn]) {
      //JWTs
    mutableDictionary[@"Authorization"] = [NSString stringWithFormat:@"Bearer %@", manager.token];
  } else {
    mutableDictionary[@"Authorization"] = nil;
  }
    
    NSString *nostr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    mutableDictionary[@"X-JXC-NOSTR"] = nostr;
    NSMutableString *signStr = [[NSMutableString alloc] initWithCapacity:10];
    [signStr appendFormat:@"%@%@", SCAPI_APP_SECRET, nostr];
    mutableDictionary[@"X-JXC-SIGN"] = [signStr stringToMD5];
    
  [configuration setHTTPAdditionalHeaders:[mutableDictionary copy]];
    NSLog(@"--------- header mutableDictionary: %@",mutableDictionary);
  return configuration;
}


+ (NSURLSessionConfiguration *)defaultSessionConfigurationWithParams:(NSDictionary *)parameters{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *headers = [[self class] commonHeader];
    NSMutableDictionary *mutableDictionary = [headers mutableCopy];
    
    if ([SKNetworkConfig sharedInstance].accept) {
        mutableDictionary[@"Accept"] = [SKNetworkConfig sharedInstance].accept;
    }
    
    SKAccountManager *manager = [SKAccountManager defaultAccountManager];
    if ([manager isLoggedIn]) {
        //JWTs
        mutableDictionary[@"Authorization"] = [NSString stringWithFormat:@"Bearer %@", manager.token];
    } else {
        mutableDictionary[@"Authorization"] = nil;
    }
    
    NSString *nostr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    mutableDictionary[@"X-JXC-NOSTR"] = nostr;
        NSArray *dataKeys = [[parameters allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
    NSMutableString *signStr = [[NSMutableString alloc] initWithCapacity:10];
        for(NSString *key in dataKeys){
            NSString *str = parameters[key];
            if(str != nil){
                [signStr appendFormat:@"%@", str];
            }
        }
    [signStr appendFormat:@"%@%@", SCAPI_APP_SECRET, nostr];
    mutableDictionary[@"X-JXC-SIGN"] = [signStr stringToMD5];
    
    [configuration setHTTPAdditionalHeaders:[mutableDictionary copy]];
    NSLog(@"--------- WithParams header mutableDictionary: %@,/n params: %@",mutableDictionary,parameters);
    return configuration;
}

@end
