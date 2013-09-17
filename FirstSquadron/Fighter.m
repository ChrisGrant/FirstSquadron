//
//  Fighter.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 18/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "Fighter.h"
#import "SpriteCategories.h"

@implementation Fighter {
    NSTimer *_timer;
}

-(id)initWithSpriteImageName:(NSString*)name {
    if(self = [super init]) {
        
        SKSpriteNode *fighterSprite = [SKSpriteNode spriteNodeWithImageNamed:name];
        fighterSprite.size = CGSizeMake(60,60);
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:fighterSprite.size];
        self.physicsBody.usesPreciseCollisionDetection = YES;
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
    // Override in subclass if you want to add effects based on the health
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