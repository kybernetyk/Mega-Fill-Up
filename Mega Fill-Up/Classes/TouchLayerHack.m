//
//  TouchLayerHack.m
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "TouchLayerHack.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
#import "MXMenuScene.h"

@implementation TouchLayerHack
- (void) dealloc
{
	NSLog(@"Touch layer dealloc");
	
	[super dealloc];
	
}
- (id) init
{
	self = [super init];
	if (self)
	{
		self.isTouchEnabled = YES;

	}
	return self;
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];
	
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	if (location.y > 150)
	{
//		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"intro.mp3"];
		
		ccColor3B col;
		col.r = 255;
		col.g = 255;
		col.b = 255;
		
		CCTransitionFade *fade = [CCTransitionFade transitionWithDuration: 0.3f scene: [MXMenuScene node] withColor: col];
		[[CCDirector sharedDirector] replaceScene: fade];
		
	}
}


@end
