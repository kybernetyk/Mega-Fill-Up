//
//  Super_Fill_UpAppDelegate.m
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright flux forge 2010. All rights reserved.
//

#import "cocos2d.h"

#import "PauseScene.h"
#import "Super_Fill_UpAppDelegate.h"
#import <GameKit/GameKit.h>
#import "GameConfig.h"
#import "GameFieldLayer.h"
#import "MainViewController.h"
#import "LevelScene.h"
#import "globals.h"
#import "IntroScene.h"
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "LoadingScene.h"
#import "MXMenuScene.h"
#import "GameCenterManager.h"
#import "MXSoundPlayer.h"
#import "FlurryAPI.h"
#import "Reachability.h"

@implementation Super_Fill_UpAppDelegate

@synthesize window;


- (void) registerUserDefaults
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"Player",@"playerName",
					   [NSNumber numberWithBool: YES], @"gameStartedBefore",
					   [NSNumber numberWithInteger: GKLeaderboardTimeScopeToday], @"leaderboardScope",
					   [NSNumber numberWithBool: NO], @"dontAskGC",
					   [NSNumber numberWithBool: NO], @"isFullVersion_1",
					   nil];
	[defs registerDefaults: d];
}


- (void) registerForNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector:@selector(authenticationChanged:)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
}

void uncaughtExceptionHandler(NSException *exception) 
{
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
//	printf("666 HEIL SATAN 666\nyou are our dark lord and master\n\t6\t6\t6");
	
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[self registerForNotifications];
	g_GameCenterManager = nil;
	
#ifdef __LITE__VERSION__
	[FlurryAPI startSession:@"THZCRUHWMBWIJLNP67DX"];
#else
	[FlurryAPI startSession:@"JH316MJ134U8MSNWBAFD"];
#endif

	
	
	
	[self registerUserDefaults];
	g_OperationQueue = [[NSOperationQueue alloc] init];
	

	srand(time(0));
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	//viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	//viewController.wantsFullScreenLayout = YES;
	
	
#ifdef __LITE__VERSION__
	viewController = [[MainViewController alloc] initWithNibName: @"MainViewController_lite" bundle: nil];
#else
	viewController = [[MainViewController alloc] initWithNibName: @"MainViewController" bundle: nil];
#endif
	[viewController setWantsFullScreenLayout: YES];
	[viewController view]; //call view to create glView <3 lazy init

	EAGLView *glView = [viewController glView];

	
	//TODO: REMOVE THIS IN 1.2
	
	[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"isFullVersion_1"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
/*	EAGLView *glView = [EAGLView viewWithFrame: CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH) //[window bounds] //not yet rotated
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
							preserveBackbuffer:NO];
	[glView setMultipleTouchEnabled: YES];*/
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	[[glView layer] setMagnificationFilter: kCAFilterNearest];
	
	// To enable Hi-Red mode (iPhone4)
		//[director setContentScaleFactor:2];
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60.0];
//	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	//[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	[window setBackgroundColor: [UIColor redColor]];
	[window makeKeyAndVisible];
	if (!g_GameCenterManager)
	{
		if ([GameCenterManager isGameCenterAvailable])
		{
			NSLog(@"gamecenter available ...");
			g_GameCenterManager = [[GameCenterManager alloc] init];
			[g_GameCenterManager setDelegate: self];
			//[g_GameCenterManager authenticateLocalUser];
			
			if (![[NSUserDefaults standardUserDefaults] boolForKey: @"dontAskGC"])
				[g_GameCenterManager authenticateLocalUser];
			
		}
	}
	
	
	reachability = [[Reachability reachabilityWithHostName: @"apple.com"] retain];
	[reachability startNotifer];
	
	
	/*******************************************************
	 I M P O R T A N T
	 
	 SCREEN SIZE DEFINITION!
	 
	 *******************************************************/
	CGRect glFrame = [glView frame];
	SCREEN_WIDTH = glFrame.size.width;
	SCREEN_HEIGHT = glFrame.size.height; 

	
//	printf("\n*********************************************\nSCREEN SIZE\nSCREEN_WIDTH: %i\nSCREEN_HEIGHT: %i\nMAX_FILL_AREA: %i\n*******************************\n",SCREEN_WIDTH,SCREEN_HEIGHT,MAX_FILL_AREA);
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	
	reset_globals();
	g_CurrentLevelScene = nil;
	is_sfx_enabled = YES;
	g_SoundPlayer = [[MXSoundPlayer alloc] init];
	
	//CCSprite *sprite = [[[CCSprite alloc] initWithFile: @"face_2.png"] autorelease];

	
	CCSprite *sprite = [[[CCSprite alloc] initWithFile: @"face_2.png"] autorelease];
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[[sprite texture] setTexParameters: &texParams];
	[[sprite texture] generateMipmap];
	
	sprite = [[[CCSprite alloc] initWithFile: @"eye_2.png"] autorelease];
	ccTexParams texParams2 = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[[sprite texture] setTexParameters: &texParams2];
	[[sprite texture] generateMipmap];
	
	
/*	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage: @"face_2.png"];
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[tex setTexParameters: &texParams];
	[tex generateMipmap];
	
	
	tex = [[CCTextureCache sharedTextureCache] addImage: @"eye_2.png"];
	ccTexParams texParams2 = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[tex setTexParameters: &texParams2];
	[tex generateMipmap];*/
	
/*	// Make this interesting.  
	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];  
	splashView.image = [UIImage imageNamed:@"Default.png"];  
	[window addSubview:splashView];  
	[window bringSubviewToFront:splashView];  
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:1.5];  
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];  
	splashView.alpha = 0.0;  
	splashView.frame = CGRectMake(-60, -85, 440, 635);  
	[UIView commitAnimations];  

*/	
	
	
	
	//[[CCDirector sharedDirector] runWithScene: [LoadingScene nodeWithSceneClassToFollow: @"MXMenuScene"]];
	
	[[CCDirector sharedDirector] runWithScene: [MXMenuScene node]];
	

}

- (void) pauseGame
{
//	if (![[[CCDirector sharedDirector] runningScene] isKindOfClass: [PauseScene class]])
	if ([[[CCDirector sharedDirector] runningScene] isKindOfClass: [LevelScene class]])
	{
		[[CCDirector sharedDirector] pushScene: [PauseScene node]];	
	}
	
	
}

- (void) resumeGame
{
	if ([[[CCDirector sharedDirector] runningScene] isKindOfClass: [PauseScene class]])
	{
		[[CCDirector sharedDirector] popScene];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
	NSLog(@"applicationWillResignActive");
	[self pauseGame];	
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
//	if (mayPurgeMemory)
		[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	NSLog(@"applicationDidEnterBackground");
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	//[[facebookController facebook] handleOpenURL: url];
	return [viewController handleOpenURL: url];
	
	return YES;
}


- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}
#pragma mark -
#pragma mark reachability
#pragma mark -
#pragma mark Reachability
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	
	NetworkStatus stat = [curReach currentReachabilityStatus];
	
	NSLog(@"reachability changed to %i",stat);

	if (stat == NotReachable)
	{	
		g_is_online = NO;
	}
	else
	{
		g_is_online = YES;
	}
	
	if (![GameCenterManager isGameCenterAvailable])
		return;
	
	
	if (!g_GameCenterManager)
	{
		if ([GameCenterManager isGameCenterAvailable])
		{
			//[FlurryAPI logEvent:@"Game Center - Auth"];
			
			NSLog(@"gamecenter available ...");
			g_GameCenterManager = [[GameCenterManager alloc] init];
			[g_GameCenterManager setDelegate: self];
			
			
			//if (g_is_online)
			{
				if (![[NSUserDefaults standardUserDefaults] boolForKey: @"dontAskGC"])
					[g_GameCenterManager authenticateLocalUser];
				else
					NSLog(@"user asked us to stop spamming him!");
			}
		}
		else
		{
			//[FlurryAPI logEvent:@"Game Center - Auth - GC Not Available"];
		}
	}
	else 
	{
		if (![[GKLocalPlayer localPlayer] isAuthenticated])
		{
			//if (g_is_online)
			{
				if (![[NSUserDefaults standardUserDefaults] boolForKey: @"dontAskGC"])
					[g_GameCenterManager authenticateLocalUser];
				else
					NSLog(@"user asked us to stop spamming him!");
			}
		//	else
		//	{
		//		NSLog(@"player is not authed, but we're offline too ...");
		//	}
		}
		else 
		{
			if (g_is_online)
			{
				NSLog(@"submitting cached scores ...");
				[g_GameCenterManager submitCachedScores];
			}
		}

		
	}

	
	NSLog(@"online? %i",g_is_online);
}


#pragma mark -
#pragma mark gamecenter delegates
- (void) authenticationChanged: (NSNotification *) notification
{
	NSLog(@"authentication changed!");
	
	NSLog(@"local player: %@",[GKLocalPlayer localPlayer]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"MXAuthChanged"  object: self];
	
	
}

- (void) scoreReported: (NSError*) error
{
	NSLog(@"scoreReported err: %@", [error localizedDescription]);
	if (!error)
	{
		//[FlurryAPI logEvent:@"Game Center - Score - Report Success"];
	}
	else
	{
		//[FlurryAPI logEvent:@"Game Center - Score - Report Failure"];
	}
}

- (void) processGameCenterAuth: (NSError*) error
{
	NSLog(@"processGameCenterAuth err: %i/%@",[error code], [error localizedDescription]);
	if (!error)
	{
	//	[FlurryAPI logEvent:@"Game Center - Auth - Success"];	
		//NSLog(@"no error. let's submit our scores to the shitlist!");
		[g_GameCenterManager submitCachedScores];
		
		[[NSNotificationCenter defaultCenter] postNotificationName: @"MXAuthChanged"  object: self];
	}
	else 
	{
		if ([error code] == 2) //cancel
		{
			NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
			[defs setBool: YES forKey: @"dontAskGC"];
			[defs synchronize];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Game Center Support Disabled:-[" 
															message:@"You have disabled Game Center support. Game Center is needed for high score lists. You won't be able to submit/view high scores until you enable GC support."
														   delegate:nil 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles: nil];
			[alert show];
			[alert release]; 
			
			
		}
		//[FlurryAPI logEvent:@"Game Center - Auth - Failure"];
		NSLog(@"uh we couldn't auth >.<");	
	}

}

- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error
{
	NSLog(@"reloadScoresComplete: %@ err: %@", leaderBoard, [error localizedDescription]);
}

- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error
{
	NSLog(@"achievementSubmitted: %@ err: %@", ach, [error localizedDescription]);
}

- (void) achievementResetResult: (NSError*) error
{
	NSLog(@"achievementResetResult err: %@", [error localizedDescription]);
}

- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error
{
	NSLog(@"mappedPlayerIDToPlayer: %@ err: %@", player, [error localizedDescription]);
}


#pragma mark -
#pragma mark external 
- (void) shareScoreOnFacebook
{
	[viewController shareScoreOnFarmville];
}
@end
