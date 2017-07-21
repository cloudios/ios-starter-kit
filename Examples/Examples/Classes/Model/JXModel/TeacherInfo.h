//
//  TeacherInfo.h
//  Examples
//
//  Created by 任我行 on 2017/7/20.
//  Copyright © 2017年 奇迹空间. All rights reserved.
//

#import "QJModel.h"

@interface TeacherInfo : QJModel

@property (nonatomic, strong, readonly) NSNumber *teacherId;
@property (nonatomic, copy, readonly) NSString *teacherName;
@property (nonatomic, strong, readonly) NSNumber *schoolId;
@property (nonatomic, copy, readonly) NSString *schoolName;
@property (nonatomic, strong, readonly) NSNumber *subjectId;
@property (nonatomic, copy, readonly) NSString *subjectName;
@end
