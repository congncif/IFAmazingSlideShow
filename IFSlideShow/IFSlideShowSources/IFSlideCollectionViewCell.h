//
//  IFSlideCollectionViewCell.h
//  IFSlideShow
//
//  Created by FOLY on 12/31/14.
//  Copyright (c) 2014 SETA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IFSlideCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imvContent;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;

@property (nonatomic, copy) NSString *imagePath;

@end
