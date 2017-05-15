//
//  DPHomeViewController.h
//  DisneyPhotoAuto
//
//  Created by Bruno.ma on 4/30/17.
//  Copyright © 2017 Bruno.ma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface DPHomeViewController : UIViewController
@property (nonatomic, strong) GADBannerView * bannerView;
@property (nonatomic, strong) GADInterstitial * interstitialView;

@end
