//
//  ViewController.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/20.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "HannuoTowerVC.h"
#import "RMAlertView.h"
#import "CommonHeader.h"

@interface ViewController ()<UICollisionBehaviorDelegate>

@property (strong, nonatomic)UIDynamicAnimator *animator;//强引用animator，否则代码块执行完成后，将被释放
@property (strong, nonatomic)CMMotionManager * manager;

@property (strong, nonatomic)UITextField *textField;

@property (strong, nonatomic)UIButton *submitButton;

@property (strong, nonatomic)UISnapBehavior *snapBehavior;

@end

@implementation ViewController



- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.title = @"汉诺塔游戏";
	
	[self.view addSubview:self.textField];
	[self.view addSubview:self.submitButton];
	
	NSMutableArray *ballList = [NSMutableArray array];
	for (NSInteger i = 0; i < 5; i ++) {
		UIView *ball = [[UIView alloc]initWithFrame:CGRectMake(60 * i, 5, 50, 50)];
		ball.backgroundColor = [UIColor redColor];
		ball.layer.masksToBounds = YES;
		ball.layer.cornerRadius = 25.0;
		[self.view addSubview:ball];
		[ballList addObject:ball];
	}
	
	// 添加重力行为
	UIGravityBehavior *gravity = [[UIGravityBehavior alloc]initWithItems:ballList];
	gravity.magnitude = 1; //加速度
	
	// 添加碰撞行为
	UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:ballList];
	collision.translatesReferenceBoundsIntoBoundary = YES;
	collision.collisionDelegate = self;
	// 手动添加边界
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.submitButton.frame];
	[collision addBoundaryWithIdentifier:@"redBoundary" forPath:bezierPath];

	
	// 物体的属性行为
	UIDynamicItemBehavior *dynamicItem = [[UIDynamicItemBehavior alloc]initWithItems:ballList];
	dynamicItem.elasticity = 0.8;// 设置物体弹性，振幅
	dynamicItem.friction = 0.2;//磨擦力 0.0~1.0 在碰撞行为里，碰撞对象的边缘产生
	dynamicItem.density = 0.2;//密度
	dynamicItem.allowsRotation = YES;//是否允许旋转
	dynamicItem.resistance = 0;//抗阻力
	
	
	
	// 初始化仿真者
	UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
	[animator addBehavior:gravity];
	[animator addBehavior:collision];
	[animator addBehavior:dynamicItem];
	self.animator = animator;
	
	
							
//	__weak typeof(self) weakSelf = self;
	CMMotionManager * manager = [[CMMotionManager alloc]init];
	self.manager = manager;
	if (!manager.isDeviceMotionAvailable) {
		NSLog(@"换手机吧");
		return;
	}

	manager.deviceMotionUpdateInterval = 0.01;
	
	[manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
		if (error) {
			NSLog(@"error = %@", error);
			return;
		}
		// 设置重力的方向（是一个二维向量）
		gravity.gravityDirection = CGVectorMake(motion.gravity.x, -motion.gravity.y);
	}];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	[self.animator removeBehavior:self.snapBehavior];
	//获取触摸点
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:touch.view];
	
//	self.snapBehavior = [[UISnapBehavior alloc] initWithItem:touch.view snapToPoint:point];
//	// 改变震动幅度，0表示振幅最大，1振幅最小
//	self.snapBehavior.damping = 0.5;
//	
//	// 4. 将吸附事件添加到仿真者行为中
//	[self.animator addBehavior:self.snapBehavior];
	
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



- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
	
	UIView *view = (UIView *)item;
	view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
	
}


- (UITextField *)textField{
	if (!_textField) {
		_textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 40)];
		_textField.placeholder = @"请输入汉诺塔的层数";
//		_textField.keyboardType = UIKeyboardTypeNumberPad;
	}
	return _textField;
}

- (UIButton *)submitButton{
	if (!_submitButton) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(60, 160, [UIScreen mainScreen].bounds.size.width - 120, 50)];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button setTitle:@"开始教学" forState:UIControlStateNormal];
		//		button.titleLabel.textAlignment = NSTextAlignmentCenter;
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



@end
