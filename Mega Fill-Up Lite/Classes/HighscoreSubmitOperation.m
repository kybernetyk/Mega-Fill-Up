//
//  HighscoreSubmitOperation.m
//  Super Fill Up
//
//  Created by jrk on 17/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "HighscoreSubmitOperation.h"
#import <GameKit/GameKit.h>

@implementation HighscoreSubmitOperation
- (id) initWithScore: (int64_t) score
{
	self = [super init];
	if (self)
	{
		_score = score;
	}
	return self;
}

- (void) main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"submitting score of %i ...", _score);
	NSString *cat = GAME_CENTER_CLASSIC_LEADERBORAD_CATEGORY;
	
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		cat = GAME_CENTER_GRAVITY_LEADERBORAD_CATEGORY;
	
	GKScore *scoreReporter = [[GKScore alloc] initWithCategory: cat];
	scoreReporter.value = _score;

	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
	 {
	//	 printf("\n\nscore submitted report scheisse ...\n\n");
		 //NSLog(@"score raport err: %@", [error localizedDescription]);
		// NSLog(@"retc: %i", [scoreReporter retainCount] );
		 [scoreReporter autorelease];
		 [self autorelease];
		 
	 }];
	NSLog(@"submit doen ...");

	[pool drain];
}

- (void) dealloc
{
	
	NSLog(@"por submit op dealloc ...");
	[super dealloc];
}


@end

/*@interface GKScore (lafafaf)
@end

@implementation GKScore (lafafaf)

- (void) dealloc
{
	NSLog(@"LOOOOOOOOOOOOOOOOOOOOOOOL FOTZE");
	
	[super dealloc];
}

@end

*/