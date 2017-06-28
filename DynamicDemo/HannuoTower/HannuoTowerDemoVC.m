//
//  HannuoTowerDemoVC.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/27.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "HannuoTowerDemoVC.h"
#import "HannuoTowerVC.h"
#import "RMAlertView.h"

@interface HannuoTowerDemoVC ()

@property (strong, nonatomic)UITextField *textField;
@property (strong, nonatomic)UIButton *submitButton;

@end

@implementation HannuoTowerDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.title = @"汉诺塔游戏";
	
	[self addSubviews];
}

- (void)addSubviews{
	[self.view addSubview:self.textField];
	[self.view addSubview:self.submitButton];
}

- (void)submitButtonAction:(UIButton *)button{
	
	if ([self.textField.text length] == 0) {
		[RMAlertView showMessage:@"请输入汉诺塔的层数"];
		return;
	}
	
	HannuoTowerVC *vc = [[HannuoTowerVC alloc]init];
	vc.towerNum = [self.textField.text integerValue];
	[self.navigationController pushViewController:vc animated:YES];
}



#pragma mark- subviews

- (UITextField *)textField{
	if (!_textField) {
		_textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 40)];
		_textField.placeholder = @"请输入汉诺塔的层数";
		_textField.keyboardType = UIKeyboardTypeNumberPad;
	}
	return _textField;
}

- (UIButton *)submitButton{
	if (!_submitButton) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(60, 160, [UIScreen mainScreen].bounds.size.width - 120, 50)];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button setTitle:@"开始教学" forState:UIControlStateNormal];
		button.layer.masksToBounds = YES;
		button.layer.cornerRadius = 2.f;
		button.backgroundColor = [UIColor redColor];
		[button addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		_submitButton = button;
	}
	return _submitButton;
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
