//
//  MenuBackgroundLayer.h
//  Super Fill Up
//
//  Created by jrk on 16/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

@interface MenuBackgroundLayer : CCLayer
{
	cpSpace *space;
	
	BOOL shouldSpawnAwesomeFace;
}

+ (id) node;
+ (id) nodeWithAwesomeFaces;
+ (id) nodeWithOneAwesomeFace;

- (id) initWithAwesomeFace: (BOOL) awesome numOfFaces: (int) numOfFaces;

@property (readwrite, assign) BOOL shouldSpawnAwesomeFace;

- (void) spawnBalloonAtX: (float) x y: (float) y scale: (float) ballScale;
- (void) spawnAwesomeFaceAtX: (float) x y: (float) y scale: (float) ballScale;
@end
