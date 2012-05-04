//
//  CRTagFile.m
//  CodeReader
//
//  Created by Motohiro Takayama on 4/30/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import "CRTagFile.h"

@implementation CRTagFile

@synthesize raw, keys, tags;

- (id) initWithPath:(NSString *)path
{
    if (self = [super init]) {
        keys = [[NSMutableArray alloc] init];
        tags = [[NSMutableArray alloc] init];
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
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        // check header
        if ([line hasPrefix:@"!"])
            continue;

        if ([line isEqualToString:@""])
            continue;

        NSArray *compos = [line componentsSeparatedByString:@"\t"];
        [keys addObject:[compos objectAtIndex:0]];
        NSRange range = {1, [compos count]-1};
        NSArray *vals = [compos subarrayWithRange:range];
        CRTag *tag = [[CRTag alloc] initWithValues:vals];
        NSLog(@"filename: %@", tag.filename);
        [tags addObject:tag];
    }
}

- (CRTag *) searchFor:(NSString *)key
{
    NSRange range = {0, [keys count]};
    NSUInteger index = [keys indexOfObject:key inSortedRange:range options:NSBinarySearchingFirstEqual usingComparator:^(NSString *a, NSString *b) {
        return [a compare:b];
    }];

    return index == NSNotFound ? nil : [tags objectAtIndex:index];
}

@end

@implementation CRTag

@synthesize filename, lineno, additional;

- (id) initWithValues:(NSArray *)values
{
    if (self = [super init]) {
        filename = [values objectAtIndex:0];
        NSArray *compos = [[values objectAtIndex:1] componentsSeparatedByString:@";\""];
        lineno = [compos objectAtIndex:0];
    }
    return self;
}
@end