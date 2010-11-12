//
//  HUDLayer.m
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "HUDLayer.h"

#define FONTNAME @"visitor_48.fnt"
//#define FONTNAME @"zomg.fnt"
//#define FONTNAME @"round.fnt"

@implementation HUDLayer
@synthesize level;
@synthesize lives;
@synthesize balls;
@synthesize fill;


- (void) dealloc
{
	NSLog(@"hud layer dealloc!");
		//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}


- (void) setFill:(float) f
{
	if (fill == f)
		return;
	
	fill = f;
	NSString *s = [NSString stringWithFormat: @"Fill: %.2f%%", f];
	[fillLabel setString: s];
	[self updateLabels];
}

- (void) setLevel:(NSInteger) value
{
	if (level == value)
		return;
	
	level = value;
	NSString *s = [NSString stringWithFormat: @"Level: %i", value];
	[levelLabel setString: s];
	[self updateLabels];
}

- (void) setLives:(NSInteger) value
{
	if (lives == value)
		return;
	
	if (value < 0) //don't show -1 on transition
		value = 0;
	
	lives = value;
	NSString *s = [NSString stringWithFormat: @"Lives: %i", value];
	[livesLabel setString: s];
	[self updateLabels];
}

- (void) setBalls:(NSInteger) value
{
	if (balls == value)
		return;
	
	if (value < 0)
		value = 0;
	
	balls = value;
	NSString *s = [NSString stringWithFormat: @"Balls: %i", value];
	[ballsLabel setString: s];
	[self updateLabels];
}


- (id) init
{
	self = [super init];
	if (self)
	{
		level = 0;
		lives = 0;
		balls = 0;
		fill = 0.0f;
		

	//	[[[CCTextureCache sharedTextureCache] addImage:@"zomg.png"] setAliasTexParameters];
		
		//[self schedule: @selector(step:)];
		//livesLabel = [CCLabelTTF labelWithString: @"Lives: 0" fontName:@"Arial" fontSize: 64];
		livesLabel = [CCLabelBMFont labelWithString: @"Lives: 0" fntFile: FONTNAME];
		[[livesLabel texture] setAliasTexParameters];
		[livesLabel setScale: 0.95];
		[self addChild: livesLabel];

		fillLabel = [CCLabelBMFont labelWithString: @"Fill: 0.00%" fntFile: FONTNAME];
		[[fillLabel texture] setAliasTexParameters];
//		[CCLabelTTF labelWithString: @"Fill: 0.00%" fontName:@"Arial" fontSize: 48];
		[fillLabel setScale: 0.75];
		[self addChild: fillLabel];
		
		ballsLabel = [CCLabelBMFont labelWithString: @"Balls: 0" fntFile: FONTNAME];
		[[ballsLabel texture] setAliasTexParameters];
//		[CCLabelTTF labelWithString: @"Balls: 0" fontName:@"Arial" fontSize: 56];
		[ballsLabel setScale: 0.95];
		[self addChild: ballsLabel];

		levelLabel = [CCLabelBMFont labelWithString: @"Level: 0" fntFile: FONTNAME];
		[[levelLabel texture] setAliasTexParameters];
//		[CCLabelTTF labelWithString: @"Level: 0" fontName:@"Arial" fontSize: 56];
		[levelLabel setScale: 0.95];
		[self addChild: levelLabel];
		
		
		[self updateLabels];	
		
	}
	return self;
}


- (void) updateLabels
{
	[livesLabel setAnchorPoint: ccp(0,0)];
	[livesLabel setPosition: ccp(2,-6)];
		
	[ballsLabel setAnchorPoint: ccp(0.0,0.0)];
	CGRect r = [ballsLabel boundingBox];
	CGPoint pos = ccp(SCREEN_WIDTH-r.size.width,SCREEN_HEIGHT-r.size.height+7/*-10*/);
	[ballsLabel setPosition: pos];

	[fillLabel setRotation: 90.0f];
	CGRect r2 = [fillLabel boundingBox];
	CGPoint pos2 = ccp(-2+r2.size.width/2,SCREEN_HEIGHT-r2.size.height/2-2/*-20*/);
	[fillLabel setPosition: pos2];
	
	
	
	[levelLabel setRotation: 270.0f];
	CGRect r3 = [levelLabel boundingBox];
	CGPoint pos3 = ccp(6+SCREEN_WIDTH-r3.size.width/2,2+r3.size.height/2);
	[levelLabel setPosition: pos3];
	
	
}
/*-(void) step: (ccTime) delta
{
	NSLog(@"level: %i, lives: %i, balls: %i", level, lives,balls);
}*/

@end
