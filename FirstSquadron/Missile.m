//
//  Missile.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 01/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "Missile.h"

@implementation Missile

-(id)init {
    if(self = [super initWithColor:[SKColor yellowColor] size:CGSizeMake(1, 3)]) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.mass = 1;
        self.physicsBody.friction = 0;
        self.physicsBody.usesPreciseCollisionDetection = YES;
    }
    return self;
}

@end