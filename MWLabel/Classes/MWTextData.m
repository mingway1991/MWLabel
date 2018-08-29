//
//  MWTextData.m
//  MWLabel
//
//  Created by 石茗伟 on 2018/8/27.
//

#import "MWTextData.h"
@import CoreText;

@interface MWTextData()
{
    NSMutableArray<NSDictionary *> *_attrDicts;     //存放普通属性字典的数组
    NSMutableArray<NSDictionary *> *_linkDicts;     //存放链接字典的数组
    CGFloat _height;                                //保存计算好的高度
}

@end

@implementation MWTextData

- (instancetype)init {
    self = [super init];
    if (self) {
        _attrDicts = [NSMutableArray array];
        _linkDicts = [NSMutableArray array];
        self.defaultColor = [UIColor blackColor];
        self.defaultFont = [UIFont systemFontOfSize:16.f];
        self.character = 4.f;
        self.lineSpacing = 10.f;
        self.paragraphSpacing = 20.f;
        [self setDefaultHeight];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone{
    MWTextData *data = [[[self class] allocWithZone:zone] init];
    data.text = self.text;
    data.defaultFont  = self.defaultFont;
    data.defaultColor  = self.defaultColor;
    //未公开的成员
    data->_attrDicts = _attrDicts;
    data->_linkDicts = _linkDicts;
    return data;
}

#pragma mark - Setters
- (void)setText:(NSString *)text {
    _text = text;
    [self setDefaultHeight];
}

- (void)setDefaultFont:(UIFont *)defaultFont {
    _defaultFont = defaultFont;
    [self setDefaultHeight];
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
}

- (void)setCharacter:(CGFloat)character {
    _character = character;
    [self setDefaultHeight];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    [self setDefaultHeight];
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    _paragraphSpacing = paragraphSpacing;
    [self setDefaultHeight];
}

#pragma mark - 设置默认高度
- (void)setDefaultHeight {
    //代表没有计算过高度，需重新计算
    _height = -1.f;
}

#pragma mark - 获取高度
/* 获取高度 */
- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth {
    if (_height >= 0) {
        return _height;
    }
    CGFloat maxHeight = 10000000;//这里的高要设置足够大
    CFMutableAttributedStringRef attributedString = [self getCFAttributedString];
    
    CGFloat total_height = 0;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGRect drawingRect = CGRectMake(0, 0, maxWidth, maxHeight);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    CGFloat line_y = (int)origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef)(linesArray[linesArray.count-1]);
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = maxHeight - line_y + (int) descent + 1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    CFRelease(attributedString);
    
    _height = total_height;
    
    return total_height;
}

#pragma mark - 添加属性
/* 添加普通属性 */
- (void)addAttributeType:(MWTextAttributeType)attributeType
                   value:(id __nullable)value
                   range:(NSRange)range {
    if (value) {
        NSDictionary *attrDict = @{@"range": [NSValue valueWithRange:range], @"key":@(attributeType), @"value":value};
        [_attrDicts addObject:attrDict];
    } else {
        NSDictionary *attrDict = @{@"range": [NSValue valueWithRange:range], @"key":@(attributeType)};
        [_attrDicts addObject:attrDict];
    }
    [self setDefaultHeight];
}

/* 添加链接属性 */
- (void)addLinkAttributeWithBlock:(ClickLinkBlock)block
                        linkColor:(UIColor *)linkColor
                     hasUnderLine:(BOOL)hasUnderLine
                            range:(NSRange)range {
    NSDictionary *attrDict = @{@"range": [NSValue valueWithRange:range], @"block":block};
    [_linkDicts addObject:attrDict];
    [self addAttributeType:MWTextAttributeTypeColor value:linkColor range:range];
    if (hasUnderLine) {
        [self addAttributeType:MWTextAttributeTypeUnderLine value:nil range:range];
    }
    [self setDefaultHeight];
}

#pragma mark - 遍历属性
- (void)enumerateAttrDictsUsingBlock:(void(^)(NSDictionary *attrDict, BOOL *stop))block {
    [_attrDicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
}

- (void)enumerateLinkDictsUsingBlock:(void(^)(NSDictionary *linkDict, BOOL *stop))block {
    [_linkDicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
}

#pragma mark - 生成CFAttributedString
- (CFMutableAttributedStringRef)getCFAttributedString {
    CFStringRef textString = (__bridge CFStringRef)_text;
    //创建一个多属性字段，maxlength为0；maxlength是提示系统有需要多少内部空间需要保留，0表示不用提示限制
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    //为attrString添加内容，也可以用CFAttributedStringCreate 开头的几个方法，根据不同的需要和参数选择合适的方法。这里用替换的方式，完成写入。
    CFAttributedStringReplaceString(attributedString, CFRangeMake(0, 0),textString);
    //布局样式
    [self configParagraphWithAttributedString:attributedString];
    //添加属性
    [self configAttrDictWithAttributedString:attributedString];
    return attributedString;
}

/* 设置属性字典样式 */
- (void)configAttrDictWithAttributedString:(CFMutableAttributedStringRef)attributedString {
    CFRange totalRange = CFRangeMake(0, [_text length]);
    CFAttributedStringSetAttribute(attributedString,totalRange,kCTFontAttributeName,(__bridge CFTypeRef)(_defaultFont));
    CFAttributedStringSetAttribute(attributedString,totalRange,kCTForegroundColorAttributeName,(__bridge CFTypeRef)(_defaultColor));
    [self enumerateAttrDictsUsingBlock:^(NSDictionary * _Nonnull attrDict, BOOL *stop) {
        MWTextAttributeType type = [attrDict[@"key"] integerValue];
        id value = attrDict[@"value"];
        CFRangeMake(0, _text.length);
        NSRange nsRange = [attrDict[@"range"] rangeValue];
        CFRange range = CFRangeMake(nsRange.location, nsRange.length);
        if (type == MWTextAttributeTypeFont) {
            CFAttributedStringSetAttribute(attributedString,range,kCTFontAttributeName,(__bridge CFTypeRef)(value));
        } else if (type == MWTextAttributeTypeColor) {
            CFAttributedStringSetAttribute(attributedString,range,kCTForegroundColorAttributeName,(__bridge CFTypeRef)(value));
        } else if (type == MWTextAttributeTypeUnderLine) {
            CFAttributedStringSetAttribute(attributedString,range,kCTUnderlineStyleAttributeName,(__bridge CFTypeRef)(@(kCTUnderlineStyleSingle)));
        }
    }];
}

/* 设置布局样式 */
- (void)configParagraphWithAttributedString:(CFMutableAttributedStringRef)attributedString {
    CFRange range = CFRangeMake(0, [_text length]);
    
    //设置字体间距
    long number = _character;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
    CFAttributedStringSetAttribute(attributedString, range, kCTKernAttributeName, num);
    CFRelease(num);
    
    //设置段落样式
    CTTextAlignment alignment = kCTTextAlignmentJustified;
    CGFloat lineSpacing = _lineSpacing;
    CGFloat paragraphSpacing = _paragraphSpacing;
    
    CTParagraphStyleSetting _settings[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paragraphSpacing), &paragraphSpacing}
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
    CFAttributedStringSetAttribute(attributedString, range, kCTParagraphStyleAttributeName, paragraphStyle);
}

@end
