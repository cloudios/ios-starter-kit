//
//  CourseList.m
//  Examples
//
//  Created by 任我行 on 2017/7/20.
//  Copyright © 2017年 奇迹空间. All rights reserved.
//

#import "CourseList.h"
#import "CourseListRows.h"

@implementation CourseList


#pragma mark MTLJSONSerializing

/*
 "pages": 1,
 "pageNumber": 1,
 "pageSize": 20,
 "totals": 1,
 "rows":
 */
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"pages" : @"pages",
           @"pageNumber" : @"pageNumber",
           @"pageSize" : @"pageSize",
           @"totals" : @"totals",
           @"rows" : @"rows",
           };
}


+ (NSValueTransformer *)rowsJSONTransformer {
  return [MTLJSONAdapter dictionaryTransformerWithModelClass:[CourseListRows class]];
}

@end
