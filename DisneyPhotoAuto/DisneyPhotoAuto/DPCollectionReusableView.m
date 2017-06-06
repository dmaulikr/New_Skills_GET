//
//  DPCollectionReusableView.m
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/30/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import "DPCollectionReusableView.h"

@implementation DPCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)remove:(id)sender {
    if (_removeBlock) {
        _removeBlock();
    }
}

@end
