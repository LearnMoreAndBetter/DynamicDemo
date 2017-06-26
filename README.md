# DynamicDemo
汉诺塔游戏和物理仿真

http://blog.csdn.net/qq_25303213/article/details/73741703

/*
汉诺塔游戏规则：

1、将盘子全部移动到塔C
2、每次只能移动一个圆盘；
3、大盘不能叠在小盘上面。
*/

1. 视图创建



2. 递归算法实现功能



3. layer层动画实现效果


4. 通过信号量来处理，一个动画结束后再开始下一个动画的功能 
关于dispatch_semaphore的使用（传送门）

此外，pathAnimation.removedOnCompletion = NO;必须要加上，否则动画结束后自动移除，在animationDidStop方法中监听不到，[_panView.layer animationForKey:@"keyAnimation"]为null，动画会一直卡着，恩，我也卡在这里好久



物理仿真





CMMotionManager监听持续更新重力方向 


项目持续更新中...
