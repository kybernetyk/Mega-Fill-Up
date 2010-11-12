//
//  HighscoreSubmitOperation.h
//  Super Fill Up
//
//  Created by jrk on 17/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HighscoreSubmitOperation : NSOperation 
{
	int64_t _score;
}

- (id) initWithScore: (int64_t) score;

@end
