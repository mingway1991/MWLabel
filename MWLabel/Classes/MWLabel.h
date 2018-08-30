//
//  MWLabel.h
//  MWLabel
//
//  Created by 石茗伟 on 2018/8/22.
//

#import <UIKit/UIKit.h>
@class MWTextData;

/**
 TODO:
 1.计算高度校准
 2.竖排，排版
 **/

NS_ASSUME_NONNULL_BEGIN

@interface MWLabel : UIView

@property (nonatomic, strong, nullable) MWTextData *data;
//支持长按复制，默认YES
@property (nonatomic, assign) BOOL canLongPressToCopy;

@end

NS_ASSUME_NONNULL_END
