//
//  MainViewController.h
//  Super Fill Up
//
//  Created by jrk on 24/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "MoneyViewController.h"

@interface GKLeaderboardViewController (meinpenis)
@end

@interface MainViewController : UIViewController <GKLeaderboardViewControllerDelegate>
{
	EAGLView *glView;
	
	id tmp;
	
	BOOL mayReleaseMemory;
	
	BOOL flag;
	BOOL rebuildMipMaps;
	
	UIView *moneyViewContainerView;

	MoneyViewController *moneyViewController;
	
}

@property (readwrite, retain) IBOutlet EAGLView *glView;

@property (readwrite, retain) IBOutlet UIView *moneyViewContainerView;

- (void) shareScoreOnFarmville;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

@end
