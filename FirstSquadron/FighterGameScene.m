//
//  FighterGameScene.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 19/07/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "FighterGameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "SpriteCategories.h"
#import "SKEmitterNode+Utilities.h"
#import "EnemyMissile.h"
#import "HeroMissile.h"
#import "HeroFighter.h"
#import "EnemyFighter.h"

@implementation FighterGameScene {
    CMMotionManager *_motionManager;
    CMAttitude *_referenceAttitude;
    SKNode *_fighterLayer;
    HeroFighter *_heroFighter;
    NSUInteger _score;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        // Make the body 3 times larger than the visible area so that planes can move off the screen and don't disappear
        // or collide immediately when they hit the edge of the view.
        CGRect bodyRect = CGRectInset(CGRectMake(-size.width, -size.height, size.width * 3, size.height * 3), 0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bodyRect];
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        // Use the device's roll and pitch to move the hero fighter.
        _motionManager = [[CMMotionManager alloc] init];
        if([_motionManager isDeviceMotionAvailable]) {
            [_motionManager setAccelerometerUpdateInterval:1.0/30.0];
            [_motionManager startDeviceMotionUpdates];
            [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                if(!_referenceAttitude) {
                    _referenceAttitude = motion.attitude;
                }
                else {
                    CMAttitude *attitude = motion.attitude;
                    // Multiply by the inverse of the reference attitude so motion is relative to the start attitude.
                    [attitude multiplyByInverseOfAttitude:_referenceAttitude];
                    [_heroFighter.physicsBody applyImpulse:CGVectorMake(attitude.roll * 250, -attitude.pitch * 200)];
                }
            }];
        }
        
        SKSpriteNode *ground = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.6 green:0.6 blue:1.0 alpha:1.0] size:size];
        ground.position = CGPointMake((self.frame.size.width / 2), (self.frame.size.height / 2));
        [self addChild:ground];
        
        // Adds Clouds on top of the ground
        SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"CloudParticleEmitter"];
        emitter.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height + 200);
        [ground addChild:emitter];
        
        _fighterLayer = [SKNode node];
        [self addChild:_fighterLayer];
        
        // Adds Clouds to the top of the view. We use two cloud emitters to add some depth.
        SKEmitterNode *emitter2 = [SKEmitterNode emitterNamed:@"CloudParticleEmitter"];
        emitter2.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height + 200);
        [self addChild:emitter2];
        
        // Add a bounding box for the hero fighter so it doesn't escape from the current view.
        SKSpriteNode *heroBox = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(size.width - 5, size.height - 5)];
        heroBox.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-(size.width / 2), -(size.height / 2), size.width - 5, size.height - 5)];
        heroBox.physicsBody.categoryBitMask = heroBoundingBoxCategory;
        heroBox.physicsBody.contactTestBitMask = heroFighterCategory;
        heroBox.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [_fighterLayer addChild:heroBox];
        
        // Launch enemy fighters every 5 seconds.
        NSTimer *timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(launchEnemyFighters) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

#pragma mark - Game Logic

-(void)start {
    _score = 0;
    _heroFighter = [HeroFighter new];
    _heroFighter.position = self.view.center;
    [_fighterLayer addChild:_heroFighter];
}

-(void)pause {
    self.view.paused = YES;
}

-(void)resume {
    self.view.paused = NO;
}

-(void)recalibrate {
    _referenceAttitude = nil; // Reset ref attiude so future motion events are multiplied by the inverse of the next available motion update.
}

// If the hero's health is below 0, then explode the hero fighter and remove it.
-(void)checkIfHeroIsStillAlive {
    if(_heroFighter.health <= 0) {
        SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"Explosion"];
        emitter.position = _heroFighter.position;
        [emitter setScale:1];
        [emitter setParticleLifetime:2];
        [emitter runAction:[SKAction sequence:@[[SKAction moveByX:0 y:-self.size.height duration:2.5f],
                                                [SKAction fadeAlphaTo:0 duration:1.0],
                                                [SKAction removeFromParent]]]];
        [self addChild:emitter];
        [_heroFighter removeFromParent];
        _heroFighter = nil;
        
        [self.interfaceDelegate updateHealth:0];
        [self.interfaceDelegate gameOver:_score];
    }
}

-(void)launchEnemyFighters {
    if(!self.view.paused) {
        [self launchEnemyFighterFromX:self.frame.size.width / 2 andY:self.frame.size.height];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 - 50 andY:self.frame.size.height + 70];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 + 50 andY:self.frame.size.height + 70];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 + 100 andY:self.frame.size.height + 145];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 - 100 andY:self.frame.size.height + 145];
    }
}

-(void)launchEnemyFighterFromX:(CGFloat)xPos andY:(CGFloat)yPos {
    EnemyFighter *fighter = [EnemyFighter new];
    fighter.position = CGPointMake(xPos, yPos);
    [fighter runAction:[SKAction rotateByAngle:M_PI duration:0]];
    [_fighterLayer addChild:fighter];
    [fighter.physicsBody applyImpulse:CGVectorMake(0, -4)];
}

#pragma mark - Collision Logic

-(void)didBeginContact:(SKPhysicsContact*)contact {
    // The hero plane has hit something
    if((contact.bodyA.categoryBitMask == heroFighterCategory || contact.bodyB.categoryBitMask == heroFighterCategory) &&
       (contact.bodyA.categoryBitMask == enemyMissleCategory || contact.bodyB.categoryBitMask == enemyMissleCategory)) {
        SKNode *enemyMissle = contact.bodyA.categoryBitMask == enemyMissleCategory ? contact.bodyA.node : contact.bodyB.node;
        [enemyMissle runAction:[SKAction removeFromParent]];
        _heroFighter.health -= 0.05;
        [self checkIfHeroIsStillAlive];
        [self.interfaceDelegate updateHealth:_heroFighter.health];
    }
    // An enemy plane has hit something
    else if(contact.bodyA.categoryBitMask == enemyFighterCategory || contact.bodyB.categoryBitMask == enemyFighterCategory) {
        SKNode *enemyBody = contact.bodyA.categoryBitMask == enemyFighterCategory ? contact.bodyA.node : contact.bodyB.node;
        [enemyBody runAction:[SKAction removeFromParent]];
        
        BOOL explode = NO;
        if(contact.bodyA.categoryBitMask == heroFighterCategory || contact.bodyB.categoryBitMask == heroFighterCategory) {
            _heroFighter.health -= 0.1;
            [self.interfaceDelegate updateHealth:_heroFighter.health];
            [self checkIfHeroIsStillAlive];
            explode = YES;
        }
        else if (contact.bodyA.categoryBitMask == heroMissileCategory || contact.bodyB.categoryBitMask == heroMissileCategory) {
            _score += 100;
            [self.interfaceDelegate updateScore:_score];
            explode = YES;
        }
        
        if(explode) {
            SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"Explosion"];
            emitter.position = enemyBody.position;
            emitter.particleAlpha = 0.5;
            [self addChild:emitter];
            [emitter runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.3],
                                                    [SKAction removeFromParent]]]];
        }
    }
    // Hero/Enemy missle has hit something - remove. If it had an effect on anything we should have done that above.
    else {
        [self checkContactAndRemoveBody:contact withCategory:enemyMissleCategory];
        [self checkContactAndRemoveBody:contact withCategory:heroMissileCategory];
    }
}

-(void)checkContactAndRemoveBody:(SKPhysicsContact*)contact withCategory:(FighterGameCategories)bitmask {
    if(contact.bodyA.categoryBitMask == bitmask || contact.bodyB.categoryBitMask == bitmask) {
        SKNode *body = contact.bodyA.categoryBitMask == bitmask ? contact.bodyA.node : contact.bodyB.node;
        [body runAction:[SKAction removeFromParent]];
    }
}

@end