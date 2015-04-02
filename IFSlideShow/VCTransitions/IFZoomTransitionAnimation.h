//
//  ScaleAnimation.h
//  VCTransitions
//
//  Created by FOLY on 9/2/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "IFBaseTransitionAnimation.h"

@interface IFZoomTransitionAnimation : IFBaseTransitionAnimation //<UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign) UINavigationController *navigationController;
@property (nonatomic, strong) UIView *viewForInteraction;
@property (nonatomic, weak) UIImageView *referenceImageView;

-(instancetype)initWithNavigationController:(UINavigationController *)controller;
-(void)handlePinch:(UIPinchGestureRecognizer *)pinch;

@end
