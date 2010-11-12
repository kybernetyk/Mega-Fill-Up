//
//  BCAchievementHandler.m
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//  $Id$
//

#import <GameKit/GameKit.h>
#import "BCAchievementNotificationCenter.h"
#import "BCAchievementNotificationView.h"

#define kBCAchievementDefaultSize   CGSizeMake(284.0f, 52.0f)
#define kBCAchievementViewPadding 10.0f
#define kBCAchievementAnimeTime     0.4f
#define kBCAchievementDisplayTime   1.75f

static BCAchievementNotificationCenter *defaultHandler = nil;

#pragma mark -

@interface BCAchievementNotificationCenter(private)

- (void)displayNotification:(UIView<BCAchievementViewProtocol> *)notification;
- (void)orientationChanged:(NSNotification *)notification;
- (CGRect)startFrameForFrame:(CGRect)aFrame;
- (CGRect)endFrameForFrame:(CGRect)aFrame;

@end

#pragma mark -

@implementation BCAchievementNotificationCenter(private)

- (void)displayNotification:(UIView<BCAchievementViewProtocol> *)notification
{
	if(![_containerView superview])
	{
		[_topView addSubview:_containerView];
	}
	//[_topView addSubview:notification];
	notification.frame = [self startFrameForFrame:notification.frame];
	[_containerView addSubview:notification];
	//[notification animateIn];
	// TODO: i think handler should handle animations, don't think it's the view's job to
	[UIView animateWithDuration:kBCAchievementAnimeTime delay:0.0 options:0 
					 animations:^{
						 notification.frame = [self endFrameForFrame:notification.frame];
					 } 
					 completion:^(BOOL finished) {
						 [UIView animateWithDuration:kBCAchievementAnimeTime delay:kBCAchievementDisplayTime options:0 
										  animations:^{
											  notification.frame = [self startFrameForFrame:notification.frame];
										  } 
										  completion:^(BOOL finished) {
											  [_queue removeObjectAtIndex:0];
											  if ([_queue count])
											  {
												  [self displayNotification:(BCAchievementNotificationView *)[_queue objectAtIndex:0]];
											  }
											  else
												  [_containerView removeFromSuperview];
										  }];
					 }];
}

- (CGRect)rectForRect:(CGRect)rect withinRect:(CGRect)bigRect withMode:(UIViewContentMode)mode
{
	CGRect result = rect;
	switch (mode)
	{
		case UIViewContentModeCenter:
			result.origin.x = CGRectGetMidX(bigRect) - (rect.size.width / 2);
			result.origin.y = CGRectGetMidY(bigRect) - (rect.size.height / 2);
			break;
		case UIViewContentModeBottom:
			result.origin.x = CGRectGetMidX(bigRect) - (rect.size.width / 2);
			result.origin.y = CGRectGetMaxY(bigRect) - (rect.size.height);
			break;
		case UIViewContentModeBottomLeft:			
			result.origin.x = CGRectGetMinX(bigRect);
			result.origin.y = CGRectGetMaxY(bigRect) - rect.size.height;
			break;
		case UIViewContentModeBottomRight:
			result.origin.x = CGRectGetMaxX(bigRect) - rect.size.width;
			result.origin.y = CGRectGetMaxY(bigRect) - rect.size.height;
			break;
		case UIViewContentModeLeft:
			result.origin.x = CGRectGetMinX(bigRect);
			result.origin.y = CGRectGetMidY(bigRect) - (rect.size.height / 2);
			break;
		case UIViewContentModeTop:
			result.origin.x = CGRectGetMidX(bigRect) - (rect.size.width / 2);
			result.origin.y = CGRectGetMinY(bigRect);
			break;
		case UIViewContentModeTopLeft:
			result.origin.x = CGRectGetMinX(bigRect);
			result.origin.y = CGRectGetMinY(bigRect);
			break;
		case UIViewContentModeTopRight:
			result.origin.x = CGRectGetMaxX(bigRect) - rect.size.width;
			result.origin.y = CGRectGetMinY(bigRect);
			break;
		case UIViewContentModeRight:
			result.origin.x = CGRectGetMaxX(bigRect) - rect.size.width;
			result.origin.y = CGRectGetMidY(bigRect) - (rect.size.height / 2);
			break;
		default:
			break;
	}
	return result;
}

// off screen
- (CGRect)startFrameForFrame:(CGRect)aFrame
{
	CGRect result = aFrame;
	CGRect containerRect = [BCAchievementNotificationCenter containerRect];
	result = [self rectForRect:result withinRect:containerRect withMode:self.viewDisplayMode];
	result = CGRectIntegral(result);
	switch (self.viewDisplayMode) {
		case UIViewContentModeTop:
		case UIViewContentModeTopLeft:
		case UIViewContentModeTopRight:
			result.origin.y -= (aFrame.size.height + kBCAchievementViewPadding);
			break;
		case UIViewContentModeBottom:
		case UIViewContentModeBottomLeft:
		case UIViewContentModeBottomRight:
			result.origin.y += (aFrame.size.height + kBCAchievementViewPadding);
			break;
		case UIViewContentModeLeft:
			result.origin.x -= aFrame.size.width;
			break;
		case UIViewContentModeRight:
			result.origin.x += aFrame.size.width;
			break;
		default:
			break;
	}
	// adjust for horizontal padding
	switch (self.viewDisplayMode) {
		case UIViewContentModeTopLeft:
		case UIViewContentModeBottomLeft:
		case UIViewContentModeLeft:
			result.origin.x += kBCAchievementViewPadding;
			break;
		case UIViewContentModeTopRight:
		case UIViewContentModeBottomRight:
		case UIViewContentModeRight:
			result.origin.x -= kBCAchievementViewPadding;
			break;
		default:
			break;
	}
	return result;
}

// on screen
- (CGRect)endFrameForFrame:(CGRect)aFrame
{
	CGRect result = aFrame;
	CGRect containerRect = [BCAchievementNotificationCenter containerRect];
	result = [self rectForRect:result withinRect:containerRect withMode:self.viewDisplayMode];
	result = CGRectIntegral(result);
	switch (self.viewDisplayMode) {
		case UIViewContentModeTop:
		case UIViewContentModeTopLeft:
		case UIViewContentModeTopRight:
			result.origin.y += kBCAchievementViewPadding; // padding from top of screen
			break;
		case UIViewContentModeBottom:
		case UIViewContentModeBottomLeft:
		case UIViewContentModeBottomRight:
			result.origin.y -= kBCAchievementViewPadding;
			break;
		default:
			break;
	}
	// adjust for horizontal padding
	switch (self.viewDisplayMode) {
		case UIViewContentModeTopLeft:
		case UIViewContentModeBottomLeft:
		case UIViewContentModeLeft:
			result.origin.x += kBCAchievementViewPadding;
			break;
		case UIViewContentModeTopRight:
		case UIViewContentModeBottomRight:
		case UIViewContentModeRight:
			result.origin.x -= kBCAchievementViewPadding;
			break;
		default:
			break;
	}
	return result;
}

- (void)orientationChanged:(NSNotification *)notification
{
	//[self showTitle];
	
	UIDeviceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
	CGFloat angle = 0;
	switch (o) {
		case UIDeviceOrientationLandscapeLeft: angle = 90; break;
		case UIDeviceOrientationLandscapeRight: angle = -90; break;
		case UIDeviceOrientationPortraitUpsideDown: angle = 180; break;
		default: break;
	}
	
	CGRect f = [[UIScreen mainScreen] applicationFrame];
	
	// Swap the frame height and width if necessary
 	if (UIDeviceOrientationIsLandscape(o)) {
		CGFloat t;
		t = f.size.width;
		f.size.width = f.size.height;
		f.size.height = t;
	}
	
	CGAffineTransform previousTransform = _containerView.layer.affineTransform;
	CGAffineTransform newTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
	//newTransform = CGAffineTransformConcat(newTransform, CGAffineTransformMakeTranslation(f.size.height, 0));
	
	// Reset the transform so we can set the size
	_containerView.layer.affineTransform = CGAffineTransformIdentity;
	_containerView.frame = (CGRect){0,0,f.size};
	
	// Revert to the previous transform for correct animation
	_containerView.layer.affineTransform = previousTransform;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// Set the new transform
	_containerView.layer.affineTransform = newTransform;
	
	// Fix the view origin
	_containerView.frame = (CGRect){f.origin.x,f.origin.y,_containerView.frame.size};
    [UIView commitAnimations];
}

- (void)setupDefaultFrame
{
	UIDeviceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
	CGFloat angle = 0;
	switch (o) {
		case UIDeviceOrientationLandscapeLeft: angle = 90; break;
		case UIDeviceOrientationLandscapeRight: angle = -90; break;
		case UIDeviceOrientationPortraitUpsideDown: angle = 180; break;
		default: break;
	}
	
	CGRect f = [[UIScreen mainScreen] applicationFrame];
	
	// Swap the frame height and width if necessary
 	if (UIDeviceOrientationIsLandscape(o)) {
		CGFloat t;
		t = f.size.width;
		f.size.width = f.size.height;
		f.size.height = t;
	}
	
	CGAffineTransform previousTransform = _containerView.layer.affineTransform;
	CGAffineTransform newTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
	
	_containerView.layer.affineTransform = CGAffineTransformIdentity;
	_containerView.frame = (CGRect){0,0,f.size};
	
	// Revert to the previous transform for correct animation
	_containerView.layer.affineTransform = previousTransform;
	
	//	[UIView beginAnimations:nil context:NULL];
	//	[UIView setAnimationDuration:0.3];
	
	// Set the new transform
	_containerView.layer.affineTransform = newTransform;
	
	// Fix the view origin
	_containerView.frame = (CGRect){f.origin.x,f.origin.y,_containerView.frame.size};
	//    [UIView commitAnimations];
}

@end

#pragma mark -

@implementation BCAchievementNotificationCenter

@synthesize image;
@synthesize defaultBackgroundImage;
@synthesize viewDisplayMode;
@synthesize defaultViewSize;
@synthesize viewClass;

#pragma mark -

+ (BCAchievementNotificationCenter *)defaultCenter
{
    if (!defaultHandler) defaultHandler = [[self alloc] init];
    return defaultHandler;
}

- (id)init
{
	if ((self = [super init]))
	{
		_topView = [[UIApplication sharedApplication] keyWindow];
		self.viewDisplayMode = UIViewContentModeTop;
		self.defaultViewSize = kBCAchievementDefaultSize;
		self.viewClass = [BCAchievementNotificationView class];
		
		_containerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_containerView.opaque = NO;
		_containerView.backgroundColor = [UIColor clearColor];
		
		[_containerView setUserInteractionEnabled: NO];	//defaults to YES where touches won't be passed to views below the achievementview (whose frame is = app window frame). Settin to NO will pass touches through.
		
		[self setupDefaultFrame];
		
        _queue = [[NSMutableArray alloc] initWithCapacity:0];
        self.image = [UIImage imageNamed:@"gk-icon.png"];
		self.defaultBackgroundImage = [[UIImage imageNamed:@"gk-notification.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f];
		
		if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			//[self setDidEnableRotationNotifications:YES];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
		//[self orientationChanged:nil]; // set it up initially?
    }
    return self;
}

- (void)dealloc
{
	[_containerView release];
    [_queue release];
    [image release];
    [super dealloc];
}

#pragma mark -

+ (CGRect)containerRect
{
	UIDeviceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
	
	CGRect f = [[UIScreen mainScreen] applicationFrame];
	
	// Swap the frame height and width if necessary
 	if (UIDeviceOrientationIsLandscape(o)) {
		CGFloat t;
		t = f.size.width;
		f.size.width = f.size.height;
		f.size.height = t;
	}
	return f;
}

#pragma mark -

- (void)queueNotification:(BCAchievementNotificationView *)notification
{
	[_queue addObject:notification];
	if([_queue count] == 1)
		[self displayNotification:notification];
}

- (void)notifyWithAchievementDescription:(GKAchievementDescription *)achievement
{
	CGRect frame = CGRectMake(0, 0, self.defaultViewSize.width, self.defaultViewSize.height);
    UIView<BCAchievementViewProtocol> *notification = [[[viewClass alloc] initWithFrame:frame achievementDescription:achievement] autorelease];
	((UIImageView *)[notification backgroundView]).image = self.defaultBackgroundImage;
	//	notification.displayMode = self.viewDisplayMode;
	//[notification resetFrameToStart];
	
	[self queueNotification:notification];
}

- (void)notifyWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)anImage
{
	CGRect frame = CGRectMake(0, 0, self.defaultViewSize.width, self.defaultViewSize.height);
    UIView<BCAchievementViewProtocol> *notification = [[[viewClass alloc] initWithFrame:frame title:title message:message] autorelease];
	((UIImageView *)[notification backgroundView]).image = self.defaultBackgroundImage;
	if(anImage)
		[notification setImage:anImage];
	else if(self.image)
        [notification setImage:self.image];
    else
        [notification setImage:nil];
	//	notification.displayMode = self.viewDisplayMode;
	//[notification resetFrameToStart];
	
	[self queueNotification:notification];
}

@end
