//
//  SKEmitterNode+Utilities.m
//  SpriteKitBlog
//
//  Created by Chris Grant on 01/08/2013.
//  Copyright (c) 2013 Chris Grant. All rights reserved.
//

#import "SKEmitterNode+Utilities.h"

@implementation SKEmitterNode (Utilities)

+(SKEmitterNode*)emitterNamed:(NSString*)emitterName {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:emitterName ofType:@"sks"]];
}

@end