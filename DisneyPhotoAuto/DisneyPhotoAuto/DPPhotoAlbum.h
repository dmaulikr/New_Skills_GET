//
//  DPPhotoAlbum.h
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPPhoto.h"
@interface DPPhotoAlbum : NSObject
@property (nonatomic, strong) NSMutableArray <DPPhoto *> *photoes;
@end
