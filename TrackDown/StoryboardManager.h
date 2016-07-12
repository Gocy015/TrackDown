//
//  StoryboardManager.h
//  TrackDown
//
//  Created by Gocy on 16/7/11.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryboardManager : NSObject

+(UIStoryboard *)mainStoryboard;



/**
 *  Get storyboard with id (not implemented yet!)
 *
 *  @param identifier id
 *
 *  @return storyboard
 */
+(UIStoryboard *)storyboardWithIdentifier:(NSString *)identifier;

@end
