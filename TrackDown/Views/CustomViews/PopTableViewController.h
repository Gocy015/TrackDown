//
//  PopTableViewController.h
//  TrackDown
//
//  Created by Gocy on 16/7/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopTableViewController : UIViewController

@property (nonatomic ,strong) NSArray *dataArray;
@property (nonatomic) NSInteger checkIndex;
@property (nonatomic) void (^clickblock)(NSUInteger);

@end
