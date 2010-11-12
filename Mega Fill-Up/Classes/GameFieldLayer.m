//
//  HelloWorldScene.m
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright flux forge 2010. All rights reserved.
//


// Import the interfaces
#import "GameFieldLayer.h"
#import"cpShape.h"
#import "chipmunk_unsafe.h"
#import "globals.h"
#import "SimpleAudioEngine.h"
#import "PauseScene.h"
#import "MXSoundPlayer.h"

#define BOUNDS_COLLISION_GROUP 5
#define ENEMY_COLLISION_GROUP 2
#define CURRENT_BALLOON_COLLISION_GROUP 3
#define OLD_BALLOON_COLLISION_GROUP 4



#define BALL_SPAWN_SPEED 0.32f
//#define ENEMY_SPEED 180.0f
#define ENEMY_SPEED 230.0f 
//^220.0f
#define ENEMY_SPEED_HARD 310.0f

#define XOFFSET -10.0
//#define
#define YOFFSET 20.0

static BOOL is_playing_tick;
static cpShape *last_shape;
static float enemy_speed;

#pragma mark -
#pragma mark enemy gravity
//override gravitry for the soviet enemy balls
static void enemyGravityVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect v = cpBodyGetVel(body);

	float len = sqrt((v.x * v.x) + (v.y * v.y));
	//float normx = v.x/len;
	//float normy = v.y/len;

	//v.x = normx * ENEMY_SPEED;
	//v.y = normy * ENEMY_SPEED;	
	v.x = ( (v.x/len) * enemy_speed );
	v.y = ( (v.y/len) * enemy_speed );
	
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

#pragma mark -
#pragma mark cp col handler
int cpCollisionDidBegin_between_current_balloon_and_past_balloon (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
	GameFieldLayer *p =  (GameFieldLayer *)gameField;
	
	[p completeBalloonSpawn];
	
	
	NSLog(@"col between 2 balloons");
	return 1;
}

int cpCollisionDidBegin_between_current_balloon_and_enemy (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
	GameFieldLayer *p =  (GameFieldLayer *)gameField;
	
	//g_GameInfo.lives --;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName: GAME_FIELD_PLAYER_ENEMY_COLLISION_NOTIFICATION object: p];
	
	[p setShouldCancelSpawn: YES];
	NSLog(@"OMG DIE DIE DIE");
	return 0; //0 = soviet enemy ball does not react to this collision
}

int cpCollisionDidBegin_between_balloon_and_bounds (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
//	if (is_playing_tick)
//		return 1;
	
	GameFieldLayer *p =  (GameFieldLayer *)gameField;

	if (is_sfx_enabled)
	{
		is_playing_tick = YES;
		if (arb->private_a == last_shape ||
			arb->private_b == last_shape)
		{
			//[[SimpleAudioEngine sharedEngine] playEffect: @"tick.wav"];	
					[g_SoundPlayer playFile: @"tick.wav"];	
		}
		
	}
	
	return 1; //0 = soviet enemy ball does not react to this collision
}

int cpCollisionDidBegin_between_past_balloons (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
//	if (is_playing_tick)
//		return 1;

	GameFieldLayer *p =  (GameFieldLayer *)gameField;
	
	if (is_sfx_enabled)
	{
		is_playing_tick = YES;
		if (arb->private_a == last_shape ||
			arb->private_b == last_shape)
		{
			//[[SimpleAudioEngine sharedEngine] playEffect: @"tick.wav"];	
					[g_SoundPlayer playFile: @"tick.wav"];	
		}
		
	}
	
	return 1; //0 = soviet enemy ball does not react to this collision
}


int cpCollisionWillSolve (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
	return 1;
}

void cpCollisionDidSolve (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
}

void cpCollisionDidSeperate (cpArbiter *arb, struct cpSpace *space, void *gameField)
{
}




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


@implementation GameFieldLayer
@synthesize shouldCancelSpawn;
@synthesize isCurrentlySpawning;

- (void) dealloc
{

	
	
	NSLog(@"game field layer dealloc!");
	if (space)
		cpSpaceFree (space);
		//[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}

#pragma mark -
#pragma mark enemy
- (void) spawnBallOfSteelAt: (float) x y: (float) y
{
#ifdef GOD_MODE
	return;
#endif
	
	CCSprite *sprite = [CCSprite spriteWithFile: @"communist_ball_of_death.png"];
	ccColor3B col;
	col.r = 255;
	col.g = 0;
	col.b = 0;
	[sprite setColor: col];
	[[sprite texture] setAntiAliasTexParameters];
	[self addChild: sprite];
	
	float r = 5.0;// [sprite boundingBox].size.width/2.0;

		
	sprite.position = ccp(x,y);
	
	cpBody *body = cpBodyNew( 1.0f, cpMomentForCircle(0.3, 0.0, 0.3, CGPointZero));
	body->p = ccp (x,y);
	
	int vx = rand()%SCREEN_WIDTH;
	int vy = rand()%SCREEN_HEIGHT;
	
	if (rand()%2 == 0)
	{
		vx *= -1;
	}
	if (rand()%2 == 0)
	{
		vy *= -1;
	}
	
	cpBodySetVel(body, cpv(vx, vy));
	body->velocity_func = enemyGravityVelocityFunc;
	cpSpaceAddBody(space, body);
	

	
	cpShape *shape = cpCircleShapeNew( body, r,  CGPointZero);
	shape->e = 1.0f; shape->u = 0.3f;

	shape->data = sprite;
	shape->collision_type = ENEMY_COLLISION_GROUP;
	cpSpaceAddShape (space, shape);
}


#pragma mark -
#pragma mark ballooon 
- (void) startSpawningBalloonAtX: (float) x y: (float) y
{
	NSLog(@"starting spawn at: %f,%f",x,y);
	
	if (x <= 0 || x >= SCREEN_WIDTH)
		return;
	if (y <= 0 || y >= SCREEN_HEIGHT)
		return;
	
	if ([self isCurrentlySpawning])
	{
		return;
	}
	
	[self setShouldCancelSpawn: NO];
	[self setIsCurrentlySpawning: YES];
	
	

	
	CCSprite *sprite = [CCSprite spriteWithFile: @"face_2.png"];
	float sprite_size = BALL_SPRITE_SIZE;
	
	NSLog(@"sprite size: %f", sprite_size);
	
	//	[[sprite texture] setAliasTexParameters];
	[sprite setScale: ballSize];
	ccColor3B col;
	col.r = rand()%255;
	col.g = rand()%255;
	col.b = rand()%255;
	[sprite setColor: col];
	
//	CCSprite *leftEye = [CCSprite spriteWithFile: @"eye_white.png"];
//	[leftEye setPosition: ccp(31,86)];

	CCSprite *leftEye = [CCSprite spriteWithFile: @"eye_2.png"];
	[leftEye setPosition: ccp(47,147)];

	
	//CCSprite *rightEye = [CCSprite spriteWithFile: @"eye_white.png"];
	//[rightEye setPosition: ccp(sprite_size-34,86)];
	
	CCSprite *rightEye = [CCSprite spriteWithFile: @"eye_2.png"];
	[rightEye setPosition: ccp(202,147)];

	
	

	
	
	
	[sprite addChild: leftEye];
	[sprite addChild: rightEye];
//	[[sprite texture] setAntiAliasTexParameters];
	[self addChild: sprite];
	
	sprite.position = ccp(x,y);
	
	cpBody *body = cpBodyNew( 0.01, cpMomentForCircle(1.0, 0.0, 1.0, CGPointZero));
	body->p = ccp (x,y);
	cpSpaceAddBody(space, body);
	
	cpShape *shape = cpCircleShapeNew( body, ((sprite_size-2) * ballSize)/2.0,  CGPointZero);
	//shape->e = 0.3f; shape->u = 1.0f;
	shape->e = g_Physics.balloon_elasticy;
	shape->u = g_Physics.balloon_friction;

	shape->data = sprite;
	shape->collision_type = CURRENT_BALLOON_COLLISION_GROUP;
	cpSpaceAddShape (space, shape);
	currentBalloonShape = shape;
	currentBalloonBody = body;
	currentBalloonSprite = sprite;
}

- (void) completeBalloonSpawn
{
	if (currentBalloonBody && currentBalloonShape)
	{
		
		cpFloat r = ((BALL_SPRITE_SIZE-2.0) / 2.0f) * ballSize;
		cpCircleShapeSetRadius(currentBalloonShape, r);
		float A = M_PI * (r *r);
//		NSLog(@"A: %f",A);
		float perc = (100.0f / MAX_FILL_AREA) * A;
		g_GameInfo.currentLevel_fill = oldfill + perc;
		
		
		cpBodySetMass(currentBalloonBody, ballSize * 160.0f); //1/164*BALL_SPRITE_SIZE
		cpBodySetMoment(currentBalloonBody, ballSize * 160.0f);
		currentBalloonShape->collision_type = OLD_BALLOON_COLLISION_GROUP;
		
		if (g_GameInfo.currentLevel_ballsLeft <= 0)
		{
			g_GameInfo.lives --;
		}
		else
		{
			g_GameInfo.currentLevel_ballsLeft --;	
		}
		
		last_shape = currentBalloonShape;
		
		if (is_sfx_enabled)
		{
		//	[[SimpleAudioEngine sharedEngine] playEffect: @"pop.wav"];
					[g_SoundPlayer playFile: @"pop.wav"];	
		}


	}
	
	currentBalloonBody = NULL;
	currentBalloonShape = NULL;
	currentBalloonSprite = nil;
	[self setIsCurrentlySpawning: NO];
	ballSize = 0.0;
	oldfill = g_GameInfo.currentLevel_fill;
}

- (void) cancelBalloonSpawn
{
	if (currentBalloonBody && currentBalloonShape)
	{	
		cpSpaceRemoveBody(space, currentBalloonBody);
		cpSpaceRemoveShape(space, currentBalloonShape);

		if (currentBalloonSprite)
			[self removeChild: currentBalloonSprite cleanup: YES];
		
		
		if (is_sfx_enabled)
		{
			//[[SimpleAudioEngine sharedEngine] playEffect: @"bam1.wav"];
					[g_SoundPlayer playFile: @"bam1.wav"];	
		}
		
	}

	
	
	g_GameInfo.currentLevel_fill = oldfill;
	currentBalloonBody = NULL;
	currentBalloonShape = NULL;
	currentBalloonSprite = nil;
	ballSize = 0.0;
	[self setShouldCancelSpawn: NO];
	[self setIsCurrentlySpawning: NO];
}

-(id) init
{
	if( (self=[super init])) 
	{
		self.isTouchEnabled = YES;

		if (g_GameInfo.gameMode == GRAVITY_MODE)
		{		
			self.isAccelerometerEnabled = YES;	
		}
		else
		{
			self.isAccelerometerEnabled = NO;	
		}
		
		[self setShouldCancelSpawn: NO];
		
		enemy_speed = ENEMY_SPEED;
		if (g_GameInfo.currentLevel % 2 == 0)
		{
			NSLog(@"THIS IS A HARD LEVEL!");
			enemy_speed = ENEMY_SPEED_HARD;
		}
		NSLog(@"enemy speed will be: %f",enemy_speed);
		
		//|_ vector
		upVector = CGPointMake(0.0, 1.0);
		
		g_GameInfo.currentLevel_fill = 0.0;
		oldfill = 0.0;
		NSLog(@"OPFERSCHEISSE!");
		
		currentBalloonBody = NULL;
		currentBalloonShape = NULL;
		
		CGSize wins = [[CCDirector sharedDirector] winSize];
		wins.width = SCREEN_WIDTH;
		wins.height = SCREEN_HEIGHT;
		
		cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);
		space->gravity = g_Physics.gravity; // ccp(0.0,-250.0);
		
		space->elasticIterations = space->iterations;

		
		//current ball + enemy collision handler
		cpSpaceAddCollisionHandler(space,
								   CURRENT_BALLOON_COLLISION_GROUP, ENEMY_COLLISION_GROUP,
								   cpCollisionDidBegin_between_current_balloon_and_enemy,
								   cpCollisionWillSolve,
								   cpCollisionDidSolve,
								   cpCollisionDidSeperate,
								   self
								   );
		
		//current ball + old balloons handler
		cpSpaceAddCollisionHandler(space,
								   CURRENT_BALLOON_COLLISION_GROUP, OLD_BALLOON_COLLISION_GROUP,
								   cpCollisionDidBegin_between_current_balloon_and_past_balloon,
								   cpCollisionWillSolve,
								   cpCollisionDidSolve,
								   cpCollisionDidSeperate,
								   self
								   );
#ifdef TICK_SOUND_EFFECT
		cpSpaceAddCollisionHandler(space,
								   OLD_BALLOON_COLLISION_GROUP, BOUNDS_COLLISION_GROUP,
								   cpCollisionDidBegin_between_balloon_and_bounds,
								   cpCollisionWillSolve,
								   cpCollisionDidSolve,
								   cpCollisionDidSeperate,
								   self
								   );

		cpSpaceAddCollisionHandler(space,
								   OLD_BALLOON_COLLISION_GROUP, OLD_BALLOON_COLLISION_GROUP,
								   cpCollisionDidBegin_between_past_balloons,
								   cpCollisionWillSolve,
								   cpCollisionDidSolve,
								   cpCollisionDidSeperate,
								   self
								   );
#endif
		
		
		
		//cpCollisionDidBegin_between_balloon_and_bounds
		
		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(-100,-100), ccp(wins.width+100,-100), 100.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		shape->collision_type = BOUNDS_COLLISION_GROUP;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(-100,wins.height+100), ccp(wins.width+100,wins.height+100), 100.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		shape->collision_type = BOUNDS_COLLISION_GROUP;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(-100,0), ccp(-100,wins.height), 100.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		shape->collision_type = BOUNDS_COLLISION_GROUP;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width+100,0), ccp(wins.width+100,wins.height), 100.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		shape->collision_type = BOUNDS_COLLISION_GROUP;
		cpSpaceAddStaticShape(space, shape);
	
#define RASTER_W 30
#define RASTER_H 20
#define RASTER_SW (480/RASTER_W)
#define RASTER_SH (320/RASTER_H)
		
		int raster[RASTER_W][RASTER_H];
		for (int ry = 0; ry < RASTER_H; ry ++)
			for (int rx = 0; rx < RASTER_W; rx ++)
				raster[rx][ry] = 0;
		
		int ballstogo = 0;
		
		if (g_GameInfo.currentLevel % 2 == 0)
			ballstogo = (int)(((float)g_GameInfo.currentLevel/2.0)+1.0);
		if (g_GameInfo.currentLevel % 2 != 0)
			ballstogo = (int)(((float)g_GameInfo.currentLevel/2.0)+2.0);
		
		while (1)
		{
			int x = rand()%SCREEN_WIDTH;
			int y = rand()%SCREEN_HEIGHT;
			
			int rx = x/RASTER_SW;
			int ry = y/RASTER_SH;
			if (rx > 0 && rx < (SCREEN_WIDTH/RASTER_SW) &&
				ry > 0 && ry < (SCREEN_HEIGHT/RASTER_SH) &&
				raster[rx][ry] == 0)
			{
				[self spawnBallOfSteelAt: x y: y];
				ballstogo --;
				raster[rx][ry] = 1;
			}
			
			if (ballstogo <= 0)
				break;
		}
		is_playing_tick = NO;
		tick_playing_timestamp = 0.0;
		last_shape = NULL;
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];

	if (g_GameInfo.gameMode == GRAVITY_MODE)
	{		
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 40.0f)];
	}
}

-(void) update: (ccTime) delta
{
	if (is_playing_tick)
	{
		if (tick_playing_timestamp == 0.0)
		{	
			tick_playing_timestamp = delta;
			
		}
		else
		{
			tick_playing_timestamp += 1.0 * delta;
			if (tick_playing_timestamp >= 0.3)
			{
				is_playing_tick = NO;
				tick_playing_timestamp = 0.0;
			}
		}
	}
	
	if (shouldCancelSpawn)
	{
		[self cancelBalloonSpawn];
	}
	
	
	ballSize += BALL_SPAWN_SPEED * delta;	
	
	if (currentBalloonShape)
	{
		cpFloat r = ((BALL_SPRITE_SIZE-2.0) / 2.0f) * ballSize;
		
		cpCircleShapeSetRadius(currentBalloonShape, r);
//		r = cpCircleShapeGetRadius(currentBalloonShape);
//		NSLog(@"r: %f", r);
		float A = M_PI * (r *r);
//				NSLog(@"A: %f",A);
		float perc = (100.0f / MAX_FILL_AREA) * A;
		g_GameInfo.currentLevel_fill = oldfill + perc;
		
		if (r >= SCREEN_HEIGHT/2)
			[self completeBalloonSpawn];
	}
	
	if (shouldCancelSpawn)
	{
		[self cancelBalloonSpawn];
	}
	
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++)
	{
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);

	if (shouldCancelSpawn)
	{
		[self cancelBalloonSpawn];
	}
	
	//resize sprite
	[currentBalloonSprite setScale: ballSize];	
	
	//set velocity to 0 to ignore the gravity
	if (currentBalloonBody)
	{
		cpBodySetVel(currentBalloonBody, cpv(0,0));
	}
	
}

- (CGPoint) rotatedXOffset
{
	//let's calculate the rotated X OFFSET 
	//x offset should be always 90 deg to the upvector so let's just exchange cos and sin >.<
	CGPoint v = CGPointMake(0.0, 1.0); //our unrotated upvector
	float angle = ccpAngleSigned ( upVector, v);
	v.x = cos(angle) * XOFFSET;
	v.y = -sin(angle) * XOFFSET;
	
	return v;
}


- (CGPoint) rotatedYOffset
{
	//let's calculate the rotated Y OFFSET 
	CGPoint v = CGPointMake(0.0, 1.0); //our unrotated upvector
	float angle = ccpAngleSigned ( upVector, v);
	v.x = sin(angle) * YOFFSET;
	v.y = cos(angle) * YOFFSET;
	
	return v;
}

- (void) ccTouchesMoved: (NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] >= 2 || [[CCDirector sharedDirector] isPaused])
		return;
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];
	
	
	if (shouldCancelSpawn)
		return;

//	printf("time: %f",[event timestamp]);
	
//	NSLog(@"MOVED!");
	
	if (currentBalloonBody && currentBalloonShape)
	{	
		
		
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		
		cpCircleShape *s = (cpCircleShape *)currentBalloonShape;
		float radius = s->r;
	//	NSLog(@"radius: %f",radius);
		
		BOOL applyCoords_x = YES;
		BOOL applyCoords_y = YES;
		
/*		location.x += XOFFSET;
		location.y += YOFFSET;*/
		
		CGPoint rotated_offset = [self rotatedYOffset];
		location.x += rotated_offset.x;
		location.y += rotated_offset.y;
		
		CGPoint rotated_x_offset = [self rotatedXOffset];
		location.x += rotated_x_offset.x;
		location.y += rotated_x_offset.y;
		
		if (location.x-radius < 0.0)
			applyCoords_x = NO;
		if (location.y-radius < 0.0)
			applyCoords_y = NO;
		if (location.x+radius > SCREEN_WIDTH)
			applyCoords_x = NO;
		if (location.y+radius > SCREEN_HEIGHT)
			applyCoords_y = NO;
		
//		printf("\nm_location: %f,%f\n",location.x,location.y);
//		printf("\napplyx: %i, applyy: %i\n",applyCoords_x,applyCoords_y);		
		
		cpVect np = currentBalloonBody->p;
		
		if (applyCoords_x)
			np.x = location.x;
		if (applyCoords_y)
			np.y = location.y;

		
		if (applyCoords_x || applyCoords_y)
			cpBodySetPos(currentBalloonBody, np);
		
		CGPoint v = CGPointMake(0.0, 1.0); //our unrotated upvector
		float angle = ccpAngleSigned ( CGPointMake(-upVector.x, upVector.y), v);
		cpBodySetAngle(currentBalloonBody, angle);
		
	}
	

}

- (void) ccTouchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"lolpenis: %i", [touches count]);
	
	//don't spawn if theres a balloon already
	
	if ([touches count] >= 2)
	{
		if ([[CCDirector sharedDirector] isPaused])
		{
			//[[CCDirector sharedDirector] resume];
		}
		else
		{
			//[[CCDirector sharedDirector] pause];
		}
		
		[[CCDirector sharedDirector] pushScene: [PauseScene node]];
		return;
	}
	
	if ([[CCDirector sharedDirector] isPaused])
		return;
	
	if (currentBalloonSprite)
		return;
	
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];

	
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	CGPoint orig_location = location;
	
//	NSLog(@"touch down @ %f,%f",location.x,location.y);
	
	
	/* if the user taps the bottom of the screen let the spawn point be the tap location without the OFFSETs added */
	//let balls spawn on the left!
	/*if (location.x >= XOFFSET)
		location.x += XOFFSET;
	
	//let balls spawn on the bottom!
	if (location.y >= YOFFSET)
		location.y += YOFFSET*/

//	CGPoint offset = CGPointMake(XOFFSET, YOFFSET);
	
	//CGPoint vect = ccpRotate(location, offset);
	
	//location.x += vect.x;
	//location.y += vect.y;
	
	//ccp vect = ccpCompMult(location, offset);
	

	CGPoint rotated_offset = [self rotatedYOffset];

	if (location.y >= YOFFSET)
	{
		location.x += rotated_offset.x;
		location.y += rotated_offset.y;
	}
//	NSLog(@"yo_addx: %f", rotated_offset.x);
//	NSLog(@"yo_addy: %f", rotated_offset.y);

	
	CGPoint rotated_x_offset = [self rotatedXOffset];
	if (location.x > XOFFSET)
	{	
		location.x += rotated_x_offset.x;
		location.y += rotated_x_offset.y;	
	}
	
//	NSLog(@"xo_addx: %f", rotated_x_offset.x);
//	NSLog(@"xo_addy: %f", rotated_x_offset.y);
	
	
//	NSLog(@"angle: %f", angle * (180.0/M_PI));
	
	
	
	// check bounds
	if (location.x <= 0)
		location.x = 1;
	
	if (location.x >= SCREEN_WIDTH)
		location.x = SCREEN_WIDTH-1;
	
	if (location.y <= 0)
		location.y = 1;
		
	if (location.y >= SCREEN_HEIGHT)
		location.y = SCREEN_HEIGHT-1;	
	
//	printf("\nt_location: %f,%f\n",location.x,location.y);

	//don't add a balloon in an existing baloon retardo
	cpShape *shape = cpSpacePointQueryFirst(space, cpv(location.x, location.y),CP_ALL_LAYERS, 0);
	if (shape)
	{
		NSLog(@"LOL U CANT DO IT ON THSI SHIT AGAIN FOTZE!");
		shape = NULL;		
	
		//check if we could add the balloon on the actual location the player tapped
		shape = cpSpacePointQueryFirst(space, cpv(orig_location.x, orig_location.y),CP_ALL_LAYERS, 0);
		if (shape)
		{
			NSLog(@"cant touch this too");
			return;	
		}

		//we can spawn at the original location
		location = orig_location;
		
	}

	ballSize = 0.15;
	[self startSpawningBalloonAtX: location.x y: location.y];
	
	CGPoint v = CGPointMake(0.0, 1.0); //our unrotated upvector
	float angle = ccpAngleSigned ( CGPointMake(-upVector.x, upVector.y), v);

	cpBodySetAngle(currentBalloonBody, angle);
	cpBodySetMass(currentBalloonBody, 0.15f);
	
	oldfill = g_GameInfo.currentLevel_fill;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

	if ([touches count] >= 2 || [[CCDirector sharedDirector] isPaused])
	{
		return;
	}
	
	UITouch *touch = [[touches allObjects] objectAtIndex: 0];
//
	
	if (shouldCancelSpawn)
	{
		NSLog(@"touches ended and shouldCancelSpawn is true! W T F?");
		[self cancelBalloonSpawn];
		return;
	}
	
	[self completeBalloonSpawn];	
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
	
	//upVector.x = -v.x;
	upVector.x = -v.x;
	upVector.y = -v.y;
//	NSLog(@"upvector: %f,%f", upVector.x, upVector.y);
	
	space->gravity = ccpMult(v, -(g_Physics.gravity.y));
}
@end
