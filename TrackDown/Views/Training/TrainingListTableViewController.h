//
//  TrainingListTableViewController.h
//  TrackDown
//
//  Created by Gocy on 16/7/16.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrainingListViewDelegate <NSObject>

-(void)didMoveFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end

@interface TrainingListTableViewController : UITableViewController

@property (nonatomic, strong)NSMutableArray *dataArr;

//@property (nonatomic) void (^moveblock)(NSUInteger ,NSUInteger);

@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic ,weak) id <TrainingListViewDelegate> delegate;

@end
