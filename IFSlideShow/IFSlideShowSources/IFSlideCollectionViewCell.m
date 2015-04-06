//
//  IFSlideCollectionViewCell.m
//  IFSlideShow
//
//  Created by FOLY on 12/31/14.
//  Copyright (c) 2014 SETA. All rights reserved.
//

#import "IFSlideCollectionViewCell.h"

#import "UIImageView+WebCache.h"

@interface IFSlideCollectionViewCell ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation IFSlideCollectionViewCell

- (void)awakeFromNib {
	[self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"image"];
}

- (void)reloadImageContent {
	if ([_imagePath hasPrefix:@"file:///"]) {
		UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
		self.image = image;
	}
	else if ([_imagePath hasPrefix:@"http://"] || [_imagePath hasPrefix:@"https://"]) {
		NSURL *url = [NSURL URLWithString:_imagePath];
		__weak typeof(self) weakSelf = self;

		[self.imvContent sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		    weakSelf.image = image;
		}];
	}
	else {
		self.image = [UIImage imageNamed:_imagePath];
	}
}

- (void)setImagePath:(NSString *)imagePath {
	_imagePath = imagePath;
	[self reloadImageContent];
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
