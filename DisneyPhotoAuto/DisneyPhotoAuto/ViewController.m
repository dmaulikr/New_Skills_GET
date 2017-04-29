//
//  ViewController.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DPNetWorkingManager addCard:@"SHDR326TPFQ3HD72" success:^{
        
    }];
//    __weak typeof(self) weakSelf = self;
//    [DPNetWorkingManager getCardList:^(NSArray *cards) {
//        for (NSString * cardId in cards) {
//            NSLog(@"-------%@------",cardId);
//            __block NSString * path = [weakSelf createLocalPath:cardId];
//
//            [DPNetWorkingManager getPhotoRequest:cardId success:^(NSArray<DPPhotoAlbum *> *PhotoAlbums) {
//                for (NSString *url in PhotoAlbums) {
//                    NSLog(@"%@",url);
//                    
//                    [DPNetWorkingManager downloadImage:url success:^(NSString *path) {
//                        [weakSelf transformImage:path destinationPath:path];
//                    }];
//                }
//            }];
//            break;
//        }
//    }];
}

- (void)transformImage:(NSString *)imagePath destinationPath:(NSString *)destinationPath
{
    char arr[] ={0xff, 0xd8, 0xff};
    NSString * imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
    NSData * data = [NSData dataWithBytes:arr length:3];

        NSMutableData * data2 = [NSMutableData dataWithContentsOfFile:imagePath];
        NSRange range1 = [data2 rangeOfData:data options:NSDataSearchAnchored range:NSMakeRange(0, data2.length)];
        
        NSRange range2 = [data2 rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, data2.length)];
        if (range1.length==0 || range2.length==0 ||[imageName containsString:@"("] || data2.length < 20000)
            return;
        [data2 replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
        
        NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",destinationPath,imageName];
        [data2 writeToFile: outImagePath atomically: NO];
    
    // Do any additional setup after loading the view.
}

- (NSString *)createLocalPath:(NSString *)cardId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directPath = [PHOTOES_CACHE_PATH stringByAppendingPathComponent:cardId];
    [fileManager createDirectoryAtPath:directPath withIntermediateDirectories:YES attributes:nil error:nil];
    return directPath;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
