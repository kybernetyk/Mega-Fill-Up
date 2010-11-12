//
//  GameOverScene.m
//  Super Fill Up
//
//  Created by jrk on 20/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "GameOverScene.h"
#import "MenuBackgroundLayer.h"
#import "HighscoreSubmitOperation.h"
#import "globals.h"
#import "MXMenuScene.h"
#import "FlurryAPI.h"

@implementation GameOverScene
#define FONTNAME @"visitor_48.fnt"
#define FONTNAME2 @"visitor_32.fnt" 
#define FONTNAME3 @"visitor_16.fnt" 

- (void) submitShit: (id) somerhing
{
	[self retain];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"submit score thread detached ...");
	
	int64_t score = (int64_t)g_GameInfo.score;
	NSLog(@"score is: %i", score);
	
	NSString *cat = GAME_CENTER_CLASSIC_LEADERBORAD_CATEGORY;
	
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		cat = GAME_CENTER_GRAVITY_LEADERBORAD_CATEGORY;
	
	
	[g_GameCenterManager reportScore: score forCategory: cat];

	
	NSLog(@"submit score thread finished ...");
	[pool drain];
	
	[self release];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}
- (id) init
{
	self = [super init];
	if (self)
	{
	//	HighscoreSubmitOperation *hso = [[HighscoreSubmitOperation alloc] initWithScore: score];
	//	[g_OperationQueue addOperation: hso];
		[FlurryAPI logEvent:@"Game Over"];
		int64_t score = (int64_t)g_GameInfo.score;

		[NSThread detachNewThreadSelector: @selector(submitShit:) toTarget: self withObject: nil];

		
		CCSprite *background = [CCSprite spriteWithFile: BACKGROUND_FILENAME];
		[background setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		[self addChild: background z: 0];
		
		NSString *hiscore_key = @"personal_classic_high_score";
		if (g_GameInfo.gameMode == GRAVITY_MODE)
			hiscore_key = @"personal_gravity_high_score";
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSNumber *personalHighScore = [defs objectForKey: hiscore_key];
		NSInteger personal_high_score = [personalHighScore integerValue];
		
		if (score >= personal_high_score)
		{	
			MenuBackgroundLayer *bl = [MenuBackgroundLayer nodeWithAwesomeFaces];
			[bl setShouldSpawnAwesomeFace: YES];
			[self addChild: bl z: 2];
		}
		else
		{
			MenuBackgroundLayer *bl = [MenuBackgroundLayer node];
			[bl setShouldSpawnAwesomeFace: YES];
			[self addChild: bl z: 2];
		}

		
		//CCLabelBMFont *lf = [CCLabelBMFont labelWithString: @"Game Over" fntFile: FONTNAME];
		//[[lf texture] setAliasTexParameters];
//		[lf setScale: 0.75];
		
		CCSprite *lf = [CCSprite spriteWithFile: @"game_over.png"];
		[[lf texture] setAliasTexParameters];
		[lf setAnchorPoint: ccp(0.5, 0.5)];
		[lf setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT-40 )];
		[self addChild: lf z: 3];
		
		//TODO: add retry game
		
		NSString *scoreString = [NSString stringWithFormat: @"Your score is: %i", score];
		
		CCLabelBMFont *urscore = [CCLabelBMFont labelWithString: scoreString fntFile:FONTNAME3];
		[[urscore texture] setAliasTexParameters];
		[urscore setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - 100)];
		[self addChild: urscore z: 4];
		
		
		if (score >= personal_high_score)
		{
			CCLabelBMFont *urscore = [CCLabelBMFont labelWithString: @"This is your new personal high score!" fntFile: FONTNAME3];
			[[urscore texture] setAliasTexParameters];
			[urscore setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - 150)];
			[self addChild: urscore z: 4];
			
			[defs setObject: [NSNumber numberWithInteger: score] forKey: hiscore_key];
			[defs synchronize];
		}
		else
		{
			NSString *s = [NSString stringWithFormat: @"Your personal high score is: %i", personal_high_score];
			CCLabelBMFont *urscore = [CCLabelBMFont labelWithString: s fntFile: FONTNAME3];
			[[urscore texture] setAliasTexParameters];
			[urscore setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - 140)];
			[self addChild: urscore z: 4];
		}
		
		
		/*		int64_t score = (int64_t)g_GameInfo.score;
		 [g_GameCenterManager reportScore: score forCategory: GAME_CENTER_LEADERBORAD_CATEGORY];*/

		CCLabelBMFont *lbl = [CCLabelBMFont labelWithString: @"Share on Facebook" fntFile: FONTNAME2];
		[[lbl texture] setAliasTexParameters];
		fbMenuItem = [CCMenuItemFont itemWithLabel: lbl
													target: self 
												  selector: @selector(openFacebook:)];
		
		lbl = [CCLabelBMFont labelWithString: @"Main Menu" fntFile: FONTNAME2];
		[[lbl texture] setAliasTexParameters];
		CCMenuItem *item2 = [CCMenuItemFont itemWithLabel: lbl
													target: self 
												  selector: @selector(goToMainMenu:)];


		lbl = [CCLabelBMFont labelWithString: @"Play Again" fntFile: FONTNAME2];
		[[lbl texture] setAliasTexParameters];
		CCMenuItem *item3 = [CCMenuItemFont itemWithLabel: lbl
												   target: self 
												 selector: @selector(restartGame:)];
		
		CCMenu *menu = [CCMenu menuWithItems: fbMenuItem,item3,item2, nil];
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[menu alignItemsVertically];
		[menu setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-80)];
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[self addChild: menu z: 5];
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver: self selector: @selector(facebookEnable:) name: @"MXCanEnableFacebookButton" object: nil];

	
	}
	return self;
}

- (void) restartGame: (id) something
{
	[FlurryAPI logEvent:@"Game Over - Restart Game"];
	

	
	
	NSLog(@"*** restarting game with mode %i", g_GameInfo.gameMode);

	NSInteger gm = g_GameInfo.gameMode;
	reset_globals();
	g_GameInfo.gameMode = gm;
	
	
	
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [LevelScene node] withColor: col];
	
	[[CCDirector sharedDirector] replaceScene: fade];
}

- (void) openFacebook: (id) something
{
	[FlurryAPI logEvent:@"Game Over - Share Facebook"];
	CCMenuItem *itm = (CCMenuItem *)something;
	[itm setIsEnabled: NO];
	
	[[[UIApplication sharedApplication] delegate] shareScoreOnFacebook];
}
							 
- (void) goToMainMenu: (id) something
{
	[FlurryAPI logEvent:@"Game Over - Go Main Menu"];
	//[[CCDirector sharedDirector] replaceScene: [MenuScene node]];
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [MXMenuScene node] withColor: col];
	[[CCDirector sharedDirector] replaceScene: fade];
	
}

- (void) facebookEnable: (NSNotification *) notification
{
	NSLog(@"can enable button ...");
	[fbMenuItem setIsEnabled: YES];
}


@end
