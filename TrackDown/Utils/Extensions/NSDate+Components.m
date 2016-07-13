//
//  NSDate+Components.m
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "NSDate+Components.h"

@implementation NSDate(Components)

-(NSDateComponents *)components{
    NSDateComponents *com = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self];
    return com;
}


-(NSInteger)year{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}
-(NSInteger)month{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}
-(NSInteger)day{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}
-(NSInteger)hour{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}
-(NSInteger)minute{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}
-(NSInteger)second{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

@end
