//
//  CATitle.m
//  Cactus
//
//  Created by 钟奇龙 on 2018/9/26.
//  Copyright © 2018年 钟奇龙. All rights reserved.
//

#import "CATitle.h"

@implementation CATitle
- (instancetype)initWithDict:(NSDictionary *)dict{
    if(self = [super init]){

        self.name = dict[@"name"];
        self.weight = (NSInteger)dict[@"weight"];
        self.titleGroup_id = dict[@"titleGroup_id"];
    }
    return self;
}

+ (instancetype) titleWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
