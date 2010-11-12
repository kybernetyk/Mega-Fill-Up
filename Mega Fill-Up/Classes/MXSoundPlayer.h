//
//  MXSoundPlayer.h
//  Super Fill Up
//
//  Created by jrk on 22/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MXSoundPlayer : NSObject 
{
	NSMutableDictionary *soundRefs;
}

- (void) playFile: (NSString *) filename;
- (void) vibrate;

@end
