//
//  UIViewController+NoBackTitle.m
//  TrackDown
//
//  Created by Gocy on 16/7/27.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "UIViewController+NoBackTitle.h"
#import <objc/runtime.h>

@implementation UIViewController(NoBackTitle)


+(void)load{
    SEL originalSelector = @selector(viewDidLoad);
    SEL mySelector = @selector(cy_viewDidLoad);
    
    Method originalImp = class_getInstanceMethod([self class], originalSelector);
    Method myImp = class_getInstanceMethod([self class], mySelector);
    
    
    method_exchangeImplementations(myImp, originalImp);
}


-(void)cy_viewDidLoad{
    [self cy_viewDidLoad]; 
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
