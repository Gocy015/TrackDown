//
//  WorkoutStatistic.h
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger ,StatType){
    StatTypeMuscle = 0,
    StatTypeAction = 1
};

@interface WorkoutStatistic : NSObject

@property (nonatomic) StatType type;
@property (nonatomic ,copy) NSString *key;
@property (nonatomic ,strong) NSDictionary *data;

@end
