//
//  ViewController.m
//  DisneyPhoto
//
//  Created by Bruno.ma on 4/24/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    char arr[] ={0xff, 0xd8, 0xff};
    NSData * data = [NSData dataWithBytes:arr length:3];
    NSString *sourcePath =  @"/Users/maxiaofen/New_Skills_GET/DisneyPhoto/photoSource";
    
    NSString * outPath = @"/Users/maxiaofen/New_Skills_GET/DisneyPhoto/out_photoes";
    
    NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:nil];
    NSMutableArray * imagePaths = [NSMutableArray new];
    for (NSString * imageName in fileList) {
        NSLog(@"%@",imageName);
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",sourcePath,imageName];
        NSMutableData * data2 = [NSMutableData dataWithContentsOfFile:imagePath];
        NSRange range1 = [data2 rangeOfData:data options:NSDataSearchAnchored range:NSMakeRange(0, data2.length)];
        
        NSRange range2 = [data2 rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, data2.length)];
        if (range1.length==0 || range2.length==0 ||[imageName containsString:@"("] || data2.length < 20000)
            continue;
        [data2 replaceBytesInRange:NSMakeRange(range1.location, range2.location) withBytes:NULL length:0];
        
        NSString *outImagePath = [NSString stringWithFormat:@"%@/%@",outPath,imageName];
        [data2 writeToFile: outImagePath atomically: NO];
    }
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
