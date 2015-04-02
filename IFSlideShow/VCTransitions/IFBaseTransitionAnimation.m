//
//  BaseAnimation.m
//  VCTransitions
//
//  Created by FOLY on 8/20/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "IFBaseTransitionAnimation.h"

@implementation IFBaseTransitionAnimation

#pragma mark - UIViewControllerAnimatedTransitioning

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(NO, @"animateTransition: should be handled by subclass of BaseAnimation");
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

-(void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    NSAssert(NO, @"handlePinch: should be handled by a subclass of BaseAnimation");
}

@end
