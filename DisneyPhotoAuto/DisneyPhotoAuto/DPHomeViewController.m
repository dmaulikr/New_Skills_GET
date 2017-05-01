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
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define IMAGES_CARD_ID_CACHE_KEY @"IMAGES_CARD_ID_CACHE_KEY"
@interface DPHomeViewController ()<ESPictureBrowserDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)UICollectionView * imageBrowserCollectionView;
@property (nonatomic, strong)NSMutableDictionary *imageDataCache;
@property (nonatomic, strong)NSMutableArray *cardIds;
@property (nonatomic, strong)NSArray *photoBrowserImages;
@end

@implementation DPHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initImageCache];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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


- (void)addPhotos
{
    //添加一些扫码或相册结果处理
    QQLBXScanViewController *vc = [QQLBXScanViewController new];
    vc.style = [StyleDIY qqStyle];
    
    //镜头拉远拉近功能
    vc.isVideoZoom = YES;
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
//    [self.navigationController pushViewController:vc animated:YES];
    
    //add
//    [self downloadImageByCardId:@"SHDR32GH7UW6HBT7"];
//    [DPNetWorkingManager addCard:@"SHDR32HUF7FQHBT8" success:nil];
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
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhotos)]];
    
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
    headerView.titleLabel.text = [NSString stringWithFormat:@"卡号:%@/照片数量:%ld",cardId,imageCount];
    
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
    [browser setLongPressBlock:^(NSInteger index) {
        NSLog(@"%zd", index);
    }];
    _photoBrowserImages = [self getTotalImages];
    [browser showFromView:self.view picturesCount:_photoBrowserImages.count currentPictureIndex:[self indexPathToIndex:indexPath]];
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
