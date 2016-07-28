//
//  SettingsManager.h
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject

//getter
+(instancetype)sharedManager;

-(NSArray *)getCurrentSettings;

@end
