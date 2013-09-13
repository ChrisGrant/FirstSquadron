//
//  EnemyMissile.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 01/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "EnemyMissile.h"
#import "SpriteCategories.h"

@implementation EnemyMissile

-(id)init {
    if(self = [super init]) {
        self.physicsBody.categoryBitMask = enemyMissleCategory;
        self.physicsBody.collisionBitMask = heroFighterCategory;
        self.physicsBody.contactTestBitMask = heroFighterCategory;
    }
    return self;
}

@end