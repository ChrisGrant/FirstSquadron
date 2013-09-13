//
//  Fighter.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 18/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "Fighter.h"
#import "SpriteCategories.h"
#import "SKEmitterNode+Utilities.h"

@implementation Fighter {
    SKEmitterNode *_smokeEmitter;
    SKEmitterNode *_fireEmitter;
    NSTimer *_timer;
}

-(id)initWithSpriteImageName:(NSString*)name {
    if(self = [super init]) {
        
        SKSpriteNode *fighterSprite = [SKSpriteNode spriteNodeWithImageNamed:name];
        fighterSprite.size = CGSizeMake(60,60);
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:fighterSprite.size];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        
        _smokeEmitter = [SKEmitterNode emitterNamed:@"DamageSmoke"];
        _smokeEmitter.position = CGPointMake(0, 30);
        [_smokeEmitter setParticleAlpha:0.1];
        [_smokeEmitter setParticleColor:[SKColor whiteColor]];
        [self addChild:_smokeEmitter];
        
        _fireEmitter = [SKEmitterNode emitterNamed:@"Fire"];
        _fireEmitter.position = CGPointMake(0, 15);
        [_fireEmitter setParticleAlpha:0.0];
        [self addChild:_fireEmitter];
        
        [self addChild:fighterSprite];
        
        self.health = 1.0;

        _timer = [NSTimer scheduledTimerWithTimeInterval:[self missleFireRate] target:self selector:@selector(fireMissle) userInfo:nil repeats: YES];
    }
    return self;
}

-(void)setHealth:(double)health {
    if(health != _health) {
        _health = MAX(0, health);
        [self updateEffectsFromHealth];
    }
}

-(void)updateEffectsFromHealth {
    [_smokeEmitter setParticleAlpha:1 - _health];
    [_smokeEmitter setParticleColor:[SKColor colorWithWhite:1 - _health alpha:1.0]];
    
    if(_health < 0.3) {
        [_fireEmitter setParticleAlpha:1.0];
    }
}

-(void)fireMissle {
    [NSException raise:@"Implement in subclass" format:@"Each subclass should fire differently"];
}

-(double)missleFireRate {
    [NSException raise:@"Implement in subclass" format:@"Each subclass should have a different missle fire rate"];
    return 0.0;
}

-(void)dealloc {
    [_timer invalidate];
}

@end