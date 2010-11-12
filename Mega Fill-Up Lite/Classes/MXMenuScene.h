//
//  MXMenuScene.h
//  Mega Fill-Up
//
//  Created by jrk on 28/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MXMainMenuLayer.h"
#import "MenuBackgroundLayer.h"

@interface MXMenuScene : CCScene 
{
	MXMainMenuLayer *mml;
	MenuBackgroundLayer *mbl;
}

@end
