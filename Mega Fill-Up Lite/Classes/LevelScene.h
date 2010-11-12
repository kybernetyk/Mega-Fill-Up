//
//  LevelScene.h
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameFieldLayer.h"
#import "HUDLayer.h"
#import "cocos2d.h"

@interface LevelScene : CCScene 
{
	CCLayer *backgroundLayer;
	GameFieldLayer *gameField;
	HUDLayer *hudLayer;
	
	BOOL isScoreboardShowing;
	BOOL isGameOverTransitioning;
	BOOL isMainMenuTransitioning;
	
	BOOL shouldSwitchToMainMenu;
}

@property (readwrite, assign) BOOL shouldSwitchToMainMenu;

-(id) init;
+ (void) saveGameState;
+ (void) loadGameState;

@end
