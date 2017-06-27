//
//  RMAlertView.m
//  RMActionSheetProject
//
//  Created by 王林 on 2017/5/19.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import "RMAlertView.h"

#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
//主色调－－深绿
#define RM_MAIN_COLOR       [UIColor colorWithRed:44 / 255.0 green:183 / 255.0 blue:124 / 255.0 alpha:1]

//文字色- - 黑色
#define RM_BLACK_COLOR       [UIColor colorWithRed:86 / 255.0 green:86 / 255.0 blue:86 / 255.0 alpha:1]

@implementation RMAlertView

static UIWindow *_alertWindow;

+ (UIWindow *)alertWindow
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_alertWindow = [self showAlertWindow];
	});
	return _alertWindow;
}

#pragma mark - HUD
+ (void)showMessage:(NSString *)text afterDelay:(NSTimeInterval)delay
{
	if (![text length]) {
		return;
	}
	
	UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
	
	NSMutableAttributedString *messageStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
	[alertCtrl setValue:messageStr forKey:@"attributedMessage"];
	
	//背景色
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10) {
		UIView *firstSubview = alertCtrl.view.subviews.firstObject;
		UIView *alertContentView = firstSubview.subviews.firstObject;
		
		for (UIView *subSubView in alertContentView.subviews) { //This is main catch
			subSubView.backgroundColor = RGBACOLOR(0, 0, 0, 0.6); //Here you change background
		}
	}else{
		UIView *firstSubview = alertCtrl.view.subviews.lastObject;
		UIView *alertContentView = firstSubview.subviews.lastObject;
		alertContentView.layer.cornerRadius = 6;
		alertContentView.backgroundColor = [UIColor darkGrayColor];
	}

	
	[[RMAlertView alertWindow] makeKeyAndVisible];
	[[RMAlertView alertWindow].rootViewController presentViewController:alertCtrl animated:YES completion:nil];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[alertCtrl dismissViewControllerAnimated:YES completion:nil];
		[[RMAlertView alertWindow]setHidden:YES];
	});
}

+ (void)showMessage:(NSString *)text
{
	[RMAlertView showMessage:text afterDelay:1];
}

#pragma mark - 使用UIAlertController自定义的AlertView
+ (void)showOKAlertTitle:(NSString *)title
				 message:(NSString *)message
		  withController:(UIViewController *)viewController
{
	[self showAlertTitle:title
				 message:message
			buttonTitles:@[@"确定"]
		  withController:viewController
			 selectBlock:nil];
}

+ (void)showOKAlertTitle:(NSString *)title
				 message:(NSString *)message
		  withController:(UIViewController *)viewController
			   doneBlock:(void(^)())doneBlock
{
	[self showAlertTitle:title
				 message:message
			buttonTitles:@[@"确定"]
		  withController:viewController
			 selectBlock:^(NSInteger selectIndex, NSString *title)
	 {
		 if (selectIndex == 0 && doneBlock) {
			 doneBlock();
		 }
	 }];
}

+ (void)showOKCancelAlertTitle:(NSString *)title
					   message:(NSString *)message
				withController:(UIViewController *)viewController
					 doneBlock:(void(^)())doneBlock
{
	[self showAlertTitle:title
				 message:message
			buttonTitles:@[@"确定",@"取消"]
		  withController:viewController
			 selectBlock:^(NSInteger selectIndex, NSString *title)
	 {
		 if (selectIndex == 0 && doneBlock) {
			 doneBlock();
		 }
	 }];
}

//自定义按钮
+ (void)showAlertTitle:(NSString *)title
			   message:(NSString *)message
		  buttonTitles:(NSArray *)buttonTitles
		withController:(UIViewController *)viewController
		   selectBlock:(void(^)(NSInteger selectIndex,NSString *title))selectBlock
{
	UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	for (int i = 0; i < [buttonTitles count]; i++) {
		NSString *title = buttonTitles[i];
		
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
			if (selectBlock) {
				selectBlock(i,title);
			}
			[[RMAlertView alertWindow]setHidden:YES];
		}];
		[action setValue:RM_MAIN_COLOR forKey:@"titleTextColor"];
		[alertCtrl addAction:action];
	}
	if ([message length]) {
		NSMutableAttributedString *messageStr = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0],NSForegroundColorAttributeName:RM_BLACK_COLOR}];
		[alertCtrl setValue:messageStr forKey:@"attributedMessage"];
	}
	
	if (viewController == nil) {
		[[RMAlertView alertWindow] makeKeyAndVisible];
		[[RMAlertView alertWindow].rootViewController presentViewController:alertCtrl animated:YES completion:nil];
	}else{
		[viewController presentViewController:alertCtrl animated:YES completion:nil];
	}
}

+ (UIWindow *)showAlertWindow{
	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setBackgroundColor:[UIColor clearColor]];
	UIViewController*rootViewController = [[UIViewController alloc] init];
	[[rootViewController view] setBackgroundColor:[UIColor clearColor]];
	// set window level
	[window setWindowLevel:UIWindowLevelAlert + 1];
	[window setRootViewController:rootViewController];
	
	return window;
}

@end
