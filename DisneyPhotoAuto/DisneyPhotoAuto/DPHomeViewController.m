//
//  DPHomeViewController.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/30/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPHomeViewController.h"
#import "CGQCollectionViewCell.h"
#import "DPCollectionReusableView.h"
#import "ESPictureBrowser.h"
#import "QQLBXScanViewController.h"
#import "StyleDIY.h"
#import "LBXAlertAction.h"
#import <Masonry/Masonry.h>
#import "UIColor+Hex.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DPHomeViewController+AD.h"
#import "GSKeyChainDataManager.h"
#import "DPPayChoiceVIew.h"

#define IMAGES_CARD_ID_CACHE_KEY @"IMAGES_CARD_ID_CACHE_KEY"
@interface DPHomeViewController ()<ESPictureBrowserDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)UICollectionView * imageBrowserCollectionView;
@property (nonatomic, strong)NSMutableDictionary *imageDataCache;
@property (nonatomic, strong)NSMutableArray *cardIds;
@property (nonatomic, strong)NSArray *photoBrowserImages;
@property (nonatomic, weak)ESPictureBrowser *browser;
@property (nonatomic, strong)NSMutableArray *bashSaveImages;
@property (nonatomic, assign)BOOL bashSaveProcessing;
@property (nonatomic, weak)DPPayChoiceVIew * payView;
@end

@implementation DPHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initImageCache];
    [self setUpViews];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initImageCache
{
    _imageDataCache = [NSMutableDictionary new];
    _cardIds = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGES_CARD_ID_CACHE_KEY]];
    if (_cardIds.count > 0) {
        for (NSString *cardId in _cardIds) {
            NSString * imageCardCachePath = [self createLocalPath:cardId];
            NSArray * images = [self getLocalCacheImage:imageCardCachePath];
            [_imageDataCache setObject:images forKey:cardId];
            [self checkCachedImageCardId:cardId count:images.count];
        }
    }
    
}

//获取所有图片的数组
- (NSArray *)getTotalImages
{
    NSMutableArray * totalImages = [NSMutableArray new];
    for (NSString *cardId in _cardIds) {
        NSArray * images = [_imageDataCache objectForKey:cardId];
        [totalImages addObjectsFromArray:images];
    }
    
    return totalImages;
}

- (NSInteger)indexPathToIndex:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger index = row;
    for (NSInteger i = 0 ; i < section ; i++) {
        NSString * cardId = [_cardIds objectAtIndex:i];
        NSInteger imageCount = ((NSArray *)[_imageDataCache objectForKey:cardId]).count;
        index += imageCount;
    }
    return  index;
}

- (NSIndexPath *)indexToIndexPath:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger section = 0;
    NSInteger row = 0;
    for (NSInteger i = 0;i < _cardIds.count ; i++) {
        NSString *cardId = [_cardIds objectAtIndex:i];
        NSInteger imageCount = ((NSArray *)[_imageDataCache objectForKey:cardId]).count;
        if (index > imageCount - 1) {
            index = index - imageCount;
            continue;
        } else {
            section = i;
            row = index;
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            break;
        }
    }
    return indexPath;
}

//检查图片数量是否够
- (void)checkCachedImageCardId:(NSString *)cardId count:(NSInteger)count
{
    NSArray * imageUrls = [[NSUserDefaults standardUserDefaults] objectForKey:cardId];
    if (imageUrls == nil) {
        return;
    }
    
    if (count != imageUrls.count) {
        [self downloadImageByCardId:cardId];
    }
}

//获取cardID 上图片的缓存路径

- (NSString *)createLocalPath:(NSString *)cardId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directPath = [PHOTOES_CACHE_PATH stringByAppendingPathComponent:cardId];
    [fileManager createDirectoryAtPath:directPath withIntermediateDirectories:YES attributes:nil error:nil];
    return directPath;
    
}

//获得缓存路径中的所有已经缓存的照片 array

- (NSArray *)getLocalCacheImage:(NSString *)path
{
    NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray * images = [NSMutableArray new];
    for (NSString * imageName in fileList) {
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",path,imageName];
        UIImage * image = [self transformImagePath:imagePath];
        if (image) {
            [images addObject:image];
        }
    }
    return images;
}

//通过加密文件路径获取加密文件并且拆包成正确图片

- (UIImage *)transformImagePath:(NSString *)imagePath
{
    char arr[] ={0xff, 0xd8, 0xff};
    NSString * imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
    NSData * tmpData = [NSData dataWithBytes:arr length:3];
    
    NSMutableData * data = [NSMutableData dataWithContentsOfFile:imagePath];
    NSRange range1 = [data rangeOfData:tmpData options:NSDataSearchAnchored range:NSMakeRange(0, data.length)];
    
    NSRange range2 = [data rangeOfData:tmpData options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
    if (range1.length==0 || range2.length==0 ||[imageName containsString:@"("] || data.length < 20000)
        return nil;
    [data replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
    UIImage * image = [UIImage imageWithData:data];
    return image;
    // Do any additional setup after loading the view.
}


- (void)downloadImageByCardId:(NSString *)cardId
{
    __weak typeof(self) weakSelf = self;
    NSString * cachePath = [self createLocalPath:cardId];
    
    [DPNetWorkingManager getPhotoRequest:cardId success:^(NSArray<NSString *> *PhotoAlbums) {
        if (PhotoAlbums.count > 0) {
            [weakSelf cacheCardId:cardId];
        }
        NSLog(@"-------%@------",cardId);
        if (PhotoAlbums.count < 1) {
            __weak __typeof(self) weakSelf = self;
            [LBXAlertAction showAlertWithTitle:[NSString stringWithFormat:@"卡号:%@",cardId] msg:@"这张卡中没有照片呦！" buttonsStatement:@[@"知道了"] chooseBlock:^(NSInteger buttonIdx) {
            }];
            return ;
        }
        for (NSString *url in PhotoAlbums) {
            [DPNetWorkingManager downloadImage:url cachePath:cachePath success:^(NSString *path) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [weakSelf setImageToMemery:cardId image:[weakSelf transformImagePath:path]];
                });
                
            }];
        }
    }];
}

//新添加的cardId缓存到本地

- (void)cacheCardId:(NSString *)cardId
{
    for (NSString *cId in _cardIds) {
        if ([cardId isEqualToString:cId]) {
            return;
        }
    }
    NSMutableArray * cIds = [NSMutableArray new];
    [cIds addObjectsFromArray:_cardIds];
    [cIds addObject:cardId];
    [[NSUserDefaults standardUserDefaults] setObject:[cIds copy] forKey:IMAGES_CARD_ID_CACHE_KEY];
    _cardIds = [cIds copy];
}

//下载好的图片解析后放入数据源

- (void)setImageToMemery:(NSString *)cardId image:(UIImage *)image
{
    @synchronized(self) {
        if (cardId == nil) {
            return;
        }
        if (image == nil) {
            return;
        }
        NSMutableArray * images = [_imageDataCache objectForKey:cardId];
        if (images == nil) {
            images = [NSMutableArray new];
            [_imageDataCache setObject:images forKey:cardId];
        }
        [images addObject:image];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }
}


- (void)saveImages
{

    if (_bashSaveImages.count == 1) {
        [self popUpInterstitialView];
        [self saveNext];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showAlertWithTitle:@"保存全部照片" msg:@"你是不是要保存全部照片？" buttonsStatement:@[@"我再想想",@"是的"] chooseBlock:^(NSInteger buttonIdx) {
        if (buttonIdx == 0) {
            
        } else if (buttonIdx == 1) {
            
            if ([DPNetWorkingManager paidCheck]) {
                if (weakSelf.bashSaveProcessing) {
                    [weakSelf showAllTextDialog:@"保存中..."];
                    return;
                }
                [weakSelf showAllTextDialog:@"保存中..."];
                weakSelf.bashSaveProcessing = YES;
                if (weakSelf.bashSaveImages.count < 1) {
                    weakSelf.bashSaveImages = [[NSMutableArray alloc] initWithArray:[self getTotalImages]];
                }
                [weakSelf saveNext];
            } else {
                [weakSelf showPayView];
            }
        }
    }];
}

- (void)showPayView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.payView.alpha = 1;
    }];
}

-(void)saveNext
{
    if (_bashSaveImages.count > 0) {
        UIImage *image = [_bashSaveImages objectAtIndex:0];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
    else {
        [self allImagesSaveDone];
    }
}

- (void)allImagesSaveDone
{
    _bashSaveProcessing = NO;
    [self showSaveSuccessMessage];
}



- (void)saveImageByIndex:(NSInteger)index
{
    UIImage *image = [_photoBrowserImages objectAtIndex:index];
    _bashSaveImages = [[NSMutableArray alloc]initWithObjects:image, nil];
    [self saveImages];
}

-(void)saveImage
{
    [self saveImageByIndex:_browser.currentPage];
}

-(void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    else {
        [_bashSaveImages removeObjectAtIndex:0];
    }
    [self saveNext];
}


- (void)showSaveSuccessMessage
{
    [self showAllTextDialog:@"保存成功"];
}


- (void)showProcessDialog:(NSString *)message
{
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.label.text = message;
    HUD.mode = MBProgressHUDModeText;
    HUD.userInteractionEnabled = NO;
    [HUD showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD hideAnimated:YES];
        
    });
    
}

- (void)showAllTextDialog:(NSString *)message
{
   MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.label.text = message;
    HUD.mode = MBProgressHUDModeText;
    HUD.userInteractionEnabled = NO;
    [HUD showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD hideAnimated:YES];

    });

}

- (void)addPhotos
{
    //添加一些扫码或相册结果处理
    QQLBXScanViewController *vc = [QQLBXScanViewController new];
    vc.style = [StyleDIY qqStyle];
    
    //镜头拉远拉近功能
    vc.isVideoZoom = YES;
    __weak typeof(self) weakSelf = self;
    [vc setScanSuccess:^(NSArray<NSString *> *cardIds) {
        for (NSString *cardId in cardIds) {
            [weakSelf downloadImageByCardId:cardId];
        }
    }];
    [self presentViewController:vc animated:YES completion:^{
        
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: UI
- (void)setUpViews
{
    
    UIImageView * titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_logo"]];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = CGRectMake(0, 0, 90, 23);
    [self.navigationItem setTitleView:titleImageView];
    
    UIButton * saveBtn = [[UIButton alloc] init];
    [saveBtn setImage:[UIImage imageNamed:@"save_blue"] forState:UIControlStateNormal];
    saveBtn.frame = CGRectMake(0, 0, 26, 26);
    [saveBtn addTarget:self action:@selector(saveImages) forControlEvents:UIControlEventTouchUpInside];

    UIButton * addBtn = [[UIButton alloc] init];
    [addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    addBtn.frame = CGRectMake(0, 0, 29, 29);
    [addBtn addTarget:self action:@selector(addPhotos) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];

    [self.navigationItem setRightBarButtonItems:@[addItem,[UIBarButtonItem new],saveItem]];
    
    UICollectionViewFlowLayout *layoutView = [[UICollectionViewFlowLayout alloc] init];
    layoutView.scrollDirection = UICollectionViewScrollDirectionVertical;
    layoutView.itemSize = CGSizeMake((SCREEN_WIDTH - 30) / 2 , (SCREEN_WIDTH - 30) / 2);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layoutView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CGQCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CGQCollectionViewCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DPCollectionReusableView class]) bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    layoutView.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 30);

    [self createBannerView];
    [self createInterstitialView];
    [self createPayView];
}


- (void)createPayView
{
    DPPayChoiceVIew * payView = [[DPPayChoiceVIew alloc] init];
    payView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:payView];
    [payView setAliPay:^{
        NSLog(@"ali");
        [DPNetWorkingManager payForDownloadImages:BmobAlipay Success:^(BOOL success) {
            if (success) {
                NSLog(@"pay ali");
            }
        }];
    }];
    [payView setWechatPay:^{
        [DPNetWorkingManager payForDownloadImages:BmobWechat Success:^(BOOL success) {
            if (success) {
                NSLog(@"pay wechat");
            }
        }];
        NSLog(@"wechat");
    }];
    _payView = payView;
    [payView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(payView.superview);
    }];
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _cardIds.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSString * cardId = [_cardIds objectAtIndex:section];
    NSArray * images = [_imageDataCache objectForKey:cardId];
    return images.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGQCollectionViewCell *cell = (CGQCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CGQCollectionViewCell" forIndexPath:indexPath];
    NSString * cardId = [_cardIds objectAtIndex:indexPath.section];
    NSArray * images = [_imageDataCache objectForKey:cardId];
    cell.imageView.image = [images objectAtIndex:indexPath.row];
    cell.layer.masksToBounds=YES;
    cell.layer.cornerRadius=5.0;
    cell.layer.borderWidth=1.0;
    cell.layer.borderColor=[[UIColor blackColor] CGColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    DPCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    NSString * cardId = [_cardIds objectAtIndex:indexPath.section];
    NSArray * images = [_imageDataCache objectForKey:cardId];
    NSInteger imageCount = images.count;
    headerView.titleLabel.text = [NSString stringWithFormat:@"卡号:%@/照片数量:%ld",cardId,(long)imageCount];
    
    return headerView;
    
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    ESPictureBrowser *browser = [[ESPictureBrowser alloc] init];
    [browser setDelegate:self];
    __weak typeof(self) weakSelf = self;
    [browser setLongPressBlock:^(NSInteger index) {
        NSLog(@"%zd", index);
        [weakSelf saveImageByIndex:index];
        
    }];
    _photoBrowserImages = [self getTotalImages];
    UIView * view = [_collectionView cellForItemAtIndexPath:indexPath];
    [browser showFromView:view picturesCount:_photoBrowserImages.count currentPictureIndex:[self indexPathToIndex:indexPath] targetView:self.navigationController.view];
    _browser = browser;
    UIButton * saveButton = [[UIButton alloc] init];
    [saveButton setImage:[UIImage imageNamed:@"save_white"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [browser addSubview:saveButton];
    _browser = browser;
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.trailing.equalTo(browser.mas_trailing).mas_offset(-20);
        make.bottom.equalTo(browser.mas_bottom).mas_offset(-60);
    }];
}

#pragma mark - ESPictureBrowserDelegate
- (NSString *)pictureView:(ESPictureBrowser *)pictureBrowser highQualityUrlStringForIndex:(NSInteger)index
{
    return nil;
}

/**
 获取对应索引的视图
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 
 @return 视图
 */
- (UIView *)pictureView:(ESPictureBrowser *)pictureBrowser viewForIndex:(NSInteger)index {
    NSIndexPath * indexPath = [self indexToIndexPath:index];
    UIView * view = [_collectionView cellForItemAtIndexPath:indexPath];
    return view;
}

/**
 获取对应索引的图片大小
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 
 @return 图片大小
 */
//- (CGSize)pictureView:(ESPictureBrowser *)pictureBrowser imageSizeForIndex:(NSInteger)index {
//    
//    UIImage * image = [_photoBrowserImages objectAtIndex:index];
//    return image.size;
//}

/**
 获取对应索引默认图片，可以是占位图片，可以是缩略图
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 
 @return 图片
 */
- (UIImage *)pictureView:(ESPictureBrowser *)pictureBrowser defaultImageForIndex:(NSInteger)index {
    UIImage * image = [_photoBrowserImages objectAtIndex:index];

    return image;
}


- (void)pictureView:(ESPictureBrowser *)pictureBrowser scrollToIndex:(NSInteger)index {
    [_collectionView scrollToItemAtIndexPath:[self indexToIndexPath:index] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}


@end
