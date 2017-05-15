//
//  DPHomeViewController+AD.m
//  DisneyPhotoAuto
//
//  Created by 马小奋 on 2017/5/7.
//  Copyright © 2017年 Bruno.ma. All rights reserved.
//

#import "DPHomeViewController+AD.h"
#import <Masonry/Masonry.h>
@interface DPHomeViewController ()<GADBannerViewDelegate,GADInterstitialDelegate>
@end

@implementation DPHomeViewController (AD)

- (void)createBannerView
{
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [self.view addSubview:bannerView];
    [bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    bannerView.rootViewController = self;
    bannerView.delegate = self;
    self.bannerView = bannerView;
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    //    request.testDevices = @[
    //                            @"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
    //                            ];
    [self.bannerView loadRequest:request];
}



- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


- (void)createInterstitialView
{
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    
    GADRequest *request = [GADRequest request];
    interstitial.delegate = self;
    // Requests test ads on test devices.
    request.testDevices = @[@"6f570dd21d6074e47860aff580e9f79d"];
    [interstitial loadRequest:request];
    self.interstitialView = interstitial;
}


- (void)popUpInterstitialView
{
    if ([self.interstitialView isReady]) {
        [self.interstitialView presentFromRootViewController:self.navigationController];
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [self createInterstitialView];
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad
{
    [self createInterstitialView];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self createInterstitialView];

}
@end
