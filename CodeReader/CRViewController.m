//
//  CRViewController.m
//  CodeReader
//
//  Created by Motohiro Takayama on 4/29/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import "CRViewController.h"
#import "CRCodeViewController.h"

@interface CRViewController ()

@end

@implementation CRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CRCodeViewController *cvc = (CRCodeViewController *)segue.destinationViewController;
    cvc.fileName = @"main.c";
}
@end
