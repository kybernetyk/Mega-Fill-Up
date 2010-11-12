//
//  SineScroller.m
//  Super Fill Up
//
//  Created by jrk on 11/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "SineScroller.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation SineScroller
@synthesize text;
#define DEG2RAD (M_PI/180.0)

/*#define SINUS_FRAMES 360
#define SINUS_FPS 60.0
#define SINUS_LENGTH (SINUS_FRAMES/4)*/

#define SINUS_AMPLITUDE 40.0
#define SINUS_FRAMES 360
#define SINUS_FPS 30.0
#define SINUS_LENGTH (SINUS_FRAMES/8)

#define PALETTE_FPS 64.0

#define CHAR_WIDTH 16.0

- (void) dealloc
{
	NSLog(@"sine scroller dealloc");
	for (int row = 0; row < SINUS_FRAMES; row++)
	{
		free(sine_lut[row]);
	}

	free(sine_lut);
	
	
	for (int row = 0; row < SINUS_FRAMES; row++)
	{
		free(cols[row]);
	}
	
	free (cols);
	
	[chars release];
	[self setText: nil];
	//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
	
}

- (id) initWithText: (NSString *) aText
{
	self = [super init];
	if (self)
	{
		self.isTouchEnabled = YES;
//		self.isAccelerometerEnabled = YES;

		
		[self setText: aText];
		
		chars = [[NSMutableArray alloc] initWithCapacity: [aText length]];
		
		NSLog(@"creating %i sprites ...", [aText length]);
		
		int length = SINUS_LENGTH;
		
		CCSprite *sineLayer = [CCSprite node];
		
		sine_lut = malloc(SINUS_FRAMES * sizeof(float *));
		
		for (int row = 0; row < SINUS_FRAMES; row++)
		{
			sine_lut[row] = malloc(length * sizeof(float));
		}
		
		float speed = 2.0;
		for (int i = 0; i < SINUS_FRAMES; i++)
		{
			for (int j = 0; j < length; j++)
			{//float y = sin(2.0*M_PI*(float)i/(float)[aText length]*4)*100.0;
				sine_lut[i][j] = sin ( (speed * M_PI * (float)(j+i)/length) ) * SINUS_AMPLITUDE;	

			}
			
		}
		
	//	NSLog(@"%f", sine_lut[10][20]);
		
		
		cols = malloc(SINUS_FRAMES * sizeof(ccColor3B*));

	
		for (int row = 0; row < SINUS_FRAMES; row++)
		{
			cols[row] = malloc(length * sizeof(float));
		}
	

		int r = 255;
		int g = 0;
		int b = 0;
		
		for (int j = 0; j < length; j++)
		{
			r = j*(255.0/(float)length);
			
			cols[0][j].r = r;
			
			cols[0][j].g = 0;//(255.0/(float)length * (float)j);
			cols[0][j].b = 0;//100;(255.0/(float)length * (float)j);//255/length*j;
		}
		
		for (int j = 0; j < length; j++)
		{
			
			int col = 6.0 / (float)length * j;
//			NSLog(@"%i",col);

			r = 0;
			g = 0;
			b = 0;
			
			if (col == 0)
			{
				r = 255;
			}
			if (col == 1)
			{
				g = 255;
			}
			if (col == 2)
			{
				g = 255;
			}
			if (col == 3)
			{
				g = 255;
				b = 255;
			}
			if (col == 4)
			{
				r = 255;
				g = 255;
			}
			if (col == 5)
			{
				r = 255;
				b = 255;
			}
			
			
			//r = g = b = 255;
			
			cols[0][j].r = r;
			
			cols[0][j].g = g;//(255.0/(float)length * (float)j);
			cols[0][j].b = b;//100;(255.0/(float)length * (float)j);//255/length*j;
		}
		
		
		ccColor3B *palette = cols[0];
		
		for (int i = 1; i < SINUS_FRAMES; i++)
		{
			for (int j = 0; j < length; j++)
			{
				int paletteoffset = i%length;
				int index = j - paletteoffset;
				if (index < 0)
					index = length - (paletteoffset - j);
				
				cols[i][j].r = palette[index].r;
				cols[i][j].g = palette[index].g;
				cols[i][j].b = palette[index].b;
			}
		}

		float x = 0;
		for (int i = 0; i < [aText length]; i++)
		{
			unichar c = [aText characterAtIndex: i];
//			CCLabelTTF *s = [CCLabelTTF labelWithString: [NSString stringWithCharacters: &c length:1] fontName: @"Arial" fontSize:24];
			
			CCLabelBMFont *s = [CCLabelBMFont labelWithString:[NSString stringWithCharacters: &c length:1] 
													  fntFile: @"visitor_24.fnt"];
			[[s texture] setAliasTexParameters];
			//[s setScale: 0.75];
			float w = 		[s boundingBox].size.width;			

			[s setAnchorPoint: ccp(0.0,0.5)];
			[s setPosition:  ccp(SCREEN_WIDTH + x, 0.0)];
			x += (w + 2);
			[sineLayer addChild: s];
			[chars addObject: s];
		}
		
		[self addChild: sineLayer];
		
		current_sine_frame = 0.0;
		xoffset = 0.0f;
		current_palette_frame = 0.0;
		
		NSLog(@"bam ... now scheduling ...");
		//[self schedule: @selector(tick:)];
		[self scheduleUpdate];


	}
	return self;
}

- (void) ccTouchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
	manualScrollOverride = YES;
	keyPressed = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	manualScrollOverride = NO;
	keyPressed = NO;
}

- (void) ccTouchesMoved: (NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"MOVED!");
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint prevlocation = [touch previousLocationInView: [touch view]];

	location = [[CCDirector sharedDirector] convertToGL: location];
	prevlocation = [[CCDirector sharedDirector] convertToGL: prevlocation];
	
	xoffset = prevlocation.x - location.x;
	if (xoffset < 0.0)
		xoffset = -400.0;
	if (xoffset > 0.0)
		xoffset = 400.0;
//	xoffset *= 25.0;
	
//	xinertia = -1.0;// * (xoffset/100);
	
}	

-(void) update: (ccTime) delta
{
	NSLog(@"update of la grande");
	
	current_sine_frame += SINUS_FPS * delta;
	if (current_sine_frame >= SINUS_FRAMES)
		current_sine_frame = 0.0;
	
	current_palette_frame += PALETTE_FPS * delta;
	if (current_palette_frame >= SINUS_FRAMES)
		current_palette_frame = 0.0;
	
	if (!manualScrollOverride)
	{
		xoffset = 100.0f;
	}
	
	int i = 0;
	CCLabelTTF *last = nil;
	for (CCLabelTTF *c in chars)
	{
		CGPoint pos = [c position];
		pos.y = sine_lut[(int)current_sine_frame][i];
		
		if (xoffset > 0)
			pos.x -= xoffset * delta;
		if (xoffset < 0)
			pos.x -= xoffset * delta;
		
		[c setPosition: pos];
		
		if (pos.x < -40 || pos.x > SCREEN_WIDTH+40)
			[c setVisible: NO];
		else
			[c setVisible: YES];
		
		
		[c setColor: cols[(int)current_palette_frame][i]];
		
		i++;
		if (i >= SINUS_LENGTH)
			i = 0;
		
		last = c;
	}
	if (xoffset > -50 && xoffset < 50)
	{
		xoffset = 100.0;
		manualScrollOverride = NO;
	}
	else
	{
		if (xoffset < 0.0)
			xoffset -= xoffset * delta;
		if (xoffset > 0.0)
			xoffset -= xoffset * delta;
	}

	if ([last position].x < 0)
	{
		int i = 0;
		float x = 0;
		for (CCLabelTTF *c in chars)
		{
			float w = 		[c boundingBox].size.width;			
			[c setPosition:  ccp(SCREEN_WIDTH + x, 0.0)];
			x += (w + 2);
			i++;
		}
	}
}

@end
