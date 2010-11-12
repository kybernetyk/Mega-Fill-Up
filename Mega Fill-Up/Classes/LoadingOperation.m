//
//  LoadingOperation.m
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "LoadingOperation.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"


@implementation LoadingOperation
@synthesize delegate=_delegate;
static BOOL graphics_loaded = NO;

- (void) loadMusic
{
	SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
	if (sae) 
	{
		[sae preloadBackgroundMusic:@"intro.mp3"];
		
		if (sae.willPlayBackgroundMusic) 
		{
			sae.backgroundMusicVolume = 1.0f;
		}
	}
	
}

- (void) loadGraphics
{
	if (graphics_loaded)
	{	
		NSLog(@"graphics loaded already. won't reload");
		return;
	}
	graphics_loaded = YES;

//	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage: @"face_2.png"];
//	[tex generateMipmap];
	
//	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
//	[tex setTexParameters: &texParams];
	
	//CCSprite *sprite = [[CCSprite alloc] initWithFile: @"face_2.png"];
	
//	[[sprite texture] generateMipmap];
//	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
//	[[sprite texture] setTexParameters: &texParams];
	//[[sprite texture] generateMipmap];
	
	
	//sprite = [[CCSprite alloc] initWithFile: @"eye_2.png"];
	
}

- (void) main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
	
	
	[self loadGraphics];
	[self loadMusic];

	[[self delegate] performSelectorOnMainThread: @selector(loadingOperationDidFinish:) withObject: self waitUntilDone: YES];
	
	[pool drain];

}

@end
