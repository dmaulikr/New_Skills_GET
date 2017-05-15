//
//  DPNetWorkingManager.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/27/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPNetWorkingManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

static const NSString * imageDownLoadUrl = @"http://www.disneyphotopass.com.cn:4000/";
static NSArray * _cards = nil;
#define TABLE_NAME @"DP_USERS"
#define USER_NAME @"userName"
#define USER_DOWNLOAD_COUNT @"downloadCount"
#define USER_PAIED @"paid"

@implementation DPNetWorkingManager
+ (void)payForDownloadImages:(BmobPayType)payType Success:(void(^)(BOOL))success
{
    [BmobPay payWithPayType:payType //支付类型选择
                      price:@0.01 //订单价格，0 - 5000
                  orderName:@"订单名称" //不为空
                   describe:@"订单描述" //不为空
                     result:^(BOOL isSuccessful, NSError *error) {
                         if (success) {
                             success(isSuccessful);
                         }
                     }]; //应用内支付回调
}

+ (BOOL)paidCheck
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:USER_PAIED];
}

+ (void)login
{
    NSString * userName = (NSString *)[KeyChainStore load:USER_LOGIN_KEY];
    
    //首次执行该方法时，uuid为空
    if ([userName isEqualToString:@""] || !userName)
    {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        userName = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [KeyChainStore save:USER_LOGIN_KEY data:userName];
    }
    if ([userName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:userName]]) {
        return;
    }
    
    BmobQuery   *bquery = [BmobQuery queryWithClassName:TABLE_NAME];
    //添加playerName不是小明的约束条件
    [bquery whereKey:USER_NAME equalTo:userName];

    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            [DPNetWorkingManager createAccount:userName];
        }
        for (BmobObject *obj in array) {
            //打印playerName
            NSLog(@"obj.playerName = %@", [obj objectForKey:USER_NAME]);
            //打印objectId,createdAt,updatedAt
            NSLog(@"obj.objectId = %@", [obj objectId]);
            NSLog(@"obj.createdAt = %@", [obj createdAt]);
            NSLog(@"obj.updatedAt = %@", [obj updatedAt]);
        }
    }];
    
}

+ (void)createAccount:(NSString *)userName
{
    BmobObject  *user = [BmobObject objectWithClassName:TABLE_NAME];
    //score为1200
    [user setObject:userName forKey:USER_NAME];
    [user setObject:@5 forKey:USER_DOWNLOAD_COUNT];
    [user setObject:@false forKey:USER_PAIED];

    [user saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:userName];
            [[NSUserDefaults standardUserDefaults] setObject:@5 forKey:USER_DOWNLOAD_COUNT];
            [[NSUserDefaults standardUserDefaults] setObject:@false forKey:USER_PAIED];
        } else if (error){
            //发生错误后的动作
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow  animated:YES];
    
    // Set the label text.
    hud.label.text = NSLocalizedString(@"加载中...", @"HUD loading title");
    //
    [DPNetWorkingManager addCard:cardId success:^{
        NSString * URLString = [NSString stringWithFormat:@"http://api.disneyphotopass.com.cn:3006/p/getPhotosByConditions?customerId=%@&tokenId=%@",cardId,tokenId];
        
        [[AFHTTPSessionManager manager] GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [hud hideAnimated:YES];

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
            [[NSUserDefaults standardUserDefaults] setObject:photoUrls forKey:cardId];
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
