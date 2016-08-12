//
//  GraphView.h
//  TrackDown
//
//  Created by Gocy on 16/8/5.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView

@property (nonatomic ,strong) NSArray * graphPoints;
@property (nonatomic ,strong) NSArray * descriptions;
@property (nonatomic ,strong) NSArray * titles;
@property (nonatomic) NSString *mainTitle;

-(void)hideTip;

@end
