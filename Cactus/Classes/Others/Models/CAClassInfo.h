//
//  CAClassInfo.h
//  Cactus
//
//  Created by 钟奇龙 on 2018/9/26.
//  Copyright © 2018年 钟奇龙. All rights reserved.
//  教学班信息

#import <Foundation/Foundation.h>
@interface CAClassInfo : NSObject
//主键
@property (nonatomic,assign) NSInteger _id;
//课程代号
@property (nonatomic,copy) NSString *cid;
//教学班名称
@property (nonatomic,copy) NSString *name;
//教师
@property (nonatomic,assign) NSInteger teacher_id;
//学年
@property (nonatomic,copy) NSString *year;
//月
@property (nonatomic,copy) NSString *month;
//日
@property (nonatomic,copy) NSString *date;
//教室
@property (nonatomic,copy) NSString *room;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype) classInfoWithDict:(NSDictionary *)dict;
@end
