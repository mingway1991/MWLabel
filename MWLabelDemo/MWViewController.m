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
        data.defaultFont = [UIFont systemFontOfSize:14.f];
        data.text = [NSString stringWithFormat:@"排版系统中文本显示的一个重要的过程就是字符到字形的转换。\n\n字符\n字符是信息本身的元素，而字形是字符的图形表征，字符还会有其它表征比如发音。字符在计算机中其实就是一个编码，某个字符集中的编码，比如Unicode字符集，就囊括了大都数存在的字符。"];
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
