//
//  CourseListRows.h
//  Examples
//
//  Created by 任我行 on 2017/7/20.
//  Copyright © 2017年 奇迹空间. All rights reserved.
//

#import "QJModel.h"

@class TeacherInfo;

@interface CourseListRows : QJModel

@property (nonatomic, copy, readonly) NSString *seriesName;
@property (nonatomic, strong, readonly) TeacherInfo *teacherInfo;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *rowId;
@property (nonatomic, copy, readonly) NSString *describe;
@property (nonatomic, copy, readonly) NSString *listImage;
@property (nonatomic, copy, readonly) NSString *seriesId;
@property (nonatomic, copy, readonly) NSString *detailImage;

@end
