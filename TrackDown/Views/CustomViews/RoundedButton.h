//
//  RoundedButton.h
//  TrackDown
//
//  Created by Gocy on 16/7/27.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface RoundedButton : UIButton

@property (nonatomic ,strong)IBInspectable UIColor *borderColor;
@property (nonatomic)IBInspectable CGFloat cornerRadius;
@property (nonatomic)IBInspectable CGFloat borderWidth;


@end
