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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"IFSlideShowViewControllerSegue"]) {
		IFSlideShowViewController *slideShowVC = segue.destinationViewController;
		slideShowVC.photoPaths = @[
                                   @"https://c1.staticflickr.com/3/2902/14245410815_864044dc17_c.jpg",
                                   @"https://c2.staticflickr.com/6/5524/14058826897_505e9f2d68_c.jpg",
                                   @"https://c1.staticflickr.com/3/2921/14222261506_17032e49d7_c.jpg",
                                   @"https://c2.staticflickr.com/4/3813/14089018987_c2718df819_c.jpg",
                                   @"https://c2.staticflickr.com/6/5543/14295711803_56126c8f32_c.jpg"
                                   ];
		slideShowVC.delegate = self;
        slideShowVC.showPageControl = YES;
        slideShowVC.autoScrollEnabled = YES;
        slideShowVC.autoTimeInterval = 5;
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
