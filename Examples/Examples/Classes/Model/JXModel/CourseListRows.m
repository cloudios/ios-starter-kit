//
//  CourseListRows.m
//  Examples
//
//  Created by 任我行 on 2017/7/20.
//  Copyright © 2017年 奇迹空间. All rights reserved.
//

#import "CourseListRows.h"
#import "TeacherInfo.h"

@implementation CourseListRows
#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"seriesName" : @"seriesName",
           @"teacherInfo" : @"teacherInfo",
           @"name" : @"name",
           @"describe" : @"describe",
           @"listImage" : @"listImage",
           @"rowId" : @"id",
           @"seriesId" : @"seriesId",
           @"detailImage" : @"detailImage",
           };
}


+ (NSValueTransformer *)teacherInfoJSONTransformer {
  return [MTLJSONAdapter dictionaryTransformerWithModelClass:[TeacherInfo class]];
}


@end
