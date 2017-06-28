//
//  ViewController.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/20.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "ViewController.h"
#import "CommonHeader.h"
#import "BallDynamicVC.h"
#import "HannuoTowerDemoVC.h"
#import "SwingBallsVC.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.title = @"物理仿真游戏";

	//导航栏设置为非透明，当你的容器是navigation controller时，默认的布局将从navigation bar的顶部开始，设置非透明后改为从navigation bar底开始
	self.navigationController.navigationBar.translucent = NO;
	
	[self addSubviews];

}

- (void)addSubviews{
	NSArray *arr = @[@"物理仿真球", @"汉诺塔游戏", @"牛顿球"];
	for (NSInteger i = 0; i < 3; i ++) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(30, 100 + 70 * i, APP_SCREEN_WIDTH - 60, 50)];
		button.tag = 101 + i;
		[button setTitle:arr[i] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		button.backgroundColor = [UIColor redColor];
		button.titleLabel.font = [UIFont systemFontOfSize:15.0];
		[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
	}
	
}

- (void)buttonAction:(UIButton *)button{
	switch (button.tag) {
		case 101:
		{
			//物理仿真球
			[self.navigationController pushViewController:[[BallDynamicVC alloc]init] animated:YES];
			break;
		}
			
		case 102:
		{
			//汉诺塔游戏
			[self.navigationController pushViewController:[[HannuoTowerDemoVC alloc]init] animated:YES];
			break;
		}
		case 103:
		{
			//牛顿球
			[self.navigationController pushViewController:[[SwingBallsVC alloc]init] animated:YES];
			break;
		}
		default:
			break;
	}

}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}



@end
