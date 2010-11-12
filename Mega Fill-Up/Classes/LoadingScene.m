//
//  LoadingScene.m
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "LoadingScene.h"
#import "IntroScene.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
#import "LoadingOperation.h"
#import "globals.h"

@implementation LoadingScene
+ (id) nodeWithSceneClassToFollow: (NSString *) className
{
	return [[[self alloc] initWithClassToFollow: className] autorelease];
}

- (void) dealloc
{
//	[self removeAllChildrenWithCleanup: YES];
	//[loadingOperation autorelease], loadingOperation = nil;
	[nextSceneClassName autorelease], nextSceneClassName = nil;
	[super dealloc];
}

- (void) loadShit
{
	
}

- (id) initWithClassToFollow: (NSString *) className
{
	NSLog(@"initWithClassToFollow: %@", className);
	self = [super init];
	if (self)
	{
		loadingOperation = nil;
		
		nextSceneClassName = [[NSString alloc] initWithString: className];
//		CCSprite *back = [CCSprite spriteWithFile: @"whiteback.png"];
//		[back setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		//[self addChild: back z: 0];
		
		CCSprite *minyx = [CCSprite spriteWithFile: @"minyx_black.png"];
		[minyx setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
		[self addChild: minyx z: 1];
		
		//CCLabelTTF *label = [CCLabelTTF labelWithString: @"Loading. Please wait .." fontName: @"Arial" fontSize: 16];
		CCLabelTTF *label = [CCLabelBMFont labelWithString: @"Loading. Please wait ..." fntFile: @"visitor_16.fnt"];
		[[label texture] setAliasTexParameters];
/*		ccColor3B col;
		col.r = 0;
		col.g = 0;
		col.b = 0;
		
		NSLog(@"%f",[minyx boundingBox].size.height);
		
		//[label setColor: col];*/
		[label setAnchorPoint: ccp(0.5,0.5)];
		[label setPosition: ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - [minyx boundingBox].size.height/4 )];
		
		[self addChild: label z: 2];
		
		
		CCSequence *seq = [CCSequence actions:
						   [CCFadeOut actionWithDuration: 0.5],
						   [CCFadeIn actionWithDuration: 0.5],
						   nil];
		CCRepeatForever *rep = [CCRepeatForever actionWithAction: seq];

		[label runAction: rep];
		
		NSLog(@"loading init ...");
		x = 0.0;
		//[CCTextureCache sharedTextureCache];
		[self scheduleUpdate];
		
	}
	return self;
}

- (void) onEnter
{
	NSLog(@"on enter ...");
	[super onEnter];
}

- (void) update: (ccTime) delta
{
	x += 1.0*delta;
	
	NSLog(@"loading tick ...");
	if (!loadingOperation)
	{
		if (x >= 0.5) //this is a fucking hack so the scene is actually displayed/in the scenegraph 
			//so the fucking director doesnt get confused
		{
			loadingOperation = [[[LoadingOperation alloc] init] autorelease];
			[loadingOperation setDelegate: self];
			[g_OperationQueue addOperation: loadingOperation];
			
		}
	}
}

- (void) loadingOperationDidFinish: (id) operation
{
	NSLog(@"loading op fertig!");
	
	ccColor3B col;
	col.r = 0;
	col.g = 0;
	col.b = 0;
	
	CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [NSClassFromString(nextSceneClassName) node] withColor: col];
	NSLog(@"fade: %@",fade);
	[[CCDirector sharedDirector] replaceScene: fade];

}

@end
