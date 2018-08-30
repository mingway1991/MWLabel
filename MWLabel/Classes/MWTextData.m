//
//  MWTextData.m
//  MWLabel
//
//  Created by 石茗伟 on 2018/8/27.
//

#import "MWTextData.h"
@import CoreText;

NSString *const kMWTextAttributeNameRange   = @"range";
NSString *const kMWTextAttributeNameKey     = @"key";
NSString *const kMWTextAttributeNameValue   = @"value";

NSString *const kMWLinkAttributeNameRange   = @"range";
NSString *const kMWLinkAttributeNameBlock   = @"block";

@interface MWTextData()
{
    NSMutableArray<NSDictionary *> *_attrDicts;                 //存放普通属性字典的数组
    NSMutableArray<NSDictionary *> *_linkDicts;                 //存放链接字典的数组
    CGFloat _height;                                            //保存计算好的高度
    NSMutableAttributedString *_attributedString;               //保存生成的富文本字符串
}

@end

@implementation MWTextData

- (instancetype)init {
    self = [super init];
    if (self) {
        _attrDicts = [NSMutableArray array];
        _linkDicts = [NSMutableArray array];
        _defaultColor = [UIColor blackColor];
        _defaultFont = [UIFont systemFontOfSize:16.f];
        _characterSpacing = 1.f;
        _lineSpacing = 2.f;
        _paragraphSpacing = 10.f;
        _numberOfLines = 0;
        [self resetStoreValue];
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
    data->_height = _height;
    data->_attributedString = _attributedString;
    return data;
}

#pragma mark - Setters
- (void)setText:(NSString *)text {
    _text = text;
    [self resetStoreValue];
}

- (void)setDefaultFont:(UIFont *)defaultFont {
    _defaultFont = defaultFont;
    [self resetStoreValue];
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
    [self resetStoreValue];
}

- (void)setCharacterSpacing:(CGFloat)characterSpacing {
    _characterSpacing = characterSpacing;
    [self resetStoreValue];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    [self resetStoreValue];
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    _paragraphSpacing = paragraphSpacing;
    [self resetStoreValue];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    [self resetStoreValue];
}

#pragma mark - 设置默认高度
- (void)resetStoreValue {
    //代表没有计算过高度，需重新计算
    _height = -1.f;
    _attributedString = nil;
}

#pragma mark - 获取高度
/* 获取高度(最后一行原点y坐标加最后一行高度) */
- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth {
    if (_height < 0) {
        CGFloat maxHeight = 1000000000;//这里的高要设置足够大
        CFMutableAttributedStringRef attributedString = (__bridge CFMutableAttributedStringRef)[self generateAttributedString];
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);
        CGRect drawingRect = CGRectMake(0, 0, maxWidth, maxHeight);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, drawingRect);
        CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
        NSArray *lines = (NSArray *)CTFrameGetLines(textFrame);
        CGPoint origins[[lines count]];
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        CGFloat line_y = (CGFloat)origins[[lines count]-1].y;  //最后一行line的原点y坐标
        
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        
        CTLineRef line = (__bridge CTLineRef)(lines[lines.count-1]);
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        _height = maxHeight - line_y + (CGFloat)lineDescent + 1;    //+1为了纠正descent转换成int小数点后舍去的值
        CFRelease(textFrame);
        _height = ceilf(_height);
    }
    return _height;
}

/* 获取固定行数的高度 */
- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth maxLine:(CGFloat)maxLine {
    CFMutableAttributedStringRef attributedString = (__bridge CFMutableAttributedStringRef)[self generateAttributedString];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);
    CGFloat maxHeight = 1000000000;//这里的高要设置足够大
    CGRect drawingRect = CGRectMake(0, 0, maxWidth, maxHeight);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), lineOrigins);
    
    /******************
     * 逐行lineHeight累加
     ******************/
    NSInteger lineNum = CFArrayGetCount(lines);
    if (lineNum > maxLine) {
        lineNum = maxLine;
    }
    CGFloat heightValue = 0;
    for (NSInteger i = 0; i < lineNum; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;//上行行高
        CGFloat lineDescent;//下行行高
        CGFloat lineLeading;//行距
        CGFloat lineHeight;//行高
        //获取每行的高度
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        lineHeight = lineAscent +  fabs(lineDescent) + lineLeading;
        heightValue = heightValue + lineHeight;
    }
    heightValue = ceilf(heightValue);
    return heightValue;
}

#pragma mark - 添加属性
/* 添加普通属性 */
- (void)addTextAttributeType:(MWTextAttributeType)attributeType
                       value:(id __nullable)value
                       range:(NSRange)range {
    if (value) {
        NSDictionary *attrDict = @{kMWTextAttributeNameRange: [NSValue valueWithRange:range],
                                   kMWTextAttributeNameKey:@(attributeType),
                                   kMWTextAttributeNameValue:value};
        [_attrDicts addObject:attrDict];
    } else {
        NSDictionary *attrDict = @{kMWTextAttributeNameRange: [NSValue valueWithRange:range],
                                   kMWTextAttributeNameKey:@(attributeType)};
        [_attrDicts addObject:attrDict];
    }
    [self resetStoreValue];
}

/* 添加链接属性 */
- (void)addLinkAttributeWithBlock:(ClickLinkBlock)block
                        linkColor:(UIColor *)linkColor
                     hasUnderLine:(BOOL)hasUnderLine
                            range:(NSRange)range {
    NSDictionary *attrDict = @{kMWLinkAttributeNameRange: [NSValue valueWithRange:range],
                               kMWLinkAttributeNameBlock:block};
    [_linkDicts addObject:attrDict];
    [self addTextAttributeType:MWTextAttributeTypeColor value:linkColor range:range];
    if (hasUnderLine) {
        [self addTextAttributeType:MWTextAttributeTypeUnderLine value:nil range:range];
    }
    [self resetStoreValue];
}

#pragma mark - 遍历属性
- (void)enumerateTextAttrDictsUsingBlock:(void(^)(NSDictionary *attrDict, BOOL *stop))block {
    [_attrDicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
}

- (void)enumerateLinkDictsUsingBlock:(void(^)(NSDictionary *linkDict, BOOL *stop))block {
    [_linkDicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
}

#pragma mark - 生成AttributedString
- (NSMutableAttributedString *)generateAttributedString {
    if (!_attributedString) {
        _attributedString = [[NSMutableAttributedString alloc] initWithString:_text];
        //添加属性
        [self configTextAttrDictWithAttributedString:_attributedString];
        //布局样式
        [self configParagraphWithAttributedString:_attributedString];
    }
    return _attributedString;
}

/* 设置属性字典样式 */
- (void)configTextAttrDictWithAttributedString:(NSMutableAttributedString *)attributedString {
    NSRange totalRange = NSMakeRange(0, [_text length]);
    [attributedString addAttribute:NSFontAttributeName value:_defaultFont range:totalRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:_defaultColor range:totalRange];
    [self enumerateTextAttrDictsUsingBlock:^(NSDictionary * _Nonnull attrDict, BOOL *stop) {
        MWTextAttributeType type = [attrDict[kMWTextAttributeNameKey] integerValue];
        id value = attrDict[kMWTextAttributeNameValue];
        NSRange range = [attrDict[kMWTextAttributeNameRange] rangeValue];
        if (type == MWTextAttributeTypeFont) {
            [attributedString addAttribute:NSFontAttributeName value:value range:range];
        } else if (type == MWTextAttributeTypeColor) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:value range:range];
        } else if (type == MWTextAttributeTypeUnderLine) {
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
        }
    }];
}

/* 设置布局样式 */
- (void)configParagraphWithAttributedString:(NSMutableAttributedString *)attributedString {
    NSRange range = NSMakeRange(0, [_text length]);
    
    //设置字体间距
    [attributedString addAttribute:NSKernAttributeName value:@(_characterSpacing) range:range];
    
    //设置段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineSpacing = _lineSpacing;
    paragraphStyle.paragraphSpacing = _paragraphSpacing;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

@end
