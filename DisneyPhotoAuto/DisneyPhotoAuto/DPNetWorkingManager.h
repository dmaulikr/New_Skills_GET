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
#import <BmobSDK/BmobPay.h>
const static NSString * tokenId = @"5913ca10-2ca3-11e7-a67d-6b4caa5d78a0";
#define PHOTOES_CACHE_PATH   [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

@interface DPNetWorkingManager : NSObject
+ (void)addCard:(NSString *)cardId success:(void(^)(void))success;

+ (void)removeCard:(NSString *)cardId;

+ (void)getPhotoRequest:(NSString *)cardId success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;

+ (void)getCardList:(void (^)(NSArray *cards))success;

+ (void)downloadImage:(NSString *)url cachePath:(NSString *)cachePath success:(void (^)(NSString * path))success;

+ (void)login;

+ (BOOL)paidCheck;

+ (void)payForDownloadImages:(BmobPayType)payType Success:(void(^)(BOOL))success;

@end
