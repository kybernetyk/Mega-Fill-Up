//
//  MXInstructionScene.m
//  Mega Fill-Up
//
//  Created by jrk on 30/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MXInstructionScene.h"
#import "MXMenuScene.h"
#import "FlurryAPI.h"
#define SWITCH_DURATION 0.3f

@implementation MXInstructionScene
- (void) dealloc
{
	NSLog(@"INSTRUCTION SCENE DEALLOC!");
	
	[super dealloc];
}


- (id) init
{
	self = [super init];
	if (self)
	{
		[FlurryAPI logEvent:@"Instructions"];
		current_screen = 0;
		[self createBackground];
		[self switchToNext: self];
	}
	return self;
}

#ifdef __LITE__VERSION__252151
- (void) createBackground
{
	CCSprite *back = [CCSprite spriteWithFile: @"mx_menu_back_lite_288.png"];
	//	CCSprite *back = [CCSprite spriteWithFile: @"mx_menu_back_lite_270.png"];
	[[back texture] setAliasTexParameters];
	[back setAnchorPoint: ccp(0.0,0.0)];
	[back setPosition: ccp(0.0,0.0)];
	[self addChild: back z: 0];
}

#else
- (void) createBackground
{
	CCSprite *back = [CCSprite spriteWithFile: @"mx_menu_back.png"];
	[[back texture] setAliasTexParameters];
	[back setAnchorPoint: ccp(0.0,0.0)];
	[back setPosition: ccp(0.0,0.0)];
	[self addChild: back z: 0];
}
#endif


- (void) createInstructionLayer
{
	currentLayer = [CCLayer node];
	NSString *filename = [NSString stringWithFormat: @"instruction_%i.png", current_screen];
	CCSprite *sprite = [CCSprite spriteWithFile: filename];
	[sprite setAnchorPoint: ccp(0,0)];
	[[sprite texture] setAliasTexParameters];
	
	[currentLayer addChild: sprite z: 0];
	[self addChild: currentLayer z: 5];
	
}

- (void) updateMenuLayer
{
	if (menuLayer)
	{
		[self removeChild: menuLayer cleanup: YES];
		menuLayer = nil;
	}
	
	menuLayer = [CCLayer node];
	CCMenuItemImage *prev = nil;
		
	if (current_screen == 1)
	{
		prev = 	[CCMenuItemImage itemFromNormalImage: @"mmenu_button_default.png"
									   selectedImage: @"mmenu_button_pressed.png"
											  target: self selector: @selector(switchToMainMenu:)];
		
	}
	else
	{
		prev = 	[CCMenuItemImage itemFromNormalImage: @"prev_button_default.png"
									   selectedImage: @"prev_button_pressed.png"
											  target: self selector: @selector(switchToPrev:)];
		
	}
	
	
	
	
	CCMenuItemImage *next = nil;
	
	
	if (current_screen == 5)
	{
		next = [CCMenuItemImage itemFromNormalImage: @"mmenu_button_default.png"
									  selectedImage: @"mmenu_button_pressed.png"
									         target: self selector: @selector(switchToMainMenu:)];
		
	}
	else
	{
		next = 	[CCMenuItemImage itemFromNormalImage: @"next_button_default.png"
									   selectedImage: @"next_button_pressed.png"
											  target: self selector: @selector(switchToNext:)];
	}
	
	
	
	NSArray *blah = [NSArray arrayWithObjects: prev,next,nil];
	for (CCMenuItemImage *item in blah)
	{
		[[[item normalImage] texture] setAliasTexParameters];	
		[[[item selectedImage] texture] setAliasTexParameters];	
	}
	
	CCMenu *menu = [CCMenu menuWithItems: prev, next, nil];
	[menu alignItemsHorizontally];
	[menu setAnchorPoint: ccp(0.0,0.0)];
	[menu setPosition: ccp(SCREEN_WIDTH - 132.0, 42.0)];
	[menuLayer addChild: menu z: 8];

	[self addChild: menuLayer z: 12];
}

- (void) switchToNext: (id) blah
{
	if (currentLayer)
	{
		CCMoveTo *a = [CCMoveTo actionWithDuration: SWITCH_DURATION position: ccp(-480.0f, 0.0f)];
		CCCallFuncN *b = [CCCallFuncN actionWithTarget: self selector: @selector(layerMoved:)];
		CCSequence *s = [CCSequence actions: a,b,nil];
		[currentLayer runAction: s];
	}
	
	current_screen ++;
	
	[self createInstructionLayer];
	[self updateMenuLayer];

	//don't animate on first screen
	if (current_screen != 1)
	{
		[currentLayer setPosition: ccp(480.0f, 0.0f)];
		CCMoveTo *a = [CCMoveTo actionWithDuration: SWITCH_DURATION position: ccp(0.0f, 0.0f)];
		[currentLayer runAction: a];
	}
	
}

- (void) layerMoved: (id) sender
{
	NSLog(@"layer moved: %@", sender);
	[self removeChild: sender cleanup: YES];
}

- (void) switchToPrev: (id) blah
{
	if (currentLayer)
	{
		CCMoveTo *a = [CCMoveTo actionWithDuration: SWITCH_DURATION position: ccp(+480.0f, 0.0f)];
		CCCallFuncN *b = [CCCallFuncN actionWithTarget: self selector: @selector(layerMoved:)];
		CCSequence *s = [CCSequence actions: a,b,nil];
		[currentLayer runAction: s];
	}
	
	current_screen --;
	
	[self createInstructionLayer];
	[self updateMenuLayer];
	
	[currentLayer setPosition: ccp(-480.0f, 0.0f)];
	CCMoveTo *a = [CCMoveTo actionWithDuration: SWITCH_DURATION position: ccp(0.0f, 0.0f)];
	[currentLayer runAction: a];
	
}

- (void) switchToMainMenu: (id) blah
{
	ccColor3B col;
	col.r = 255;
	col.g = 255;
	col.b = 255;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [MXMenuScene node] withColor: col];
	[[CCDirector sharedDirector] replaceScene: fade];
}

@end
