//
//  CYGuidanceManager.m
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYGuidanceManager.h"

#define m_defaults [NSUserDefaults standardUserDefaults]

@implementation CYGuidanceManager

+(BOOL)shouldShowGuidance:(GuideType)type{
    NSString *key = [self keyForGuideType:type];
    
    //if has shown,return no.
    return ![m_defaults boolForKey:key];
}

+(void)updateGuidance:(GuideType)type withShowStatus:(BOOL)shown{
    NSString *key = [self keyForGuideType:type];
    
    [m_defaults setBool:shown forKey:key];
    [m_defaults synchronize];
}


+(NSString *)keyForGuideType:(GuideType)type{
    return [NSString stringWithFormat:@"GuideType_%lu",type];
}

@end
