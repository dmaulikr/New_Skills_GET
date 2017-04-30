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
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define IMAGES_CARD_ID_CACHE_KEY @"IMAGES_CARD_ID_CACHE_KEY"
@interface DPHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)NSMutableDictionary *imageDataCache;
@property (nonatomic, strong)NSMutableArray *cardIds;
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
        }
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
            [_imageDataCache setObject:cardId forKey:images];
        }
        [images addObject:image];
    }
}


- (void)addPhotos
{
    //add
    [self downloadImageByCardId:@"SHDR32HUF7FQHBT8"];
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
    headerView.titleLabel.text=[_cardIds objectAtIndex:indexPath.section];
    
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
    NSLog(@"%ld", (long)indexPath.row);
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self downloadImageByCardId:@""];
    } else if (indexPath.row == 1) {
        [self downloadImageByCardId:@""];
    }

}


@end
