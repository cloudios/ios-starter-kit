//
//  TeacherInfo.m
//  Examples
//
//  Created by 任我行 on 2017/7/20.
//  Copyright © 2017年 奇迹空间. All rights reserved.
//

#import "TeacherInfo.h"

@implementation TeacherInfo


#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
 /* return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:
          @{
            @"teacherId" : @"teacherId",
            @"teacherName" : @"teacherName",
            @"schoolId" : @"schoolId",
            @"schoolName" : @"schoolName",
            @"subjectId" : @"subjectId",
            @"subjectName" : @"subjectName",
            }];
  */
  return @{
            @"teacherId" : @"teacherId",
            @"teacherName" : @"teacherName",
            @"schoolId" : @"schoolId",
            @"schoolName" : @"schoolName",
            @"subjectId" : @"subjectId",
            @"subjectName" : @"subjectName",
            };
}

@end
