//
//  IntroScene.h
//  Super Fill Up
//
//  Created by jrk on 11/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IntroScene : CCScene
{
	CCSprite *minyx;
	float counter;
	
	CCSprite *bar1;
	CCSprite *bar2;
	
	float bar1_factor;
	float bar2_factor;
}

@end
