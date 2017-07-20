//
// KHTTPSessionManager 类的 Category 类别
// Created by 杨玉刚 on 7/18/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import <StarterKit/SKPaginatorModel.h>
#import "QJNetworkClient.h"
#import "QJPost.h"

@implementation SKHTTPSessionManager (NetworkClient)

- (AnyPromise *)fetchFeeds:(NSDictionary *)parameters {
  NSLog(@"--------------- fetchFeeds ");
  return [self pmk_GET:@"/site/courseLis" parameters:parameters];
}

- (AnyPromise *)fetchFeedsWithPages:(NSDictionary *)parameters {
  NSLog(@"--------------- fetchFeedsWithPages ");
  return [self pmk_GET:@"/site/courseLis" parameters:parameters];
}



//- (AnyPromise *)fetchFeedsNoParams {
//  NSLog(@"--------------- fetchFeeds ");
//  return [self pmk_GET:@"/site/courseLis" parameters: self.parametersDic];
//}
//
//- (AnyPromise *)fetchFeedsWithPagesNoParams {
//  NSLog(@"--------------- fetchFeedsWithPages ");
//  return [self pmk_GET:@"/site/courseLis" parameters:self.parametersDic];
//}


+ (NSDictionary *)modelClassesByResourcePath {
  return @{
      @"/posts/paginator" : [SKPaginatorModel class],
      @"/posts" : [QJPost class],
  };
}

@end
