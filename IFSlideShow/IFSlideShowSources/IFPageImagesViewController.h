//
//  PageImagesViewController.h
//  Tats
//
//  Created by FOLY on 12/15/14.
//  Copyright (c) 2014 Roxwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IFPageImagesDatasource <NSObject>

@required
- (NSString *)imagePathAtIndex:(NSInteger)index;
- (NSInteger)numberOfPhotos;

@end

typedef void(^PageImagesCallback)(NSInteger pageIndex);

@interface IFPageImagesViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, weak) id <IFPageImagesDatasource> dataSource;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, copy) PageImagesCallback callbackHandler;

@property (nonatomic, assign) BOOL zoomEnabled;
@property (nonatomic, assign) BOOL showPageControl;

@end
