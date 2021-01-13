//
//  IBButton.h
//  ExtremeVPN
//
//  Created by Gin on 2017/1/19.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface IBButton : UIButton

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

@property (nonatomic, assign) IBInspectable BOOL semicircle;        ///< 始终一半高度的圆角
@end
