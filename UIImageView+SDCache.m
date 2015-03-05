//  UIImageView+SDCache.m
//  Created by sanjana on 03/03/15.
//  Copyright (c) 2015 Sanjana (sanjana.s17@gmail.com) All rights reserved.

#import "UIImageView+SDCache.h"
#import <objc/runtime.h>
#import "UIView+WebCacheOperation.h"

static char imageURLKey;

@implementation UIImageView (SDCache)

#pragma mark - Set Image With URL

- (void)sd_setImageWithURL:(NSURL *)url {
    
    [self sd_setImageWithURL:url placeholderImage:nil options:0 usingActivityIndicatorStyle:0 shouldShowActivityIndicator:NO progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 usingActivityIndicatorStyle:0 shouldShowActivityIndicator:NO progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options usingActivityIndicatorStyle:0 shouldShowActivityIndicator:NO progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style shouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator {
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options usingActivityIndicatorStyle:style shouldShowActivityIndicator:shouldShowActivityIndicator progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {

    [self sd_setImageWithURL:url placeholderImage:nil options:0 usingActivityIndicatorStyle:0 shouldShowActivityIndicator:NO progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {

    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 usingActivityIndicatorStyle:0 shouldShowActivityIndicator:NO progress:nil completed:completedBlock];
}


- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {

    [self sd_setImageWithURL:url placeholderImage:placeholder options:options usingActivityIndicatorStyle:0 shouldShowActivityIndicator:NO progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style shouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator completed:(SDWebImageCompletionBlock)completedBlock {

    [self sd_setImageWithURL:url placeholderImage:placeholder options:options usingActivityIndicatorStyle:style shouldShowActivityIndicator:shouldShowActivityIndicator progress:nil completed:completedBlock];
    
}


- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style shouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    
    [self sd_cancelImageRequestOperationAndRemoveActivityIndicatorView];
    
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (shouldShowActivityIndicator) {
        [self sd_addActivityIndicatorWithStyle:style];
    }
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    __weak UIImageView *wself = self;
    if (url) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                [wself sd_removeActivityIndicatorView];
                
                if (image) {
                    [wself sd_setImageWithAnimation:image];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        [wself sd_setImageWithAnimation:image];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [wself sd_removeActivityIndicatorView];
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}


#pragma mark - Object Association

- (UIActivityIndicatorView *)activityIndicatorView
{
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, @selector(activityIndicatorView));
}

- (void)setActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView {
    objc_setAssociatedObject(self, @selector(activityIndicatorView), activityIndicatorView, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Cancel Request

- (void)sd_cancelImageRequestOperationAndRemoveActivityIndicatorView
{
    [self sd_cancelCurrentImageLoad];
    [self sd_removeActivityIndicatorView];
}

- (void)sd_removeActivityIndicatorView
{
    UIActivityIndicatorView *activityIndicator = [self activityIndicatorView];
    
    if (!activityIndicator) {
        return;
    }
    
    [activityIndicator removeFromSuperview];
    [self setActivityIndicatorView:nil];
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

#pragma mark - Private Helpers

- (void)sd_setImageWithAnimation:(UIImage *)image {
    
    [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.image = image;
    } completion:^(BOOL finished) {
        [self setNeedsLayout];
    }];
    
}

- (void)sd_addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style
{
    UIActivityIndicatorView *activityIndicator = [self activityIndicatorView];
    
    if (!activityIndicator) {
        
        activityIndicator = [self sd_createActivityIndicatorWithStyle:style];
        [self setActivityIndicatorView:activityIndicator];
        
        if ([NSThread isMainThread]) {
            [self addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self addSubview:activityIndicator];
                [activityIndicator startAnimating];
            });
        }
        return;
    }
    
    if ([NSThread isMainThread]) {
        [activityIndicator startAnimating];
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [activityIndicator startAnimating];
        });
    }
}

- (UIActivityIndicatorView *)sd_createActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    activityIndicator.userInteractionEnabled = NO;
    activityIndicator.center = self.center;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    return activityIndicator;
}

@end
