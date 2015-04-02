//
//  ImageViewerViewController.h
//  Tats
//
//  Created by FOLY on 12/15/14.
//  Copyright (c) 2014 Roxwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IFImageViewerViewController : UIViewController

@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, assign) NSInteger indexPage;

@property (nonatomic, assign) BOOL zoomEnabled;

- (UIImageView *)refercenceView;

@end
