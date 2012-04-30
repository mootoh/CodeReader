//
//  CRTagFile.h
//  CodeReader
//
//  Created by Motohiro Takayama on 4/30/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRTagFile : NSObject

- (id) initWithPath:(NSString *)path;

@property (strong, nonatomic) NSString *raw;

@end
