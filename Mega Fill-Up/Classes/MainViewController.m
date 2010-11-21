//
//  MainViewController.m
//  Super Fill Up
//
//  Created by jrk on 24/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MainViewController.h"
#import "FacebookSubmitController.h"
#import "MXMenuScene.h"
#import "FlurryAPI.h"
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "RootViewController.h"
#import "GameConfig.h"

@implementation GKLeaderboardViewController (meinpenis)


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
#ifdef ORIENTATION_LANDSCAPE_LOCKED
	if (interfaceOrientation ==  UIInterfaceOrientationLandscapeRight)
		return YES;
#else
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   interfaceOrientation == UIInterfaceOrientationLandscapeRight )
		return YES;
#endif
	
	return NO;
}

@end


@implementation MainViewController
@synthesize glView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		NSLog(@"initWithNibName:");
		flag = NO;
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
	
	[center addObserver: self selector: @selector(handleShowClassicHighScoresMenuItem:) name: @"MXShowClassicHighScores" object: nil];
	[center addObserver: self selector: @selector(handleShowGravityHighScoresMenuItem:) name: @"MXShowGravityHighScores" object: nil];
	[center addObserver: self selector: @selector(handleShowGameCenterDialog:) name: @"MXGameCenterDialog" object: nil];	
	
}


- (void) handleShowGameCenterDialog: (NSNotification *) notification
{
	NSLog(@"showing game center dialog ...");
	
	NSString *button1 = @"Sign Out";
	
	if (![[GKLocalPlayer localPlayer] isAuthenticated])
	{
		NSLog(@"player not authed");
		button1 = @"Sign In";
		
	}

	NSString *button2 = @"Stop asking me to sign in!";
	
	UIAlertView *alertView = nil;
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey: @"dontAskGC"])
	{
		alertView = [[UIAlertView alloc] initWithTitle: @"Game Center" 
								   message: nil 
								  delegate: self 
						 cancelButtonTitle: @"Cancel" 
						 otherButtonTitles: button1, button2, nil];
	}
	else
	{
		alertView = [[UIAlertView alloc] initWithTitle: @"Game Center" 
											   message: nil 
											  delegate: self 
									 cancelButtonTitle: @"Cancel" 
									 otherButtonTitles: button1, nil];
		
	}
	
	[alertView show];
	[alertView autorelease]; 

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"omg der buttonen indexen: %i, %@", buttonIndex,	[alertView buttonTitleAtIndex: buttonIndex]);
	if (buttonIndex == 1)
	{
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setBool: NO forKey: @"dontAskGC"];
		[defs synchronize];
			
		[g_GameCenterManager authenticateLocalUser];
	}
	if (buttonIndex == 2)
	{
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setBool: YES forKey: @"dontAskGC"];
		[defs synchronize];
	}
}

- (void) handleShowClassicHighScoresMenuItem: (NSNotification *) notification
{
	if (![GameCenterManager isGameCenterAvailable])
	{	
		NSLog(@"game center not available on this device!");
		[FlurryAPI logEvent:@"Menu - Classic Highscores - NOT AVAILABLE"];	
		return;
		
	}
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *scope = [defs objectForKey: @"leaderboardScope"];
	GKLeaderboardTimeScope lbscope = [scope integerValue];
	
	[FlurryAPI logEvent:@"Menu - Classic Highscores"];
//	[[CCDirector sharedDirector] pause];
	NSLog(@"*** showing classic high scores");
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController) 
    {
		NSString *cat = GAME_CENTER_CLASSIC_LEADERBORAD_CATEGORY;
		mayReleaseMemory = NO;
		NSLog(@"showing highscore for category: %@", cat);
		
        leaderboardController.category = cat;
        leaderboardController.timeScope = lbscope;
        leaderboardController.leaderboardDelegate = self; 
		[[CCDirector sharedDirector] replaceScene: [CCScene node]];
        
		[self presentModalViewController: leaderboardController animated: NO];
		

    }
	else
	{
		//[[CCDirector sharedDirector] resume];
	}
	
}

- (void) handleShowGravityHighScoresMenuItem: (NSNotification *) notification
{
	if (![GameCenterManager isGameCenterAvailable])
	{	
		NSLog(@"game center not available on this device!");
		[FlurryAPI logEvent:@"Menu - Gravity Highscores - NOT AVAILABLE"];	
		return;
		
	}
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *scope = [defs objectForKey: @"leaderboardScope"];
	GKLeaderboardTimeScope lbscope = [scope integerValue];
	
	
	[FlurryAPI logEvent:@"Menu - Gravity Highscores"];
	NSLog(@"*** showing gravity high scores");
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController) 
    {
		NSString *cat = GAME_CENTER_GRAVITY_LEADERBORAD_CATEGORY;
		mayReleaseMemory = NO;
		NSLog(@"showing highscore for category: %@", cat);
	

		[[CCDirector sharedDirector] replaceScene: [CCScene node]];		
        leaderboardController.category = cat;
        leaderboardController.timeScope = lbscope;
        leaderboardController.leaderboardDelegate = self; 
        [self presentModalViewController: leaderboardController animated: NO];
		

    }
	else
	{
	}
}


- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *scope = [NSNumber numberWithInt: [viewController timeScope]];
	if (scope)
	{	
		[defs setObject: scope forKey: @"leaderboardScope"];
	}


    [self dismissModalViewControllerAnimated: NO];
    [viewController autorelease];
	mayReleaseMemory = YES;
//	[[CCDirector sharedDirector] resume];
	
	[[CCDirector sharedDirector] replaceScene: [MXMenuScene node]];
}


- (void) viewDidAppear:(BOOL)animated
{
	NSLog(@"view did appear .. %@", [self view]);
	mayReleaseMemory = YES;
//	[[self view] retain];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	//return YES;
	
	/*if (unlock_orientation)
	{
		if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		   interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
		   interfaceOrientation == UIInterfaceOrientationPortrait)
			return YES;
	}*/
	

	
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
#ifdef ORIENTATION_LANDSCAPE_LOCKED
	if (interfaceOrientation ==  UIInterfaceOrientationLandscapeRight)
		return YES;
#else
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   interfaceOrientation == UIInterfaceOrientationLandscapeRight )
		return YES;
#endif	
	
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
	return;
	//shit below only works if full screen
	
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
	EAGLView *glView_ = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	glView_.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning 
{
	//if ([[CCDirector sharedDirector] isPaused])
	//	[[CCDirector sharedDirector] resume];
	//let's rebuild our essential mipmaps
	
	if (mayReleaseMemory)
	{	
		NSLog(@"main view controller doing memory shits ...");
		[super didReceiveMemoryWarning];
		
	}
		rebuildMipMaps = YES;
		
		CCSprite *sprite = [[[CCSprite alloc] initWithFile: @"face_2.png"] autorelease];
		ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
		[[sprite texture] setTexParameters: &texParams];
		[[sprite texture] generateMipmap];
		
		sprite = [[[CCSprite alloc] initWithFile: @"eye_2.png"] autorelease];
		ccTexParams texParams2 = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
		[[sprite texture] setTexParameters: &texParams2];
		[[sprite texture] generateMipmap];
		
	
	
	
}
- (void)viewDidLoad 
{
	[super viewDidLoad];
	[[self view] retain];
	
	[[CCDirector sharedDirector] setOpenGLView: [self glView]];
	[[glView layer] setMagnificationFilter: kCAFilterNearest];
	mayReleaseMemory = YES;
	
	facebookController = [[FacebookSubmitController alloc] initWithNibName: @"FacebookSubmitController" bundle: nil];
	[facebookController setDelegate: self];
	
	/*CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage: @"face_2.png"];
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[tex setTexParameters: &texParams];
	[tex generateMipmap];
	
	
	tex = [[CCTextureCache sharedTextureCache] addImage: @"eye_2.png"];
	ccTexParams texParams2 = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[tex setTexParameters: &texParams2];
	[tex generateMipmap];*/
	
	
	
}

- (void)viewDidUnload 
{
//	[[CCDirector sharedDirector] stopAnimation];
	
    [super viewDidUnload];
	


	NSLog(@"view did unload ... wtf");
//	NSLog(@"unload: my view is: %@", view]);
//	NSLog(@"unload: my gl view is: %@", [self glView]);
	//[self setGlView: nil];
}

- (BOOL) handleOpenURL: (NSURL *) url
{
	return [[facebookController facebook] handleOpenURL: url];
}


- (void)dealloc 
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
    [[self view] release];
	
	NSLog(@"mein view controller dealloc ... WTF?");
	[super dealloc];
}

- (void) shareScoreOnFarmville
{
	
	if (!g_is_online)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook Error",nil) 
														message:NSLocalizedString(@"You are not online. Please connect to the internet to share your scores!",nil)
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release]; 

		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center postNotificationName: @"MXCanEnableFacebookButton" object: nil];

		return;
	}
	
/*	if (isPostingOnFB)
		return;
	
	isPostingOnFB = YES;
	unlock_orientation = YES;
	
	[self shareOverFarmville];*/
	
//	[[CCDirector sharedDirector] stopAnimation];
//	[[CCDirector sharedDirector] pause];
	//mayReleaseMemory = NO;
	//[[CCDirector sharedDirector] setIsPaused: YES];
	
//	[[[UIApplication sharedApplication] delegate] pauseGame];
	[FlurryAPI logEvent:@"Facebook"];
	
	[facebookController setLevel: g_GameInfo.currentLevel];
	[facebookController setScore: g_GameInfo.score];
	
//	[self presentModalViewController: fbsc animated: YES];
	[facebookController shareOverFarmville];

	NSLog(@"charlie alpha bingo");
}

- (void) facebookSubmitControllerDidFinish: (id) controller
{
	//[self dismissModalViewControllerAnimated: YES];
//	[[[UIApplication sharedApplication] delegate] resumeGame];
	NSLog(@"facebook controller finished");

	mayReleaseMemory = YES;
}

@end
