//
//  MyScene.h
//  SpriteKitBlog
//

//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol FighterGameSceneInterfaceDelegate <NSObject>

-(void)gameOver:(int)finalScore;
-(void)updateScore:(int)newScore;
-(void)updateHealth:(double)newHealth;

@end

@interface FighterGameScene : SKScene <SKPhysicsContactDelegate>

@property id<FighterGameSceneInterfaceDelegate> interfaceDelegate;

-(void)start;
-(void)pause;
-(void)resume;
-(void)recalibrate;

@end