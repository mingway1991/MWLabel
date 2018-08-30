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
    for (NSInteger i=0; i < 100; i++) {
        MWTextData *data = [[MWTextData alloc] init];
        data.numberOfLines = 0;
        data.defaultFont = [UIFont systemFontOfSize:12.f];
        data.text = [NSString stringWithFormat:@"庙市和夜景合二为一，这里始终是南京最繁华的地方之一，美称\"十里珠帘\"这里还包含景点： 秦淮河 乌衣巷 瞻园 中国科举博物馆(江南贡院) 白鹭洲公园 老门东 中华门瓮城 李香君故居陈列馆 回味鸭血粉丝汤(瞻园奥特莱斯店) 清真·莲湖糕团店 南京大牌档(夫子庙平江府店)\n我的家乡南京是一个迷人、繁华、历史悠久的大都市。\n南京有很多迷人的风景。春天，梅花山的梅花竞相开放，远远看去，那粉色的、大红色的、浅绿色的、白色的、桃红色的梅花像五彩霞衣，将梅花山装扮得焕然一新；凑近了看，梅花们有的三个一群、两个一伙地聚在枝头，有的一朵独秀。梅花的形状非常好看，有层层叠叠地开着的，也有单层五瓣的，还有的梅花正羞涩地打着朵儿呢。秋天，北京西路的银杏树叶金光闪闪，满城尽带黄金甲，栖霞山的枫叶则红透了半边天。\n南京的街市非常繁华，高楼大厦鳞次栉比。大街上人来人往，摩肩接踵，人们七嘴八舌地议论着，到处都是喧闹的声音。汽车一辆接着一辆行驶在大街上，五颜六色，从远处看，像一条彩色的长龙在游动。新街口有很多商店，太平洋百货、金鹰国际、东方商城、新华书店、中央商场……从早到晚都是顾客盈门。夜晚，高楼大厦亮起了灯，街上顿时流光溢彩。\n南京也是一座历史悠久的文化名城。中山陵是孙中山先生的陵墓，那里绿树环绕，景色优美；雨花台烈士陵园掩映在绿树丛中，环境十分幽静。南京的古城墙长、城门多。明代的古城墙现存有２１公里长，还有１８个城门，其中如中山门、汉中门、中华门、玄武门等名称仍然在使用。"];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(0, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:20.f] range:NSMakeRange(1, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:20.f] range:NSMakeRange(30, 1)];
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
    return [_datas[indexPath.row] heightWithMaxWidth:[UIScreen mainScreen].bounds.size.width];
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
