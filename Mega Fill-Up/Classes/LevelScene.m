//
//  LevelScene.m
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "LevelScene.h"
#import "MenuScene.h"
#import "globals.h"
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>
#import "HighscoreSubmitOperation.h"
#import "ScoreBoardLayer.h"
#import "GameOverScene.h"
#import "MXMenuScene.h"

@implementation LevelScene
@synthesize shouldSwitchToMainMenu;

+ (void) saveGameState
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *key = @"classic_game_save";
	
	if (g_GameInfo.gameMode ==GRAVITY_MODE)
		key = @"gravity_game_save";
	
	NSLog(@"writing game state for key: %@", key);
	
	NSMutableDictionary *save = [NSMutableDictionary dictionary];
	[save setObject: [NSNumber numberWithInteger: g_GameInfo.currentLevel] forKey: @"level"];
	[save setObject: [NSNumber numberWithInteger: g_GameInfo.lives] forKey: @"lives"];
	[save setObject: [NSNumber numberWithInteger: g_GameInfo.score] forKey: @"score"];
	
	[defs setObject: save forKey: key];
	[defs synchronize];
	
	NSLog(@"wrote state: %@", save);
}

+ (void) loadGameState
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *key = @"classic_game_save";
	
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		key = @"gravity_game_save";

	NSLog(@"loading game state for key: %@", key);
	
	NSDictionary *save = [defs objectForKey: key];
	if (!save)
		return;
	
	NSLog(@"loaded state: %@", save);
	
	g_GameInfo.currentLevel = [[save objectForKey: @"level"] integerValue];
	g_GameInfo.lives = [[save objectForKey: @"lives"] integerValue];
	g_GameInfo.score = [[save objectForKey: @"score"] integerValue];
}

- (void) unregisterFromNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
}


- (void) dealloc
{
	NSLog(@"level scene dealloc!");
	[self unregisterFromNotification];
//	[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}

-(id) init
{
	if( (self=[super init])) 
	{
		[[UIAccelerometer sharedAccelerometer] setDelegate: nil];
		
		g_CurrentLevelScene = self;
		[self registerForNotifications];
		
		backgroundLayer = [CCLayer node];
		
		isGameOverTransitioning = NO;
		isMainMenuTransitioning = NO;
		shouldSwitchToMainMenu = NO;
		
		CCSprite *back = [CCSprite spriteWithFile: BACKGROUND_FILENAME];
		[back setAnchorPoint: ccp(0.0,0.0)];
		[back setPosition: ccp(0.0,0.0)];
		[backgroundLayer addChild: back];
		
		gameField = [GameFieldLayer node];
		
		hudLayer = [HUDLayer node];
		//currentLevel = levelNumber;
		
		
		int ballsadd = ((g_GameInfo.currentLevel+1)/2)*2;
		
		//1 = (1+1)/2*2 = 2
		//2 = (2+1)/2*2 = 2
		//3 = (3+1)/2*2 = 4
		//4 = (4+1)/2*2 = 4
		
		g_GameInfo.currentLevel_ballsLeft = 18 + ballsadd;
		g_GameInfo.currentLevel_time = 0.0;
		
		[hudLayer setLevel: g_GameInfo.currentLevel];
		[hudLayer setLives: 2];
		[hudLayer setBalls: g_GameInfo.currentLevel_ballsLeft];
		[hudLayer setFill: 0.0];
		
		[self addChild: backgroundLayer z: 0];
		[self addChild: gameField z: 3];
		[self addChild: hudLayer z: 5];
		
		
		
		//now let's get messaging set up
		
		[self scheduleUpdate];
		
//		ccGridSize s;
//		s.x = 10;
//		s.y = 10;
		
		//		[self runAction: [CCLiquid actionWithWaves: 10 amplitude:10 grid:s duration:10]];
		//[self runAction: [CCRipple3D actionWithPosition: ccp(480/2,320/2) radius: 300 waves: 20 amplitude:10 grid: s duration:10.0]];
		//[self runAction: [CCShaky3D actionWithRange: 10 shakeZ: YES grid:s duration:10]];
		
	}
	return self;
}


#pragma mark -
#pragma mark notification handler
- (void) playerDidCollideWithEnemy: (NSNotification *) notification
{
	g_GameInfo.lives --;
	[LevelScene saveGameState];
	
	NSLog(@"now lives left: %i",g_GameInfo.lives);
	
	CCSprite *white = [CCSprite spriteWithFile: @"whiteback.png"];
	[white setOpacity: 0];
	[white setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
	
	[self addChild: white z: 12];
	
	CCFadeIn *fin = [CCFadeIn actionWithDuration: 0.3];
	CCFadeOut *fout = [CCFadeOut actionWithDuration: 0.3];
	CCCallFuncN *cf = [CCCallFuncN actionWithTarget: self selector: @selector(flashlightOver:)];
	
	CCSequence *seq = [CCSequence actions: fin, fout,cf, nil];
	[white runAction: seq];
}

- (void) flashlightOver: (id) theFlashlightNode
{
	[self removeChild: theFlashlightNode cleanup: YES];
}

- (void) registerForNotifications
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector: @selector(playerDidCollideWithEnemy:) name: GAME_FIELD_PLAYER_ENEMY_COLLISION_NOTIFICATION object: nil];
	[center addObserver: self selector: @selector(changeToNextLevel:) name: CHANGE_TO_NEXT_LEVEL_NOTIFICATION object: nil];
	
}




- (void) showScoreboard
{
	if (isScoreboardShowing)
		return;
	isScoreboardShowing = YES;


	[gameField setIsAccelerometerEnabled: NO];
	[gameField setIsTouchEnabled: NO];
	[[UIAccelerometer sharedAccelerometer] setDelegate: nil];
	
	ScoreBoardLayer *sl = [ScoreBoardLayer node];
	[self addChild: sl z: 4];


}


- (void) changeToNextLevel: (NSNotification *) notification
{
	NSLog(@"change to next leel!");
	
	float scoreForThisLevel = g_calcScoreForCurrentLevel();
	
	[gameField setIsAccelerometerEnabled: NO];
	[gameField setIsTouchEnabled: NO];
	[[UIAccelerometer sharedAccelerometer] setDelegate: nil];
	


	if (g_GameInfo.gameMode == CLASSIC_MODE)
	{	
		g_GameInfo.lives ++;
	}
	else
	{
		if ((g_GameInfo.currentLevel % 3) == 0)
			g_GameInfo.lives ++;
	}
	
	g_GameInfo.score +=  scoreForThisLevel;
	
	NSLog(@"time in this level: %f", g_GameInfo.currentLevel_time);
	NSLog(@"this level score: %f", scoreForThisLevel);
	NSLog(@"total score: %i", g_GameInfo.score );
	
	g_GameInfo.currentLevel ++;
	
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	g_CurrentLevelScene = nil; 
	
	[LevelScene saveGameState];
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [LevelScene node] withColor: col];
	
	[[CCDirector sharedDirector] replaceScene: fade];
	
	
	//[[CCDirector sharedDirector] replaceScene: [LevelScene node]]; 
	
}

-(void) update: (ccTime) delta
{
//	static float f = 0.0f;
	
	//f += 1.0 * delta;

	//float fill = [gameField fill];
	if (!isScoreboardShowing)
	{
		g_GameInfo.currentLevel_time += 1.0 * delta;
	}
	
	
	[hudLayer setLevel: g_GameInfo.currentLevel];
	[hudLayer setLives: g_GameInfo.lives];
	[hudLayer setBalls: g_GameInfo.currentLevel_ballsLeft];
	[hudLayer setFill: g_GameInfo.currentLevel_fill];
	

	
	if (g_GameInfo.currentLevel_fill >= 66.666f)
	{
		//only change level when spawn is complete
		if (![gameField isCurrentlySpawning])
		{
			[self showScoreboard];
		}
	}
	
	if (g_GameInfo.lives < 0 && !isGameOverTransitioning)
	{
		isGameOverTransitioning = YES;
				NSLog(@"game over! schwuchtel!");
		ccColor3B col;
		col.r = 255;
		col.g = 255;
		col.b = 255;
		g_CurrentLevelScene = nil; 
		CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [GameOverScene node] withColor: col];
		[[CCDirector sharedDirector] replaceScene: fade];
	}
	
	if (shouldSwitchToMainMenu && !isMainMenuTransitioning)
	{
		isMainMenuTransitioning = YES;
		
		ccColor3B col;
		col.r = 0;
		col.g = 0;
		col.b = 0;
		
		CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.5f scene: [MXMenuScene node] withColor: col];
		[[CCDirector sharedDirector] replaceScene: fade];
		
	}
	
	//NSLog(@"level: %i, lives: %i, balls: %i", level, lives,balls);
}

@end
