//
//  BaseAnimation.h
//  VCTransitions
//
//  Created by FOLY on 8/20/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef enum {
    AnimationTypePresent,
    AnimationTypeDismiss
} AnimationType;

@interface IFBaseTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) AnimationType type;

@end
