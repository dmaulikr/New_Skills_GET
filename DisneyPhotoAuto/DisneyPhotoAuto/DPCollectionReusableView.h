//
//  DPCollectionReusableView.h
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/30/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (strong, nonatomic)void (^removeBlock)(void);
@end
