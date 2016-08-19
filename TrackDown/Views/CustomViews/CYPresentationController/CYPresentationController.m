//
//  CYPresentationController.m
//  TrackDown
//
//  Created by Gocy on 16/8/19.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYPresentationController.h"
#import "ArrowContainerView.h"

@interface CYPresentationController ()
@property (nonatomic ,weak) ArrowContainerView *arrContainerView;

@end

@implementation CYPresentationController



#pragma mark - LifeCycle

- (instancetype)init{
    if (self = [super init]){
        _showPoint = CGPointZero;
        _type = PresentationType_Popover;
    }
    return self;
}

- (void)dealloc{
    NSLog(@"CYPopoverController Dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Method

-(void)showFrom:(UIViewController *)vc{
    if (!self.contentController) {
        return ;
    }
    if (_type == PresentationType_Popover) {
        
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//        self.contentController.view.bounds = CGRectMake(0, 0, self.contentController.preferredContentSize.width, self.contentController.preferredContentSize.height);
        self.arrContainerView.contentView = self.contentController.view;
        self.arrContainerView.backgroundFillColor = self.backgroundFillColor;
        self.arrContainerView.bounds = CGRectMake(0, 0, self.contentController.view.bounds.size.width + 15, self.contentController.view.bounds.size.height + 10);
        
        if (![UIApplication sharedApplication].statusBarHidden) {
            self.showPoint = CGPointMake(self.showPoint.x, self.showPoint.y + 20);
        }
        
        self.arrContainerView.showPoint = self.showPoint;
        
        self.arrContainerView.alpha = 0.92;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.view];
        
//        [vc.view addSubview:self.view];
        
        [vc addChildViewController:self];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self.view addGestureRecognizer:tap];
        
        self.view.backgroundColor = [UIColor clearColor];
        
    }else{
        
        [self.view addSubview:self.contentController.view];
        // simply push
        if (vc.navigationController) {
            [vc.navigationController pushViewController:self animated:YES];
        }else{ //present
            [vc presentViewController:self animated:YES completion:nil];
        }
    }
}

-(void)dismiss{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}



#pragma mark - Setters & Getters
-(void)setShowPoint:(CGPoint)showPoint{
    _showPoint = showPoint;
    
//    if (self.type == PresentationType_FullScreen) {
//        return ;
//    }
//    //calculate triangle position
////    if (self.arrContainerView) {
////        self.arrContainerView.showPoint = _showPoint;
////    }
}

-(void)setContentController:(UIViewController *)contentController{
    if (_contentController) {
        [_contentController.view removeFromSuperview];
        [_contentController removeFromParentViewController];
    }
    
//    [self.view addSubview:contentController.view];
    [self addChildViewController:contentController];
    
    _contentController = contentController;
}


-(ArrowContainerView *)arrContainerView{
    if (!_arrContainerView) {
        ArrowContainerView *arr = [[ArrowContainerView alloc] initWithTriangleDirection:TriangleDirection_Top triangleXPosition:0.92 triangleYPosition:0.5];
        [self.view addSubview:arr];
        
        if (self.contentController) {
            arr.contentView = self.contentController.view;
        }
        arr.showPoint = self.showPoint;
        arr.maxTriangleSize = CGSizeMake(15, 10);
        
        _arrContainerView = arr;
    }
    
    return _arrContainerView;
}


#pragma mark - Helpers

-(void)didTap:(UITapGestureRecognizer *)tap{
    [self dismiss];
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
