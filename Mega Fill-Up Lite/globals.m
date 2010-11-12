/*
 *  globals.c
 *  Super Fill Up
 *
 *  Created by jrk on 14/10/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#import "globals.h"

void reset_globals (void)
{
	g_GameInfo.currentLevel = 1;
	g_GameInfo.lives = 2;
	g_GameInfo.score = 0;
	g_GameInfo.currentLevel_time = 0.0;
	
	g_Physics.balloon_elasticy = 0.5;
	g_Physics.balloon_friction = 0.5;
	
	g_Physics.gravity = cpv(0.0,-350.0); //-250
	
	g_GameInfo.gameMode = CLASSIC_MODE;
}

float g_calcScoreForCurrentLevel (void)
{
	float r = (int)(((float)g_GameInfo.currentLevel * g_GameInfo.currentLevel_fill) + 0.5) + (int)(g_GameInfo.currentLevel * g_GameInfo.currentLevel_ballsLeft) - ((int)g_GameInfo.currentLevel_time * 1);	
	if (r < 0.0)
		r = 0.0;
	
	return r;
}