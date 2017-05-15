//
//  DPPayChoiceVIew.h
//  DisneyPhotoAuto
//
//  Created by 马小奋 on 2017/5/7.
//  Copyright © 2017年 Bruno.ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPPayChoiceVIew : UIView
@property (nonatomic , strong)void (^aliPay)(void);
@property (nonatomic , strong)void (^wechatPay)(void);
@end
