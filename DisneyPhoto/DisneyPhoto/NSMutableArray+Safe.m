//
//  NSMutableArray+Safe.m
//  DisneyPhoto
//
//  Created by 马小奋 on 2017/7/29.
//  Copyright © 2017年 Bruno.ma. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)
- (void)addObjectSafe:(id)anObject
{
    if (anObject != nil) {
        [self addObject:anObject];
    }
}
@end
