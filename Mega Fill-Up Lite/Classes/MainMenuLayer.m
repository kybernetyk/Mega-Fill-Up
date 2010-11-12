//
//  MainMenuLayer.m
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MainMenuLayer.h"

@implementation MainMenuLayer

- (id) init
{
	self = [super init];
	if (self)
	{
	//	CCSprite *s = [CCSprite spriteWithFile: @"whiteback.png"];
	//	[s setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
	//	[self addChild: s];

		
		CCMenuItem *item1_1 = [CCMenuItemFont itemFromString: @"Start Classic Game" 
													 block: 
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXStartClassicGameMenuItem" object: sender];
								
							 }];

		
		CCMenuItem *item1_2 = [CCMenuItemFont itemFromString: @"Classic High Scores"
													   block:
							   ^(id sender)
							   {
								   NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								   [center postNotificationName: @"MXShowClassicHighScores" object: sender];
							   }];
		
		CCMenuItem *item2_1 = [CCMenuItemFont itemFromString: @"Start Gravity Game" 
													 block: 
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXStartGravityGameMenuItem" object: sender];
								 
							 }];
		
		CCMenuItem *item2_2 = [CCMenuItemFont itemFromString: @"Gravity High Scores"
													 block:
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXShowGravityHighScores" object: sender];
							 }];
		
		
		CCMenuItem *item3 = [CCMenuItemFont itemFromString: @"Credits"
													 block:
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXShowIntroMenuItem" object: sender];
							 }];
		
		
		CCMenuItem *emptyItem1 = [CCMenuItemFont itemFromString: @" "
														  block:
								  ^(id sender)
								  {
								  }];
		CCMenuItem *emptyItem2 = [CCMenuItemFont itemFromString: @" "
														  block:
								  ^(id sender)
								  {
								  }];
		
		CCMenu *menu = [CCMenu menuWithItems: item1_1,item1_2,emptyItem1, item2_1, item2_2,emptyItem2, item3,nil];
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[menu alignItemsVertically];
		[menu setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[self addChild: menu];
	}
	return self;
}

@end
