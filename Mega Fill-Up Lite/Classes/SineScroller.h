//
//  SineScroller.h
//  Super Fill Up
//
//  Created by jrk on 11/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SineScroller : CCLayer 
{
	NSString *text;
	
	NSMutableArray *chars;
	
	float **sine_lut;
	
	ccColor3B **cols;
	
	
	float current_sine_frame;
	float current_palette_frame;
	float xoffset;
	float xinertia;
	
	BOOL manualScrollOverride;
	BOOL keyPressed;
}

@property (readwrite, retain) NSString *text;

@end
