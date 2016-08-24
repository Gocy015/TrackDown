//
//  MBProgressHUD+DefaultHUD.m
//  TrackDown
//
//  Created by Gocy on 16/8/24.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "MBProgressHUD+DefaultHUD.h"

@implementation MBProgressHUD(DefaultHUD)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)textHUDAddedTo:(UIView *)view text:(NSString *)text animated:(BOOL)animated {
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    
    
    [view addSubview:hud];
    [hud showAnimated:animated];
    
    [hud hideAnimated:YES afterDelay:1.6];
    return hud;
}

@end
