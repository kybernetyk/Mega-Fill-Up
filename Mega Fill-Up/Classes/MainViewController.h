//
//  MainViewController.h
//  Super Fill Up
//
//  Created by jrk on 24/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface GKLeaderboardViewController (meinpenis)
@end

@interface MainViewController : UIViewController <GKLeaderboardViewControllerDelegate>
{
	EAGLView *glView;
	
	id tmp;
	
	BOOL mayReleaseMemory;
	
	BOOL flag;
	BOOL rebuildMipMaps;
}

@property (readwrite, retain) IBOutlet EAGLView *glView;
- (void) shareScoreOnFarmville;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

@end
