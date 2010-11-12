/*
 *  globals.h
 *  Super Fill Up
 *
 *  Created by jrk on 9/10/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#import "chipmunk.h"
#import "GameCenterManager.h"
#import "MXSoundPlayer.h"
#import "LevelScene.h"

GameCenterManager *g_GameCenterManager;
NSOperationQueue *g_OperationQueue;
MXSoundPlayer *g_SoundPlayer;
LevelScene *g_CurrentLevelScene;

BOOL is_sfx_enabled;
BOOL g_is_online;

typedef struct GameInfo
{
	NSInteger lives;
	NSInteger currentLevel;
	NSInteger score;
	
	NSInteger currentLevel_ballsLeft;
	
	double currentLevel_time;
	
	float currentLevel_fill;
	
	NSInteger gameMode;
} GameInfo;

GameInfo g_GameInfo;

typedef struct PhysicsInfo
{
	cpVect gravity;
	
	float balloon_elasticy;
	float balloon_friction;
} PhysicsInfo;

PhysicsInfo g_Physics; 


void reset_globals (void);
float g_calcScoreForCurrentLevel (void);