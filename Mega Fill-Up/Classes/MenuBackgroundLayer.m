//
//  MenuBackgroundLayer.m
//  Super Fill Up
//
//  Created by jrk on 16/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MenuBackgroundLayer.h"
#import "globals.h"
static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.		
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

static void ballGravityVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect v = cpBodyGetVel(body);
	
	float len = sqrt((v.x * v.x) + (v.y * v.y));
	//float normx = v.x/len;
	//float normy = v.y/len;
	
	//v.x = normx * ENEMY_SPEED;
	//v.y = normy * ENEMY_SPEED;	
	v.x = ( (v.x/len) * 10.0f );
	v.y = ( (v.y/len) * 10.0f );
	
	cpBodySetVel(body,v);
	
	//	NSLog(@"new vel for body %p: %f,%f",body, v.x,v.y );
	// Gravitational acceleration is proportional to the inverse square of
	// distance, and directed toward the origin. The central planet is assumed
	// to be massive enough that it affects the satellites but not vice versa.
	/*	cpVect p = body->p;
	 cpFloat sqdist = cpvlengthsq(p);
	 cpVect g = cpvmult(p, -gravityStrength / (sqdist * cpfsqrt(sqdist)));
	 
	 cpBodyUpdateVelocity(body, g, damping, dt);*/
}




@implementation MenuBackgroundLayer
@synthesize shouldSpawnAwesomeFace;
+ (id) node
{
	return [[[self alloc] initWithAwesomeFace: NO numOfFaces: 3] autorelease];
}

+ (id) nodeWithAwesomeFaces
{
	return [[[self alloc] initWithAwesomeFace: YES numOfFaces: 3] autorelease];
}


+ (id) nodeWithOneAwesomeFace
{
	return [[[self alloc] initWithAwesomeFace: YES numOfFaces: 1] autorelease];
}

- (void) dealloc
{
//	[self setIsAccelerometerEnabled: NO];
	if (space)
	{	
		cpSpaceFree (space);
		space = nil;
	}
	NSLog(@"menu background layer dealloc!");
	//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}

- (id) initWithAwesomeFace: (BOOL) awesome numOfFaces: (int) numOfFaces
{
	NSAssert( (numOfFaces == 3 || numOfFaces == 1), @"LOL NUM OF FACES MUST BE EITHER 1 OR 3!");
	
	if( (self=[super init])) 
	{
//		self.isTouchEnabled = YES;
		//self.isAccelerometerEnabled = YES;
		[self setShouldSpawnAwesomeFace: awesome];
		
		CGSize wins = [[CCDirector sharedDirector] winSize];
		wins.width = SCREEN_WIDTH;
		wins.height = SCREEN_HEIGHT;
		
		cpInitChipmunk();

		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		space->elasticIterations = 5;
		space->damping = 1.0105;
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);
		space->gravity = ccp(0.0,-250.0);
		
		space->elasticIterations = space->iterations;
		
		
		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(-100,-100), ccp(wins.width+100,-100), 100.0f);
		shape->e = 1.0f; shape->u = 0.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(-100,wins.height+100), ccp(wins.width+100,wins.height+100), 100.0f);
		shape->e = 1.0f; shape->u = 0.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(-100,0), ccp(-100,wins.height), 100.0f);
		shape->e = 1.0f; shape->u = 0.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width+100,0), ccp(wins.width+100,wins.height), 100.0f);
		shape->e = 1.0f; shape->u = 0.0f;
		cpSpaceAddStaticShape(space, shape);
		
		if (numOfFaces == 3)
		{
			if (![self shouldSpawnAwesomeFace])
			{
				[self spawnBalloonAtX: 100.0f y: 150.0f scale: 0.5];
				[self spawnBalloonAtX: 240.0 y: 200.0 scale: 0.75f];
				[self spawnBalloonAtX: 380.0 y: 150.0 scale: 0.5f];
			}
			else
			{
				[self spawnAwesomeFaceAtX: 100.0f y: 150.0f scale: 0.5];
				[self spawnAwesomeFaceAtX: 240.0 y: 200.0 scale: 0.75f];
				[self spawnAwesomeFaceAtX: 380.0 y: 150.0 scale: 0.5f];
				
			}
		}
		if (numOfFaces == 1)
		{
			if (![self shouldSpawnAwesomeFace])
			{
				[self spawnBalloonAtX: 240.0 y: 200.0 scale: 0.75f];
			}
			else
			{
				[self spawnAwesomeFaceAtX: 240.0 y: 200.0 scale: 0.75f];
				
			}
			
		}

//		[self spawnBalloonAtX: 40.0 y: 300.0 scale: 0.2f];
//		[self spawnBalloonAtX: 440.0 y: 300.0 scale: 0.2f];

		
		[self scheduleUpdate];
		
	}
	
	return self;
}

- (void) spawnAwesomeFaceAtX: (float) x y: (float) y scale: (float) ballScale
{
	CCSprite *sprite = [CCSprite spriteWithFile: @"awesome_face_small.png"];
	
	//float ballScale = 0.5;;
	[sprite setScale: ballScale];
	[self addChild: sprite];
	
	float sprite_size = [sprite boundingBoxInPixels].size.width;
	sprite_size = 160.0f;
	
	sprite.position = ccp(x,y);
	
	cpBody *body = cpBodyNew( 1.0, cpMomentForCircle(1.0, 1.0, 1.0, CGPointZero));
	body->p = ccp (x,y);
	//body->velocity_func = ballGravityVelocityFunc;
	cpSpaceAddBody(space, body);
	
	cpShape *shape = cpCircleShapeNew( body, ((sprite_size-2.0) * ballScale)/2.0,  CGPointZero);
	shape->e = 1.0;
	shape->u = 1.0;
	
	shape->data = sprite;
	cpSpaceAddShape (space, shape);
	
}
- (void) spawnBalloonAtX: (float) x y: (float) y scale: (float) ballScale 
{
	CCSprite *sprite = [CCSprite spriteWithFile: @"ball.png"];
	float sprite_size = [sprite boundingBoxInPixels].size.width;
	sprite_size = 160.0f;
	//float ballScale = 0.5;;
	[sprite setScale: ballScale];
	ccColor3B col;
	col.r = rand()%255;
	col.g = rand()%255;
	col.b = rand()%255;
	[sprite setColor: col];
	
	CCSprite *leftEye = [CCSprite spriteWithFile: @"eye_white.png"];
	[leftEye setPosition: ccp(31,86)];
	
	CCSprite *rightEye = [CCSprite spriteWithFile: @"eye_white.png"];
	[rightEye setPosition: ccp(sprite_size-34,86)];
	
	[sprite addChild: leftEye];
	[sprite addChild: rightEye];
	[[sprite texture] setAntiAliasTexParameters];
	[self addChild: sprite];

	sprite.position = ccp(x,y);
	
	cpBody *body = cpBodyNew( 0.01, cpMomentForCircle(1.0, 0.0, 1.0, CGPointZero));
	body->p = ccp (x,y);
	//	body->velocity_func = ballGravityVelocityFunc;
	cpSpaceAddBody(space, body);
	
	cpShape *shape = cpCircleShapeNew( body, ((sprite_size-2.0) * ballScale)/2.0,  CGPointZero);
	shape->e = 1.0;
	shape->u = 0.0;
	
	shape->data = sprite;
	cpSpaceAddShape (space, shape);
}



-(void) update: (ccTime) delta
{
//	NSLog(@"lol!");
	
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++)
	{
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;

#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;

	
	CGPoint v = ccp( -accelY,accelX );
	
	
	space->gravity = ccpMult(v, -(g_Physics.gravity.y));
}


@end
