//
//  HeroMissile.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 01/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "HeroMissile.h"
#import "SpriteCategories.h"

@implementation HeroMissile

-(id)init {
    if(self = [super init]) {
        self.physicsBody.categoryBitMask = heroMissileCategory;
        self.physicsBody.collisionBitMask = enemyFighterCategory | heroBoundingBoxCategory;
        self.physicsBody.contactTestBitMask = enemyFighterCategory | heroBoundingBoxCategory;
        self.physicsBody.mass = 100;
    }
    return self;
}

@end