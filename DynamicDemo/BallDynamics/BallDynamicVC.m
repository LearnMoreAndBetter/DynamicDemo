//
//  BallDynamicVC.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/27.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "BallDynamicVC.h"
#import <CoreMotion/CoreMotion.h>
#import "CommonHeader.h"
#import "RMDynamicImageView.h"

@interface BallDynamicVC ()<UICollisionBehaviorDelegate>

@property (strong, nonatomic)UIDynamicAnimator *animator;//强引用animator，否则代码块执行完成后，将被释放
@property (strong, nonatomic)CMMotionManager * manager;
@property (strong, nonatomic)UIGravityBehavior *gravity;
@property (strong, nonatomic)UICollisionBehavior *collision;
@property (strong, nonatomic)UIDynamicItemBehavior *dynamicItem;
@property (strong, nonatomic)NSMutableArray *ballList;
@property (strong, nonatomic)CAShapeLayer *boundryLayer;
@property (strong, nonatomic)UIBezierPath *boundryPath;

@end

@implementation BallDynamicVC


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.title = @"物理仿真球";
	
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
	[self.view.layer addSublayer:self.boundryLayer];
	
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



- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
	
	UIView *view = (UIView *)item;
	view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
	
}

#pragma mark- subviews


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
		[collision addBoundaryWithIdentifier:@"redBoundary" forPath:self.boundryPath];
		
		
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

- (UIBezierPath *)boundryPath{
	if (!_boundryPath) {
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(0, 100)];
		[path addLineToPoint:CGPointMake(0, 110)];
		[path addLineToPoint:CGPointMake(100, APP_SCREEN_HEIGHT)];
		[path addLineToPoint:CGPointMake(105, APP_SCREEN_HEIGHT)];
		[path closePath];
		_boundryPath = path;
	}
	return _boundryPath;
}

- (CAShapeLayer *)boundryLayer{
	if (!_boundryLayer) {
		_boundryLayer = [CAShapeLayer layer];
		_boundryLayer.path = self.boundryPath.CGPath;
//		_boundryLayer.lineWidth = 0;
		_boundryLayer.fillColor = [UIColor redColor].CGColor;
		
	}
	return _boundryLayer;
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
