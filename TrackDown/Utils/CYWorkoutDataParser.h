//
//  CYWorkoutDataParser.h
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TargetMuscle;
@interface CYWorkoutDataParser : NSObject

//getter
+(instancetype)defaultParser;

//parse method
-(NSArray <TargetMuscle *> *)parseWorkoutTypesFromFile:(NSString *)filePath;
-(NSArray <TargetMuscle *> *)parseWorkoutTypesFromString:(NSString *)jsonString;

//encode method
-(NSData *)serializeWorkoutArray:(NSArray <TargetMuscle *>*)array;

@end
