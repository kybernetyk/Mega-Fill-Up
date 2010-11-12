//
//  HelloWorldScene.m
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright flux forge 2010. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Importing Chipmunk headers
#import "chipmunk.h"
#import "cpMouse.h"
#import <AVFoundation/AVFoundation.h>

// HelloWorld Layer
@interface GameFieldLayer : CCLayer
{
	cpSpace *space;
	
	float ballSize;

	cpMouse *mouse;

	cpShape *currentBalloonShape;
	cpBody *currentBalloonBody;
	CCSprite *currentBalloonSprite;
	
	int currentBallMipMap;
	float oldfill;
	
	BOOL isCurrentlySpawning;
	BOOL shouldCancelSpawn;
	
	float tick_playing_timestamp;
	
	CGPoint upVector;
	CGPoint rightVector;
}
@property (nonatomic, assign) BOOL isCurrentlySpawning;
@property (nonatomic, assign) BOOL shouldCancelSpawn;


- (void) startSpawningBalloonAtX: (float) x y: (float) y;
- (void) completeBalloonSpawn;

@end
