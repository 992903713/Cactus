//
//  CACollege.h
//  Cactus
//
//  Created by 钟奇龙 on 2018/9/26.
//  Copyright © 2018年 钟奇龙. All rights reserved.
//  学院

#import <Foundation/Foundation.h>
@class CAUniversity;
@interface CACollege : NSObject
//学院名
@property (nonatomic,copy) NSString *name;
//学院昵称
@property (nonatomic,copy) NSString *shortname;
//所在学校
@property (nonatomic,weak) CAUniversity *university;
//拥有专业组
@property (nonatomic,strong) NSArray *majors;
//拥有教师组
@property (nonatomic,strong) NSArray *teachers;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype) userWithDict:(NSDictionary *)dict;
@end
