//
//  BCAchievementViewProtocol.h
//  Aki
//
//  Created by Jeremy Knope on 10/26/10.
//  Copyright 2010 Ambrosia Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@protocol BCAchievementViewProtocol

- (id)initWithFrame:(CGRect)aFrame achievementDescription:(GKAchievementDescription *)anAchievement;
- (id)initWithFrame:(CGRect)aFrame title:(NSString *)aTitle message:(NSString *)aMessage;

- (UIView *)backgroundView;
- (void)setBackgroundView:(UIView *)aBackgroundView;
- (UILabel *)textLabel;
- (UILabel *)detailLabel;
- (UIImageView *)iconView;

- (void)setImage:(UIImage *)image;
@end
