//
//
//
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "QQLBXScanViewController.h"
#import "CreateBarCodeViewController.h"
#import "ScanResultViewController.h"
#import "LBXScanVideoZoomView.h"
#import <Masonry/Masonry.h>
#import "UIColor+Hex.h"
@interface QQLBXScanViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) LBXScanVideoZoomView *zoomView;
@property (nonatomic, strong) UITextField *codeInputField;
@end

@implementation QQLBXScanViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置扫码后需要扫码图像
    self.isNeedScanImage = YES;
    [self.view addSubview:_topTitle];
    [self drawBottomItems];
    [self drawTitle];
    [self drawCloseButton];
    [self drawTextField];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)drawTextField
{
    self.codeInputField = [[UITextField alloc] init];
    _codeInputField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.codeInputField];
    [_codeInputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_centerY).mas_offset(-50);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    _codeInputField.textColor = [UIColor colorWithHexString:@"1ca8e4"];
    _codeInputField.textAlignment = NSTextAlignmentCenter;
    _codeInputField.font = [UIFont boldSystemFontOfSize:20];
    _codeInputField.delegate = self;
    _codeInputField.returnKeyType = UIReturnKeyDone;
    _codeInputField.userInteractionEnabled = NO;
    _codeInputField.keyboardType = UIKeyboardTypeASCIICapable;
}

- (void)drawCloseButton
{
    UIButton * closeButton = [[UIButton alloc]init];
    [closeButton setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_close"] forState:UIControlStateNormal];

    [self.view addSubview: closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).mas_offset(30);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(-20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
}

- (void)close
{
    [_codeInputField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//绘制扫描区域
- (void)drawTitle
{
    if (!_topTitle)
    {
        self.topTitle = [[UILabel alloc]init];
        [self.view addSubview:_topTitle];
        [_topTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).mas_offset(30);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        
        _topTitle.textAlignment = NSTextAlignmentCenter;
        _topTitle.numberOfLines = 0;
        _topTitle.text = @"请扫描您的乐拍通二维码\n或者迪士尼门票二维码";
        _topTitle.textColor = [UIColor whiteColor];
    }
}

- (void)cameraInitOver
{
    if (self.isVideoZoom) {
        [self zoomView];
    }
}

- (LBXScanVideoZoomView*)zoomView
{
    if (!_zoomView)
    {
      
        CGRect frame = self.view.frame;
        
        int XRetangleLeft = self.style.xScanRetangleOffset;
        
        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
        
        if (self.style.whRatio != 1)
        {
            CGFloat w = sizeRetangle.width;
            CGFloat h = w / self.style.whRatio;
            
            NSInteger hInt = (NSInteger)h;
            h  = hInt;
            
            sizeRetangle = CGSizeMake(w, h);
        }
        
        CGFloat videoMaxScale = [self.scanObj getVideoMaxScale];
        
        //扫码区域Y轴最小坐标
        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
        CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
        
        CGFloat zoomw = sizeRetangle.width + 40;
        _zoomView = [[LBXScanVideoZoomView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-zoomw)/2, YMaxRetangle + 40, zoomw, 18)];
        
        [_zoomView setMaximunValue:videoMaxScale/4];
        
        
        __weak __typeof(self) weakSelf = self;
        _zoomView.block= ^(float value)
        {            
            [weakSelf.scanObj setVideoScale:value];
        };
        [self.view addSubview:_zoomView];
                
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [self.view addGestureRecognizer:tap];
    }
    
    return _zoomView;
   
}

- (void)tap
{
    _zoomView.hidden = !_zoomView.hidden;
}

- (void)drawBottomItems
{
    if (_bottomItemsView) {
        
        return;
    }
    
    self.bottomItemsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-100,
                                                                      CGRectGetWidth(self.view.frame), 100)];
    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [self.view addSubview:_bottomItemsView];
    
    
    CGSize size = CGSizeMake(65, 87);
    self.btnFlash = [[UIButton alloc]init];
    [_bottomItemsView addSubview:_btnFlash];
    [_btnFlash mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.leading.equalTo(_bottomItemsView.mas_leading).mas_offset(50);
        make.centerY.equalTo(_bottomItemsView.mas_centerY);
    }];
     [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnInput = [[UIButton alloc]init];
    [_bottomItemsView addSubview:_btnInput];
    [_btnInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.trailing.equalTo(_bottomItemsView.mas_trailing).mas_offset(-50);
        make.centerY.equalTo(_bottomItemsView.mas_centerY);
    }];
    [_btnInput setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_input_btn_photo_nor"] forState:UIControlStateNormal];
    [_btnInput setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_input_btn_photo_down"] forState:UIControlStateHighlighted];
    [_btnInput addTarget:self action:@selector(inputCode) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)showError:(NSString*)str
{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
}

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (array.count < 1)
    {
        [self popAlertMsgWithScanResult:nil];
     
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    
    NSMutableArray * cardIds = [NSMutableArray new];
    for (LBXScanResult *result in array) {
        if (result.strScanned != nil) {
            NSArray * tmp = [result.strScanned componentsSeparatedByString:@"="];
            NSString * cardId = [tmp lastObject];
            if (cardId != nil) {
                [cardIds addObject:cardId];
                NSLog(@"scanResult:%@",cardId);
            }
        }
    }
    __weak __typeof(self) weakSelf = self;

    if (_scanSuccess != nil) {
        [self dismissViewControllerAnimated:YES completion:^{
            weakSelf.scanSuccess(cardIds);
        }];
        return;
    }

}

- (void)popAlertMsgWithScanResult:(NSString*)strResult
{
    if (!strResult) {
        strResult = @"抱歉,我还没看清...";
    }
    
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showAlertWithTitle:@"扫码内容" msg:strResult buttonsStatement:@[@"知道了"] chooseBlock:^(NSInteger buttonIdx) {
        
        [weakSelf reStartDevice];
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_codeInputField.isFirstResponder == YES) {
        [_codeInputField resignFirstResponder];
        _codeInputField.userInteractionEnabled = NO;
        _codeInputField.text = @"";
    }
}

#pragma mark -底部功能项
//打开相册
- (void)openPhoto
{
}

//开关闪光灯
- (void)openOrCloseFlash
{
    
    [super openOrCloseFlash];
   
    
    if (self.isOpenFlash)
    {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    }
    else
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
}


#pragma mark -底部功能项


- (void)myQRCode
{
    CreateBarCodeViewController *vc = [CreateBarCodeViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputCode
{
    _codeInputField.userInteractionEnabled = YES;
    [_codeInputField becomeFirstResponder];
}

#pragma mark -textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString * cardId = textField.text;
    
    NSCharacterSet *setToRemove =
    [[ NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"]
     invertedSet ];
    
    cardId  = [[cardId componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
    ////////////////////////////////////////////////////////////////////////
    if (cardId != nil && cardId.length > 4) {
        if (_scanSuccess != nil) {
            __weak typeof(self) weakSelf = self;
            [self dismissViewControllerAnimated:YES completion:^{
                weakSelf.scanSuccess(@[cardId.uppercaseString]);
            }];
        }
    }


    [textField resignFirstResponder];
    _codeInputField.userInteractionEnabled = NO;
    _codeInputField.text = @"";

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _codeInputField.userInteractionEnabled = NO;
    _codeInputField.text = @"";
}
@end
