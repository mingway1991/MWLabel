//
//  MWViewController.m
//  MWLabel
//
//  Created by mingway1991 on 08/22/2018.
//  Copyright (c) 2018 mingway1991. All rights reserved.
//

#import "MWViewController.h"
#import "TextCell.h"

@interface MWViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray<MWTextData *> *_datas;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];
    
    _datas = [NSMutableArray array];
    for (NSInteger i=0; i < 1; i++) {
        MWTextData *data = [[MWTextData alloc] init];
        data.numberOfLines = 0;
        data.defaultFont = [UIFont systemFontOfSize:16.f];
        data.text = [NSString stringWithFormat:@"简评中国杂志中有关介绍高达的文章@#*)\n\n历史终究是会向前发展的。\n\n终于，寻梦人有了自己的家。#*)而高达，也因此开始有了自己的落脚处。\n*)nA.D 1997年7月，中国@#*)大陆第一篇系统介绍它的文章诞生在了《电子游戏与电脑游戏》杂志上。虽然这篇文章仅仅是从名游戏《超级机器人大战》~~~|||>>??!系列的角度去评价高达，但是作为大陆#*)第一个敢吃螃蟹的人，它所迈出的这一步，是具有历史意义的。总的来说，这篇文章还是主要是从主观角度去看高达。几部曾在SRW中出现的高达作品，在这里都得到了啼笑皆非的评价。例如《0080》，该作完全是从在SRW中的战斗力来评价的，所以结果可想而知。而对《0083》评价是GP01Fb因为机动力高，所以“印象中的GP01在《第四次》中，只是到处奔波着寻找宝藏，无闲暇去战斗了”;卡特"];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(0, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:20.f] range:NSMakeRange(1, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:28.f] range:NSMakeRange(30, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:30.f] range:NSMakeRange(80, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:30.f] range:NSMakeRange(120, 1)];
        [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
            NSLog(@"test1 %@", linkString);
        } linkColor:[UIColor redColor] hasUnderLine:YES range:NSMakeRange(0, 5)];
        [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
            NSLog(@"test2 %@", linkString);
        } linkColor:[UIColor blueColor] hasUnderLine:NO range:NSMakeRange(5, 5)];
        [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
            NSLog(@"test3 %@", linkString);
        } linkColor:[UIColor blueColor] hasUnderLine:NO range:NSMakeRange(105, 5)];
        [_datas addObject:data];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_datas[indexPath.row] heightWithMaxWidth:[UIScreen mainScreen].bounds.size.width maxLine:6];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[TextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.uilabel.hidden = YES;
    cell.label.data = _datas[indexPath.row];
//    cell.label.hidden = YES;
//    cell.uilabel.attributedText = [_datas[indexPath.row] generateAttributedString];
    return cell;
}

@end
