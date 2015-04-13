//
//  IFSlideShowViewController.m
//  IFSlideShow
//
//  Created by FOLY on 12/30/14.
//  Copyright (c) 2014 SETA. All rights reserved.
//

#import "IFSlideShowViewController.h"
#import "IFPageImagesViewController.h"

#import "IFZoomAnimatedProtocol.h"
#import "IFSlideCollectionViewCell.h"

@interface IFSlideShowViewController () <UICollectionViewDelegateFlowLayout, IFPageImagesDatasource, UINavigationControllerDelegate, IFZoomAnimatedProtocol> {
}

@property (nonatomic, assign) CGSize sizeCell;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, weak) IBOutlet UICollectionView *clvSlideImages;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *layoutSlide;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timerScroller;

@property (nonatomic, assign) BOOL directionReverse;

@end

@implementation IFSlideShowViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	if (!_photoPaths) {
		_photoPaths = @[];
	}
	_currentPage = 0;
	_autoTimeInterval = 5;
}

- (void)dealloc {
	[self stopAutoScroller];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshLayout];
	[self scrollToPage:@(_currentPage)];
	[self refreshPageControl];
	[self refreshScroller];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self stopAutoScroller];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	[self refreshLayout];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
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
        [self refreshLayout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollToPage:@(_currentPage) animated:YES];
        });
	}];

	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.view layoutSubviews];
    [self refreshLayout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToPage:@(_currentPage) animated:YES];
    });
}

#pragma mark - Setters

- (void)setPhotoPaths:(NSArray *)photoPaths {
	_photoPaths = photoPaths;
	_currentPage = 0;
	_pageControl.numberOfPages = _photoPaths.count;
	[self refreshLayout];
}

- (void)setShowPageControl:(BOOL)showPageControl {
	_showPageControl = showPageControl;
	[self refreshPageControl];
}

- (void)setAutoTimeInterval:(NSTimeInterval)autoTimeInterval {
	_autoTimeInterval = autoTimeInterval;
	if (_timerScroller.valid) {
		[self stopAutoScroller];
		[self startAutoScroller];
	}
}

#pragma mark - Layout
- (void)refreshPageControl {
	if (_showPageControl) {
		self.clvSlideImages.showsHorizontalScrollIndicator = NO;
		self.pageControl.hidden = NO;
	}
	else {
		self.clvSlideImages.showsHorizontalScrollIndicator = YES;
		self.pageControl.hidden = YES;
	}
	_pageControl.numberOfPages = _photoPaths.count;
	_pageControl.currentPage = _currentPage;
}

- (void)refreshLayout {
	_sizeCell = self.view.bounds.size;
	[_layoutSlide invalidateLayout];
	[self.clvSlideImages reloadData];
	//    if (self.delegate){
	//		[self.delegate updateReferenceView:[self refercenceView]];
	//    }
}

- (void)setAutoScrollEnabled:(BOOL)autoScrollEnabled {
	_autoScrollEnabled = autoScrollEnabled;
}

#pragma mark - CollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _photoPaths.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	IFSlideCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellID" forIndexPath:indexPath];
	[cell setImagePath:_photoPaths[indexPath.row]];
	return cell;
}

#pragma mark - CollectionView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopAutoScroller];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	_currentPage = self.clvSlideImages.contentOffset.x / self.clvSlideImages.contentSize.width * _photoPaths.count;
	_pageControl.currentPage = _currentPage;
//	NSLog(@"CURRENT PAGE: %ld", _currentPage);
    [self startAutoScroller];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (self.delegate && [self.delegate respondsToSelector:@selector(slideShowViewController:didSelectedAtIndex:)]) {
		[self.delegate slideShowViewController:self didSelectedAtIndex:indexPath.row];
	}
	else {
		IFPageImagesViewController *pageImagesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IFPageImagesViewController"];
		pageImagesVC.dataSource = self;
		pageImagesVC.currentPage = _currentPage;
		pageImagesVC.showPageControl = YES;
		__weak typeof(self) weakSelf = self;

		pageImagesVC.callbackHandler = ^(NSInteger pageIndex) {
			weakSelf.currentPage = pageIndex;
			dispatch_async(dispatch_get_main_queue(), ^{
			    [weakSelf scrollToPage:@(pageIndex)];
			});
		};

		if (self.delegate && [self.delegate respondsToSelector:@selector(slideShowViewController:presentPageViewController:)]) {
			[self.delegate slideShowViewController:self presentPageViewController:pageImagesVC];
		}
		else {
			[self presentViewController:pageImagesVC animated:YES completion:nil];
		}
	}

	if (self.delegate) [self.delegate updateReferenceView:[self refercenceView]];
}

#pragma mark - CollectionViewLayout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return _sizeCell;
}

#pragma mark - Functions
- (void)scrollToPage:(NSNumber *)pageNumber {
    [self scrollToPage:pageNumber animated:NO];
}

- (void)scrollToPage:(NSNumber *)pageNumber animated: (BOOL)animated{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNumber.integerValue inSection:0];
    [self.clvSlideImages scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    
    if (self.delegate) {
        [self.delegate updateReferenceView:[self refercenceView]];
    }
}

- (void)refreshScroller {
	if (self.view) {
		if (_autoScrollEnabled) {
			if (_timerScroller.valid) {
				return;
			}
			[self startAutoScroller];
		}
		else {
			[self stopAutoScroller];
		}
	}
}

- (void)startAutoScroller {
	if ([self numberOfPhotos] > 1) {
        if (_timerScroller && !_timerScroller.isValid) {
            [self stopAutoScroller];
        }
        
		if (!_timerScroller) {
			_timerScroller = [NSTimer scheduledTimerWithTimeInterval:_autoTimeInterval target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
		}
	}
}

- (void)timerFire:(NSTimer *)timer {
	_currentPage = [self nextPage];
	[self scrollToPage:@(_currentPage) animated:YES];
	[self refreshPageControl];
}

- (NSInteger)nextPage {
	NSInteger nextPage;
	if (_directionReverse) {
		nextPage = _currentPage - 1;
	}
	else {
		nextPage = _currentPage + 1;
	}

	if (nextPage >= 0 && nextPage < [self numberOfPhotos]) {
		return nextPage;
	}
	else {
		_directionReverse = !_directionReverse;
		return [self nextPage];
	}
}

- (void)stopAutoScroller {
	if (_timerScroller) {
		[_timerScroller invalidate];
		_timerScroller = nil;
	}
}

#pragma mark - PageImageDatasource
- (NSString *)imagePathAtIndex:(NSInteger)index {
	return _photoPaths[index];
}

- (NSInteger)numberOfPhotos {
	return _photoPaths.count;
}

#pragma mark - Zoom
- (UIImageView *)refercenceView {
	NSIndexPath *displayIndexPath = [NSIndexPath indexPathForRow:_currentPage inSection:0];
	UICollectionViewCell *cell = (UICollectionViewCell *)[self.clvSlideImages cellForItemAtIndexPath:displayIndexPath];

	if (!cell) {
		[self.clvSlideImages reloadItemsAtIndexPaths:@[displayIndexPath]];
		cell =  (UICollectionViewCell *)[self.clvSlideImages cellForItemAtIndexPath:displayIndexPath];
	}
	return (UIImageView *)[cell viewWithTag:1];
}

@end
