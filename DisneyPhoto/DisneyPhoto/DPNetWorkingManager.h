//
//  DPNetWorkingManager.h
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Empty.h"

#import "AFNetworking/AFNetworking/AFNetworking.h"
#define API_DOMAIN      SH_API_DOMAIN
#define IMAGE_DOMAIN    SH_IMAGE_DOMAIN
#define TOKENID         SH_TOKENID

//#define API_DOMAIN      HK_API_DOMAIN
//#define IMAGE_DOMAIN    HK_IMAGE_DOMAIN
//#define TOKENID         HK_TOKENID
//
#define SH_API_DOMAIN  @"http://api.disneyphotopass.com.cn:3006/"
#define HK_API_DOMAIN  @"http://api.disneyphotopass.com.hk:3006/"

#define SH_IMAGE_DOMAIN  @"http://www.disneyphotopass.com.cn:4000/"
#define HK_IMAGE_DOMAIN  @"http://www.disneyphotopass.com.hk:4000/"


#define SH_TOKENID      @"5913ca10-2ca3-11e7-a67d-6b4caa5d78a0"
#define HK_TOKENID      @"b8042880-2cc1-11e7-8ae6-e1e6aeaced20"
static const NSString *PHOTOES_CACHE_PATH = @"/Users/maxiaofen/Desktop/Disney_photoes";

@interface DPNetWorkingManager : NSObject
+ (void)addCard:(NSString *)cardId success:(void(^)(void))success;

+ (void)removeCard:(NSString *)cardId;

+ (void)getPhotoRequest:(NSString *)cardId success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;

+ (void)getCardList:(void (^)(NSArray *cards))success;

+ (void)downloadImage:(NSString *)url success:(void (^)(NSString * path))success;
//+ (void)getPhotoRequest:(NSString *)URLString success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;

@end
