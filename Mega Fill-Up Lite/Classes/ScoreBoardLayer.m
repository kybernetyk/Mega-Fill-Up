//
//  ScoreBoardLayer.m
//  Super Fill Up
//
//  Created by jrk on 18/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "ScoreBoardLayer.h"
#import "globals.h"


@implementation ScoreBoardLayer

#define FONTNAME @"visitor_18.fnt"
- (void) dealloc
{
	//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}
- (void) addLabelsWithLeftString: (NSString *) lstring centerString: (NSString *) cstring rightString: (NSString *) rstring atLine: (int) line
{
	int y = (SCREEN_HEIGHT/2+60) - line * 20;
	int left = 120;
	int center = SCREEN_WIDTH/2;
	int right = 365;
	
	CCLabelBMFont *l = nil;
	
	if (lstring)
	{
		l = [CCLabelBMFont labelWithString: lstring fntFile: FONTNAME];
		[[l texture] setAliasTexParameters];
//		[l setScale: 0.75];
		[l setAnchorPoint: ccp(0.0,0.5)];
		[l setPosition: ccp(left, y)];
		[self addChild: l];
	}
	
	if (cstring)
	{
		l = [CCLabelBMFont labelWithString: cstring fntFile: FONTNAME];
		[[l texture] setAliasTexParameters];
		//		[l setScale: 0.75];
		[l setAnchorPoint: ccp(0.5,0.5)];
		[l setPosition: ccp(center, y)];
		[self addChild: l];
	}

	if (rstring)
	{	
		l = [CCLabelBMFont labelWithString: rstring fntFile: FONTNAME];
		[[l texture] setAliasTexParameters];
		//		[l setScale: 0.75];
		[l setAnchorPoint: ccp(0.0,0.5)];
		[l setPosition: ccp(right - [l boundingBox].size.width , y)];
		[self addChild: l];
	}
	
}

- (id) init
{
	self = [super init];
	if (self)
	{
		[self setIsTouchEnabled: YES];
		clickDown = NO;
		
		CCSprite *s = [CCSprite spriteWithFile: @"levelscoreboard.png"];
		[[s texture] setAliasTexParameters];
		[s setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		[self addChild: s z: 0];

		CCLabelBMFont *lf = [CCLabelBMFont labelWithString: @"LEVEL FINISHED!" fntFile: FONTNAME];
		[[lf texture] setAliasTexParameters];
		//[lf setScale: 0.75];
		[lf setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 90)];
		[self addChild: lf z: 1];
		
		
		CCLabelBMFont *pressKey = [CCLabelBMFont labelWithString: @"TAP TO CONTINUE ..." fntFile: FONTNAME];
		[[pressKey texture] setAliasTexParameters];
		//[pressKey setScale: 0.75];
		[pressKey setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 90)];
		[self addChild: pressKey z: 1];
		
		
		CCSequence *seq = [CCSequence actions:
						   [CCFadeOut actionWithDuration: 1.0],
						   [CCFadeIn actionWithDuration: 1.0],
						   nil];
		CCRepeatForever *rep = [CCRepeatForever actionWithAction: seq];
		[pressKey runAction: rep];
		
		[self addLabelsWithLeftString: @"FILL:" 
						 centerString: [NSString stringWithFormat: @"%.2f X %i =", g_GameInfo.currentLevel_fill,g_GameInfo.currentLevel]
					rightString: [NSString stringWithFormat: @"+%2.f", g_GameInfo.currentLevel_fill * g_GameInfo.currentLevel]
							   atLine: 0];

		[self addLabelsWithLeftString: @"BALLS:" 
						 centerString: [NSString stringWithFormat: @"%i X %i =", g_GameInfo.currentLevel_ballsLeft,g_GameInfo.currentLevel]
						  rightString: [NSString stringWithFormat: @"+%i", g_GameInfo.currentLevel_ballsLeft * g_GameInfo.currentLevel]
							   atLine: 1];

		[self addLabelsWithLeftString: @"TIME:" 
						 centerString: [NSString stringWithFormat: @"%i SEC. =", (int)g_GameInfo.currentLevel_time]
						  rightString: [NSString stringWithFormat: @"-%i", (int)g_GameInfo.currentLevel_time]
							   atLine: 2];
		
		int y = (SCREEN_HEIGHT/2+60) - 3 * 20;
		CCLabelBMFont *l = [CCLabelBMFont labelWithString: @"-----------------------" fntFile: FONTNAME];
		[[l texture] setAliasTexParameters];		
		//[l setScale: 0.75];
		[l setAnchorPoint: ccp(0.5,0.5)];
		[l setPosition: ccp(SCREEN_WIDTH/2, y )];
		[self addChild: l];
		
		
		[self addLabelsWithLeftString: @"THIS LEVEL:"
						 centerString: nil
						  rightString: [NSString stringWithFormat: @"%i", (int)g_calcScoreForCurrentLevel()]
							   atLine: 4];
		
		[self addLabelsWithLeftString: @"TOTAL:"
						 centerString: nil
						  rightString: [NSString stringWithFormat: @"%i", (int)g_GameInfo.score + (int)g_calcScoreForCurrentLevel()]
							   atLine: 5];

		NSString *hiscore_key = @"personal_classic_high_score";
		if (g_GameInfo.gameMode == GRAVITY_MODE)
			hiscore_key = @"personal_gravity_high_score";
		
		NSInteger pershigh = [[[NSUserDefaults standardUserDefaults] objectForKey: hiscore_key] integerValue];

		if  (((int)g_GameInfo.score + (int)g_calcScoreForCurrentLevel()) > pershigh)
		{
			[self addLabelsWithLeftString: nil
							 centerString: @"NEW PERSONAL RECORD!"
							  rightString: nil
								   atLine: 6];
			
		}
		else
		{ 
			[self addLabelsWithLeftString: @"YOUR RECORD:"
							 centerString: nil
							  rightString: [NSString stringWithFormat: @"%i", pershigh]
								   atLine: 6];
			
		}
		
	}
	return self;
}

- (void) ccTouchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];
	
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];

	if (location.x >= 110 && location.x <= 370 &&
		location.y >= 50 && location.y <= 270)
	{	
		clickDown = YES;
		
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!clickDown)
		return;
	[self setIsTouchEnabled: NO];
	
	NSLog(@"penil!");
	NSNotificationCenter *defc = [NSNotificationCenter defaultCenter];
	[defc postNotificationName: CHANGE_TO_NEXT_LEVEL_NOTIFICATION object: nil];
}


@end
