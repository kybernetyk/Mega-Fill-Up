//
//  MXMenuScene.m
//  Mega Fill-Up
//
//  Created by jrk on 28/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MXMenuScene.h"
#import "MXMainMenuLayer.h"
#import "FlurryAPI.h"
#import "LevelScene.h"
#import "IntroScene.h"
#import "LoadingScene.h"
#import "MenuBackgroundLayer.h"
#import "Reachability.h"
#import "MXInstructionScene.h"
#import <GameKit/GameKit.h>
@implementation MXMenuScene

- (id) init
{
	self = [super init];
	if (self)
	{
		[self createBackground];

		mml = [MXMainMenuLayer node];
		NSLog(@"mml: %i",[mml retainCount]);
		[self addChild: mml z: 5];
		NSLog(@"mml: %i",[mml retainCount]);
		
/*		mbl = [MenuBackgroundLayer nodeWithOneAwesomeFace];
		[mbl setPosition: ccp(150.0,25.0)];
		[self addChild: mbl z: 2];*/
		
		CCSprite *spr = [CCSprite spriteWithFile: @"fullgameteaser.png"];
		[spr setAnchorPoint: ccp(0.0,0.0)];
		[spr setPosition: ccp(480-256-10,10.0)];
		[self addChild: spr z: 3];
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver: self selector: @selector(handleStartClassicGameMenuItem:) name: @"MXStartClassicGameMenuItem" object: nil];
		[center addObserver: self selector: @selector(handleStartGravityGameMenuItem:) name: @"MXStartGravityGameMenuItem" object: nil];
		[center addObserver: self selector: @selector(handleShowIntroMenuItem:) name: @"MXShowIntroMenuItem" object: nil];
		[center addObserver: self selector: @selector(handleShowInstructionsMenuItem:) name: @"MXShowIntroInstructionsItem" object: nil];

		[center addObserver: self selector: @selector(authChanged:) name: @"MXAuthChanged" object: nil];
		
		
		
		[FlurryAPI logEvent:@"Menu"];

		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		
	}
	return self;
}

- (void) dealloc
{
//	[self removeAllChildrenWithCleanup: YES];
	NSLog(@"mml: %i", [mml retainCount]);
	
	NSLog(@"MXMenuScene dealloc");
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	
	[super dealloc];
	
	
}


- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NetworkStatus stat = [curReach currentReachabilityStatus];
	
	NSLog(@"mxmenu reachability changed to %i",stat);
	
	
	
	if (stat == NotReachable)
	{	
		g_is_online = NO;	
	}
	else
	{
		g_is_online = YES;
	}
	
	[self removeChild: mml cleanup: YES];
	mml = [MXMainMenuLayer node];
	[self addChild: mml z: 5];

	
	
	
	//[[CCDirector sharedDirector] replaceScene: [MXMenuScene node]];
	NSLog(@"online? %i",g_is_online);
	NSLog(@"mml: %i", [mml retainCount]);	
}


- (void) authChanged: (NSNotification* )note
{
	[self removeChild: mml cleanup: YES];
	mml = [MXMainMenuLayer node];
	[self addChild: mml z: 5];

//	[self removeChild: mbl cleanup: YES];
//	mbl = nil;
	
	
	if ([GameCenterManager isGameCenterAvailable] && g_is_online && ![[GKLocalPlayer localPlayer] isAuthenticated])
	{	
		NSLog(@"WE'RE ONLINE, GC IS AVAILABLE, BUT NOT AUTHED!");
		
	}
	else
	{
		//mbl = [MenuBackgroundLayer nodeWithOneAwesomeFace];
//		[mbl setPosition: ccp(150.0,25.0)];
//		[self addChild: mbl z: 2];
		
	}
	
	
}



#ifdef __LITE__VERSION__
- (void) createBackground
{
	CCSprite *back = [CCSprite spriteWithFile: @"mx_menu_back_lite_288.png"];
//	CCSprite *back = [CCSprite spriteWithFile: @"mx_menu_back_lite_270.png"];
	[[back texture] setAliasTexParameters];
	[back setAnchorPoint: ccp(0.0,0.0)];
	[back setPosition: ccp(0.0,0.0)];
	[self addChild: back z: 0];
}

#else
- (void) createBackground
{
	CCSprite *back = [CCSprite spriteWithFile: @"mx_menu_back.png"];
	[[back texture] setAliasTexParameters];
	[back setAnchorPoint: ccp(0.0,0.0)];
	[back setPosition: ccp(0.0,0.0)];
	[self addChild: back z: 0];
}
#endif

#pragma mark -
#pragma mark notification handler 
- (void) handleShowInstructionsMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Instructions"];
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [MXInstructionScene node] withColor: col];
	
	[[CCDirector sharedDirector] replaceScene: fade];
	
}

- (void) completeGameStart
{
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [LevelScene node] withColor: col];
	
	[[CCDirector sharedDirector] replaceScene: fade];
	
}
- (void) handleStartGravityGameMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Start Gravity Game"];
	NSLog(@"*** starting gravity game");
	reset_globals();
	g_GameInfo.gameMode = GRAVITY_MODE;
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *key = @"classic_game_save";
	
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		key = @"gravity_game_save";
	NSDictionary *save = [defs objectForKey: key];
	if (save)	
	{
		if ([[save objectForKey: @"lives"] integerValue] > 0)
		{
			NSLog(@"shall we resume?");
			
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Gravity Game" 
												   message: nil 
												  delegate: self 
										 cancelButtonTitle: @"Cancel" 
										 otherButtonTitles: @"New Game", @"Resume Game", nil];
		
			[alertView show];
			[alertView autorelease]; 
		}
		else
		{
			NSLog(@"found game save - but lives < 0. starting new game");
			[self completeGameStart];	
		}
	}
	else
	{
			NSLog(@"no game save found!");
		[self completeGameStart];
	}
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"omg der buttonen indexen: %i, %@", buttonIndex,	[alertView buttonTitleAtIndex: buttonIndex]);
	if (buttonIndex == 1)
	{

		[self completeGameStart];
		return;
	}
	if (buttonIndex == 2)
	{
		[LevelScene loadGameState];
		
		[self completeGameStart];
		return;
	}
	
	NSLog(@"user cancelled game");
}



- (void) handleStartClassicGameMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Start Classic Game"];
	NSLog(@"*** starting classic game");
	reset_globals();
	g_GameInfo.gameMode = CLASSIC_MODE;


	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *key = @"classic_game_save";
	
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		key = @"gravity_game_save";
	NSDictionary *save = [defs objectForKey: key];
	if (save)	
	{
		if ([[save objectForKey: @"lives"] integerValue] > 0)
		{
			NSLog(@"shall we resume?");
			
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Classic Game" 
																message: nil 
															   delegate: self 
													  cancelButtonTitle: @"Cancel" 
													  otherButtonTitles: @"New Game", @"Resume Game", nil];
			
			[alertView show];
			[alertView autorelease]; 
		}
		else
		{
				NSLog(@"found game save - but lives < 0. starting new game");
			[self completeGameStart];	
		}
	}
	else
	{
		NSLog(@"no game save found!");
		[self completeGameStart];
	}
	
}


- (void) handleShowIntroMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Credits"];
	
	ccColor3B col;
	col.r = 0;
	col.g = 0;
	col.b = 0;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [LoadingScene nodeWithSceneClassToFollow: @"IntroScene"] withColor: col];
	
	[[CCDirector sharedDirector] replaceScene: fade];
	
	
	
}

@end
