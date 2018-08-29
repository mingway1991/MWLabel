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
}

@end

@implementation MWLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)dealloc {
    CFRelease(_ctFrameRef);
}

- (void)setData:(MWTextData *)data {
    _data = data;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_data) {
        return;
    }
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
    //获取组装好的CFMutableAttributedStringRef
    CFMutableAttributedStringRef attributedString = [_data getCFAttributedString];
    //通过多属性字符，可以得到一个文本显示范围的工厂对象，我们最后渲染文本对象是通过这个工厂对象进行的。
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);
    //attrString 完成使命可以休息了
    CFRelease(attributedString);
    //创建一个有文本内容的范围
    _ctFrameRef = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0),path,NULL);
    //把内容显示在给定的文本范围内；
    CTFrameDraw(_ctFrameRef,context);
    //完成任务就把我们创建的对象回收掉，内存宝贵，不用了就回收，这是好习惯。
    CFRelease(framesetter);
    CFRelease(path);
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
        CTLineRef line = (__bridge CTLineRef)lines[lineNum];
        CGPoint origin = origins[lineNum];
        CGRect CTRunFrame = [self frameForCTRunWithIndex:i CTLine:line origin:origin];
        if ([self isFrame:CTRunFrame containsPoint:location]) {
            //遍历link属性，查看点击字符是否在链接range
            [self.data enumerateLinkDictsUsingBlock:^(NSDictionary * _Nonnull linkDict, BOOL *stop) {
                NSRange nsRange = [linkDict[@"range"] rangeValue];
                if ([self isIndex:i inRange:nsRange]) {
                    *stop = YES;
                    ClickLinkBlock linkBlock = linkDict[@"block"];
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

@end
