//
//  CYGuidanceManager.h
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger ,GuideType){
    GuideType_Planning = 1,
    GuideType_MuscleManagement = 2,
    GuideType_Records = 3,
    GuideType_Statistic = 4,
    GuideType_ActionManagement = 5
};

@interface CYGuidanceManager : NSObject

+(BOOL)shouldShowGuidance:(GuideType)type;

+(void)updateGuidance:(GuideType)type withShowStatus:(BOOL)shown;

@end
