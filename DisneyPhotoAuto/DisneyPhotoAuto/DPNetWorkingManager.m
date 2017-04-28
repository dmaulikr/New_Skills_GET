//
//  DPNetWorkingManager.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPNetWorkingManager.h"

@implementation DPNetWorkingManager
+ (void)addCard:(NSString *)cardId success:(void(^)(void))success
{
    if (cardId == nil) {
        return ;
    }
    NSString * URLString = @"http://api.disneyphotopass.com.cn:3006/user/addCodeToUser";
    [[AFHTTPSessionManager manager] POST:URLString
                              parameters:@{@"tokenId":tokenId,
                                           @"customerId":cardId}
                                progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


+ (void)getPhotoRequest:(NSArray *)cardId success:(void (^)(NSArray <DPPhotoAlbum *> *PhotoAlbums))success;
{
    NSString * URLString = @"http://api.disneyphotopass.com.cn:3006/p/getLocationPhoto?tokenId=a3540150-2b02-11e7-a47f-651e419c9bc5";
    [[AFHTTPSessionManager manager] GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
@end
