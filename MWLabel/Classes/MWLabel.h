//
//  MWLabel.h
//  MWLabel
//
//  Created by 石茗伟 on 2018/8/22.
//

#import <UIKit/UIKit.h>
@class MWTextData;

/**
 CoreText绘制Label
 **/

//TODO:
//1.竖排，排版
//2.显示更多与收起
NS_ASSUME_NONNULL_BEGIN

@interface MWLabel : UIView

@property (nonatomic, strong, nullable) MWTextData *data;
//支持长按复制，默认YES
@property (nonatomic, assign) BOOL canLongPressToCopy;

@end

NS_ASSUME_NONNULL_END
