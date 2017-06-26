//
//  RMAlertView.h
//  RMActionSheetProject
//
//  Created by 王林 on 2017/5/19.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RMAlertView : NSObject


#pragma mark - 使用UIAlertController自定义的AlertView
/**
 有“确定”按钮的AlertView
 
 @param title 标题
 @param message 内容
 @param viewController 显示的控制器，可为nil
 */
+ (void)showOKAlertTitle:(NSString *)title
				 message:(NSString *)message
		  withController:(UIViewController *)viewController;

/**
 有“确定”按钮的AlertView
 
 @param title 标题
 @param message 内容
 @param viewController 显示的控制器，可为nil
 @param doneBlock 确定block
 */
+ (void)showOKAlertTitle:(NSString *)title
				 message:(NSString *)message
		  withController:(UIViewController *)viewController
			   doneBlock:(void(^)())doneBlock;

/**
 有“确定”和”取消“按钮的AlertView
 
 @param title 标题
 @param message 内容
 @param viewController 显示的控制器，可为nil
 @param doneBlock 确定block
 */
+ (void)showOKCancelAlertTitle:(NSString *)title
					   message:(NSString *)message
				withController:(UIViewController *)viewController
					 doneBlock:(void(^)())doneBlock;


/**
 有多个按钮的AlertView
 
 @param title 标题
 @param message 内容
 @param buttonTitles 按钮标题
 @param viewController 显示的控制器，可为nil
 @param selectBlock 选择block，返回标题及index
 */
+ (void)showAlertTitle:(NSString *)title
			   message:(NSString *)message
		  buttonTitles:(NSArray *)buttonTitles
		withController:(UIViewController *)viewController
		   selectBlock:(void(^)(NSInteger selectIndex,NSString *title))selectBlock;


#pragma mark - HUD
/**
 无按钮的AlertView（HUD），默认停留时间为1秒
 
 @param text 内容
 */
+ (void)showMessage:(NSString *)text;

/**
 无按钮的AlertView（HUD）
 
 @param text 内容
 @param delay 停留时间
 */
+ (void)showMessage:(NSString *)text
		 afterDelay:(NSTimeInterval)delay;



@end
