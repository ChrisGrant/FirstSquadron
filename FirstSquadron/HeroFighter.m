//
//  HeroFighter.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 01/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "HeroFighter.h"
#import "SpriteCategories.h"
#import "HeroMissile.h"
#import "SKEmitterNode+Utilities.h"

@implementation HeroFighter {
    SKEmitterNode *_smokeEmitter;
    SKEmitterNode *_fireEmitter;
}

-(id)init {
    if(self = [super initWithSpriteImageName:@"spitfire"]) {
        self.name = @"Hero Fighter";
        self.physicsBody.categoryBitMask = heroFighterCategory;
        self.physicsBody.collisionBitMask = enemyFighterCategory | enemyMissleCategory | heroBoundingBoxCategory;
        self.physicsBody.contactTestBitMask = enemyFighterCategory | enemyMissleCategory | heroBoundingBoxCategory;
        self.physicsBody.mass = 50;
        self.physicsBody.allowsRotation = NO;
        self.health = 1.0;
        
        _smokeEmitter = [SKEmitterNode emitterNamed:@"DamageSmoke"];
        _smokeEmitter.position = CGPointMake(0, 30);
        [_smokeEmitter setParticleAlpha:0.0];
        [_smokeEmitter setParticleColor:[SKColor whiteColor]];
        [self addChild:_smokeEmitter];
        
        _fireEmitter = [SKEmitterNode emitterNamed:@"Fire"];
        _fireEmitter.position = CGPointMake(0, 15);
        [_fireEmitter setParticleAlpha:0.0];
        [self addChild:_fireEmitter];
    }
    return self;
}

-(double)missleFireRate {
    return 0.3;
}

-(void)fireMissle {
    HeroMissile *missle1 = [HeroMissile new];
    missle1.position = CGPointMake(self.position.x - 17, self.position.y + 16);
    [self.parent addChild:missle1];
    [missle1.physicsBody applyImpulse:CGVectorMake(0, 40000)];
    
    HeroMissile *missle2 = [HeroMissile new];
    missle2.position = CGPointMake(self.position.x + 17, self.position.y + 16);
    [self.parent addChild:missle2];
    [missle2.physicsBody applyImpulse:CGVectorMake(0, 40000)];
}

-(void)updateEffectsFromHealth {
    [_smokeEmitter setParticleAlpha:1 - self.health];
    [_smokeEmitter setParticleColor:[SKColor colorWithWhite:1 - self.health alpha:1.0]];
    
    if(self.health < 0.3) {
        [_fireEmitter setParticleAlpha:1.0];
    }
}

@end