//
//  PauseScene.m
//  Super Fill Up
//
//  Created by jrk on 21/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "PauseScene.h"
#import "FlurryAPI.h"
#import "MXMenuScene.h"

@implementation PauseScene

- (id) init
{
	self = [super init];
	if (self)
	{
		[FlurryAPI logEvent:@"Pause"];
		CCSprite *background = [CCSprite spriteWithFile: BACKGROUND_FILENAME];
		[background setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		[self addChild: background z: 0];
		
		MenuBackgroundLayer *bl = [MenuBackgroundLayer nodeWithAwesomeFaces];
		[bl setShouldSpawnAwesomeFace: YES];
		[self addChild: bl z: 2];
		
		
		CCLabelBMFont *lf = [CCLabelBMFont labelWithString: @"Paused" fntFile: @"visitor_48.fnt"];
		//		[lf setScale: 0.75];
		[[lf texture] setAliasTexParameters];
		[lf setAnchorPoint: ccp(0.5, 1.0)];
		[lf setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT )];
		[self addChild: lf z: 3];
		
		
		CCLabelBMFont *lbl = [CCLabelBMFont labelWithString: @"Resume Game" fntFile: @"visitor_32.fnt"];
		[[lbl texture] setAliasTexParameters];
		
		CCMenuItem *item = [CCMenuItemFont itemWithLabel: lbl
												   target: self 
												 selector: @selector(resumeGame:)];

		
		lbl = [CCLabelBMFont labelWithString: @"Exit To Main Menu" fntFile: @"visitor_32.fnt"];
		[[lbl texture] setAliasTexParameters];
		CCMenuItem *item2 = [CCMenuItemFont itemWithLabel: lbl
												  target: self 
												selector: @selector(exitToMainMenu:)];
		
		CCMenuItem *emptyItem1 = [CCMenuItemFont itemFromString: @" "
														  block:
								  ^(id sender)
								  {
								  }];
		
		
		CCMenu *menu = [CCMenu menuWithItems: item,emptyItem1,item2,nil];
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[menu alignItemsVertically];
		[menu setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[self addChild: menu z: 5];
		
	}
	return self;
}

- (void) dealloc
{
	NSLog(@"pause scene dealloc!");
		//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
	
}

- (void) resumeGame: (id) something
{
	[FlurryAPI logEvent:@"Pause - Resume"];
	[[CCDirector sharedDirector] popScene];
}

- (void) exitToMainMenu: (id) something
{
	[FlurryAPI logEvent:@"Pause - Main Menu"];
	[g_CurrentLevelScene setShouldSwitchToMainMenu: YES];
//	NSLog(@"current scene: %@",[[CCDirector sharedDirector] runningScene]);
	[[CCDirector sharedDirector] popScene];
//	NSLog(@"current scene: %@",[[CCDirector sharedDirector] runningScene]);
	

	//[[CCDirector sharedDirector] replaceScene: [MenuScene node]];

	ccColor3B col;
//	col.r = 255;
//	col.g = 255;
//	col.b = 255;
	
//	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [MXMenuScene node] withColor: col];
//	[[CCDirector sharedDirector] replaceScene: fade];
//	[[CCDirector sharedDirector] end];
//	[[CCDirector sharedDirector] runWithScene: fade];
	
	
}

@end
