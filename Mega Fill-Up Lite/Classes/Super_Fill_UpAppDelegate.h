//
//  Super_Fill_UpAppDelegate.h
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright flux forge 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "FBConnect.h"
#import "Reachability.h"


@class MainViewController;

@interface Super_Fill_UpAppDelegate : NSObject <UIApplicationDelegate, GameCenterManagerDelegate> 
{
	UIWindow			*window;
	MainViewController	*viewController;
	UIImageView *splashView; 
	
		Reachability *reachability;
}

@property (nonatomic, retain) UIWindow *window;

- (void) shareScoreOnFacebook;

@end
