//
//  MyScene.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 19/07/2013.
//  Copyright (c) 2013 TODO. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "SpriteCategories.h"
#import "SKEmitterNode+Utilities.h"
#import "EnemyMissile.h"
#import "HeroMissile.h"
#import "HeroFighter.h"
#import "EnemyFighter.h"

@interface GameScene () <SKPhysicsContactDelegate>
@end

@implementation GameScene {
    SKNode *_groundLayer;
    SKNode *_fighterLayer;
    SKNode *_topCloudLayer;
    
    HeroFighter *_heroFighter;
    
    CMMotionManager *_motionManager;
    CMAttitude *_initialAttitude;
    
    int spawnCounter;
    
    SKLabelNode *_gameOverlabel;
    SKLabelNode *_scoreLabel;
    SKLabelNode *_healthLabel;
    NSUInteger _score;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectInset(CGRectMake(-size.width, -size.height, size.width * 3, size.height * 3), 0, 0)];
        self.physicsBody.collisionBitMask = -1;
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGPointMake(0, 0);
        
        _motionManager = [[CMMotionManager alloc] init];
        if([_motionManager isDeviceMotionAvailable]) {
            [_motionManager setAccelerometerUpdateInterval:1.0/35.0];
            [_motionManager startDeviceMotionUpdates];
            [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                if(!_initialAttitude) {
                    _initialAttitude = motion.attitude;
                }
                else {
                    CMAttitude *attitude = motion.attitude;
                    [attitude multiplyByInverseOfAttitude:_initialAttitude];
                    [_heroFighter.physicsBody applyImpulse:CGVectorMake(attitude.roll * 200, -attitude.pitch * 200)];
                }
            }];
        }
        
        _groundLayer = [SKNode node];
        [_groundLayer setZPosition:-2];
        [self addChild:_groundLayer];

        SKSpriteNode *ground = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.6 green:0.6 blue:1.0 alpha:1.0] size:size];
        ground.position = _groundLayer.position = CGPointMake((self.frame.size.width / 4), (self.frame.size.height / 4));
        [_groundLayer addChild:ground];

        _fighterLayer = [SKNode node];
        [self addChild:_fighterLayer];
        
        _heroFighter = [HeroFighter new];
        _heroFighter.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 100);
        [_fighterLayer addChild:_heroFighter];
        
        // Adds Clouds to the top of the view
        SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"CloudParticleEmitter"];
        emitter.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height + 200);
        [_groundLayer addChild:emitter];
        
        // Adds Clouds to the top of the view
        SKEmitterNode *emitter2 = [SKEmitterNode emitterNamed:@"CloudParticleEmitter"];
        emitter2.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height + 200);
        [self addChild:emitter2];
        
        _gameOverlabel = [[SKLabelNode alloc] initWithFontNamed:@"AvenirNextCondensed-Medium"];
        [_gameOverlabel setText:@"GAME OVER"];
        _gameOverlabel.position = CGPointMake(self.frame.size.width / 2, 50);
        [_gameOverlabel setHidden:YES];
        [self addChild:_gameOverlabel];
        
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"AvenirNextCondensed-Medium"];
        [_scoreLabel setText:@"Score: 0"];
        [_scoreLabel setFontSize:16.0f];
        _scoreLabel.position = CGPointMake(self.frame.size.width / 2, 10);
        [self addChild:_scoreLabel];
        
        _healthLabel = [[SKLabelNode alloc] initWithFontNamed:@"AvenirNextCondensed-Medium"];
        [_healthLabel setText:@"100%"];
        [_healthLabel setFontSize:16.0f];
        [_healthLabel setPosition:CGPointMake(self.frame.size.width - 20, 10)];
        [self addChild:_healthLabel];
    }
    return self;
}

// Reset the initial attiude so future motion events are multiplied by the inverse of the next available motion update.
-(void)recalibrate {
    _initialAttitude = nil;
}

-(void)didBeginContact:(SKPhysicsContact*)contact {
    // Don't do an explosion if the a missle hits the hero. We want it to stay alive! We should remove the missle.
    if(contact.bodyA.categoryBitMask == enemyMissleCategory && contact.bodyB.categoryBitMask == heroFighterCategory) {
        [contact.bodyA.node runAction:[SKAction removeFromParent]];
        _heroFighter.health -= 0.05;
        [self updateEffectsFromHeroHealth];
        return;
    }
    else if(contact.bodyB.categoryBitMask == enemyMissleCategory && contact.bodyA.categoryBitMask == heroFighterCategory) {
        [contact.bodyB.node runAction:[SKAction removeFromParent]];
        _heroFighter.health -= 0.05;
        [self updateEffectsFromHeroHealth];
        return;
    }
    
    CGPoint position = CGPointZero;
    // If anything hits an enemy plane, destroy it immediately.
    if(contact.bodyA.categoryBitMask == enemyFighterCategory || contact.bodyB.categoryBitMask == enemyFighterCategory) {
        if(contact.bodyA.categoryBitMask == enemyFighterCategory) {
            [contact.bodyA.node runAction:[SKAction sequence:@[[SKAction removeFromParent]]]];
            position = contact.bodyA.node.position;
            _score += 100;
        }
        else if(contact.bodyB.categoryBitMask == enemyFighterCategory) {
            [contact.bodyB.node runAction:[SKAction sequence:@[[SKAction removeFromParent]]]];
            position = contact.bodyB.node.position;
            _score += 100;
        }
        
        if(contact.bodyA.categoryBitMask == heroFighterCategory || contact.bodyB.categoryBitMask == heroFighterCategory) {
            _heroFighter.health -= 0.1;
            [self updateEffectsFromHeroHealth];
        }
        
        
        SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"Explosion"];
        emitter.position = position;
        emitter.particleAlpha = 0.5;
        [self addChild:emitter];
        [emitter runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.3], [SKAction removeFromParent]]]];
        
        [_scoreLabel setText:[NSString stringWithFormat:@"Score: %i", _score]];
        [_healthLabel setText:[NSString stringWithFormat:@"%.0f%%", _heroFighter.health * 100]];
    }
}

-(void)updateEffectsFromHeroHealth {
    if(_heroFighter.health <= 0) {
        SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"Explosion"];
        emitter.position = _heroFighter.position;
        [emitter setScale:1];
        [emitter setParticleLifetime:2];
        [emitter runAction:[SKAction moveBY:CGVectorMake(0, -self.size.height) duration:2.5f]];
        [emitter runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:1.0], [SKAction removeFromParent]]]];
        [self addChild:emitter];
        [_heroFighter removeFromParent];
        _heroFighter = nil;
        
        [_healthLabel setText:[NSString stringWithFormat:@"%.0f%%", 0.0f]];
        [_gameOverlabel setHidden:NO];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if(spawnCounter % 600 == 0) {
        [self launchEnemyFighterFromX:self.frame.size.width / 2 andY:self.frame.size.height + 50];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 - 50 andY:self.frame.size.height + 150];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 + 50 andY:self.frame.size.height + 150];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 + 100 andY:self.frame.size.height + 250];
        [self launchEnemyFighterFromX:self.frame.size.width / 2 - 100 andY:self.frame.size.height + 250];
        spawnCounter = 1; // We don't want this int to overflow!
    }
    
//    if(spawnCounter % 15 == 0) {
//        [self fireFromHero];
//    }
//    
//    if(spawnCounter % 50 == 0) {
//        [self fireFromEnemies];
//    }
    
    spawnCounter++;
    
    [self.physicsWorld enumerateBodiesInRect:CGRectMake(-self.size.width, -(self.size.height), self.size.width * 3, self.size.height)
                                  usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
        if((body.categoryBitMask == enemyFighterCategory || body.categoryBitMask == enemyMissleCategory) && body.node.position.y < -60) {
            [body.node runAction:[SKAction removeFromParent]];
        }
        else if(body.categoryBitMask == heroFighterCategory && body.velocity.dy < 0) {
            [body applyImpulse:CGVectorMake(0, fabs(body.velocity.dy * 15))];
        }
    }];
    
    [self.physicsWorld enumerateBodiesInRect:CGRectMake(-self.size.width, -self.size.height, self.size.width, self.size.height * 3)
                                  usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
        if(body.categoryBitMask == enemyFighterCategory || body.categoryBitMask == enemyMissleCategory || body.categoryBitMask == heroMissileCategory) {
            [body.node runAction:[SKAction removeFromParent]];
        }
        else if(body.categoryBitMask == heroFighterCategory && body.velocity.dx < 0) {
            [body applyImpulse:CGVectorMake(fabs(body.velocity.dx * 10), 0)];
        }
    }];
    
    [self.physicsWorld enumerateBodiesInRect:CGRectMake(self.size.width, -self.size.height, self.size.width, self.size.height * 3)
                                  usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
        if(body.categoryBitMask == enemyFighterCategory || body.categoryBitMask == enemyMissleCategory || body.categoryBitMask == heroMissileCategory) {
            [body.node runAction:[SKAction removeFromParent]];
        }
        else if(body.categoryBitMask == heroFighterCategory && body.velocity.dx > 0) {
            [body applyImpulse:CGVectorMake(-(body.velocity.dx * 10), 0)];
        }
    }];
    
    [self.physicsWorld enumerateBodiesInRect:CGRectMake(-self.size.width, self.size.height, self.size.width * 3, self.size.height)
                                  usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
        if(body.categoryBitMask == heroMissileCategory || body.categoryBitMask == enemyMissleCategory) {
            [body.node runAction:[SKAction removeFromParent]];
        }
        if(body.categoryBitMask == heroFighterCategory && body.velocity.dy > 0) {
                [body applyImpulse:CGVectorMake(0, -(body.velocity.dy * 15))];
        }
    }];
}

-(void)fireFromEnemies {
    [self.physicsWorld enumerateBodiesInRect:self.frame usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
        if(body.categoryBitMask == enemyFighterCategory) {
            [self fireFromEnemyFighter:body];
        }
    }];
}

-(void)fireFromEnemyFighter:(SKPhysicsBody*)body {
    EnemyMissile *missle = [EnemyMissile new];
    missle.position = CGPointMake(body.node.position.x, body.node.position.y - 30);
    [_fighterLayer addChild:missle];
    [missle.physicsBody applyImpulse:CGVectorMake(0, -400)];
}

-(void)fireFromHero {
    if(_heroFighter) {
        HeroMissile *missle1 = [HeroMissile new];
        missle1.position = CGPointMake(_heroFighter.position.x - 17, _heroFighter.position.y + 16);
        [_fighterLayer addChild:missle1];
        [missle1.physicsBody applyImpulse:CGVectorMake(0, 30000)];
        
        HeroMissile *missle2 = [HeroMissile new];
        missle2.position = CGPointMake(_heroFighter.position.x + 17, _heroFighter.position.y + 16);
        [_fighterLayer addChild:missle2];
        [missle2.physicsBody applyImpulse:CGVectorMake(0, 30000)];
    }
}

-(void)launchEnemyFighterFromX:(CGFloat)xPos andY:(CGFloat)yPos {
    EnemyFighter *fighter = [EnemyFighter new];
    
    fighter.position = CGPointMake(xPos, yPos);
    [fighter runAction:[SKAction rotateByAngle:M_PI duration:0]];
    [_fighterLayer addChild:fighter];
    
    [fighter.physicsBody applyImpulse:CGVectorMake(0, -300)];
}

@end