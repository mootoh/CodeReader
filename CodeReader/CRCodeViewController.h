//
//  CRCodeViewController.h
//  CodeReader
//
//  Created by Motohiro Takayama on 5/2/12.
//  Copyright (c) 2012 mootoh.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CESyntaxHighlightedCodeView.h"

@interface CRCodeViewController : UIViewController <UIScrollViewDelegate, CESyntaxHighlightedCodeViewDelegate>

@property (weak, nonatomic) IBOutlet CESyntaxHighlightedCodeView *codeTextView;
@property (strong, nonatomic) NSString *fileName;

@end
