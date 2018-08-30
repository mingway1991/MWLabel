//
//  MWLabel.m
//  MWLabel
//
//  Created by 石茗伟 on 2018/8/22.
//

#import "MWLabel.h"
#import "MWTextData.h"
@import CoreText;

@interface MWLabel()
{
    CTFrameRef _ctFrameRef;
    UIColor *_savedBackgroundColor;
}

@end

@implementation MWLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self attachTapHandler];
        _canLongPressToCopy = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuItemHidden:)name:UIMenuControllerWillHideMenuNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    if (_ctFrameRef) {
        CFRelease(_ctFrameRef);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setData:(MWTextData *)data {
    _data = data;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect {
    if (!_data) {
        return;
    }
    //#####################前期准备#################################
    //初始化一个画布
    CGContextRef context = UIGraphicsGetCurrentContext();
#ifdef TARGET_OS_IPHONE
    //反转画布的坐标系，由于OS中坐标系原点在左下角，iOS中在左上角，所以在iOS需要反转一下，OS中不用。
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
#endif
    //设置文本的矩阵
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    //创建文本范围的路径
    CGMutablePathRef path = CGPathCreateMutable();
    //创建一个矩形文本区域
    CGPathAddRect(path, NULL, self.bounds);
    CFMutableAttributedStringRef attributedString = (__bridge CFMutableAttributedStringRef)[_data generateAttributedString];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);
    if (!framesetter) {
        CFRelease(path);
        return;
    }
    if (_ctFrameRef) {
        CFRelease(_ctFrameRef);
    }
    _ctFrameRef = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0),path,NULL);
    if (!_ctFrameRef) {
        CFRelease(path);
        CFRelease(framesetter);
        return;
    }
    //#######################开始绘制内容################################
    CFArrayRef ctLines = CTFrameGetLines(_ctFrameRef);
    CFIndex numberOfLines = CFArrayGetCount(ctLines);
    if (_data.numberOfLines > 0 && numberOfLines > _data.numberOfLines) {
        numberOfLines = _data.numberOfLines;
    }
    CGPoint lineOrigins[CFArrayGetCount(ctLines)];
    CTFrameGetLineOrigins(_ctFrameRef, CFRangeMake(0, 0), lineOrigins);
    
    //给定的高度
    CGFloat curHeight = rect.size.height;
    //实际展示需要的高度
    CGFloat totalHeight = [_data heightWithMaxWidth:rect.size.width];
    
    if (_data.numberOfLines > 0 || curHeight < totalHeight) {
        //如果给定的高度不满足需要的高度，则开启逐行绘制
        for (int i = 0 ; i < numberOfLines; i++) {
            //逐行绘制
            CTLineRef line = CFArrayGetValueAtIndex(ctLines, i);
            CGContextSetTextPosition(context, lineOrigins[i].x, lineOrigins[i].y);
            if (i == numberOfLines - 1) {
                //判断最后一行，加省略号
                CFRange lastLineRange = CTLineGetStringRange(line);
                if (lastLineRange.location + lastLineRange.length < _data.text.length) {
                    CTLineTruncationType truncationType = kCTLineTruncationEnd;
                    //加省略号的位置
                    NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                    //获取省略号位置的字符串属性
                    NSDictionary *tokenAttributes = [(__bridge NSAttributedString *)attributedString attributesAtIndex:truncationAttributePosition
                                                                         effectiveRange:NULL];
                    //初始化省略号的属性字符串
                    NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:@"..."
                                                                                      attributes:tokenAttributes];
                    //创建一行
                    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                    NSMutableAttributedString *truncationString = [[(__bridge NSAttributedString *)attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                    if (lastLineRange.length > 0) {
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                    [truncationString appendAttributedString:tokenString];

                    //创建省略号的行
                    CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                    // 在省略号行的末尾加上省略号
                    CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                    if (!truncatedLine) {
                        // If the line is not as wide as the truncationToken, truncatedLine is NULL
                        truncatedLine = CFRetain(truncationToken);
                    }
                    CFRelease(truncationLine);//CF得自己释放，ARC的不会释放
                    CFRelease(truncationToken);

                    CTLineDraw(truncatedLine, context);
                    CFRelease(truncatedLine);
                }
            } else {
                CTLineDraw(line, context);
            }
        }
    } else {
        //如果给定的高度大于等于需要的高度，那就不需要考虑被截断的问题，则直接使用frame绘制
        CTFrameDraw(_ctFrameRef,context);
    }
    CFRelease(framesetter);
    CFRelease(path);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawTextInRect:rect];
}

#pragma mark - Touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint location = [self systemPointFromScreenPoint:[touch locationInView:self]];
    [self clickOnStringWithPoint:location];
}

#pragma mark - ClickHelper
/* 点击字符串上某个位置的处理 */
- (void)clickOnStringWithPoint:(CGPoint)location {
    //拿到所有的lines
    NSArray *lines = (NSArray *)CTFrameGetLines(_ctFrameRef);
    CFRange ranges[lines.count];
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(_ctFrameRef, CFRangeMake(0, 0), origins);
    //获取每一行的range
    for (NSUInteger i=0; i < lines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        CFRange range = CTLineGetStringRange(line);
        ranges[i] = range;
    }
    //判断点击位置
    for (NSUInteger i=0; i < self.data.text.length; i++) {
        //计算当前字符位于第几行
        long maxLoc;
        NSInteger lineNum = 0;
        for (NSUInteger j=0; j < lines.count; j++) {
            CFRange range = ranges[j];
            maxLoc = range.location + range.length - 1;
            if (i <= maxLoc) {
                lineNum = j;
                break;
            }
        }
        if (lines.count <= lineNum) {
            return;
        }
        CTLineRef line = (__bridge CTLineRef)lines[lineNum];
        CGPoint origin = origins[lineNum];
        CGRect CTRunFrame = [self frameForCTRunWithIndex:i CTLine:line origin:origin];
        if ([self isFrame:CTRunFrame containsPoint:location]) {
            //遍历link属性，查看点击字符是否在链接range
            [self.data enumerateLinkDictsUsingBlock:^(NSDictionary * _Nonnull linkDict, BOOL *stop) {
                NSRange nsRange = [linkDict[kMWLinkAttributeNameRange] rangeValue];
                if ([self isIndex:i inRange:nsRange]) {
                    *stop = YES;
                    ClickLinkBlock linkBlock = linkDict[kMWLinkAttributeNameBlock];
                    linkBlock([self.data.text substringWithRange:nsRange], nsRange);
                }
            }];
            return;
        }
    }
    NSLog(@"您没有点击到文字");
}

/* 将屏幕坐标转换为系统坐标 */
- (CGPoint)systemPointFromScreenPoint:(CGPoint)origin {
    return CGPointMake(origin.x, self.bounds.size.height - origin.y);
}

/* frame是否包含这个point */
-(BOOL)isFrame:(CGRect)frame containsPoint:(CGPoint)point {
    return CGRectContainsPoint(frame, point);
}

/* 判断字符索引是否在某个range之中 */
- (BOOL)isIndex:(NSInteger)index inRange:(NSRange)range {
    if ((index <= range.location + range.length - 1) && (index >= range.location)) {
        return YES;
    }
    return NO;
}

/* 获取每一个CTRun的frame，根据origin（原点），line（行数），index（第几个字符） */
- (CGRect)frameForCTRunWithIndex:(NSInteger)index
                         CTLine:(CTLineRef)line
                         origin:(CGPoint)origin {
    CGFloat offsetX = CTLineGetOffsetForStringIndex(line, index, NULL);
    CGFloat offsexX2 = CTLineGetOffsetForStringIndex(line, index + 1, NULL);
    offsetX += origin.x;
    offsexX2 += origin.x;
    CGFloat offsetY = origin.y;
    CGFloat lineAscent;
    CGFloat lineDescent;
    NSArray * runs = (__bridge NSArray *)CTLineGetGlyphRuns(line);
    CTRunRef runCurrent;
    for (NSUInteger k=0; k < runs.count; k++) {
        CTRunRef run = (__bridge CTRunRef)runs[k];
        CFRange range = CTRunGetStringRange(run);
        NSRange rangeOC = NSMakeRange(range.location, range.length);
        if ([self isIndex:index inRange:rangeOC]) {
            runCurrent = run;
            break;
        }
    }
    CTRunGetTypographicBounds(runCurrent, CFRangeMake(0, 0), &lineAscent, &lineDescent, NULL);
    CGFloat height = lineAscent + lineDescent;
    return CGRectMake(offsetX, offsetY, offsexX2 - offsetX, height);
}

#pragma mark - 复制
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action ==@selector(copy:)) {
        return _canLongPressToCopy;
    } else if (action ==@selector(paste:)) {
        return NO;
    } else if (action ==@selector(cut:)) {
        return NO;
    } else if (action ==@selector(delete:)) {
        return NO;
    }
    return NO;
}

- (void)attachTapHandler {
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
    if (_canLongPressToCopy && !_savedBackgroundColor) {
        //保存原始背景色
        _savedBackgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
    }
}

- (void)copy:(nullable id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = _data.text;
    //恢复原始背景色
    if (_savedBackgroundColor) {
        self.backgroundColor = _savedBackgroundColor;
        _savedBackgroundColor = nil;
    }
}

#pragma mark - mark Menu Hidden
-(void)menuItemHidden:(id)sender{
    //恢复原始背景色
    if (_savedBackgroundColor) {
        self.backgroundColor = _savedBackgroundColor;
        _savedBackgroundColor = nil;
    }
}

@end
