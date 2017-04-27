//
//  DPPhotoAlbum.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPPhotoAlbum.h"

@implementation DPPhotoAlbum

-(instancetype)init
{
    self = [super init];
    if (self) {
        _photoes = [NSMutableArray new];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    DPPhotoAlbum * pa = [DPPhotoAlbum new];
    pa.photoes = [self.photoes copy];
    return pa;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    DPPhotoAlbum * pa = [DPPhotoAlbum new];
    pa.photoes = [self.photoes copy];
    return pa;
}
@end
