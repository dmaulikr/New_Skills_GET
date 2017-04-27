//
//  DPNetWorkingManager.h
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "DPPhotoAlbum.h"
const static NSString * tokenId = @"a3540150-2b02-11e7-a47f-651e419c9bc5";

@interface DPNetWorkingManager : NSObject
+ (void)getPhotoRequest:(NSArray *)cardId success:(void (^)(NSArray <DPPhotoAlbum *> *PhotoAlbums))success;


@end
