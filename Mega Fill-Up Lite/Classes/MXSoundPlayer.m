//
//  MXSoundPlayer.m
//  Super Fill Up
//
//  Created by jrk on 22/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MXSoundPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation MXSoundPlayer

- (SystemSoundID) loadSound: (NSString *) filename
{
	// Create the URL for the source audio file. The URLForResource:withExtension: method is
	//    new in iOS 4.0.
	NSURL *soundURL   = [[NSBundle mainBundle] URLForResource: filename
												withExtension: nil];
	
	// Store the URL as a CFURLRef instance
	CFURLRef soundFileURLRef = (CFURLRef) [soundURL retain];
	SystemSoundID sid;
	
	// Create a system sound object representing the sound file.
	AudioServicesCreateSystemSoundID (
									  soundFileURLRef,
									  &sid
									  );		
	
	
	NSNumber *theID = [NSNumber numberWithInt: sid];
	
	[soundRefs setObject: theID forKey: filename];
	
	return sid;
	
	//AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);		
	//AudioServicesPlaySystemSound (sid);		
	
}

- (void) preloadSounds
{
	[self loadSound: @"pop.wav"];
	[self loadSound: @"tick.wav"];
	[self loadSound: @"bam1.wav"];
}

- (id) init
{
	self = [super init];
	if (self)
	{
		soundRefs = [[NSMutableDictionary alloc] initWithCapacity: 4];
		[self preloadSounds];
	}
	return self;
}

- (void) playFile: (NSString *) filename
{
	SystemSoundID theid = 0;
	
	NSNumber *num = [soundRefs objectForKey: filename];
	if (!num)
	{
		theid = [self loadSound: filename];
	}
	else
	{
		theid = [num intValue];
	}
	
	AudioServicesPlaySystemSound (theid);
}

- (void) vibrate
{
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}
@end
