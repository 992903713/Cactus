//
//  CAStudentListViewController.m
//  Cactus
//
//  Created by 钟奇龙 on 2018/9/22.
//  Copyright © 2018年 钟奇龙. All rights reserved.
//

#import "CAStudentListViewController.h"

@interface CAStudentListViewController ()

@end

@implementation CAStudentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"show CAStudentListViewController");

    // Do any additional setup after loading the view.
}
- (void)setLessonClass:(CAClass *)lessonClass{
    NSLog(@"CAStudentListViewController setClass");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
