//
//  IBButton.m
//  ExtremeVPN
//
//  Created by Gin on 2017/1/19.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import "IBButton.h"

@implementation IBButton
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_semicircle) {
        self.layer.cornerRadius = self.bounds.size.height / 2.0;
    }
}
@end
