//
//  CAAddPointTitleViewController.m
//  Cactus
//
//  Created by 钟奇龙 on 2018/11/3.
//  Copyright © 2018 钟奇龙. All rights reserved.
//

#import "CAAddPointTitleViewController.h"
#import "CAAddPointTitleCell.h"
#import "CAStudent.h"
#import "CAPoint.h"
@interface CAAddPointTitleViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) NSMutableArray *modifiedPoints;
@property (nonatomic,strong) NSMutableArray *textFields;
@end

@implementation CAAddPointTitleViewController

- (NSMutableArray *)modifiedPoints{
    if (!_modifiedPoints) {
        _modifiedPoints = [NSMutableArray array];
    }
    return _modifiedPoints;
}

- (NSMutableArray *)textFields{
    if (!_textFields) {
        _textFields = [NSMutableArray array];
    }
    return _textFields;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑分数列";
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    [rightButton setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000eb29", 34, [UIColor orangeColor])] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    [leftButton setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000eb2c", 34, [UIColor orangeColor])] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
}
- (void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)save{
    [self.modifiedPoints removeAllObjects];
    for (int i=0; i<self.textFields.count; ++i) {
        UITextField *currentTextField = self.textFields[i];
        if (i == 0) {
            if ([currentTextField.text isEqualToString:@""]) {
                [MBProgressHUD showError:@"请输入合适的分数列名称"];
                return;
            }
            self.pointTitle = [[CATitle alloc] init];
            self.pointTitle.name = currentTextField.text;
        }else{
            if ([currentTextField.text isEqualToString:@""]) {
                continue;
            }
            CAStudent *currentStudent = self.students[i-1];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            CAPoint *newPoint = [[CAPoint alloc] init];
            newPoint.classInfo_id = [[userDefaults valueForKey:@"currentClassInfo_id"] integerValue];
            newPoint.student_id = currentStudent._id;
            newPoint.pointNumber = [currentTextField.text integerValue];
            [self.modifiedPoints addObject:newPoint];
        }
    
    }
    [MBProgressHUD showMessage:@"提交中..."];
    //发送请求,先请求插入分数列
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block BOOL tag = YES;
    dispatch_group_async(group, queue, ^{
        //1.插入分数列
        NSString *urlString = [baseURL stringByAppendingString:@"title/format"];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [userDefaults valueForKey:@"userToken"];
        params[@"token"] = token;
        params[@"subjects"] = @[@{@"name":self.pointTitle.name,@"titleGroup_id":@"1"}];
        [ShareDefaultHttpTool POSTWithCompleteURL:urlString parameters:params progress:^(id progress) {
            
        } success:^(id responseObject) {
            NSDictionary *responseDict = responseObject;
            if ([responseDict[@"code"] isEqualToString:@"1042"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"分数列提交失败，请检查输入"];
                tag = NO;
            }else{
                self.pointTitle._id = [responseDict[@"subjects"][0] integerValue];
            }
            dispatch_semaphore_signal(semaphore);

        } failure:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"分数列提交失败，请稍后重试"];
            tag = NO;
            dispatch_semaphore_signal(semaphore);
        }];
        
        
        
    });
    dispatch_group_async(group, queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (tag == NO) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"分数值提交失败，请检查输入"];
            return;
        }
        //2.插入每个分数
        NSString *urlString = [baseURL stringByAppendingString:@"point/format"];

        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [userDefaults valueForKey:@"userToken"];
        params[@"token"] = token;
        NSMutableArray *subjects = [NSMutableArray array];
        for (CAPoint *point in self.modifiedPoints) {
            point.title_id = self.pointTitle._id;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"classInfo_id"] = [NSString stringWithFormat:@"%ld", point.classInfo_id];
            dict[@"title_id"] = [NSString stringWithFormat:@"%ld", point.title_id];
            dict[@"student_id"] = [NSString stringWithFormat:@"%ld", point.student_id];
            dict[@"pointNumber"] = [NSString stringWithFormat:@"%ld", point.pointNumber];
            [subjects addObject:dict];
        }
        params[@"subjects"] = subjects;
        [ShareDefaultHttpTool POSTWithCompleteURL:urlString parameters:params progress:^(id progress) {
            
        } success:^(id responseObject) {
            NSDictionary *responseDict = responseObject;
            if ([responseDict[@"code"] isEqualToString:@"1042"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"分数值提交失败，请检查输入"];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"提交成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pointModefySuccessNotification" object:nil];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"分数值提交失败，请稍后重试"];
        }];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return self.students.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"pointTitleCell";
//    CAAddPointTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        if (indexPath.section == 0) {
//            cell.studentSidLabel.text = @"设置新的分数列";
//        }else{
//            CAStudent *student = self.students[indexPath.row];
//            cell.studentSidLabel.text = student.sid;
//            cell.studentNameLabel.text = student.name;
//        }
        if (indexPath.section == 0) {
            UITextField *inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-20, cell.height-10)];
            inputTextField.borderStyle = UITextBorderStyleRoundedRect;
            inputTextField.delegate = self;
            [self.textFields addObject:inputTextField];
//            inputTextField.tag = -10;
//            inputTextField.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:inputTextField];
        }else{
            UILabel *studentSidLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, cell.height-10)];
            UILabel *studentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(studentSidLabel.getMaxX + 5, studentSidLabel.y, studentSidLabel.width, studentSidLabel.height)];
            UITextField *inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100-10, 5, 100, cell.height-10)];
//            inputTextField.backgroundColor = [UIColor lightGrayColor];
            inputTextField.borderStyle = UITextBorderStyleRoundedRect;
            inputTextField.delegate = self;
            [self.textFields addObject:inputTextField];

            
//            inputTextField.tag = indexPath.row;
            [cell.contentView addSubview:inputTextField];
            [cell.contentView addSubview:studentSidLabel];
            [cell.contentView addSubview:studentNameLabel];
            CAStudent *student = self.students[indexPath.row];
            studentSidLabel.text = student.sid;
            studentNameLabel.text = student.name;
        }
    }
    
    return cell;
}


//头视图高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"输入新的分数列名";
    }else{
        return @"输入分数值";
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark --textfield点击事件
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
