//
//  NSString+Empty.m
//  DisneyPhoto
//
//  Created by 马小奋 on 2017/7/29.
//  Copyright © 2017年 Bruno.ma. All rights reserved.
//

#import "NSString+Empty.h"

@implementation NSString (Empty)

- (BOOL)isEmpty
{
    if (self == nil || [self isEqualToString:@""]) {
        return YES;
    }return NO;
}
@end
