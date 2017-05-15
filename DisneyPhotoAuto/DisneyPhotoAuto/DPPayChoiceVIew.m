//
//  DPPayChoiceVIew.m
//  DisneyPhotoAuto
//
//  Created by 马小奋 on 2017/5/7.
//  Copyright © 2017年 Bruno.ma. All rights reserved.
//

#import "DPPayChoiceVIew.h"
#import <Masonry/Masonry.h>
@implementation DPPayChoiceVIew
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    self.backgroundColor = [UIColor colorWithHexString:@"#111111" withAlpha:0.5];

    UIButton *aliButton = [[UIButton alloc] init];
    [aliButton setImage:[UIImage imageNamed:@"alipay_pay"] forState:UIControlStateNormal];
    [aliButton addTarget:self action:@selector(aliPayTouch) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *wechatButton = [[UIButton alloc] init];
    [wechatButton setImage:[UIImage imageNamed:@"wechat_pay"] forState:UIControlStateNormal];
    [wechatButton addTarget:self action:@selector(wechatPayTouch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:aliButton];
    [self addSubview:wechatButton];
    
    [aliButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerY.equalTo(self.mas_centerY);
        make.leading.equalTo(self).mas_offset(50);
    }];
    
    [wechatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerY.equalTo(self.mas_centerY);
        make.trailing.equalTo(self).mas_offset(-50);
    }];
}

- (void)setAlpha:(CGFloat)alpha
{
    if (alpha > 0) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
    [super setAlpha:alpha];
}

- (void)aliPayTouch
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    }];

    if (self.aliPay) {
        self.aliPay();
    }
}

- (void)wechatPayTouch
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    }];

    if (self.wechatPay) {
        self.wechatPay();
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    }];
}
@end
