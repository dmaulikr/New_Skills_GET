//
//  DPPhoto.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPPhoto.h"

@implementation DPPhoto
- (id)copyWithZone:(NSZone *)zone
{
    DPPhoto * p = [DPPhoto new];
    p.photoName = [self.photoName copy];
    return p;
}
@end
