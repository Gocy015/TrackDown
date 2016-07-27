//
//  ExpandableObjectProtocol.h
//  TrackDown
//
//  Created by Gocy on 16/7/22.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#ifndef ExpandableObjectProtocol_h
#define ExpandableObjectProtocol_h


@protocol ExpandableObject <NSObject>

-(NSArray *)descriptionForSecondaryObjects;

-(NSString *)description;

-(NSUInteger)countOfSecondaryObjects;

@property (nonatomic ,readwrite) BOOL opened;

@end

#endif /* ExpandableObjectProtocol_h */
