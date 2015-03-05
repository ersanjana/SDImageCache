//
//  UIImageView+SDCache.h
//
//  Created by sanjana on 03/03/15.
//  Copyright (c) 2015 Sanjana (sanjana.s17@gmail.com) All rights reserved.

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

@interface UIImageView (SDCache)

- (void)sd_setImageWithURL:(NSURL *)url;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style shouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator;

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style shouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator completed:(SDWebImageCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style shouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;


- (NSURL *)sd_imageURL;


@end
