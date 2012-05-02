//
//  CRCodeViewController.m
//  CodeReader
//
//  Created by Motohiro Takayama on 5/2/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import "CRCodeViewController.h"

@interface CRCodeViewController ()

@end

@implementation CRCodeViewController
@synthesize codeTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:@"Samples"];
    NSString *mainPath = [path stringByAppendingPathComponent:@"main.c"];

    NSError *err = nil;
    NSString *contents = [NSString stringWithContentsOfFile:mainPath encoding:NSUTF8StringEncoding error:&err];
    codeTextView.text = contents;
}

- (void)viewDidUnload
{
    [self setCodeTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
