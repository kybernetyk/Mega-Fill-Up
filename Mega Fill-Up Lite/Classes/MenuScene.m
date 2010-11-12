//
//  MenuScene.m
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MenuScene.h"
#import "globals.h"
#import "MainMenuLayer.h"
#import "LevelScene.h"
#import "IntroScene.h"
#import "LoadingScene.h"
#import "MenuBackgroundLayer.h"
#import "FlurryAPI.h"

@implementation MenuScene

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self)
	{
	
		CCSprite *background = [CCSprite spriteWithFile: BACKGROUND_FILENAME];
		[background setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		[self addChild: background z: 0];
		
		MenuBackgroundLayer *bl = [MenuBackgroundLayer node];
		//[bl setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		
		[self addChild: bl z: 2];
		
		MainMenuLayer *mml = [MainMenuLayer node];
		//[mml setAnchorPoint: ccp(0.5,0.5)];
		//[mml setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		
		[self addChild: mml z: 5];
		
		

		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver: self selector: @selector(handleStartClassicGameMenuItem:) name: @"MXStartClassicGameMenuItem" object: nil];
		[center addObserver: self selector: @selector(handleStartGravityGameMenuItem:) name: @"MXStartGravityGameMenuItem" object: nil];

		[center addObserver: self selector: @selector(handleShowIntroMenuItem:) name: @"MXShowIntroMenuItem" object: nil];
		
		[FlurryAPI logEvent:@"Menu"];
	}
	return self;
}

- (void) handleStartGravityGameMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Start Gravity Game"];
	NSLog(@"*** starting gravity game");
	reset_globals();
	g_GameInfo.gameMode = GRAVITY_MODE;
	
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [LevelScene node] withColor: col];
	
	[[CCDirector sharedDirector] replaceScene: fade];
}


- (void) handleStartClassicGameMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Start Classic Game"];
	NSLog(@"*** starting classic game");
	reset_globals();
	g_GameInfo.gameMode = CLASSIC_MODE;
	
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [LevelScene node] withColor: col];

	[[CCDirector sharedDirector] replaceScene: fade];
}


- (void) handleShowIntroMenuItem: (NSNotification *) notification
{
	[FlurryAPI logEvent:@"Menu - Credits"];
	[[CCDirector sharedDirector] replaceScene: [LoadingScene nodeWithSceneClassToFollow: @"IntroScene"]];
}


@end
