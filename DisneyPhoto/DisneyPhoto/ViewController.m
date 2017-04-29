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
@interface ViewController ()
@property (nonatomic , strong) NSMutableDictionary * cardPhotoesCountCahce;

@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _cardPhotoesCountCahce = [[NSMutableDictionary alloc] init];
    //    [DPNetWorkingManager addCard:@"SHDR32WTNN8CHBT8" success:^{
    //
    //    }];
    // [DPNetWorkingManager getPhotoRequest:nil success:nil];
    __weak typeof(self) weakSelf = self;
    [DPNetWorkingManager getCardList:^(NSArray *cards) {
        NSLog(@"cardList");
        
        for (NSString * cardId in cards) {
//            [DPNetWorkingManager removeCard:cardId];
             NSString * destinationPath = [weakSelf createLocalPath:cardId];
            [DPNetWorkingManager getPhotoRequest:cardId success:^(NSArray<NSString *> *PhotoAlbums) {
                [self.cardPhotoesCountCahce setObject:PhotoAlbums forKey:cardId];
                NSLog(@"-------%@------",cardId);
                for (NSString *url in PhotoAlbums) {
                    [DPNetWorkingManager downloadImage:url success:^(NSString *path) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        [weakSelf transformImage:path destinationPath:destinationPath];
                        });
                        
                    }];
                }
            }];
        }
    }];
}

- (void)transformImage:(NSString *)imagePath destinationPath:(NSString *)destinationPath
{
    NSLog(@"%@",[NSThread currentThread]);
    char arr[] ={0xff, 0xd8, 0xff};
    NSString * imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
    NSData * data = [NSData dataWithBytes:arr length:3];
    
    NSMutableData * data2 = [NSMutableData dataWithContentsOfFile:imagePath];
    NSRange range1 = [data2 rangeOfData:data options:NSDataSearchAnchored range:NSMakeRange(0, data2.length)];
    
    NSRange range2 = [data2 rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, data2.length)];
    if (range1.length==0 || range2.length==0 || data2.length < 20000)
        return;
    [data2 replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
    
    NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",destinationPath,imageName];
    [data2 writeToFile: outImagePath atomically: NO];
    [self zipFileCheck:destinationPath];
    // Do any additional setup after loading the view.
}

- (void)zipFileCheck:(NSString *)destinationPath
{
    NSArray * strs = [destinationPath componentsSeparatedByString:@"/"];
    NSString * cardId = [strs lastObject];
    NSInteger  imageCount = ((NSArray *)[_cardPhotoesCountCahce objectForKey:cardId]).count;
    NSInteger  cachedCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:nil].count;
    if (imageCount == cachedCount) {
        [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@.zip",destinationPath] withContentsOfDirectory:destinationPath];
    }
}

- (NSString *)createLocalPath:(NSString *)cardId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directPath = [PHOTOES_CACHE_PATH stringByAppendingPathComponent:cardId];
    [fileManager createDirectoryAtPath:directPath withIntermediateDirectories:YES attributes:nil error:nil];
    return directPath;
    
}
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    char arr[] ={0xff, 0xd8, 0xff};
//    NSData * data = [NSData dataWithBytes:arr length:3];
//    NSString *sourcePath =  @"/Users/maxiaofen/New_Skills_GET/DisneyPhoto/photoSource";
//    
//    NSString * outPath = @"/Users/maxiaofen/New_Skills_GET/DisneyPhoto/out_photoes";
//    
//    NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:nil];
//    NSMutableArray * imagePaths = [NSMutableArray new];
//    for (NSString * imageName in fileList) {
//        NSLog(@"%@",imageName);
//        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",sourcePath,imageName];
//        NSMutableData * data2 = [NSMutableData dataWithContentsOfFile:imagePath];
//        NSRange range1 = [data2 rangeOfData:data options:NSDataSearchAnchored range:NSMakeRange(0, data2.length)];
//        
//        NSRange range2 = [data2 rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, data2.length)];
//        if (range1.length==0 || range2.length==0 ||[imageName containsString:@"("] || data2.length < 20000)
//            continue;
//        [data2 replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
//        
//        NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",outPath,imageName];
//        [data2 writeToFile: outImagePath atomically: NO];
//    }
//    
//    // Do any additional setup after loading the view.
//}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
