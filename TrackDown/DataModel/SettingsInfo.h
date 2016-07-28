//
//  SettingsInfo.h
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger ,SettingType){
    SettingType_TimeBreak = 1 ,
    SettingType_About = 2
};

@interface SettingsInfo : NSObject

-(instancetype)initWithDescription:(NSString *)desc canEnter:(BOOL)canEnter settingType:(SettingType)t;

@property (nonatomic ,copy) NSString *desc;
@property (nonatomic) BOOL canEnter;
@property (nonatomic) SettingType type;

@end
