//
//  CESyntaxHighlightedCodeView.m
//  CodExcavator
//
//  Created by Motohiro Takayama on 12/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "CRSyntaxHighlightedCodeView.h"
#import "CRAppDelegate.h"
#import "CRTagFile.h"

@implementation CRSyntaxHighlightedCodeView
@synthesize codeText;
@synthesize searchText;
@synthesize shcvDelegate;

- (void) initialize
{
    codeText = nil;
    searchText = nil;
    attributedCodeText = NULL;
    framesetter = NULL;
    currentFrame = NULL;
    nextFrame = NULL;
    textRanges = NULL;
    prevViewframeRect = CGRectZero;
    textRangesCount = 0;
    lineCount = 0;
    shcvDelegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    if (textRanges) free(textRanges);
    if (framesetter) CFRelease(framesetter);
    if (attributedCodeText) CFRelease(attributedCodeText);
}

- (void) setCodeText:(NSString *) ct
{
    codeText = [ct copy];
    [self setupTypeset];
    [self updateScrollViewContentSize];
    [self collectTextRanges];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Private

- (void) setupTypeset
{
    attributedCodeText = CFAttributedStringCreateMutable(NULL, codeText.length);
    CFAttributedStringReplaceString(attributedCodeText, CFRangeMake(0, 0), (__bridge CFStringRef)codeText);
    CTFontRef codeFont = CTFontCreateWithName(CFSTR("Inconsolata"), 16.0, NULL);
    CFAttributedStringSetAttribute(attributedCodeText, CFRangeMake(0, codeText.length), kCTFontAttributeName, codeFont);

//    TODO: enable it later
//    [self syntaxHighlight:attributedCodeText];
//    [self highlightSearchResult:attributedCodeText];
    [self highlightTaggedWords:attributedCodeText];

    // Create the framesetter with the attributed string.
    framesetter = CTFramesetterCreateWithAttributedString(attributedCodeText);
}

void printRect(CGRect *rect, NSString *prefix)
{
    NSLog(@"%@: rect:(%f, %f, %f, %f)", prefix, rect->origin.x, rect->origin.y, rect->size.width, rect->size.height);
}

- (void) updateScrollViewContentSize
{
    // Calculate the content size of this scroll view based on the CT frame.
    CFRange range;
    CGSize scrollViewSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, codeText.length), NULL, CGSizeMake(self.frame.size.width, CGFLOAT_MAX), &range);
    [self setContentSize:scrollViewSize];
}

- (void) layoutSubviews
{
    if (! CGRectEqualToRect(self.frame, prevViewframeRect)) {
        [self updateScrollViewContentSize];
        [self collectTextRanges];
        prevViewframeRect = self.frame;
    }
}

- (void) collectTextRanges
{
    size_t TEXT_RANGE_MAX = 500;
    if (textRanges)
        free(textRanges);
    textRanges = (CFRange *)malloc(sizeof(CFRange) * TEXT_RANGE_MAX);

    CFRange fullRange = CFRangeMake(0, codeText.length);
    textRangesCount=0;
    for (CFRange textRange = CFRangeMake(0, codeText.length);
         textRange.location < fullRange.length;
         ) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.frame);

        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
        if (frame == NULL) {
            NSLog(@"frame is null..... for range:(%ld, %ld)", textRange.location, textRange.length);
            CFRelease(path);
            break;
        }
        CFArrayRef lines = CTFrameGetLines(frame);
        lineCount += CFArrayGetCount(lines);

        textRange = CTFrameGetVisibleStringRange(frame);
        textRanges[textRangesCount++] = textRange;
        if (textRangesCount >= TEXT_RANGE_MAX) {
            TEXT_RANGE_MAX *= 2;
            realloc(textRanges, TEXT_RANGE_MAX);
            if (textRanges == NULL) {
                NSLog(@"failed in reallocating text ranges array");
                abort();
            }
        }
        
        CFRelease(frame);
        CFRelease(path);

        textRange.location += textRange.length;
        textRange.length = fullRange.length - textRange.location;
    }
}

- (void) coloring:(CFMutableAttributedStringRef) string range:(CFRange) range color:(CGColorRef)color
{
    CFAttributedStringSetAttribute(string, range, kCTForegroundColorAttributeName, color);
}

// parse, syntax highlight coloring
- (void) syntaxHighlight:(CFMutableAttributedStringRef)string pattern:(NSString *)pattern color:(CGColorRef)color
{
    // parse keywords
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:codeText options:0 range:NSMakeRange(0, codeText.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        NSRange matchRange = [match range];
        CFRange range = CFRangeMake(matchRange.location, matchRange.length);
        [self coloring:string range:range color:color];
    }];
}

- (void) syntaxHighlight:(CFMutableAttributedStringRef) string
{
    // Create a color and add it as an attribute to the string.
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat redComponents[] = { 1.0, 0.0, 0.0, 0.8 };
    CGColorRef red = CGColorCreate(rgbColorSpace, redComponents);
    [self syntaxHighlight:string pattern:@"\\b(int)|(char)\\b" color:red];
    
    CGFloat blueComponents[] = { 0.0, 0.0, 1.0, 0.8 };
    CGColorRef blue = CGColorCreate(rgbColorSpace, blueComponents);
    [self syntaxHighlight:string pattern:@"^#include\\b" color:blue];
    
    CGFloat greenComponents[] = { 0.0, 0.5, 0.25, 0.8 };
    CGColorRef green = CGColorCreate(rgbColorSpace, greenComponents);
    [self syntaxHighlight:string pattern:@"\".*\"" color:green];
    
    CGColorRelease(red);
    CGColorRelease(blue);
    CGColorRelease(green);
    CGColorSpaceRelease(rgbColorSpace);
}

- (void) highlightSearchResult:(CFMutableAttributedStringRef) string
{
    if (! searchText) return;
    // Create a color and add it as an attribute to the string.
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat searchResultColorComponents[] = { 1.0, 0.5, 0.0, 0.8 };
    CGColorRef searchResultColor = CGColorCreate(rgbColorSpace, searchResultColorComponents);
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchText
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:codeText options:0 range:NSMakeRange(0, codeText.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        NSRange matchRange = [match range];
        CFRange range = CFRangeMake(matchRange.location, matchRange.length);
        
        SInt32 one = 1;
        CFNumberRef underline = CFNumberCreate(NULL, kCFNumberSInt32Type, &one);	
        CFAttributedStringSetAttribute(string, range, kCTForegroundColorAttributeName, searchResultColor);
        CFAttributedStringSetAttribute(string, range, kCTUnderlineColorAttributeName, searchResultColor);
        CFAttributedStringSetAttribute(string, range, kCTUnderlineStyleAttributeName, underline);
        CFRelease(underline);
    }];
    
    CGColorRelease(searchResultColor);
    CGColorSpaceRelease(rgbColorSpace);
}

- (void) highlightTaggedWords:(CFMutableAttributedStringRef) string
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat taggedComponents[] = { 0.0, 0.5, 0.25, 0.8 };
    CGColorRef taggedColor = CGColorCreate(rgbColorSpace, taggedComponents);
    
    CRAppDelegate *appDelegate = (CRAppDelegate *)[UIApplication sharedApplication].delegate;
    CRTagFile *tagFile = appDelegate.tagFile;
    NSRange range = NSMakeRange(0, [codeText length]);
    
    // TODO: should search for only the visible range
    [codeText enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([tagFile searchFor:substring]) {
            CFRange wordRange = CFRangeMake(substringRange.location, substringRange.length);
            CFAttributedStringSetAttribute(string, wordRange, kCTUnderlineColorAttributeName, taggedColor);
            NSNumber *styleNum = [NSNumber numberWithInt:kCTUnderlinePatternDot | kCTUnderlineStyleThick];
            CFAttributedStringSetAttribute(string, wordRange, kCTUnderlineStyleAttributeName, (__bridge CFNumberRef)styleNum);
        }
    }];
    
    CGColorRelease(taggedColor);
    CGColorSpaceRelease(rgbColorSpace);
}

- (CTFrameRef)drawFrameOf:(int)index InRect:(CGRect)rect context:(CGContextRef)context
{
    CGRect textRect = CGRectMake(rect.origin.x, rect.origin.y - index * rect.size.height + self.frame.origin.y, rect.size.width, rect.size.height);
    CGPathRef path = CGPathCreateWithRect(textRect, NULL);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRanges[index], path, NULL);
    CTFrameDraw(frame, context);
    
    CFRelease(path);
    return frame;
}

- (void)drawRect:(CGRect)rect
{
    if (! codeText) return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0.0, self.frame.size.height + self.frame.origin.y + self.bounds.origin.y);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGFloat y = rect.origin.y / (CGFloat)rect.size.height;
    int index = (int)y;

    if (currentFrame)
        CFRelease(currentFrame);
    if (nextFrame)
        CFRelease(nextFrame);
    currentFrame = [self drawFrameOf:index InRect:rect context:context];
    if (textRangesCount > 1)
        nextFrame = [self drawFrameOf:index+1 InRect:rect context:context];
}

- (void) setSearchText:(NSString *) st
{
    searchText = (st == nil) ? nil : [st copy];
    [self setNeedsDisplay];
}

- (BOOL) findTappedPoint:(CGPoint)point InFrame:(CTFrameRef)frame
{
    BOOL ret = FALSE;
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex lineSize = CFArrayGetCount(lines);
    CGPoint *origins = (CGPoint *)malloc(sizeof(CGPoint) * lineSize);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, lineSize), origins);
    CGPathRef path = CTFrameGetPath(frame);
    CGRect pathBounds = CGPathGetBoundingBox(path);
    
    for (int i=0; i < lineSize; i++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange nsLineRange = {lineRange.location, lineRange.length};
        CGPoint origin = *(origins+i);
        
        // Get typographics bounds
        float ascent;
        float descent;
        float leading;
        double width  = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // Decide line frame
        CGRect lineFrame;
        lineFrame.origin.x = origin.x;
        lineFrame.origin.y = self.contentOffset.y - pathBounds.origin.y + pathBounds.size.height - origin.y; // - descent
        lineFrame.size.width = width;
        lineFrame.size.height = ascent + descent;
        

        // Check with point
        if (CGRectContainsPoint(lineFrame, point)) {
            CGPoint position = {point.x + origins[0].x, point.y + origins[0].y};
            CFIndex index = CTLineGetStringIndexForPosition(line, position);
            if (index == kCFNotFound)
                continue;
            
            __block NSString *left = nil, *right = nil;
            [codeText enumerateSubstringsInRange:NSMakeRange(0, index) options:NSStringEnumerationReverse | NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                left = [subString copy];
                *stop = YES;
            }];
            
            [codeText enumerateSubstringsInRange:NSMakeRange(index, [codeText length]-index) options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                right = [subString copy];
                *stop = YES;
            }];
            
            NSString *word = [left stringByAppendingString:right];
            NSLog(@"word = %@", word);
            if (shcvDelegate)
                [shcvDelegate wordTapped:word];
            ret = YES;
            break;
        }
    }
    free(origins);
    return ret;
}

// tapped character lookup code is from  http://hmdt.jp/blog/?p=105 .
- (void) tappedAt:(CGPoint)point
{
    if ([self findTappedPoint:point InFrame:currentFrame])
        return;
    [self findTappedPoint:point InFrame:nextFrame];
}

- (void) scrollToLine:(NSInteger) lineNumber
{
    float viewHeight = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
    ? (self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width)
    : (self.frame.size.width > self.frame.size.height ? self.frame.size.width : self.frame.size.height);
    float height = self.contentSize.height/lineCount;
    float scrollTo = lineNumber * height;// + height * 12;
    if (scrollTo + viewHeight/2 < self.contentSize.height)
        scrollTo += viewHeight/2;
    
    CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y + scrollTo, 8, 8);
    [self scrollRectToVisible:rect animated:YES];
}

@end