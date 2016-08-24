//
//  MBProgressHUD+DefaultHUD.h
//  TrackDown
//
//  Created by Gocy on 16/8/24.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD(DefaultHUD)

+ (instancetype)textHUDAddedTo:(UIView *)view text:(NSString *)text animated:(BOOL)animated;

@end
