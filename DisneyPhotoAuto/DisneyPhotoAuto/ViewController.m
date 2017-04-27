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
    DPPhoto * photo = [DPPhoto new];
    photo.photoName = @"dd";
    
    DPPhoto *pcs = [photo copy];
    DPPhotoAlbum * pa1  = [DPPhotoAlbum new];
    [pa1.photoes addObject:photo];
    [pa1.photoes addObject:pcs];
    
    DPPhotoAlbum * pa2 = [pa1 mutableCopy];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
