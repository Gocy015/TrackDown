//
//  WorkoutAction.h
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkoutAction : NSObject

@property (nonatomic ,copy) NSString *actionName;
@property (nonatomic) NSMutableArray *weightPerSet;
@property (nonatomic) NSUInteger sets;
@property (nonatomic) NSMutableArray *repeatsPerSet;

@end
