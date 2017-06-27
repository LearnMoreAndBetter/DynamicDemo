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
#import "RMDynamicImageView.h"

@interface ViewController ()<UICollisionBehaviorDelegate>

@property (strong, nonatomic)UIDynamicAnimator *animator;//强引用animator，否则代码块执行完成后，将被释放
@property (strong, nonatomic)CMMotionManager * manager;
@property (strong, nonatomic)UIGravityBehavior *gravity;
@property (strong, nonatomic)UICollisionBehavior *collision;
@property (strong, nonatomic)UIDynamicItemBehavior *dynamicItem;
@property (strong, nonatomic)NSMutableArray *ballList;

@property (strong, nonatomic)UITextField *textField;
@property (strong, nonatomic)UIButton *submitButton;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.title = @"汉诺塔游戏";
	
	[self addSubviews];
	
	[self addAnimatorBehavior];
	
	[self startMotion];

}

- (void)addAnimatorBehavior{
	[self.animator addBehavior:self.gravity];
	[self.animator addBehavior:self.collision];
	[self.animator addBehavior:self.dynamicItem];
}

- (void)addSubviews{
	[self.view addSubview:self.textField];
	[self.view addSubview:self.submitButton];
	
	for (NSInteger i = 0; i < 5; i ++) {
		RMDynamicImageView *ball = [[RMDynamicImageView alloc]initWithFrame:CGRectMake(60 * i, 64, 50, 50)];
		ball.backgroundColor = [UIColor redColor];
		ball.layer.masksToBounds = YES;
		ball.layer.cornerRadius = 25.0;
		ball.image = [UIImage imageNamed:@"icon_ball.jpg"];
		ball.contentMode = UIViewContentModeScaleAspectFit;
		
		ball.collisionBoundsType = UIDynamicItemCollisionBoundsTypeEllipse;
		
		[self.view addSubview:ball];
		[self.ballList addObject:ball];
	}
	
}


- (void)startMotion{
	//	__weak typeof(self) weakSelf = self;
	
	if (!self.manager.isDeviceMotionAvailable) {
		NSLog(@"换手机吧");
		return;
	}
	
	[self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
		if (error) {
			NSLog(@"error = %@", error);
			return;
		}
		// 设置重力的方向（是一个二维向量）
		self.gravity.gravityDirection = CGVectorMake(motion.gravity.x, -motion.gravity.y);
	}];
}



//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//	[self.animator removeBehavior:self.snapBehavior];
	//获取触摸点
//	UITouch *touch = [touches anyObject];
//	CGPoint point = [touch locationInView:touch.view];
	
//	self.snapBehavior = [[UISnapBehavior alloc] initWithItem:touch.view snapToPoint:point];
//	// 改变震动幅度，0表示振幅最大，1振幅最小
//	self.snapBehavior.damping = 0.5;
//	
//	// 4. 将吸附事件添加到仿真者行为中
//	[self.animator addBehavior:self.snapBehavior];
	
//}

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

//添加重力行为
- (UIGravityBehavior *)gravity{
	if (!_gravity) {
		_gravity = [[UIGravityBehavior alloc]initWithItems:self.ballList];
		_gravity.magnitude = 9.8; //加速度
	}
	return _gravity;
}

//添加碰撞行为
- (UICollisionBehavior *)collision{
	if (!_collision) {
		UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:self.ballList];
		collision.translatesReferenceBoundsIntoBoundary = YES;
		collision.collisionDelegate = self;
		// 手动添加边界
		UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.submitButton.frame];
		[collision addBoundaryWithIdentifier:@"redBoundary" forPath:bezierPath];
	
		
		_collision = collision;
	}
	return _collision;
}

//添加物理属性
- (UIDynamicItemBehavior *)dynamicItem{
	if (!_dynamicItem) {
		UIDynamicItemBehavior *dynamicItem = [[UIDynamicItemBehavior alloc]initWithItems:self.ballList];
		dynamicItem.elasticity = 0.8;// 设置物体弹性，振幅
		dynamicItem.friction = 0.2;//磨擦力 0.0~1.0 在碰撞行为里，碰撞对象的边缘产生
		dynamicItem.density = 1000;//密度
		dynamicItem.allowsRotation = YES;//是否允许旋转
		dynamicItem.resistance = 0.2;//抗阻力
		
		_dynamicItem = dynamicItem;
	}
	return _dynamicItem;
}


- (CMMotionManager *)manager{
	if (!_manager) {
		CMMotionManager * manager = [[CMMotionManager alloc]init];
		manager.deviceMotionUpdateInterval = 0.01;
		
		_manager = manager;
	}
	return _manager;
}

//添加执行动画
- (UIDynamicAnimator *)animator{
	if (!_animator) {
		UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
		
		
		_animator = animator;
	}
	return _animator;
}

- (NSMutableArray *)ballList{
	if (!_ballList) {
		_ballList = [NSMutableArray array];
	}
	return _ballList;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}



@end
