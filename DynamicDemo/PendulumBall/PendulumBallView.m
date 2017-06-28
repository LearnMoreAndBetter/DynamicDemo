//
//  PendulumBallView.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/28.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "PendulumBallView.h"
#import "CommonHeader.h"
#import "RMDynamicImageView.h"

@interface PendulumBallView()

@property (strong, nonatomic)RMDynamicImageView *ball;
@property (strong, nonatomic)UIView *anchorView;
@property (strong, nonatomic)UIDynamicAnimator *animator;//强引用animator，否则代码块执行完成后，将被释放
@property (strong, nonatomic)UIGravityBehavior *gravity;
@property (strong, nonatomic)UICollisionBehavior *collision;
@property (strong, nonatomic)UIAttachmentBehavior *attachment;
@property (strong, nonatomic)UIDynamicItemBehavior *dynamicItem;
@property (strong, nonatomic)UISnapBehavior *snap;


@end

@implementation PendulumBallView


- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
		
		[self addSubviews];
		
		[self addBehaviors];
	}
	return self;
}


- (void)addBehaviors{
	[self.animator addBehavior:self.gravity];
	
	[self.animator addBehavior:self.collision];
	
	[self.animator addBehavior:self.dynamicItem];
	
	[self.animator addBehavior:self.attachment];
}


- (void)addSubviews{
	
	[self addSubview:self.ball];
	
	[self addSubview:self.anchorView];
	
}


//使用 touchBegan方法移除物理仿真 用 touchMove的方法使我们的小球随着手指滑动 使用 touchEnd 方法移除 snap 行为释放小球 并添加仿真动画
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	
	[self.animator removeAllBehaviors];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	
	if (_snap == nil) {
		UITouch *touch=[touches anyObject];
		CGPoint point=[touch locationInView:self];
		
		_snap = [[UISnapBehavior alloc]initWithItem:self.ball snapToPoint:point];
		_snap.damping = 0.5;
		[self.animator addBehavior:_snap];
	}else{
		[self.animator removeBehavior:_snap];
		_snap = nil;
	}
	
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	[self.animator removeBehavior:_snap];
	[self addBehaviors];
}


- (void)drawRect:(CGRect)rect {
	
	// 1. 获取路径
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	
	// 2. 划线
	[bezierPath moveToPoint:self.anchorView.center];
	
	[bezierPath addLineToPoint:self.ball.center];
	
	bezierPath.lineWidth = 6;
	
	[[UIColor orangeColor] setStroke];
	// 3. 渲染
	[bezierPath stroke];
	
}


//添加了Observer必须释放，不然会造成内存泄露。
-(void)dealloc
{
	[self.ball removeObserver:self forKeyPath:@"center"];
	
}

//监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
	if ([keyPath isEqualToString:@"center"]) {
		[self setNeedsDisplay];
	}
}

#pragma mark- subviews

- (RMDynamicImageView *)ball{
	if (!_ball) {
		RMDynamicImageView *ball = [[RMDynamicImageView alloc]initWithFrame:CGRectMake(100, 0, 50, 50)];
		ball.backgroundColor = [UIColor redColor];
		ball.layer.masksToBounds = YES;
		ball.layer.cornerRadius = 25.0;
		ball.image = [UIImage imageNamed:@"icon_ball.jpg"];
		ball.contentMode = UIViewContentModeScaleAspectFit;
		
		ball.collisionBoundsType = UIDynamicItemCollisionBoundsTypeEllipse;
		
		//这里添加的 kvo 方法作用是当监听到小球的中心变化时 执行 setNeedDisplay 方法 走了这方法后 就会重新绘制
		[ball addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
		
		_ball = ball;
	}
	return _ball;
}


- (UIView *)anchorView{
	if (!_anchorView) {
		UIView *anchorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
		anchorView.center = CGPointMake(APP_SCREEN_WIDTH/2, 100);
		anchorView.backgroundColor = [UIColor blueColor];
		anchorView.layer.masksToBounds = YES;
		anchorView.layer.cornerRadius = 15.0;
		
		_anchorView = anchorView;
	}
	return _anchorView;
}


//添加重力行为
- (UIGravityBehavior *)gravity{
	if (!_gravity) {
		_gravity = [[UIGravityBehavior alloc]initWithItems:@[self.ball]];
		_gravity.magnitude = 10; //加速度
	}
	return _gravity;
}

//添加碰撞行为
- (UICollisionBehavior *)collision{
	if (!_collision) {
		UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:@[self.ball]];
		collision.translatesReferenceBoundsIntoBoundary = YES;
		//		collision.collisionDelegate = self;
		
		_collision = collision;
	}
	return _collision;
}

// 添加附着行为
- (UIAttachmentBehavior *)attachment{
	if (!_attachment) {
		UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc]initWithItem:self.ball attachedToAnchor:self.anchorView.center];
		//		attachment.length = 120;//设置固定的附着长度
		_attachment = attachment;
	}
	return _attachment;
}

//添加物理属性
- (UIDynamicItemBehavior *)dynamicItem{
	if (!_dynamicItem) {
		UIDynamicItemBehavior *dynamicItem = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ball]];
		dynamicItem.elasticity = 0.8;// 设置物体弹性，振幅
		dynamicItem.friction = 0.2;//磨擦力 0.0~1.0 在碰撞行为里，碰撞对象的边缘产生
		dynamicItem.density = 1000;//密度
		dynamicItem.allowsRotation = YES;//是否允许旋转
		dynamicItem.resistance = 0.2;//抗阻力
		
		_dynamicItem = dynamicItem;
	}
	return _dynamicItem;
}


//添加执行动画
- (UIDynamicAnimator *)animator{
	if (!_animator) {
		UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		
		_animator = animator;
	}
	return _animator;
}


@end
