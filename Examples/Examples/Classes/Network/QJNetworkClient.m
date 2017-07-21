//
// KHTTPSessionManager 类的 Category 类别
// Created by 杨玉刚 on 7/18/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import <StarterKit/SKPaginatorModel.h>
#import "QJNetworkClient.h"
#import "QJPost.h"
#import <Overcoat/OVCResponse.h>

@implementation SKHTTPSessionManager (NetworkClient)

//- (AnyPromise *)fetchFeeds:(NSDictionary *)parameters {
//  NSLog(@"--------------- fetchFeeds ");
//  return [self pmk_GET:@"/site/courseList" parameters:self.params];
//}
//
//- (AnyPromise *)fetchFeedsWithPages:(NSDictionary *)parameters {
//  NSLog(@"--------------- fetchFeedsWithPages ");
//  return [self pmk_POST:@"/site/courseList" parameters:self.params];
//}



- (AnyPromise *)fetchFeedsNoParams {
  NSLog(@"--------------- fetchFeeds ");
  
  /*
  return [self GET: @"/site/courseList" parameters: self.params].then(^(OVCResponse *response){
    return response.result;
  });
   */
  return [self pmk_GET:@"/site/courseList" parameters: self.params];
}

- (AnyPromise *)fetchFeedsWithPagesNoParams {
  NSLog(@"--------------- fetchFeedsWithPages ");
  [self GET:@"/site/courseList" parameters:self.params completion:^(OVCResponse * _Nullable response, NSError * _Nullable error) {
    NSLog(@"--get data : %@", response.result);
  }];
  return [self pmk_POST:@"/site/courseList" parameters:self.params];
}


+ (NSDictionary *)modelClassesByResourcePath {
  return @{
      @"/site/courseLis" : [SKPaginatorModel class],
      @"/site/courseLis" : [QJPost class],
  };
}

@end
