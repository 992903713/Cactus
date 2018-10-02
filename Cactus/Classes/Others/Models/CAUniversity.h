//
//  CAUniversity.h
//  Cactus
//
//  Created by 钟奇龙 on 2018/9/26.
//  Copyright © 2018年 钟奇龙. All rights reserved.
//  学校

#import <Foundation/Foundation.h>
#import "CACollege.h"
@interface CAUniversity : NSObject
//校名
@property (nonatomic,copy) NSString *name;
//校昵称
@property (nonatomic,copy) NSString *shortname;
//学院组
@property (nonatomic,strong) NSArray *colleges;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype) userWithDict:(NSDictionary *)dict;
@end
