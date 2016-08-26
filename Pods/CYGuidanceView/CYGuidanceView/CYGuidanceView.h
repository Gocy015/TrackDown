//
//  CYGuidanceView.h
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideInfo.h"

@interface CYGuidanceView : UIView

@property (nonatomic ,copy) NSString *hintText;
 
-(void)addStep:(NSArray <GuideInfo *> *)step;

-(void)showInView:(UIView *)view animated:(BOOL)animate;

@end
