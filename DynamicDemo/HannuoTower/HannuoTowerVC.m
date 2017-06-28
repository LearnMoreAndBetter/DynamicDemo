//
//  HannuoTowerVC.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/21.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "HannuoTowerVC.h"
#import "CommonHeader.h"
#import "TowerLearnInstructionVC.h"

@interface HannuoTowerVC ()<CAAnimationDelegate>
{
	NSInteger _index;//步骤数
	dispatch_queue_t _globalQueue;
}

//@property (copy, nonatomic)NSMutableArray *instructionLists;//存放文字解说
@property (copy, nonatomic)NSMutableArray *panLists;//存放盘子View
@property (strong, nonatomic)UIButton *rightButton;
@property (strong, nonatomic)UIButton *startButton;
@property (strong, nonatomic)UIButton *resetButton;
@property (strong, nonatomic)dispatch_semaphore_t sema;
@property (strong, nonatomic)UIView *panView;

@end

@implementation HannuoTowerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor whiteColor];
	self.title = @"汉诺塔游戏教学";
	
	[self addRightNavButton];
	
	[self addSubviews];
	
}

- (void)addRightNavButton{
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)addSubviews{
	for (NSInteger i = 0; i < 3; i ++) {
		CALayer *verticalLayer = [CALayer layer];
		verticalLayer.frame = CGRectMake(50 + APP_SCREEN_WIDTH/3 * i, APP_SCREEN_HEIGHT/2 - 210, 2, 310);
		verticalLayer.backgroundColor = [UIColor blackColor].CGColor;
		[self.view.layer addSublayer:verticalLayer];
		
		CALayer *horizonalLayer = [CALayer layer];
		horizonalLayer.frame = CGRectMake(20 + APP_SCREEN_WIDTH/3 * i, APP_SCREEN_HEIGHT/2 + 100, 60, 2);
		horizonalLayer.backgroundColor = [UIColor blackColor].CGColor;
		[self.view.layer addSublayer:horizonalLayer];
		
		UILabel *towerNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20 + APP_SCREEN_WIDTH/3 * i, APP_SCREEN_HEIGHT/2 + 105, 60, 20)];
		towerNameLabel.textColor = [UIColor blackColor];
		towerNameLabel.textAlignment = NSTextAlignmentCenter;
		[self.view addSubview:towerNameLabel];
		if (i == 0) {
			towerNameLabel.text = @"A";
		}else if(i == 1){
			towerNameLabel.text = @"B";
		}else if(i == 2){
			towerNameLabel.text = @"C";
		}
	}

	[self addPanViews];

	[self.view addSubview:self.startButton];
	[self.view addSubview:self.resetButton];
}

- (void)addPanViews{
	for (UIView *panView in self.panLists) {
		[panView.layer removeAnimationForKey:@"keyAnimation"];
	}
	[self.panLists makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.panLists removeAllObjects];
	
	for (NSInteger i = 0; i < self.towerNum; i ++) {
		CGFloat panWidth = [self panWidth:i + 1];
		CGFloat y = APP_SCREEN_HEIGHT/2 + 100 - (self.towerNum - i) * [self panHeight];
		UIView *panView = [[UIView alloc]initWithFrame:CGRectMake(51 - panWidth/2, y, panWidth, [self panHeight])];
		panView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
		panView.tag = 101 + i;
		[self.view addSubview:panView];
		[self.panLists addObject:panView];
	}
}


- (CGFloat)panWidth:(NSInteger)panNum{
	CGFloat widthScale = (APP_SCREEN_WIDTH/3 - 50) / self.towerNum;

	return widthScale * (panNum - 1) + 30;
}

- (CGFloat)panHeight{
	CGFloat panHeight = 0.0;
	if (self.towerNum < 10) {
		panHeight = 30;
	}else{
		panHeight = 300.0/self.towerNum;
	}
	return panHeight;
}

/*
 汉诺塔游戏规则：
 
 1、将盘子全部移动到塔C
 2、每次只能移动一个圆盘；
 3、大盘不能叠在小盘上面。
 */

- (void)hannoTowerWith:(NSInteger)num{
	HannuoTowerModel *ATower = [[HannuoTowerModel alloc] init];
	ATower.towerName = @"A";
	ATower.towerNum = self.towerNum;
	
	HannuoTowerModel *BTower = [[HannuoTowerModel alloc] init];
	BTower.towerName = @"B";
	BTower.towerNum = 0;
	
	HannuoTowerModel *CTower = [[HannuoTowerModel alloc] init];
	CTower.towerName = @"C";
	CTower.towerNum = 0;
	
	
	_globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(_globalQueue, ^{
		[self hannoTowerNum:num TowerA:ATower TowerB:BTower TowerC:CTower];
	});
	
}

- (void)hannoTowerNum:(NSInteger)towerNum TowerA:(HannuoTowerModel *)towerA TowerB:(HannuoTowerModel *)towerB TowerC:(HannuoTowerModel *)towerC{
	if (towerNum == 1) {
		[self move:towerNum from:towerA to:towerC];
	}else{
		//把前n-1个盘子从A移动到B
		[self hannoTowerNum:towerNum - 1 TowerA:towerA TowerB:towerC TowerC:towerB];
		//把第n个盘子从A移动到C
		[self move:towerNum from:towerA to:towerC];
		//把前n-1个盘子从B移动到C
		[self hannoTowerNum:towerNum - 1 TowerA:towerB TowerB:towerA TowerC:towerC];
	}
}


- (void)move:(NSInteger)towerNum from:(HannuoTowerModel *)fromTower to:(HannuoTowerModel *)toTower{
	NSString *instruction = [NSString stringWithFormat:@"第%ld次移动：把%ld号盘从%@移动到%@", ++_index, towerNum, fromTower.towerName, toTower.towerName];
	NSLog(@"%@", instruction);
	
	fromTower.towerNum --;
	toTower.towerNum ++;
	
	UIView *panView = self.panLists[towerNum - 1];
	_panView = panView;
	CGRect originFrame = panView.frame;
	CGRect finalFrame = originFrame;
	CGFloat panWidth = [self panWidth:towerNum];
	if ([toTower.towerName isEqualToString:@"A"]) {
		finalFrame.origin.x = 51- panWidth/2;
	}else if ([toTower.towerName isEqualToString:@"B"]) {
		finalFrame.origin.x = 51- panWidth/2 + APP_SCREEN_WIDTH/3;
	}else if ([toTower.towerName isEqualToString:@"C"]) {
		finalFrame.origin.x = 51- panWidth/2 + APP_SCREEN_WIDTH/3 * 2;
	}
	
	finalFrame.origin.y = APP_SCREEN_HEIGHT/2 + 100 - toTower.towerNum * [self panHeight];
	_sema = dispatch_semaphore_create(0);// 初始化信号量为0
	dispatch_async(dispatch_get_main_queue(), ^{
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(originFrame.origin.x + originFrame.size.width/2, originFrame.origin.y + originFrame.size.height/2)];
		
		[path addLineToPoint:CGPointMake(originFrame.origin.x + originFrame.size.width/2, APP_SCREEN_HEIGHT/2 - 210 - originFrame.size.height/2)];
		
		[path addLineToPoint:CGPointMake(finalFrame.origin.x + finalFrame.size.width/2, APP_SCREEN_HEIGHT/2 - 210 - finalFrame.size.height/2)];
		
		[path addLineToPoint:CGPointMake(finalFrame.origin.x + finalFrame.size.width/2, finalFrame.origin.y + finalFrame.size.height/2)];
		
		CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		pathAnimation.path = path.CGPath;
		pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		pathAnimation.duration = 1.5;
		pathAnimation.delegate = self;
		pathAnimation.removedOnCompletion = NO;
		[panView.layer addAnimation:pathAnimation forKey:@"keyAnimation"];
		
		panView.frame = finalFrame;
	});
	
	dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);// 信号量若没增加，则一直等待，直到动画完成
	
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	if (anim == [_panView.layer animationForKey:@"keyAnimation"]) {
		dispatch_semaphore_signal(_sema);// 增加信号量，结束等待
		
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
//	[self resetButtonAction];
	
}


- (void)clickNavRightButton{
	TowerLearnInstructionVC *vc = [[TowerLearnInstructionVC alloc]init];
	vc.towerNum = self.towerNum;
	[self.navigationController pushViewController:vc animated:YES];
}


- (void)startButtonAction{
	self.startButton.userInteractionEnabled = NO;

	_index = 0;
	[self hannoTowerWith:self.towerNum];
}

- (void)resetButtonAction{
	[RMAlertView showMessage:@"尚未实现"];
//	[RMAlertView showMessage:@"重置成功"];
//	self.startButton.userInteractionEnabled = YES;
//	
//	[self addPanViews];
//	
}

- (UIButton *)rightButton{
	if (!_rightButton) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 25)];
		[button setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
		[button setTitle:@"说明" forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:15.0];
		[button addTarget:self action:@selector(clickNavRightButton) forControlEvents:UIControlEventTouchUpInside];
		_rightButton = button;
	}
	return  _rightButton;
}

- (UIButton *)startButton{
	if (!_startButton) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, APP_SCREEN_HEIGHT - 64 - 50, APP_SCREEN_WIDTH/2, 50)];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		button.backgroundColor = [UIColor redColor];
		[button setTitle:@"开始" forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:15.0];
		[button addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
		_startButton = button;
	}
	return  _startButton;
}

- (UIButton *)resetButton{
	if (!_resetButton) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(APP_SCREEN_WIDTH/2, APP_SCREEN_HEIGHT - 64 - 50, APP_SCREEN_WIDTH/2, 50)];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		button.backgroundColor = [UIColor greenColor];
		[button setTitle:@"重置" forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:15.0];
		[button addTarget:self action:@selector(resetButtonAction) forControlEvents:UIControlEventTouchUpInside];
		_resetButton = button;
	}
	return  _resetButton;
}

- (NSMutableArray *)panLists{
	if (!_panLists) {
		_panLists = [NSMutableArray array];
	}
	return _panLists;
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


@implementation HannuoTowerModel


@end
