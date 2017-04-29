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
static const NSString *PHOTOES_CACHE_PATH = @"/Users/maxiaofen/Desktop/Disney_photoes";

@interface DPNetWorkingManager : NSObject
+ (void)addCard:(NSString *)cardId success:(void(^)(void))success;

+ (void)removeCard:(NSString *)cardId;

+ (void)getPhotoRequest:(NSString *)cardId success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;

+ (void)getCardList:(void (^)(NSArray *cards))success;

+ (void)downloadImage:(NSString *)url success:(void (^)(NSString * path))success;
@end
