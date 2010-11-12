//
//  MXInstructionScene.h
//  Mega Fill-Up
//
//  Created by jrk on 30/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MXInstructionScene : CCScene
{
	NSInteger current_screen;
	
	CCLayer *currentLayer;
	CCLayer *tempLayer;
	
	CCLayer *menuLayer;
}

- (void) switchToNext: (id) blah;
- (void) switchToPrev: (id) blah;
- (void) switchToMainMenu: (id) blah;

- (void) createBackground;
- (void) createInstructionLayer;
- (void) updateMenuLayer;

@end
