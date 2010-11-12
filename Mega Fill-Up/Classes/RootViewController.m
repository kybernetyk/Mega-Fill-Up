#ifdef LOLPENISLOL
//
//  RootViewController.m
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright flux forge 2010. All rights reserved.
//


#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "RootViewController.h"
#import "GameConfig.h"

@implementation GKLeaderboardViewController (meinpenis)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   interfaceOrientation == UIInterfaceOrientationLandscapeRight )
		return YES;
	
	return NO;
}

@end


@implementation RootViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
     	[self registerNotifications];
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) registerNotifications
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector: @selector(handleShowHighScoresMenuItem:) name: @"MXShowHighScores" object: nil];
	
}

- (void) handleShowHighScoresMenuItem: (NSNotification *) notification
{
	[[CCDirector sharedDirector] pause];
	NSLog(@" om g wtf?");
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController) 
    {
        leaderboardController.category = GAME_CENTER_LEADERBORAD_CATEGORY;
        leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = self; 
        [self presentModalViewController: leaderboardController animated: YES];
    }
}


- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated: YES];
    [viewController release];
	[[CCDirector sharedDirector] resume];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	

}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated
	//
	return NO;
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	return NO;

#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in landscpe mode
	//
	// return YES for the supported orientations
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   interfaceOrientation == UIInterfaceOrientationLandscapeRight )
		return YES;
	
	// Unsupported orientations:
	// UIInterfaceOrientationPortrait, UIInterfaceOrientationPortraitUpsideDown
	return NO;
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION

		// Shold not happen
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// Assuming that the main window has the size of the screen
	// BUG: This won't work if the EAGLView is not fullscreen
	///
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect rect;

	if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
		rect = screenRect;
			
	else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
	
	CCDirector *director = [CCDirector sharedDirector];
	EAGLView *glView = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
    
	
	[super dealloc];
}


@end
#endif