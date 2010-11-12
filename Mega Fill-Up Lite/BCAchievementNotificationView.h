//
//  BCAchievementNotificationView.h
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//  $Id$
//

#import <UIKit/UIKit.h>
//#import "BCAchievementHandler.h"
#import "BCAchievementViewProtocol.h"

//#define kBCAchievementAnimeTime     0.4f
//#define kBCAchievementDisplayTime   1.75f

//#define kBCAchievementDefaultSize   CGRectMake(0.0f, 0.0f, 284.0f, 52.0f);
//#define kBCAchievementFrameStart    CGRectMake(18.0f, -53.0f, 284.0f, 52.0f);
//#define kBCAchievementFrameEnd      CGRectMake(18.0f, 10.0f, 284.0f, 52.0f);

#define kBCAchievementText1         CGRectMake(10.0, 6.0f, 264.0f, 22.0f);
#define kBCAchievementText2         CGRectMake(10.0, 20.0f, 264.0f, 22.0f);
#define kBCAchievementText1WLogo    CGRectMake(45.0, 6.0f, 229.0f, 22.0f);
#define kBCAchievementText2WLogo    CGRectMake(45.0, 20.0f, 229.0f, 22.0f);

#pragma mark -

/**
 * The BCAchievementNotificationView is a view for showing the achievement earned.
 */
@interface BCAchievementNotificationView : UIView<BCAchievementViewProtocol>
{
    GKAchievementDescription  *achievementDescription;  /**< Description of achievement earned. */

//    NSString *message;  /**< Optional custom achievement message. */
//    NSString *title;    /**< Optional custom achievement title. */

    UIView  *backgroundView;  /**< Stretchable background view. */
    UIImageView  *iconView;        /**< Logo that is displayed on the left. */

    UILabel      *textLabel;    /**< Text label used to display achievement title. */
    UILabel      *detailLabel;  /**< Text label used to display achievement description. */
	
	UIViewContentMode displayMode; // where to display the view: corners, top, or bottom. default: top
}

/** Description of achievement earned. setting this will automatically set approrpiate UI with title, description and image. */
@property (nonatomic, retain) GKAchievementDescription *achievementDescription;

// decided against these in favor of table cell style API of accessing the special subviews
///** Optional custom achievement message. */
//@property (nonatomic, retain) NSString *message;
///** Optional custom achievement title. */
//@property (nonatomic, retain) NSString *title;

/** Stretchable background view. */
// TODO: these views should be readonly outside of ourselves, similar to UITableViewCell's imageView etc., except allow backgroundView maybe to be swapped?
@property (nonatomic, retain) UIView *backgroundView;
/** Logo that is displayed on the left. */
@property (readonly) UIImageView *iconView;
/** Text label used to display achievement title. */
@property (readonly) UILabel *textLabel;
/** Text label used to display achievement description. */
@property (readonly) UILabel *detailLabel;

//@property (nonatomic, assign) UIViewContentMode displayMode;

#pragma mark -

/**
 * Create a notification with an achievement description.
 * @param achievement  Achievement description to notify user of earning.
 * @return a BCAchievementNoficiation view.
 */
- (id)initWithFrame:(CGRect)aFrame achievementDescription:(GKAchievementDescription *)anAchievement;

/**
 * Create a notification with a custom title and description.
 * @param title    Title to display in notification.
 * @param message  Descriotion to display in notification.
 * @return a BCAchievementNoficiation view.
 */
- (id)initWithFrame:(CGRect)aFrame title:(NSString *)aTitle message:(NSString *)aMessage;

///**
// * Resets the view's current frame to the starting offscreen position
// */
//- (void)resetFrameToStart;
//
///**
// * Show the notification.
// */
//- (void)animateIn;
//
///**
// * Hide the notificaiton.
// */
//- (void)animateOut;

/**
 * Change the logo that appears on the left.
 * @param image  The image to display.
 */
- (void)setImage:(UIImage *)image;

@end
