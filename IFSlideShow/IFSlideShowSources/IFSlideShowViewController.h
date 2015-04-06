//
//  IFSlideShowViewController.h
//  IFSlideShow
//
//  Created by FOLY on 12/30/14.
//  Copyright (c) 2014 SETA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFSlideShowViewController;
@class IFPageImagesViewController;
@protocol IFSlideShowDelegate <NSObject>

@optional
- (void)slideShowViewController:(IFSlideShowViewController *)viewController didSelectedAtIndex:(NSInteger)pageIndex;
- (void)slideShowViewController:(IFSlideShowViewController *)viewController presentPageViewController:(IFPageImagesViewController *)pageViewController;
- (void)updateReferenceView: (UIImageView *)refImageView;

@end

@interface IFSlideShowViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id <IFSlideShowDelegate> delegate;

@property (nonatomic, strong) NSArray *photoPaths;
@property (nonatomic, assign) BOOL showPageControl;
@property (nonatomic, assign) BOOL autoScrollEnabled;
@property (nonatomic) NSTimeInterval autoTimeInterval;

- (UIImageView *)refercenceView;

@end
