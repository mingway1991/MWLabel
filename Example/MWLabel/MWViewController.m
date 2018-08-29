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
    [self.view addSubview:self.tableView];
    
    _datas = [NSMutableArray array];
    for (NSInteger i=0; i < 1000; i++) {
        MWTextData *data = [[MWTextData alloc] init];
        data.defaultFont = [UIFont systemFontOfSize:12.f];
        data.text = [NSString stringWithFormat:@"测试文本啊wecwecwcewcwwecwecwr%@\n是啊哈哈哈哈\n擦拭传媒网IOC",@(i)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(0, 1)];
        [data addTextAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:20.f] range:NSMakeRange(1, 1)];
        [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
            NSLog(@"test1 %@", linkString);
        } linkColor:[UIColor redColor] hasUnderLine:YES range:NSMakeRange(0, 5)];
        [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
            NSLog(@"test2 %@", linkString);
        } linkColor:[UIColor blueColor] hasUnderLine:NO range:NSMakeRange(5, 5)];
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
    //maxLine:5
    return [_datas[indexPath.row] heightWithMaxWidth:[UIScreen mainScreen].bounds.size.width maxLine:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[TextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.label.data = _datas[indexPath.row];
    return cell;
}

@end
