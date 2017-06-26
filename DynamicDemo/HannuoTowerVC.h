//
//  HannuoTowerVC.h
//  DynamicDemo
//
//  Created by 王林 on 2017/6/21.
//  Copyright © 2017年 CETC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HannuoTowerVC : UIViewController

@property (assign, nonatomic)NSInteger towerNum;

@end


@interface HannuoTowerModel : NSObject

@property (assign, nonatomic)NSInteger towerNum;

@property (strong, nonatomic)NSString *towerName;

@end
