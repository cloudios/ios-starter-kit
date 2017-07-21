//
//  CourseList.h
//  Examples
//
//  Created by 任我行 on 2017/7/20.
//  Copyright © 2017年 奇迹空间. All rights reserved.
//

#import "QJModel.h"

@class CourseListRows;

@interface CourseList : QJModel

/*
"pages": 1,
"pageNumber": 1,
"pageSize": 20,
"totals": 1,
"rows":
 */

@property (nonatomic, strong, readonly) NSNumber *pages;
@property (nonatomic, strong, readonly) NSNumber *pageNumber;
@property (nonatomic, strong, readonly) NSNumber *pageSize;
@property (nonatomic, strong, readonly) NSNumber *totals;
@property (nonatomic, strong, readonly) CourseListRows *rows;


@end
