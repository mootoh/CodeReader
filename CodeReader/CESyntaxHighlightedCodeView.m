//
//  CESyntaxHighlightedCodeView.m
//  CodExcavator
//
//  Created by Motohiro Takayama on 12/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "CESyntaxHighlightedCodeView.h"
#import "CRAppDelegate.h"
#import "CRTagFile.h"

@implementation CESyntaxHighlightedCodeView
@synthesize codeText;
@synthesize searchText;
@synthesize shcvDelegate;

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      codeText = nil;
      searchText = nil;
      attributedString = NULL;
      ctFrame = NULL;
      shcvDelegate = nil;
   }
   return self;
}

#pragma mark -
#pragma mark Private

- (void) coloring:(CFAttributedStringRef) string range:(CFRange) range color:(CGColorRef)color
{
   CFAttributedStringSetAttribute(string, range, kCTForegroundColorAttributeName, color);
}

// parse, syntax highlight coloring
- (void) syntaxHighlight:(CFAttributedStringRef)string pattern:(NSString *)pattern color:(CGColorRef)color
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

- (void) syntaxHighlight:(CFAttributedStringRef) string
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

- (void) highlightSearchResult:(CFAttributedStringRef) string
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

- (void) highlightTaggedWords:(CFAttributedStringRef) string
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
            CFAttributedStringSetAttribute(string, wordRange, kCTForegroundColorAttributeName, taggedColor);
        }
    }];

    CGColorRelease(taggedColor);
    CGColorSpaceRelease(rgbColorSpace);
}

- (void)drawRect:(CGRect)rect
{
   if (! codeText) return;

   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetTextMatrix(context, CGAffineTransformIdentity);
   CGContextTranslateCTM(context, 0.0, self.contentSize.height);
   CGContextScaleCTM(context, 1.0, -1.0);

   CTFrameDraw(ctFrame, context);
   CGContextTranslateCTM(context, 0.0, self.contentOffset.y);

/*
   CFArrayRef lines = CTFrameGetLines(ctFrame);
   CFIndex lineSize = CFArrayGetCount(lines);
   for (int i=0; i<lineSize; i++) {
      CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
      CGRect bounds = CTLineGetImageBounds(line, context);
      NSLog(@"bounds: (%f, %f), (%f, %f)",
            bounds.origin.x, bounds.origin.y,
            bounds.size.width, bounds.size.height);
   }
*/ 
}

- (void)dealloc
{
   if (attributedString) CFRelease(attributedString);
   if (ctFrame) CFRelease(ctFrame);
}

- (void) updateFrame
{
   CFStringRef string = (__bridge CFStringRef)codeText;
   if (attributedString) CFRelease(attributedString);
   attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
   CFAttributedStringReplaceString(attributedString, CFRangeMake(0, 0), string);

   [self syntaxHighlight:attributedString];
   [self highlightSearchResult:attributedString];
    [self highlightTaggedWords:attributedString];

   CTFontRef codeFont = CTFontCreateWithName(CFSTR("Times"), 20.0, NULL);
	CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, codeText.length), kCTFontAttributeName, codeFont);

   // Create the framesetter with the attributed string.
   CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);

   // calculate the scrollView size
   CFRange range;
   CGSize scrollViewSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, codeText.length), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), &range);

   // Initialize a rectangular path.
   CGMutablePathRef path = CGPathCreateMutable();
   CGRect bounds = CGRectMake(0.0, 0.0, scrollViewSize.width, scrollViewSize.height);
   CGPathAddRect(path, NULL, bounds);

   // Create the frame and draw it into the graphics context
   if (ctFrame) CFRelease(ctFrame);
   ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
   CFRelease(framesetter);

   [self setContentSize:scrollViewSize];
   [self setNeedsDisplay];
}

- (void) setCodeText:(NSString *) ct
{
   codeText = [ct copy];
   [self updateFrame];
}

- (void) setSearchText:(NSString *) st
{
   searchText = (st == nil) ? nil : [st copy];
   [self updateFrame];
}

// tapped character lookup code is from  http://hmdt.jp/blog/?p=105 .
- (void) tappedAt:(CGPoint)point
{
    point.y = self.contentSize.height - point.y;
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex lineSize = CFArrayGetCount(lines);
    CGPoint *origins = (CGPoint *)malloc(sizeof(CGPoint) * lineSize);
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineSize), origins);

    for (int i=0; i < lineSize; i++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
        CGPoint origin = *(origins+i);
        
        // Get typographics bounds
        float ascent;
        float descent;
        float leading;
        double width  = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);

        // Decide line frame
        CGRect lineFrame;
        lineFrame.origin.x = origin.x;
        lineFrame.origin.y = origin.y - descent;
        lineFrame.size.width = width;
        lineFrame.size.height = ascent + descent;
        
//        NSLog(@"lineFrame:%f, %f, %f, %f", lineFrame.origin.x, lineFrame.origin.y, lineFrame.size.width, lineFrame.size.height);

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
            break;
        }
    }
    free(origins);
}

- (void) scrollToLine:(NSInteger) lineNumber
{
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CTLineRef line = CFArrayGetValueAtIndex(lines, 0);

    // Get typographics bounds
    double width;
    float ascent;
    float descent;
    float leading;
    width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);

    float viewHeight = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
        ? (self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width)
        : (self.frame.size.width > self.frame.size.height ? self.frame.size.width : self.frame.size.height);
//    NSLog(@"orientation:%d, width:%f, height:%f, viewHeight:%f", [UIDevice currentDevice].orientation, self.frame.size.width, self.frame.size.height, viewHeight);
    float height = self.contentSize.height/CFArrayGetCount(lines);
    float scrollTo = lineNumber * height;// + height * 12;
    if (scrollTo + viewHeight/2 < self.contentSize.height)
        scrollTo += viewHeight/2;
//    NSLog(@"lineNumber=%d, scrollTo=%f, height=%f", lineNumber, scrollTo, self.contentSize.height);

    CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y + scrollTo, width, height);
    [self scrollRectToVisible:rect animated:YES];
}

@end