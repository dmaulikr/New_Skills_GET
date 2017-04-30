//
//  DPNetWorkingManager.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPNetWorkingManager.h"
static const NSString * imageDownLoadUrl = @"http://www.disneyphotopass.com.cn:4000/";
static NSArray * _cards = nil;

@implementation DPNetWorkingManager

+ (void)login
{
    
}
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
                                    if (success == nil) {
                                        return ;
                                    }
                                    success();
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    
                                }];
}

+ (void)removeCard:(NSString *)cardId
{
    if (cardId == nil) {
        return ;
    }
    NSString * URLString = @"http://api.disneyphotopass.com.cn:3006/user/removePPFromUser";
    [[AFHTTPSessionManager manager] POST:URLString
                              parameters:@{@"tokenId":tokenId,
                                           @"customerId":cardId}
                                progress:^(NSProgress * _Nonnull uploadProgress) {
                                    
                                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    
                                }];
}

+ (void)getCardList:(void (^)(NSArray *cards))success
{
    NSString * url = [NSString stringWithFormat:@"http://api.disneyphotopass.com.cn:3006/p/getLocationPhoto?tokenId=%@",tokenId];
    [[AFHTTPSessionManager manager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = responseObject;
        dict = dict[@"result"];
        NSArray * cardObjects = dict[@"locationP"];
        NSMutableArray * cards = [NSMutableArray new];
        for (NSDictionary * cardObjectDict in cardObjects) {
            NSString * cardId = cardObjectDict[@"PPCode"];
            [cards addObject:cardId];
        }
        success([cards copy]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

+ (void)getPhotoRequest:(NSString *)cardId success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;
{
    if ( cardId == nil) {
        return;
    }
    [DPNetWorkingManager addCard:cardId success:^{
        NSString * URLString = [NSString stringWithFormat:@"http://api.disneyphotopass.com.cn:3006/p/getPhotosByConditions?customerId=%@&tokenId=%@",cardId,tokenId];
        
        [[AFHTTPSessionManager manager] GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [DPNetWorkingManager removeCard:cardId];
            if (responseObject == nil) {
                return ;
            }
            NSDictionary * dict = responseObject;
            NSDictionary * result = dict[@"result"];
            NSArray * photoes = result[@"photos"];
            NSMutableArray * photoUrls = [NSMutableArray new];
            for (NSDictionary * photoObjectDict in photoes) {
                NSDictionary * thumbnail = photoObjectDict[@"thumbnail"];
                NSString *mimeType = photoObjectDict[@"mimeType"];
                if ([mimeType isEqualToString:@"jpg"] == NO) {
                    continue ;
                }
                NSDictionary * thumbnailUrl = thumbnail[@"en1024"];
                if(thumbnailUrl == nil) {
                    thumbnailUrl =  thumbnail[@"x1024"];
                }
                NSString * url = thumbnailUrl[@"url"];
                if (url != nil) {
                    [photoUrls addObject:url];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:cardId forKey:photoUrls];
            success(photoUrls);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];

    }];
}

+ (void)downloadImage:(NSString *)url cachePath:(NSString *)cachePath success:(void (^)(NSString * path))success
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    NSString * imageUrl = [NSString stringWithFormat:@"%@%@",imageDownLoadUrl,url];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString * path = [cachePath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        success([filePath path]);
    }];
    [downloadTask resume];
}

@end
