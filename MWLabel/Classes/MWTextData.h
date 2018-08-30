//
//  MWTextData.h
//  MWLabel
//
//  Created by 石茗伟 on 2018/8/27.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kMWTextAttributeNameRange;
FOUNDATION_EXPORT NSString *const kMWTextAttributeNameKey;
FOUNDATION_EXPORT NSString *const kMWTextAttributeNameValue;

FOUNDATION_EXPORT NSString *const kMWLinkAttributeNameRange;
FOUNDATION_EXPORT NSString *const kMWLinkAttributeNameBlock;

typedef enum : NSUInteger {
    MWTextAttributeTypeFont,            //字体
    MWTextAttributeTypeColor,           //颜色
    MWTextAttributeTypeUnderLine,       //下划线
} MWTextAttributeType;

typedef void(^ClickLinkBlock)(NSString *linkString, NSRange range);

NS_ASSUME_NONNULL_BEGIN

@interface MWTextData : NSObject <NSCopying>

/* 文本 */
@property (nonatomic, copy, nullable) NSString *text;               //文本
@property (nonatomic, strong) UIColor *defaultColor;                //默认颜色
@property (nonatomic, strong) UIFont *defaultFont;                  //默认字体
@property (nonatomic, assign) CGFloat characterSpacing;             //字间距
@property (nonatomic, assign) CGFloat lineSpacing;                  //行间距
@property (nonatomic, assign) CGFloat paragraphSpacing;             //段落间距
@property (nonatomic, assign) NSUInteger numberOfLines;             //最大行数，默认为0

#pragma mark - 添加属性
/* 添加普通属性 */
- (void)addTextAttributeType:(MWTextAttributeType)attributeType
                       value:(id __nullable)value
                       range:(NSRange)range;
/* 添加链接属性 */
- (void)addLinkAttributeWithBlock:(ClickLinkBlock)block
                        linkColor:(UIColor *)linkColor
                     hasUnderLine:(BOOL)hasUnderLine
                            range:(NSRange)range;
#pragma mark - 获取高度
/* 获取高度 */
- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth;
/* 获取固定行数的高度 */
- (CGFloat)heightWithMaxWidth:(CGFloat)maxWidth maxLine:(CGFloat)maxLine;

#pragma mark MWLabel使用，用户绘制以及计算点击链接
/* 获取根绝配置生成的字符串 */
- (NSMutableAttributedString *)generateAttributedString;
/* 遍历链接属性 */
- (void)enumerateLinkDictsUsingBlock:(void(^)(NSDictionary *linkDict, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
