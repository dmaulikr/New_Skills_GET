//
//  KeyChainStore.h
//  
//
//  Created by 马小奋 on 2017/5/7.
//
//

#import <Foundation/Foundation.h>

@interface KeyChainStore : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;

@end
