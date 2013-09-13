//
//  EnemyFighter.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 18/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "EnemyFighter.h"
#import "EnemyMissile.h"
#import "SpriteCategories.h"

@implementation EnemyFighter

-(id)init {
    if(self = [super initWithSpriteImageName:@"spitfire"]) {
        self.name = @"Enemy Fighter";
        self.physicsBody.categoryBitMask = enemyFighterCategory;
        self.physicsBody.collisionBitMask = heroFighterCategory | heroMissileCategory;
        self.physicsBody.contactTestBitMask = heroFighterCategory | heroMissileCategory;
        self.physicsBody.mass = 2;
        self.physicsBody.friction = 0;
        self.health = 1.0;
    }
    return self;
}

-(double)missleFireRate {
    return 0.9;
}

-(void)fireMissle {
    EnemyMissile *missle = [EnemyMissile new];
    missle.position = CGPointMake(self.position.x, self.position.y - 30);
    [self.parent addChild:missle];
    [missle.physicsBody applyImpulse:CGVectorMake(0, -500)];
}

@end