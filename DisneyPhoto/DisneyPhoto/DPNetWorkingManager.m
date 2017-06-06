//
//  DPNetWorkingManager.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPNetWorkingManager.h"


//@"http://api.disneyphotopass.com.cn:3006/p/getLocationPhoto?tokenId=a3540150-2b02-11e7-a47f-651e419c9bc5";
static NSArray * _cards = nil;

@implementation DPNetWorkingManager

+ (void)addCard:(NSString *)cardId success:(void(^)(void))success
{
    if (cardId == nil) {
        return ;
    }
    NSString * url = [NSString stringWithFormat:@"%@user/addCodeToUser",API_DOMAIN];
    //NSString * url = @"http://api.disneyphotopass.com.cn:3006/user/addCodeToUser";
    [[AFHTTPSessionManager manager] POST:url
                              parameters:@{@"tokenId":TOKENID,
                                           @"customerId":cardId}
                                progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

+ (void)getCardList:(void (^)(NSArray *cards))success
{
    NSString * url = [NSString stringWithFormat:@"%@p/getLocationPhoto?tokenId=%@",API_DOMAIN,TOKENID];

    //NSString * url = [NSString stringWithFormat:@"http://api.disneyphotopass.com.cn:3006/p/getLocationPhoto?tokenId=%@",tokenId];
    [[AFHTTPSessionManager manager] GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = responseObject;
        dict = dict[@"result"];
        NSArray * cardObjects = dict[@"locationP"];
        NSMutableArray * cards = [NSMutableArray new];
        for (NSDictionary * cardObjectDict in cardObjects) {
            NSString * cardId = cardObjectDict[@"PPCode"];
            [cards addObject:cardId];
            [DPNetWorkingManager getPhotoRequest:cardId date:cardObjectDict[@"shootOnDate"] success:^(NSArray<NSString *> *PhotoAlbums) {
                success([PhotoAlbums copy]);
            }];
        }
//        success([cards copy]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

+ (void)getPhotoRequest:(NSString *)cardId date:(NSString *)date success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;
{
    NSString * URLString = [NSString stringWithFormat:@"%@p/getPhotosByConditions?customerId=%@&tokenId=%@&shootDate=%@",API_DOMAIN,cardId,TOKENID,date];
    __weak typeof(self) weakSelf = self;
    id cacheResponse = [[NSUserDefaults standardUserDefaults] objectForKey:URLString];
    if ( cacheResponse != nil) {
        NSDictionary * dict = cacheResponse;
        NSDictionary * result = dict[@"result"];
        NSArray * photoes = result[@"photos"];
        if (photoes.count == 750) {
            return;
        }
        NSMutableArray * photoUrls = [NSMutableArray new];
        for (NSDictionary * photoObjectDict in photoes) {
            NSDictionary * thumbnail = photoObjectDict[@"thumbnail"];
            NSDictionary * thumbnailUrl = thumbnail[@"en1024"];
            if(thumbnailUrl == nil) {
                thumbnailUrl =  thumbnail[@"x1024"];
            }
            NSString * url = thumbnailUrl[@"url"];
            [photoUrls addObject:url];
        }
        success(photoUrls);
        NSLog(@"使用缓存数据");
        if(photoes.count != 0) {
        return;    
        }
        
    }
    
    [[AFHTTPSessionManager manager] GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:URLString];
        NSDictionary * dict = responseObject;
        NSDictionary * result = dict[@"result"];
        NSArray * photoes = result[@"photos"];
        NSMutableArray * photoUrls = [NSMutableArray new];
        for (NSDictionary * photoObjectDict in photoes) {
            NSDictionary * thumbnail = photoObjectDict[@"thumbnail"];
            NSDictionary * thumbnailUrl = thumbnail[@"en1024"];
            if(thumbnailUrl == nil) {
                thumbnailUrl =  thumbnail[@"x1024"];
            }
            NSString * url = thumbnailUrl[@"url"];
            [photoUrls addObject:url];
            
            NSDictionary * originalInfo = photoObjectDict[@"originalInfo"];
            NSString *hdImageUrl = originalInfo[@"url"];
            if (hdImageUrl != nil && ![hdImageUrl isEqualToString:@""]) {
                [DPNetWorkingManager downloadHDImage:hdImageUrl cardId:cardId success:nil];
            }
        }
        success(photoUrls);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf getPhotoRequest:cardId success:success];
    }];
}


+ (void)getPhotoRequest:(NSString *)cardId success:(void (^)(NSArray <NSString *> *PhotoAlbums))success;
{
    NSString * URLString = [NSString stringWithFormat:@"%@p/getPhotosByConditions?customerId=%@&tokenId=%@",API_DOMAIN,cardId,TOKENID];
    __weak typeof(self) weakSelf = self;
    id cacheResponse = [[NSUserDefaults standardUserDefaults] objectForKey:cardId];
    if ( cacheResponse != nil) {
        NSDictionary * dict = cacheResponse;
        NSDictionary * result = dict[@"result"];
        NSArray * photoes = result[@"photos"];
        NSMutableArray * photoUrls = [NSMutableArray new];
        for (NSDictionary * photoObjectDict in photoes) {
            NSDictionary * thumbnail = photoObjectDict[@"thumbnail"];
            NSDictionary * thumbnailUrl = thumbnail[@"en1024"];
            if(thumbnailUrl == nil) {
                thumbnailUrl =  thumbnail[@"x1024"];
            }
            NSString * url = thumbnailUrl[@"url"];
            [photoUrls addObject:url];
        }
        success(photoUrls);
        NSLog(@"使用缓存数据");
        return;
    }

    [[AFHTTPSessionManager manager] GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:cardId];
        NSDictionary * dict = responseObject;
        NSDictionary * result = dict[@"result"];
        NSArray * photoes = result[@"photos"];
        NSMutableArray * photoUrls = [NSMutableArray new];
        for (NSDictionary * photoObjectDict in photoes) {
            NSDictionary * thumbnail = photoObjectDict[@"thumbnail"];
            NSDictionary * thumbnailUrl = thumbnail[@"en1024"];
            if(thumbnailUrl == nil) {
                thumbnailUrl =  thumbnail[@"x1024"];
            }
            NSString * url = thumbnailUrl[@"url"];
            [photoUrls addObject:url];
        }
        success(photoUrls);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf getPhotoRequest:cardId success:success];
    }];
}
+ (void)downloadHDImage:(NSString *)url cardId:(NSString *)cardId success:(void (^)(NSString * path))success
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];


    NSString * imageUrl = [NSString stringWithFormat:@"%@%@",IMAGE_DOMAIN,url];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    __block NSString *imageBlockUrl = [url copy];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

        return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@.jpeg",PHOTOES_CACHE_PATH,cardId,imageBlockUrl]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"下载了一个高清！");
    }];
    [downloadTask resume];

}

+ (void)downloadImage:(NSString *)url success:(void (^)(NSString * path))success
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
//    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    

    NSString * imageUrl = [NSString stringWithFormat:@"%@%@",IMAGE_DOMAIN,url];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/tmp/%@.jpeg",PHOTOES_CACHE_PATH,url]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"File downloaded to: %@", filePath);
        success([filePath path]);
    }];
    [downloadTask resume];

}

+ (void)removeCard:(NSString *)cardId
{
    if (cardId == nil) {
        return ;
    }
    NSString * url = [NSString stringWithFormat:@"%@user/removePPFromUser",API_DOMAIN];

//    NSString * url = @"http://api.disneyphotopass.com.cn:3006/user/removePPFromUser";
    [[AFHTTPSessionManager manager] POST:url
                              parameters:@{@"tokenId":TOKENID,
                                           @"customerId":cardId}
                                progress:^(NSProgress * _Nonnull uploadProgress) {
                                    
                                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    
                                }];
}

@end
