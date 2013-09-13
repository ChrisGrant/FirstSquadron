//
//  Fighter.h
//  SpriteKitBlog
//
//  Created by Chris Grant on 18/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Fighter : SKSpriteNode

-(id)initWithSpriteImageName:(NSString*)name;

@property (nonatomic) double health;

// Override these methods in subclasses of Fighter.
-(void)fireMissle;
-(double)missleFireRate;

@end