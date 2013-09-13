//
//  ViewController.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 19/07/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController  {
    FighterGameScene *scene;
    
    UIButton *_startButton;
    
    UIButton *pauseButton;
    UILabel *_scoreLabel;
    UILabel *_healthLabel;
    
    UILabel *_gameOverLabel;
    UILabel *_gameOverDetailsLabel;
    
    UIImageView *iv;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView*)self.view;
    
    // Create and configure the scene.
    scene = [FighterGameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
    
    scene.interfaceDelegate = self;
    
    _gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2 - 120, self.view.bounds.size.width, 50)];
    [_gameOverLabel setText:@"GAME OVER"];
    [_gameOverLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0f]];
    [_gameOverLabel setTextAlignment:NSTextAlignmentCenter];
    [_gameOverLabel setTextColor:[UIColor whiteColor]];
    [_gameOverLabel setHidden:YES];
    [self.view addSubview:_gameOverLabel];
    
    iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [iv setCenter:CGPointMake(self.view.center.x, self.view.center.y - 100)];
    [self.view addSubview:iv];
    
    _gameOverDetailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2 - 65, self.view.bounds.size.width, 100)];
    [_gameOverDetailsLabel setNumberOfLines:0];
    [_gameOverDetailsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    [_gameOverDetailsLabel setTextAlignment:NSTextAlignmentCenter];
    [_gameOverDetailsLabel setTextColor:[UIColor whiteColor]];
    [_gameOverDetailsLabel setHidden:YES];
    [self.view addSubview:_gameOverDetailsLabel];
    
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [_startButton setTitle:@"START" forState:UIControlStateNormal];
    [[_startButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]];
    [_startButton setTitleColor:[UIColor colorWithRed:204.0f/255.0f green:0 blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_startButton setCenter:CGPointMake(self.view.center.x, self.view.center.y + 100)];
    [_startButton addTarget:self action:@selector(startTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    
    UIFont *bottomFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 32, 70, 32)];
    [[pauseButton titleLabel] setFont:bottomFont];
    [pauseButton setTitle:@"PAUSE" forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton setHidden:YES];
    [self.view addSubview:pauseButton];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 3,
                                                            self.view.bounds.size.height - 32,
                                                            self.view.frame.size.width / 3,
                                                            32)];
    [_scoreLabel setTextAlignment:NSTextAlignmentCenter];
    [_scoreLabel setFont:bottomFont];
    [_scoreLabel setTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:_scoreLabel];
    
    _healthLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 3) * 2,
                                                             self.view.bounds.size.height - 32,
                                                             (self.view.frame.size.width / 3) - 5,
                                                             32)];
    [_healthLabel setTextColor:[UIColor whiteColor]];
    [_healthLabel setFont:bottomFont];
    [_healthLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:_healthLabel];
}

-(void)startTapped {
    [self updateHealth:1];
    [self updateScore:0];
    [scene recalibrate];
    [scene start];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_gameOverLabel setAlpha:0.0f];
        [_gameOverDetailsLabel setAlpha:0.0f];
        [_startButton setAlpha:0.0f];
        [iv setAlpha:0.0f];
        [pauseButton setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [_gameOverLabel setHidden:YES];
        [_gameOverDetailsLabel setHidden:YES];
        [_startButton setHidden:YES];
        [iv setHidden:YES];
        [pauseButton setHidden:NO];
    }];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)pauseTapped {
    if(scene.view.paused) {
        [scene recalibrate];
        [scene resume];
        [pauseButton setTitle:@"PAUSE" forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else {
        [scene pause];
        [pauseButton setTitle:@"RESUME" forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

#pragma mark - FighterGameSceneInterfaceDelegate methods

-(void)updateHealth:(double)newHealth {
    [_healthLabel setText:[NSString stringWithFormat:@"%.0f%%", newHealth * 100]];
}

-(void)updateScore:(int)newScore {
    [_scoreLabel setText:[NSString stringWithFormat:@"SCORE: %i", newScore]];
}

-(void)gameOver:(int)finalScore {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    NSNumber *topScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"TOP_SCORE"];
    if(topScore == nil || topScore.intValue < finalScore) {
        topScore = [NSNumber numberWithInt:finalScore];
        [[NSUserDefaults standardUserDefaults] setObject:topScore forKey:@"TOP_SCORE"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_startButton setTitle:@"RESTART" forState:UIControlStateNormal];
    [_gameOverDetailsLabel setText:[NSString stringWithFormat:@"YOUR SCORE: %i\nTop Score: %i",  finalScore, topScore.intValue]];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_startButton setAlpha:1.0f];
        [pauseButton setAlpha:0.0f];
        [_gameOverDetailsLabel setAlpha:1.0f];
        [_gameOverLabel setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [_startButton setHidden:NO];
        [pauseButton setHidden:YES];
        [_gameOverDetailsLabel setHidden:NO];
        [_gameOverLabel setHidden:NO];
    }];
}

@end