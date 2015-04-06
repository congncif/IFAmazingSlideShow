//
//  ImageViewerViewController.m
//  Tats
//
//  Created by FOLY on 12/15/14.
//  Copyright (c) 2014 Roxwin. All rights reserved.
//

#import "IFImageViewerViewController.h"

#import "IFZoomAnimatedProtocol.h"

#import "UIImageView+WebCache.h"

@interface IFImageViewerViewController () <UIScrollViewDelegate, IFZoomAnimatedProtocol> {
	BOOL finishedLayout;
}
@property (nonatomic, weak) IBOutlet UIScrollView *scrContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *imvContent;
@property (strong, nonatomic)IBOutletCollection(NSLayoutConstraint) NSArray * constraints;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIImage *image;

@end

@implementation IFImageViewerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.scrContainerView.delegate = self;
	self.scrContainerView.minimumZoomScale = 1;

	CGFloat maxZoom = 1;
	if (_zoomEnabled) {
		maxZoom = 3;
	}
	self.scrContainerView.maximumZoomScale = maxZoom;
	self.scrContainerView.backgroundColor = [UIColor clearColor];

	self.imvContent.translatesAutoresizingMaskIntoConstraints = YES;
//    self.imvContent.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.imvContent.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.scrContainerView removeConstraints:self.constraints];
	self.loadingView.hidden = YES;

	[self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"image"];
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
	_zoomEnabled = zoomEnabled;
	CGFloat maxZoom = 1;
	if (_zoomEnabled) {
		maxZoom = 3;
	}
	self.scrContainerView.maximumZoomScale = maxZoom;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	self.scrContainerView.zoomScale = 1;
	self.scrContainerView.contentSize = self.imvContent.bounds.size;
}

#pragma mark - Rotate
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator> )coordinator {
	[coordinator animateAlongsideTransition: ^(id < UIViewControllerTransitionCoordinatorContext > context)
	{
	    //	    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	    // do whatever
	}                            completion: ^(id <UIViewControllerTransitionCoordinatorContext> context)
	{
	}];

	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

#pragma mark - Functions

- (void)setImagePath:(NSString *)imagePath {
	_imagePath = imagePath;
	[self reloadImageContent];
}

- (void)reloadImageContent {
	if ([_imagePath hasPrefix:@"file:///"]) {
		UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
		self.image = image;
	}
	else if ([_imagePath hasPrefix:@"http://"] || [_imagePath hasPrefix:@"https://"]) {
		NSURL *url = [NSURL URLWithString:_imagePath];
		__weak typeof(self) weakSelf = self;

		[self.imvContent sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached progress: ^(NSInteger receivedSize, NSInteger expectedSize) {
		} completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		    weakSelf.image = image;
		}];
	}
	else {
		self.image = [UIImage imageNamed:_imagePath];
	}
}

#pragma mark - Zoom

- (UIImageView *)refercenceView {
	return _imvContent;
}

#pragma mark - ScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imvContent;
}

#pragma mark - Observers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        self.imvContent.image = self.image;
        if (!self.image) {
            self.loadingView.hidden = NO;
            [self.loadingView startAnimating];
        }
        else {
            [self.loadingView stopAnimating];
        }
    }
}

@end
