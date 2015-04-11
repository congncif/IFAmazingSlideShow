//
//  PageImagesViewController.m
//  Tats
//
//  Created by FOLY on 12/15/14.
//  Copyright (c) 2014 Roxwin. All rights reserved.
//

#import "IFPageImagesViewController.h"

#import "IFImageViewerViewController.h"
#import "IFZoomAnimatedProtocol.h"

@interface IFPageImagesViewController () <IFZoomAnimatedProtocol, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation IFPageImagesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self initializeComponents];
	[self refreshPageControl];

	[self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"currentPage" context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)initializeComponents {
	self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:20.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];

	self.pageController.dataSource = self;
	self.pageController.delegate = self;
    
	[[self.pageController view] setFrame:[[self view] bounds]];
    self.pageController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.automaticallyAdjustsScrollViewInsets = NO;

	IFImageViewerViewController *initialViewController = [self viewControllerAtIndex:_currentPage];
	NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

	[self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

	[self addChildViewController:self.pageController];
	[[self view] addSubview:[self.pageController view]];
	[self.pageController didMoveToParentViewController:self];

    [self.view sendSubviewToBack:self.pageController.view];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator> )coordinator {
    
    [coordinator animateAlongsideTransition: ^(id < UIViewControllerTransitionCoordinatorContext > context)
     {
         // do whatever
         
     }                            completion: ^(id <UIViewControllerTransitionCoordinatorContext> context)
     {
         [self.view layoutSubviews];
         IFImageViewerViewController *childViewController = (IFImageViewerViewController *)[self.pageController viewControllers][0];
         childViewController.view.frame = self.view.frame;
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.view layoutSubviews];
    IFImageViewerViewController *childViewController = (IFImageViewerViewController *)[self.pageController viewControllers][0];
    childViewController.view.frame = self.view.frame;
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

#pragma mark - Actions
- (IBAction)closeButtonTapped:(id)sender {
	[self dismissViewControllerAnimated:YES completion: ^{
	}];
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPageView
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	IFImageViewerViewController *childViewController = (IFImageViewerViewController *)viewController;
	if (childViewController.indexPage - 1 < 0) {
		return nil;
	}
	return [self viewControllerAtIndex:childViewController.indexPage - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	IFImageViewerViewController *childViewController = (IFImageViewerViewController *)viewController;
//	NSLog(@"Number pages: %ld", [self.dataSource numberOfPhotos]);
	if (childViewController.indexPage + 1 == [self.dataSource numberOfPhotos]) {
		return nil;
	}
	return [self viewControllerAtIndex:childViewController.indexPage + 1];
}

- (IFImageViewerViewController *)viewControllerAtIndex:(NSUInteger)index {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

	IFImageViewerViewController *childViewController = [storyboard instantiateViewControllerWithIdentifier:@"IFImageViewerViewController"];
	childViewController.view.frame = self.view.frame;
    childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	childViewController.indexPage = index;
	childViewController.imagePath = [self.dataSource imagePathAtIndex:index];
	childViewController.zoomEnabled = _zoomEnabled;

	return childViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
	if (finished && completed) {
		IFImageViewerViewController *childViewController = (IFImageViewerViewController *)[self.pageController viewControllers][0];
		NSInteger indexPage = childViewController.indexPage;
        self.currentPage = indexPage;
		if (self.callbackHandler) {
			self.callbackHandler(indexPage);
		}
	}
}

//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//	// The number of items reflected in the page indicator.
//	return 5;
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//	// The selected item reflected in the page indicator.
//	return 0;
//}

#pragma mark - Zoom

- (UIImageView *)refercenceView {
	IFImageViewerViewController *photoViewController = [[self.pageController viewControllers]lastObject];
	return [photoViewController refercenceView];
}

#pragma mark - Setters/Getters

- (void)setShowPageControl:(BOOL)showPageControl {
	_showPageControl = showPageControl;
	[self refreshPageControl];
}

- (NSInteger)currentIndex {
	IFImageViewerViewController *photoViewController = [[self.pageController viewControllers]lastObject];
	return photoViewController.indexPage;
}

#pragma mark - Layout
- (void)refreshPageControl {
	if (_showPageControl) {
		self.pageControl.hidden = NO;
	}
	else {
		self.pageControl.hidden = YES;
	}
	_pageControl.numberOfPages = [self.dataSource numberOfPhotos];
    _pageControl.currentPage = [self currentIndex];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"currentPage"]) {
		[self refreshPageControl];
	}
}

@end
