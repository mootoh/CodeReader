//
//  CRTagFile.h
//  CodeReader
//
//  Created by Motohiro Takayama on 4/30/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRTag : NSObject

@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSString *lineno;
@property (strong, nonatomic) NSString *additional;

- (id) initWithValues:(NSArray *)values;

@end


@interface CRTagFile : NSObject

@property (strong, nonatomic) NSString *raw;
@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) NSMutableArray *tags;

- (id) initWithPath:(NSString *)path;
- (CRTag *) searchFor:(NSString *)key;

@end