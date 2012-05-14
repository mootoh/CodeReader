//
//  CRCodeViewController.h
//  CodeReader
//
//  Created by Motohiro Takayama on 5/2/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRSyntaxHighlightedCodeView.h"

@interface CRCodeViewController : UIViewController <UIScrollViewDelegate, CRSyntaxHighlightedCodeViewDelegate>

@property (weak, nonatomic) IBOutlet CRSyntaxHighlightedCodeView *codeTextView;
@property (strong, nonatomic) NSString *fileName;
@property (nonatomic) NSInteger lineNumber;

@end
