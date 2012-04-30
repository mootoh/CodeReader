//
//  CRTagFile.m
//  CodeReader
//
//  Created by Motohiro Takayama on 4/30/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import "CRTagFile.h"

@implementation CRTagFile
@synthesize raw;

- (id) initWithPath:(NSString *)path
{
    if (self = [super init]) {
        NSError *err = nil;
        NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        NSLog(@"contents = %@", contents);
        self.raw = contents;
        [self parse:contents];
    }
    return self;
}

- (void) parse:(NSString *)contents
{
    // check header
    // set offset and line size
}

@end
