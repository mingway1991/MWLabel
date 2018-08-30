//
//  TextCell.m
//  MWLabel_Example
//
//  Created by 石茗伟 on 2018/8/29.
//  Copyright © 2018年 mingway1991. All rights reserved.
//

#import "TextCell.h"

@implementation TextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.label = [[MWLabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.label];
        self.uilabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.uilabel.numberOfLines = 0;
//        [self addSubview:self.uilabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.label.data = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
    self.uilabel.frame = self.bounds;
}

@end
