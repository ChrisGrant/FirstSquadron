//
//  SpriteCategories.h
//  SpriteKitBlog
//
//  Created by Chris Grant on 01/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, FighterGameCategories) {
    heroFighterCategory                 = 0,
    enemyFighterCategory   = 1 << 0,
    heroMissileCategory        = 1 << 1,
    enemyMissleCategory  = 1 << 2,
    heroBoundingBoxCategory    = 1 << 3
};