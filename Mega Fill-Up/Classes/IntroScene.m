//
//  IntroScene.m
//  Super Fill Up
//
//  Created by jrk on 11/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "IntroScene.h"
#import "SineScroller.h"
#import "StarScroller.h"
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "TouchLayerHack.h"

#define CRACKTRO_TEXT @"*** minyx *** your favorite crew is back with a new release *** mega fill-up *** code by jrk^mnx *** gfx & sfx by smn^mnx *** supplier hkr^bbcrew *** greetings * fairlight * minxy * bse * steve * razor 911 * reddit * kamelot *** fr killed the demoscene *** minyx 2010 *** we're looking for suppliers *** contact us on our bbs *** multiline bbs (555) 4354-11x *** minyx always #1 *** press any key to continue *** (tap the moving minyx logo) ***    "

@implementation IntroScene
- (void) dealloc
{
	NSLog(@"intro scene dealloc");
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[SimpleAudioEngine end];
	//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];	
}


- (id) init
{
	NSLog(@"intro scene init");
	self = [super init];
	if (self)
	{
		//self.isTouchEnabled = YES;

		ccColor3B col;
		col.r = 0;
		col.g = 0;
		col.b = 240;
		
		
		CCSprite *scrollerBack = [CCSprite spriteWithFile: @"inner_scroller_back.png"];
		[scrollerBack setAnchorPoint: ccp(0.0,0.0)];
		[scrollerBack setPosition: ccp(0,30)];
		[scrollerBack setColor: col];
		
		CCSprite *scrollerFrame = [CCSprite spriteWithFile: @"scroller_back.png"];
		[scrollerFrame setAnchorPoint: ccp(0.0,0.0)];
//		[innerScrollerBack setPosition: ccp(0,3)];

		[scrollerBack addChild: scrollerFrame];

		
		
		
		SineScroller *sineScroller = [[[SineScroller alloc] initWithText: CRACKTRO_TEXT] autorelease];
		[sineScroller setAnchorPoint: ccp(0.0,1.0)];
		[sineScroller setPosition: ccp(16.0,100)];
		
		StarScroller *starScroller = [StarScroller node];
		
		
		bar1 = [CCSprite spriteWithFile: @"bar.png"];
		[bar1 setPosition:  ccp (SCREEN_WIDTH/2, SCREEN_HEIGHT-40)];
		
		minyx = [CCSprite spriteWithFile: @"minyx.png"];
		[minyx setAnchorPoint: ccp(0.5,0.0)];
		[minyx setPosition:  ccp (SCREEN_WIDTH/2, SCREEN_HEIGHT-102-30)];
		
		bar2 = [CCSprite spriteWithFile: @"bar.png"];
		[bar2 setPosition:  ccp (SCREEN_WIDTH/2, SCREEN_HEIGHT-102-30)];
		
		CCLabelBMFont *pressKey = [CCLabelBMFont labelWithString: @"Press Any Key" fntFile: @"visitor_24.fnt"];
		[[pressKey texture] setAliasTexParameters];

//		[pressKey setScale: 0.75];
//		CCLabelTTF *pressKey = [CCLabelTTF labelWithString: @"Press Any Key" fontName: @"Arial" fontSize: 24];
		[pressKey setPosition: ccp(SCREEN_WIDTH/2, 16)];
		
		CCSequence *seq = [CCSequence actions:
						   [CCFadeOut actionWithDuration: 1.0],
						   [CCFadeIn actionWithDuration: 1.0],
						   nil];
		CCRepeatForever *rep = [CCRepeatForever actionWithAction: seq];
		[pressKey runAction: rep];
		

		[self addChild: scrollerBack z: 1];
		[self addChild: starScroller z: 0];
		
		[self addChild: bar1 z: 2];
		[self addChild: minyx z: 3];
		[self addChild: bar2 z: 4];
		
		[self addChild: sineScroller z: 5];

		[self addChild: pressKey z: 6];
		[self addChild: [TouchLayerHack node] z: 4];
		
		counter = 0;
		bar1_factor = -1.0;
		bar2_factor = 1.0;

		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"intro.mp3" loop: YES];
		
/*		NSLog(@"%@",[NSDate date]);
		
		NSError *error;
		NSURL *url = [NSURL  fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"mp3"] ];
		
		AVAudioPlayer *audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL: url error: &error];
		[audioplayer setNumberOfLoops: -1]; //repeat bitch
		NSLog(@"avp: %@ error: %@",audioplayer, error);
		//NSLog(@"starting music: %i",[audioplayer play]);
		[audioplayer play];
		NSLog(@"%@",[NSDate date]);*/
		
		[self schedule: @selector(tick:)];
		
	}
	return self;
}


#define BAR_SPEED 100.0f

-(void) tick: (ccTime) delta
{
	NSLog(@"intro scene tick");
	
	counter += 1.0 * delta;
	
	//NSLog(@"tick!");
	CGPoint pos = [minyx position];
	pos.x = SCREEN_WIDTH/2 +  sin(counter) * 200;
	//NSLog(@"%f",pos.x);
	[minyx setPosition: pos];
	
	pos = [bar1 position];
	pos.y += BAR_SPEED * delta * bar1_factor;
	if (pos.y >= SCREEN_HEIGHT - 40)
	{	
		bar1_factor = -1.0;
		int newz = 2;
		[self reorderChild: bar1 z: newz];
	}
	if (pos.y <= SCREEN_HEIGHT-102-30)
	{	
		bar1_factor = 1.0;
		int newz = 4;
		[self reorderChild: bar1 z: newz];
	}
	[bar1 setPosition: pos];
	
	pos = [bar2 position];
	pos.y += BAR_SPEED * delta * bar2_factor;
	if (pos.y >= SCREEN_HEIGHT - 40)
	{	
		bar2_factor = -1.0;
		int newz = 2;
		[self reorderChild: bar2 z: newz];
	}
	if (pos.y <= SCREEN_HEIGHT-102-30)
	{	
		bar2_factor = 1.0;
		int newz = 4;
		[self reorderChild: bar2 z: newz];
	}
	[bar2 setPosition: pos];
	
}
@end
