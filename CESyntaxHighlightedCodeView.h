//
//  CESyntaxHighlightedCodeView.h
//  CodExcavator
//
//  Created by Motohiro Takayama on 12/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol CESyntaxHighlightedCodeViewDelegate

- (void) wordTapped:(NSString *)word;

@end

@interface CESyntaxHighlightedCodeView : UIScrollView
{
   NSString *codeText;
   NSString *searchText;
   CFMutableAttributedStringRef attributedString;
   CTFrameRef ctFrame;
   id <CESyntaxHighlightedCodeViewDelegate> shcvDelegate;
}

@property (nonatomic, copy) NSString *codeText;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) id <CESyntaxHighlightedCodeViewDelegate> shcvDelegate;

- (void) tappedAt:(CGPoint)point;

@end