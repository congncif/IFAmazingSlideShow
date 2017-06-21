//
//  ViewController.m
//  IFSlideShow
//
//  Created by FOLY on 12/30/14.
//  Copyright (c) 2014 SETA. All rights reserved.
//

#import "ViewController.h"

#import "IFSlideShowViewController.h"
#import "IFPageImagesViewController.h"

#import "IFZoomTransitionAnimation.h"
#import "IFZoomAnimatedProtocol.h"

@interface ViewController () <IFSlideShowDelegate, UIViewControllerTransitioningDelegate, IFZoomAnimatedProtocol>

@property (nonatomic, strong) IFZoomTransitionAnimation *animationTransition;
@property (nonatomic, weak) UIImageView *refrerenceImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	_animationTransition = [[IFZoomTransitionAnimation alloc]init];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator> )coordinator {
	[coordinator animateAlongsideTransition: ^(id < UIViewControllerTransitionCoordinatorContext > context)
	{
	    //	    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	    // do whatever
	    [self.view layoutSubviews];
	}                            completion: ^(id <UIViewControllerTransitionCoordinatorContext> context)
	{
	}];

	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.view layoutSubviews];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"IFSlideShowViewControllerSegue"]) {
		IFSlideShowViewController *slideShowVC = segue.destinationViewController;
		slideShowVC.photoPaths = @[
		    @"https://i.imgur.com/G5cA589.png",
		    @"https://i.imgur.com/MTga82K.png",
		    @"https://i.imgur.com/zKg73hq.png",
		    @"https://i.imgur.com/nafky5f.png",
		    @"https://i.imgur.com/nA8RVni.png",
		    @"https://i.imgur.com/y5gP9O2.png",
		    @"https://i.imgur.com/TGMrfnQ.jpg",
		    @"https://i.imgur.com/S9XTU61.jpg",
		    @"https://i.imgur.com/6I69iAd.jpg",
		];
		slideShowVC.delegate = self;
		slideShowVC.showPageControl = YES;
		slideShowVC.autoScrollEnabled = YES;
		slideShowVC.autoTimeInterval = 5;
        slideShowVC.autoScrollType = AutoScrollTypeCircle;
	}
}

#pragma mark - SlideShow Delegate
//- (void)slideShowViewController:(IFSlideShowViewController <IFPageImagesDatasource> *)viewController didSelectedAtIndex:(NSInteger)pageIndex {
//	IFPageImagesViewController *pageImagesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IFPageImagesViewController"];
//	pageImagesVC.dataSource = viewController;
//	pageImagesVC.currentPage = pageIndex;
//
//	pageImagesVC.transitioningDelegate = self;
//	pageImagesVC.modalPresentationStyle = UIModalPresentationFullScreen;
//
//	[self presentViewController:pageImagesVC animated:YES completion:nil];
//}

- (void)slideShowViewController:(IFSlideShowViewController *)viewController presentPageViewController:(IFPageImagesViewController *)pageViewController {
	pageViewController.transitioningDelegate = self;
	pageViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	pageViewController.zoomEnabled = YES;

	[self presentViewController:pageViewController animated:YES completion:nil];
}

- (void)updateReferenceView:(UIImageView *)refImageView {
	_refrerenceImageView = refImageView;
}

#pragma mark - Transitioning Delegate (Modal)
- (id <UIViewControllerAnimatedTransitioning> )animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	_animationTransition.type = AnimationTypePresent;
	return _animationTransition;
}

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForDismissedController:(UIViewController *)dismissed {
	_animationTransition.type = AnimationTypeDismiss;
	return _animationTransition;
}

#pragma mark - Zoom Protocol
- (UIImageView *)refercenceView {
	return _refrerenceImageView;
}

@end
