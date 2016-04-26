//
//  ViewController.m
//  coreMotionTest
//
//  Created by 马小奋 on 15/7/20.
//  Copyright (c) 2015年 马小奋. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
@interface ViewController ()
@property (nonatomic , strong)UILabel * lable;
@property (nonatomic, strong) CMMotionManager *mManager;
@property (readwrite) float velocity;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.lable.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.lable];
    
    self.mManager = [[CMMotionManager alloc]init];
    
    NSTimeInterval updateInterval = 0.07;
    
    CGSize size = self.view.frame.size;
    
    __block CGRect f = [self.lable frame];
    
    //在block中，只能使用weakSelf。
    UILabel * __weak weakSelf = self.lable;
    
    self.velocity = 200;

    
    /* 判断是否加速度传感器可用，如果可用则继续 */
    if ([self.mManager isAccelerometerAvailable] == YES) {
        /* 给采样频率赋值，单位是秒 */
        [self.mManager setAccelerometerUpdateInterval:updateInterval];
        
        /* 加速度传感器开始采样，每次采样结果在block中处理 */
        [self.mManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             f.origin.x += (accelerometerData.acceleration.x * self.velocity) * 1;
             f.origin.y += (accelerometerData.acceleration.y * self.velocity) * -1;
             
             if(f.origin.x < 0)
                 f.origin.x = 0;
             if(f.origin.y < 0)
                 f.origin.y = 0;
             
             if(f.origin.x > (size.width - f.size.width))
                 f.origin.x = (size.width - f.size.width);
             if(f.origin.y > (size.height - f.size.height))
                 f.origin.y = (size.height - f.size.height);
             
             /* 运动动画 */
             [UIView beginAnimations:nil context:nil];
             [UIView setAnimationDuration:0.1];
             [weakSelf setFrame:f];
             [UIView commitAnimations];
//             CGRect frame = self.lable.frame;
//             frame.origin.x = accelerometerData.acceleration.x ;
//             frame.origin.y = accelerometerData.acceleration.y ;
//             self.lable.frame = frame;
         }];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
