//
//  TowerLearnInstructionVC.m
//  DynamicDemo
//
//  Created by 王林 on 2017/6/21.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import "TowerLearnInstructionVC.h"
#import "CommonHeader.h"


@interface TowerLearnInstructionVC ()<UITableViewDelegate, UITableViewDataSource>
{
	NSInteger _index;//步骤数
}
@property (strong, nonatomic)UITableView *tableView;
@property (copy, nonatomic)NSMutableArray *instructionLists;//存放文字解说

@end

@implementation TowerLearnInstructionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.title = @"教学文字说明";
	[self.view addSubview:self.tableView];
	
	[self hannoTowerWith:self.towerNum];
}


/*
 汉诺塔游戏规则：
 
 1、将盘子全部移动到塔C
 2、每次只能移动一个圆盘；
 3、大盘不能叠在小盘上面。
 */

- (void)hannoTowerWith:(NSInteger)num{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self hannoTowerNum:num TowerA:@"A" TowerB:@"B" TowerC:@"C"];
	});
	
}

- (void)hannoTowerNum:(NSInteger)towerNum TowerA:(NSString *)towerA TowerB:(NSString *)towerB TowerC:(NSString *)towerC{
	if (towerNum == 1) {
		[self move:towerNum from:towerA to:towerC];
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[self.tableView reloadData];
		});
		
	}else{
		//把前n-1个盘子从A移动到B <=> B、C交换 再从A移动到C
		[self hannoTowerNum:towerNum - 1 TowerA:towerA TowerB:towerC TowerC:towerB];
		//把第n个盘子从A移动到C
		[self move:towerNum from:towerA to:towerC];
		//把前n-1个盘子从B移动到C  <=> B、A交换 再从A移动到C
		[self hannoTowerNum:towerNum - 1 TowerA:towerB TowerB:towerA TowerC:towerC];
	}
}


- (void)move:(NSInteger)towerNum from:(NSString *)fromTower to:(NSString *)toTower{
	NSString *instruction = [NSString stringWithFormat:@"第%ld次移动：把%ld号盘从%@移动到%@", ++_index, towerNum, fromTower, toTower];
	NSLog(@"%@", instruction);
	[self.instructionLists addObject:instruction];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.instructionLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *cellId = @"cellId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.text = self.instructionLists[indexPath.row];
	
	return cell;
}

- (UITableView *)tableView{
	if (!_tableView) {
		UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
		tableView.showsVerticalScrollIndicator = NO;
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		tableView.backgroundColor = [UIColor whiteColor];
		tableView.tableFooterView = [[UIView alloc]init];
		_tableView = tableView;
	}
	return _tableView;
}

- (NSMutableArray *)instructionLists{
	if (!_instructionLists) {
		_instructionLists = [NSMutableArray array];
	}
	return _instructionLists;
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
