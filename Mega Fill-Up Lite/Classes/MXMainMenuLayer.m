//
//  MXMainMenuLayer.m
//  Mega Fill-Up
//
//  Created by jrk on 28/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MXMainMenuLayer.h"
#import <GameKit/GameKit.h>

@implementation MXMainMenuLayer
- (id) init
{
	self = [super init];
	if (self)
	{
		
	//	[self setIsTouchEnabled: YES];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage: @"classic_game_default.png" selectedImage: @"classic_game_selected.png" 
														   block: 
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXStartClassicGameMenuItem" object: sender];
								 
							 }];
		
//		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage: @"gravity_game_default.png" selectedImage: @"gravity_game_selected.png"
//														   block: 
//							 ^(id sender)
//							 {
//								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//								 [center postNotificationName: @"MXStartGravityGameMenuItem" object: sender];
//								 
//							 }];
		CCMenuItemImage *item4 = [CCMenuItemImage itemFromNormalImage: @"classic_scores_default.png" selectedImage: @"classic_scores_selected.png"
														   block: 
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXShowClassicHighScores" object: sender];
								 
							 }];
//		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage: @"gravity_score_default.png" selectedImage: @"gravity_score_selected.png"
//														   block: 
//							 ^(id sender)
//							 {
//								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//								 [center postNotificationName: @"MXShowGravityHighScores" object: sender];
//								 
//							 }];
		CCMenuItemImage *item5 = [CCMenuItemImage itemFromNormalImage: @"instructions_default.png" selectedImage: @"instructions_selected.png"
														   block: 
							 ^(id sender)
							 {
								 NSLog(@"instruction ...");
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXShowIntroInstructionsItem" object: sender];
								 
							 }];

		CCMenuItemImage *item6 = [CCMenuItemImage itemFromNormalImage: @"credits_default.png" selectedImage: @"credits_selected.png"
														   block: 
							 ^(id sender)
							 {
								 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
								 [center postNotificationName: @"MXShowIntroMenuItem" object: sender];
								 
							 }];
		CCMenuItemImage *gcmenuitem = [CCMenuItemImage itemFromNormalImage: @"game_center_default_2.png" selectedImage: @"game_center_pressed_2.png"
											   block: 
				 ^(id sender)
				 {
					 NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
					 [center postNotificationName: @"MXGameCenterDialog" object: sender];
					 
				 }];
		
		CCMenuItemImage *i1 = [CCMenuItemImage itemFromNormalImage: @"SoundON.png" selectedImage: @"SoundON_P.png"];
		CCMenuItemImage *i2 = [CCMenuItemImage itemFromNormalImage: @"SoundOFF.png" selectedImage: @"SoundOFF_P.png"];
		
		id one;
		id two;
		
		if (is_sfx_enabled)
		{
			one = i1;
			two = i2;
		}
		else
		{
			one = i2;
			two = i1;
		}
		
		CCMenuItemToggle *toggle1 = [CCMenuItemToggle itemWithBlock: ^(id sender)
									 {
										 is_sfx_enabled = !is_sfx_enabled;
										 NSLog(@"sound is: %i", is_sfx_enabled);
									 }
															  items: one, two,nil];
		
		
		NSArray *blah = [NSArray arrayWithObjects: gcmenuitem, item2,item4,item5,item6,i1,i2,nil];
		for (CCMenuItemImage *item in blah)
		{
			[[[item normalImage] texture] setAliasTexParameters];	
			[[[item selectedImage] texture] setAliasTexParameters];	
		}
		
		
		
		
		CCMenu *menu = nil;
		
		if ([GameCenterManager isGameCenterAvailable] && g_is_online)
		{	
			if ([[GKLocalPlayer localPlayer] isAuthenticated])
				menu = [CCMenu menuWithItems: item2, item4, item5, item6,toggle1,nil];
			else
			{	
				menu = [CCMenu menuWithItems: gcmenuitem, item2, item5, item6,toggle1,nil];	
		
/*				if (![[NSUserDefaults standardUserDefaults] boolForKey: @"dontAskGC"])
				{
					CCSprite *warning = [CCSprite spriteWithFile: @"please_sign_in.png"];
					[[warning texture] setAliasTexParameters];
					[warning setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2+9)];
					[self addChild: warning z: 6];
				}
*/				
			}
		}
		else 
		{
			menu = [CCMenu menuWithItems: item2, item5, item6,nil];
		}

		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
#ifdef __LITE__VERSION__
		[menu alignItemsVerticallyWithPadding: 10.0];
#else
		[menu alignItemsVerticallyWithPadding: 16.0];
#endif
		
		[menu setPosition: ccp(64+20.0-2, SCREEN_HEIGHT/2)];
		
		
		NSLog(@"menu pos: %f,%f", [menu position].x, [menu position].y);
		
		[self addChild: menu];

		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage: @"getitnow_default.png" selectedImage: @"getitnow_selected.png"
												   block: 
					 ^(id sender)
					 {
						[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://itunes.apple.com/us/app/mega-fill-up/id400633918?mt=8&ls=1"]];
					 }];
			[[[item1 normalImage] texture] setAliasTexParameters];	
			[[[item1 selectedImage] texture] setAliasTexParameters];	
			
			
			menu = [CCMenu menuWithItems: item1, nil];
			[menu setPosition: ccp(SCREEN_WIDTH/2+96 , 40)];
			
			[self addChild: menu];
	}
	return self;
}

- (void) dealloc
{
	//[self removeAllChildrenWithCleanup: YES];
	NSLog(@"mai menu layer dealloc");
	[super dealloc];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];
	
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	NSLog(@"tacz@: %f,%f", location.x,location.y);
	
	CGRect classicGame = CGRectMake(20.0, 250.0, 128.0, 25.0);
	CGRect gravityGame = CGRectMake(20.0, 208.0, 128.0, 25.0);
	CGRect classicScores = CGRectMake(20.0, 166.0, 128.0, 25.0);
	CGRect gravityScores = CGRectMake(20.0, 125.0, 128.0, 25.0);
	CGRect instructions = CGRectMake(20.0, 85.0, 128.0, 25.0);
	CGRect credits = CGRectMake(20.0, 42.0, 128.0, 25.0);
	
		
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	id sender = self;
	
	if (CGRectContainsPoint (classicGame, location))
	{
		[center postNotificationName: @"MXStartClassicGameMenuItem" object: sender];
	}
	if (CGRectContainsPoint (gravityGame, location))
	{
		[center postNotificationName: @"MXStartGravityGameMenuItem" object: sender];
	}
	if (CGRectContainsPoint (classicScores, location))
	{
		[center postNotificationName: @"MXShowClassicHighScores" object: sender];
	}
	if (CGRectContainsPoint (gravityScores, location))
	{
		[center postNotificationName: @"MXShowGravityHighScores" object: sender];
	}
	if (CGRectContainsPoint (instructions, location))
	{
		//[center postNotificationName: @"" object: sender];
	}
	if (CGRectContainsPoint (credits, location))
	{
		[center postNotificationName: @"MXShowIntroMenuItem" object: sender];
	}
	
}

@end
