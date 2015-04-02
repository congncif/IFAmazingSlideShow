//
//  ScaleAnimation.m
//  VCTransitions
//
//  Created by FOLY on 9/2/13.
//  Copyright (c) 2013 FOLY. All rights reserved.
//

#import "IFZoomTransitionAnimation.h"

#import "IFZoomAnimatedProtocol.h"
#import "UIImage+AspectFit.h"

@interface IFZoomTransitionAnimation () {
	CGFloat _startScale, _completionSpeed;
	id <UIViewControllerContextTransitioning> _context;
	UIView *_transitioningView;
	UIPinchGestureRecognizer *_pinchRecognizer;
}


- (void)updateWithPercent:(CGFloat)percent;
- (void)end:(BOOL)cancelled;

@end

@implementation IFZoomTransitionAnimation

@synthesize viewForInteraction = _viewForInteraction;

- (instancetype)initWithNavigationController:(UINavigationController *)controller {
	self = [super init];
	if (self) {
		self.navigationController = controller;
		_completionSpeed = 0.2;

		_pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	}
	return self;
}

- (void)setViewForInteraction:(UIView *)viewForInteraction {
	if (_viewForInteraction && [_viewForInteraction.gestureRecognizers containsObject:_pinchRecognizer]) [_viewForInteraction removeGestureRecognizer:_pinchRecognizer];

	_viewForInteraction = viewForInteraction;
	[_viewForInteraction addGestureRecognizer:_pinchRecognizer];
}

#pragma mark - Animated Transitioning


- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext {
	//Get references to the view hierarchy
	UIView *containerView = [transitionContext containerView];
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	if (self.type == AnimationTypePresent) {
		UIViewController <IFZoomAnimatedProtocol> *fromVC = (UIViewController <IFZoomAnimatedProtocol> *)fromViewController;

		UIImageView *sourceView = [fromVC refercenceView];
		CGRect frame = [sourceView.superview convertRect:sourceView.bounds fromView:sourceView];
		frame = [containerView convertRect:frame fromView:sourceView.superview];

		UIImageView *transitionView = [[UIImageView alloc] initWithImage:sourceView.image];
		transitionView.contentMode = sourceView.contentMode;
		transitionView.clipsToBounds = YES;
		transitionView.frame = frame;

		[transitionContext.containerView addSubview:transitionView];

		// Compute the final frame for the temporary view
		CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
		CGRect transitionViewFinalFrame = [sourceView.image tgr_aspectFitRectForSize:finalFrame.size];

		self.referenceImageView = sourceView;

		// Perform the transition using a spring motion effect
		NSTimeInterval duration = [self transitionDuration:transitionContext];

		[UIView animateWithDuration:duration
		                      delay:0
		     usingSpringWithDamping:duration
		      initialSpringVelocity:0
		                    options:UIViewAnimationOptionCurveLinear
		                 animations: ^{
		    fromViewController.view.alpha = 0;
		    transitionView.frame = transitionViewFinalFrame;
		}

		                 completion: ^(BOOL finished) {
		    fromViewController.view.alpha = 1;

		    [transitionView removeFromSuperview];
		    toViewController.view.frame = finalFrame;
		    [transitionContext.containerView addSubview:toViewController.view];

		    [transitionContext completeTransition:YES];
		}];
	}
	else if (self.type == AnimationTypeDismiss) {
		//Add 'to' view to the hierarchy
		UIViewController <IFZoomAnimatedProtocol> *toViewController = (UIViewController <IFZoomAnimatedProtocol> *)[transitionContext viewControllerForKey : UITransitionContextToViewControllerKey];
		UIViewController <IFZoomAnimatedProtocol> *fromViewController = (UIViewController <IFZoomAnimatedProtocol> *)[transitionContext viewControllerForKey : UITransitionContextFromViewControllerKey];


		// The toViewController view will fade in during the transition
		toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
		toViewController.view.alpha = 0;
		[transitionContext.containerView addSubview:toViewController.view];
		[transitionContext.containerView sendSubviewToBack:toViewController.view];

		self.referenceImageView = [toViewController refercenceView];
		self.referenceImageView.hidden = YES;
		// Compute the initial frame for the temporary view based on the image view
		// of the TGRImageViewController
		UIImageView *sourceView = [fromViewController refercenceView];

		CGRect transitionViewInitialFrame = [sourceView.image tgr_aspectFitRectForSize:sourceView.bounds.size];
		transitionViewInitialFrame = [transitionContext.containerView convertRect:transitionViewInitialFrame fromView:sourceView];

		// Compute the final frame for the temporary view based on the reference
		// image view
		CGRect transitionViewFinalFrame = [transitionContext.containerView convertRect:self.referenceImageView.bounds fromView:self.referenceImageView];
//        CGRect transitionViewFinalFrame = [self.referenceImageView.superview convertRect:sourceView.bounds fromView:sourceView];
//        transitionViewFinalFrame = [containerView convertRect:transitionViewFinalFrame fromView:self.referenceImageView.superview];

		if (UIApplication.sharedApplication.isStatusBarHidden && ![toViewController prefersStatusBarHidden]) {
			transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20);
		}

		// Create a temporary view for the zoom out transition based on the image
		// view controller contents
		UIImageView *transitionView = [[UIImageView alloc] initWithImage:sourceView.image];
		transitionView.contentMode = self.referenceImageView.contentMode;
		transitionView.clipsToBounds = YES;
		transitionView.frame = transitionViewInitialFrame;
		[transitionContext.containerView addSubview:transitionView];
		[fromViewController.view removeFromSuperview];

		// Perform the transition
		NSTimeInterval duration = [self transitionDuration:transitionContext];

		__weak typeof(self) weakSelf = self;

		[UIView animateWithDuration:duration
		                      delay:0
		                    options:UIViewAnimationOptionCurveEaseInOut
		                 animations: ^{
		    toViewController.view.alpha = 1;
		    transitionView.frame = transitionViewFinalFrame;
		} completion: ^(BOOL finished) {
		    [transitionView removeFromSuperview];
		    [transitionContext completeTransition:YES];
		    weakSelf.referenceImageView.hidden = NO;
		}];
	}
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext {
	return 0.45;
}

- (void)animationEnded:(BOOL)transitionCompleted {
	self.interactive = NO;
}

#pragma mark - Interactive Transitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning> )transitionContext {
	//Maintain reference to context
	_context = transitionContext;

	//Get references to view hierarchy
	UIView *containerView = [transitionContext containerView];
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	//Insert 'to' view into hierarchy
	toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
	[containerView insertSubview:toViewController.view belowSubview:fromViewController.view];

	//Save reference for view to be scaled
	_transitioningView = fromViewController.view;
}

- (void)updateWithPercent:(CGFloat)percent {
	CGFloat scale = fabsf(percent - 1.0);
	_transitioningView.transform = CGAffineTransformMakeScale(scale, scale);
	[_context updateInteractiveTransition:percent];
}

- (void)end:(BOOL)cancelled {
	if (cancelled) {
		[UIView animateWithDuration:_completionSpeed animations: ^{
		    _transitioningView.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion: ^(BOOL finished) {
		    [_context cancelInteractiveTransition];
		    [_context completeTransition:NO];
		}];
	}
	else {
		[UIView animateWithDuration:_completionSpeed animations: ^{
		    _transitioningView.transform = CGAffineTransformMakeScale(0.0, 0.0);
		} completion: ^(BOOL finished) {
		    [_context finishInteractiveTransition];
		    [_context completeTransition:YES];
		}];
	}
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
	CGFloat scale = pinch.scale;
	switch (pinch.state) {
		case UIGestureRecognizerStateBegan:
			_startScale = scale;
			self.interactive = YES;
			[self.navigationController popViewControllerAnimated:YES];
			break;

		case UIGestureRecognizerStateChanged: {
			CGFloat percent = (1.0 - scale / _startScale);
			[self updateWithPercent:(percent < 0.0) ? 0.0:percent];
			break;
		}

		case UIGestureRecognizerStateEnded : {
				CGFloat percent = (1.0 - scale / _startScale);
				BOOL cancelled = ([pinch velocity] < 5.0 && percent <= 0.3);
				[self end:cancelled];
				break;
		}

		case UIGestureRecognizerStateCancelled: {
			CGFloat percent = (1.0 - scale / _startScale);
			BOOL cancelled = ([pinch velocity] < 5.0 && percent <= 0.3);
			[self end:cancelled];
			break;
		}

		case UIGestureRecognizerStatePossible:
			break;

		case UIGestureRecognizerStateFailed:
			break;
	}
}

@end
