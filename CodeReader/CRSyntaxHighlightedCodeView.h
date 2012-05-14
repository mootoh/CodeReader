//
//  CESyntaxHighlightedCodeView.h
//  CodExcavator
//
//  Created by Motohiro Takayama on 12/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol CRSyntaxHighlightedCodeViewDelegate

- (void) wordTapped:(NSString *)word;

@end

@interface CRSyntaxHighlightedCodeView : UIScrollView
{
    NSString *codeText;
    NSString *searchText;
    CFMutableAttributedStringRef attributedCodeText;
    CTFramesetterRef framesetter;
    CTFrameRef currentFrame, nextFrame;
    CFRange *textRanges;
    CGRect prevViewframeRect;
    size_t textRangesCount;
    size_t lineCount;
    id <CRSyntaxHighlightedCodeViewDelegate> shcvDelegate;
}

@property (nonatomic, copy) NSString *codeText;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) id <CRSyntaxHighlightedCodeViewDelegate> shcvDelegate;

- (void) tappedAt:(CGPoint)point;
- (void) scrollToLine:(NSInteger) lineNumber;

@end