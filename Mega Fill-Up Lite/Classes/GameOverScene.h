//
//  GameOverScene.h
//  Super Fill Up
//
//  Created by jrk on 20/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface GameOverScene : CCScene
{

	CCMenuItem *fbMenuItem;
}

- (void) goToMainMenu: (id) something;
- (void) openFacebook: (id) something;

@end
