//
//  StarScroller.m
//  Super Fill Up
//
//  Created by jrk on 12/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "StarScroller.h"


@implementation StarScroller
- (void) dealloc
{
	[stars_back release];
	[stars_mid release];
	[stars_fore release];
	//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self)
	{
		stars_back = [[NSMutableArray alloc] initWithCapacity: 50];
		stars_mid = [[NSMutableArray alloc] initWithCapacity: 50];
		stars_fore = [[NSMutableArray alloc] initWithCapacity: 50];
		
		for (int i = 0; i < 33; i++)
		{
			CCSprite *s = [CCSprite spriteWithFile: @"star.png"];
			CGPoint pos;
			pos.x = rand()%SCREEN_WIDTH;
			pos.y = rand()%SCREEN_HEIGHT;
			[s setPosition: pos];
			[self addChild: s];
			
			[stars_fore addObject: s];
		}
		
		for (int i = 0; i < 33; i++)
		{
			CCSprite *s = [CCSprite spriteWithFile: @"star_2.png"];
			CGPoint pos;
			pos.x = rand()%SCREEN_WIDTH;
			pos.y = rand()%SCREEN_HEIGHT;
			[s setPosition: pos];
			[self addChild: s];
			
			[stars_mid addObject: s];
		}

		for (int i = 0; i < 33; i++)
		{
			CCSprite *s = [CCSprite spriteWithFile: @"star_3.png"];
			CGPoint pos;
			pos.x = rand()%SCREEN_WIDTH;
			pos.y = rand()%SCREEN_HEIGHT;
			[s setPosition: pos];
			[self addChild: s];
			
			[stars_back addObject: s];
		}
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) update: (ccTime) delta
{
	for (CCSprite *star in stars_back)
	{
		CGPoint pos = [star position];
		pos.x -= 20.0f * delta;
		
		if (pos.x <= -10.0)
		{
			pos.x = SCREEN_WIDTH + 10.0;
			pos.y = rand()%SCREEN_HEIGHT;
		}
		[star setPosition: pos];
	}

	
	for (CCSprite *star in stars_mid)
	{
		CGPoint pos = [star position];
		pos.x -= 50.0f * delta;
		
		if (pos.x <= -10.0)
		{
			pos.x = SCREEN_WIDTH + 10.0;
			pos.y = rand()%SCREEN_HEIGHT;
		}
		[star setPosition: pos];
	}
	
	
	for (CCSprite *star in stars_fore)
	{
		CGPoint pos = [star position];
		pos.x -= 100.0f * delta;
		
		if (pos.x <= -10.0)
		{
			pos.x = SCREEN_WIDTH + 10.0;
			pos.y = rand()%SCREEN_HEIGHT;
		}
		[star setPosition: pos];
	}
	
}


@end
