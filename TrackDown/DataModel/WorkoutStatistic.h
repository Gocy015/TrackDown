//
//  WorkoutStatistic.h
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExpandableObjectProtocol.h"

typedef NS_ENUM (NSInteger ,StatType){
    StatTypeMuscle = 0,
    StatTypeAction = 1
};


extern NSString *const key_weight;
extern NSString *const key_reps;
extern NSString *const key_sets;

@interface WorkoutStatistic : NSObject

@property (nonatomic) StatType type;
@property (nonatomic ,copy) NSString *key;
@property (nonatomic ,copy) NSString *mus;
@property (nonatomic ,strong) NSMutableDictionary *data;
@property (nonatomic) NSUInteger storeDate;
@property (nonatomic) NSUInteger trainingCount;
@property (nonatomic) NSUInteger storeMonth;

@end
