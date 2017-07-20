//
// SKHTTPSessionManager 类的 Category 类别
// Created by 杨玉刚 on 7/18/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import <StarterKit/SKHTTPSessionManager.h>

@interface SKHTTPSessionManager (NetworkClient)

- (AnyPromise *)fetchFeeds:(NSDictionary *)parameters;
- (AnyPromise *)fetchFeedsWithPages:(NSDictionary *)parameters;


//- (AnyPromise *)fetchFeedsNoParams;
//- (AnyPromise *)fetchFeedsWithPagesNoParams;

@end
