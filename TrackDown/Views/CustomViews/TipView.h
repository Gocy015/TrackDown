//
//  TipView.h
//  TrackDown
//
//  Created by Gocy on 16/8/8.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrowContainerView.h"



@interface TipView : ArrowContainerView


@property (nonatomic ,copy) NSString *tip;

-(instancetype)initWithTip:(NSString *)tip triangleDirection:(TriangleDirection)dir triangleXPosition:(CGFloat)xPos triangleYPosition:(CGFloat)yPos;
 

@end
