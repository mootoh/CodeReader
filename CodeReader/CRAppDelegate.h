//
//  CRAppDelegate.h
//  CodeReader
//
//  Created by Motohiro Takayama on 4/29/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRTagFile;
@interface CRAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) CRTagFile *tagFile;
@end
