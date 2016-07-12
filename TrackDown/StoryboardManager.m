//
//  StoryboardManager.m
//  TrackDown
//
//  Created by Gocy on 16/7/11.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "StoryboardManager.h"

@implementation StoryboardManager

+(UIStoryboard *)mainStoryboard{
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
}

+(UIStoryboard *)storyboardWithIdentifier:(NSString *)identifier{
    
    return [UIStoryboard storyboardWithName:identifier bundle:[NSBundle mainBundle]];

}

@end
