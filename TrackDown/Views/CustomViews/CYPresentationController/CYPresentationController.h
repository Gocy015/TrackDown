//
//  CYPresentationController.h
//  TrackDown
//
//  Created by Gocy on 16/8/19.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger ,PresentationType){
    PresentationType_Popover = 1,
    PresentationType_FullScreen = 2
};


@interface CYPresentationController : UIViewController

@property (nonatomic ,strong) UIColor *backgroundFillColor;

@property (nonatomic ,weak) UIViewController *contentController;

@property (nonatomic) PresentationType type;

@property (nonatomic) CGPoint showPoint;

-(void)showFrom:(UIViewController *)vc;

-(void)dismiss;

@end
