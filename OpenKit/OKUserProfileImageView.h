//
//  OKUserProfileImageView.h
//  OKClient
//
//  Created by Suneet Shah on 1/8/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "OKUser.h"
#import "OKScore.h"

@interface OKUserProfileImageView : UIView

@property (nonatomic, strong) OKUser *user;
@property (nonatomic, strong) UIImage *image;

- (void)setImageURL:(NSString *)url;
- (void)setImageURL:(NSString *)url withPlaceholderImage:(UIImage *)placeholder;
- (void)setOKScoreProtocolScore:(OKScore*)aScore;

@end
