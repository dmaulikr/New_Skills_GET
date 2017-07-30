//
//  ViewController.m
//  DisneyPhoto
//
//  Created by Bruno.ma on 4/24/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "ViewController.h"
#import "DPNetWorkingManager.h"
#import "SSZipArchive.h"
#import <CoreImage/CoreImage.h>
@interface ViewController ()
@property (nonatomic , strong) NSMutableDictionary * cardPhotoesCountCahce;
@property (unsafe_unretained) IBOutlet NSTextView *idsText;
@property (unsafe_unretained) IBOutlet NSTextView *maxIdsText;

@end
@implementation ViewController
- (IBAction)zip:(id)sender {
    NSArray * cacheCardPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PHOTOES_CACHE_PATH error:nil];
    for (NSString *path in cacheCardPaths) {
        NSString *destinationPath = [NSString stringWithFormat:@"%@/%@",PHOTOES_CACHE_PATH,path];
        if ([destinationPath hasSuffix:@"zip"]) {
            continue;
        }
        if ([path hasPrefix:@"SH"] || [path hasPrefix:@"sh"]) {
            NSLog(@"%@",destinationPath);
            [self zipImages:destinationPath];
        }
    }
}
- (IBAction)download:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSString * ids =  [_idsText.string stringByReplacingOccurrencesOfString:@" " withString:@""];
    ids =  [ids stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    _idsText.string = ids;
    [[NSUserDefaults standardUserDefaults] setObject:ids forKey:@"ids"];
    NSArray *ARR =[ids componentsSeparatedByString:@"\n"];

    for (NSString * cardId in ARR) {
        if ([cardId containsString:@"//"]) {
            continue;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [DPNetWorkingManager addCard:cardId success:^{
                
                [DPNetWorkingManager getPhotoRequest:cardId success:^(NSArray<NSString *> *PhotoAlbums) {
                    NSString * destinationPath = [weakSelf createLocalPath:[NSString stringWithFormat:@"%@_(%ld)",cardId,PhotoAlbums.count]];
                    
                    [self.cardPhotoesCountCahce setObject:PhotoAlbums forKey:destinationPath];
                    NSLog(@"-------%@------",cardId);
                    NSLog(@"-------%ld------",PhotoAlbums.count);
                    [DPNetWorkingManager removeCard:cardId];
                    
                    [weakSelf dowmloadImage:destinationPath PhotoAlbums:PhotoAlbums];
                }];
            }];
        });
    }
    NSString * maxIds =  [_maxIdsText.string stringByReplacingOccurrencesOfString:@" " withString:@""];
    maxIds = [maxIds stringByReplacingOccurrencesOfString:@"-" withString:@""];
    _maxIdsText.string = maxIds;
    [[NSUserDefaults standardUserDefaults] setObject:maxIds forKey:@"max_ids"];
    ARR =[maxIds componentsSeparatedByString:@"\n"];
    
    for (NSString * cardId in ARR) {
        if ([cardId containsString:@"//"]) {
            continue;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [DPNetWorkingManager addCard:cardId success:^{
                
                [DPNetWorkingManager getCardList:^(NSArray *PhotoAlbums) {
                    NSString * destinationPath = [weakSelf createLocalPath:[NSString stringWithFormat:@"%@_(%ld)",cardId,PhotoAlbums.count]];
                    
                    [self.cardPhotoesCountCahce setObject:PhotoAlbums forKey:destinationPath];
                    NSLog(@"-------%@------",cardId);
                    NSLog(@"-------%ld------",PhotoAlbums.count);
                    //        [DPNetWorkingManager removeCard:cardId];
                    
                    [weakSelf dowmloadImage:destinationPath PhotoAlbums:PhotoAlbums];
                    
                }];
                
            }];

        });
    }
//

}

- (void)zipImages:(NSString *)destinationPath
{
    NSArray * strs = [destinationPath componentsSeparatedByString:@"/"];
    NSString * cardId = [strs lastObject];
    NSArray *  cachedImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:nil];
    NSInteger zipPackages = cachedImages.count / 100 + 1;
    NSMutableArray * tmp = [NSMutableArray new];
    for (NSString *path in cachedImages) {
        if ([path hasSuffix:@"zip"]) {
            continue;
        }
        [tmp addObject: [NSString stringWithFormat:@"%@/%@",destinationPath,path]];
    }
    cachedImages = tmp;
    for (NSInteger index = 0; index < zipPackages; index++) {
        if (index == zipPackages - 1) {
            NSArray * zipImages = [cachedImages subarrayWithRange:NSMakeRange(index * 100, cachedImages.count % 100)];
            [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@/迪士尼照片—%@_%ld.zip",destinationPath,cardId,index+1] withFilesAtPaths:zipImages];
        } else {
            NSArray * zipImages = [cachedImages subarrayWithRange:NSMakeRange(index * 100, 100)];
            [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@/迪士尼照片-%@_%ld.zip",destinationPath,cardId,index+1] withFilesAtPaths:zipImages];
        }
    }
//    if (imageCount == cachedCount) {
//        [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@.zip",destinationPath] withContentsOfDirectory:destinationPath];
//    }
    
}

- (IBAction)clear:(id)sender {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* dict = [defs dictionaryRepresentation];
    
    for(id key in dict) {
        
        [defs removeObjectForKey:key];
        
    }
    
    [defs synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;


    _cardPhotoesCountCahce = [[NSMutableDictionary alloc] init];
    _idsText.string = [[NSUserDefaults standardUserDefaults] objectForKey:@"ids"] == nil ? @"": [[NSUserDefaults standardUserDefaults] objectForKey:@"ids"];
    _maxIdsText.string = [[NSUserDefaults standardUserDefaults] objectForKey:@"max_ids"] == nil ? @"": [[NSUserDefaults standardUserDefaults] objectForKey:@"max_ids"];
}

- (void)dowmloadImage:(NSString*)destinationPath PhotoAlbums:(NSArray *)PhotoAlbums
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *cachedImageList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:nil];
        for (NSString *url in PhotoAlbums) {
//        for (NSInteger i = 249; i < 600; i++){
//            NSString * url = [PhotoAlbums objectAtIndex:i];
            NSString * imageFileName = [NSString stringWithFormat:@"%@.jpeg",[[url componentsSeparatedByString:@"/"] lastObject]];
            
            if ([cachedImageList containsObject:imageFileName]) {
                continue;
            }
//            [NSThread sleepForTimeInterval:1];
            [DPNetWorkingManager downloadImage:url success:^(NSString *path) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [weakSelf transformImage:path destinationPath:destinationPath];
                });
                
            }];
        }
//        重试
        __block NSInteger retryTimes = 100;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *cachedImageList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:nil];
            if (retryTimes < 0) {
                return ;
            }
            NSLog(@"retryTimes%ld",retryTimes);
            if (cachedImageList.count < PhotoAlbums.count) {
                retryTimes--;
                [weakSelf dowmloadImage:destinationPath PhotoAlbums:PhotoAlbums];
            }
            
        });
    });
}
- (void)transformImage:(NSString *)imagePath destinationPath:(NSString *)destinationPath
{
    @synchronized (self) {
//    NSLog(@"%@",[NSThread currentThread]);
    char arr[] ={0xff, 0xd8, 0xff};
    char mp4Arr[] ={0x00,0x00,0x00,0x20,0x66,0x74,0x79,0x70,0x69,0x73,0x6F,0x6D};

    NSString * imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
    NSData * data = [NSData dataWithBytes:arr length:3];
    
    NSMutableData * data2 = [NSMutableData dataWithContentsOfFile:imagePath];
    NSRange range1 = [data2 rangeOfData:data options:NSDataSearchAnchored range:NSMakeRange(0, data2.length)];
    
    NSRange range2 = [data2 rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, data2.length)];
    if (range1.length==0 || range2.length==0 || data2.length < 20000) {
        return;
    }
        
    if (NSEqualRanges(range1,range2)) {
        NSString * fileName = [NSString stringWithFormat:@"%@",imageName];
        NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",destinationPath,fileName];
        [data2 writeToFile: outImagePath atomically: NO];
    }
    if (NSEqualRanges(range1,range2)) {
        data = [NSData dataWithBytes:mp4Arr length:12];
        range2 = [data2 rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, data2.length)];
        if (range1.length==0 || range2.length==0 || data2.length < 20000)
            return;
        [data2 replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
//        NSDate * date = [NSDate date];
        NSString * fileName = [NSString stringWithFormat:@"%@.mp4",imageName];
        NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",destinationPath,fileName];
        [data2 writeToFile: outImagePath atomically: NO];
        NSLog(@"下载成功");

    } else{
        [data2 replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
//        NSDate * date = [NSDate date];
        NSString * fileName = [NSString stringWithFormat:@"%@",imageName];
        NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",destinationPath,fileName];
        [data2 writeToFile: outImagePath atomically: NO];
        NSLog(@"下载成功");

    }
    }
    // Do any additional setup after loading the view.
}

- (NSData *)resizeImageWithData:(NSData *)data
{
    CIImage * image = [CIImage imageWithData:data];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextCacheIntermediates : @false, kCIContextPriorityRequestLow : @true, kCIContextWorkingFormat : @(kCIFormatRGBAh)}];
//    NSDictionary * option = @{kCGImageDestinationOptimizeColorForSharing: @true,kCGImageDestinationLossyCompressionQuality:@0.8}

    data = [context JPEGRepresentationOfImage:image colorSpace:CGColorSpaceCreateWithName(kCGColorSpaceDisplayP3) options:@{}];
    return data;
}
//- (NSImage *)doubleSizeImage:(NSImage *)image
//{
//    NSImage *sourceImage = image;
//    NSImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = imageSize.width * 2;
//    CGFloat targetHeight = imageSize.height * 2;
//    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
//    if (CGSizeEqualToSize(imageSize, targetSize) ==NO) {
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        if (widthFactor < heightFactor)
//            scaleFactor = widthFactor;
//        else
//            scaleFactor = heightFactor;
//        scaledWidth  = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        // center the image
//        if (widthFactor < heightFactor) {
//            
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        } else if (widthFactor > heightFactor) {
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//    // this is actually the interesting part:
//    UIGraphicsBeginImageContext(targetSize);
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width  = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    [sourceImage drawInRect:thumbnailRect];
//    newImage =UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    if(newImage == nil)
//        NSLog(@"could not scale image");
//    return newImage ;
//}

- (void)zipFileCheck:(NSString *)destinationPath
{
//    NSArray * strs = [destinationPath componentsSeparatedByString:@"/"];
//    NSString * cardId = [strs lastObject];
//    NSInteger  imageCount = ((NSArray *)[_cardPhotoesCountCahce objectForKey:cardId]).count;
//    NSInteger  cachedCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:nil].count;
//    if (imageCount == cachedCount) {
//        [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@.zip",destinationPath] withContentsOfDirectory:destinationPath];
//    }
}

- (NSString *)createLocalPath:(NSString *)cardId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directPath = [PHOTOES_CACHE_PATH stringByAppendingPathComponent:cardId];
    [fileManager createDirectoryAtPath:directPath withIntermediateDirectories:YES attributes:nil error:nil];
//    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/tmp/media",PHOTOES_CACHE_PATH] error:nil];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[NSString stringWithFormat:@"%@/tmp/media",PHOTOES_CACHE_PATH]];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[[NSString stringWithFormat:@"%@/tmp/media",PHOTOES_CACHE_PATH] stringByAppendingPathComponent:fileName] error:nil];
    }
    return directPath;
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
