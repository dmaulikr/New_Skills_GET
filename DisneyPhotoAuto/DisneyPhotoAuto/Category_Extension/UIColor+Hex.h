//  Created by Jason Morrissey

#import <UIKit/UIKit.h>

#define RGB(color) [UIColor colorWithHexString:color]
#define RGBA(color,alpha) [UIColor colorWithHexString:color withAlpha:alpha]

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)opacity;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha;
@end
