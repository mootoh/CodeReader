//
//  CRAppDelegate.m
//  CodeReader
//
//  Created by Motohiro Takayama on 4/29/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import "CRAppDelegate.h"
#import "CRTagFile.h"

@implementation CRAppDelegate

@synthesize window = _window;
@synthesize basePath;
@synthesize tagFile;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self createSourceTreeStructure];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) createSourceTreeStructure
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [documentPath stringByAppendingPathComponent:@"Samples"];
    if (! [fm fileExistsAtPath:path]) {
        NSError *err = nil;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            NSLog(@"createSourceTreeStructure: failed in creating a directory");
            return;
        }
        
        // copy Sample code files
        for (NSString *srcPath in [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"Samples"]) {
            NSLog(@"srcPath = %@", srcPath);
            NSString *toPath = [path stringByAppendingPathComponent:[srcPath lastPathComponent]];

            [fm copyItemAtPath:srcPath toPath:toPath error:&err];
            if (err) {
                NSLog(@"createSourceTreeStructure: failed in copy a file");
                return;
            }
        }
    }
    self.basePath = path;

    NSString *tagPath = [path stringByAppendingPathComponent:@"tags"];
    self.tagFile = [[CRTagFile alloc] initWithPath:tagPath];
}

@end
