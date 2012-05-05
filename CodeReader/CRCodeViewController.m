//
//  CRCodeViewController.m
//  CodeReader
//
//  Created by Motohiro Takayama on 5/2/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import "CRCodeViewController.h"
#import "CRAppDelegate.h"
#import "CRTagFile.h"

@interface CRCodeViewController ()

@end

@implementation CRCodeViewController
@synthesize codeTextView;
@synthesize fileName;
@synthesize lineNumber;

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
    self.codeTextView.delegate = self;
    self.codeTextView.shcvDelegate = self;

    self.title = fileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
//    NSString *path = [documentPath stringByAppendingPathComponent:@"Samples/ruby"];
    NSString *path = [documentPath stringByAppendingPathComponent:@"Samples"];
    NSString *mainPath = [path stringByAppendingPathComponent:fileName];

    NSError *err = nil;
    NSString *contents = [NSString stringWithContentsOfFile:mainPath encoding:NSUTF8StringEncoding error:&err];
    codeTextView.codeText = contents;

    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.numberOfTapsRequired = 1;
    [codeTextView addGestureRecognizer:tgr];
    [codeTextView scrollToLine:lineNumber];
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

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.codeTextView setNeedsDisplay];
}

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:codeTextView];
    NSLog(@"tapped: %f, %f", location.x, location.y);
    [codeTextView tappedAt:location];
}

- (void) wordTapped:(NSString *)word
{
    CRAppDelegate *appDelegate = (CRAppDelegate *)[UIApplication sharedApplication].delegate;
    CRTagFile *tagFile = appDelegate.tagFile;

    CRTag *tag = [tagFile searchFor:word];
    if (tag) {
        NSLog(@"jump to the definition of %@", word);
        CRCodeViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CodeViewController"];
        cvc.fileName = tag.filename;
        cvc.lineNumber = [tag.lineno intValue];
        [self.navigationController pushViewController:cvc animated:YES];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView setNeedsDisplay];
}
@end
