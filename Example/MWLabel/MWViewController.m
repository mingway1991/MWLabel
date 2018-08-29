//
//  MWViewController.m
//  MWLabel
//
//  Created by mingway1991 on 08/22/2018.
//  Copyright (c) 2018 mingway1991. All rights reserved.
//

#import "MWViewController.h"
@import MWLabel;

@interface MWViewController ()

@property (nonatomic, strong) MWLabel *label;

@end

@implementation MWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MWTextData *data = [[MWTextData alloc] init];
    data.text = @"是阿森松岛#wec#上档次哦IM噢IM吃什么吃我妈我是阿森松岛\n xscscwccwcw\nhttp://www.baidu.com";
    [data addAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(0, 1)];
    [data addAttributeType:MWTextAttributeTypeFont value:[UIFont systemFontOfSize:20.f] range:NSMakeRange(1, 1)];
    [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
        NSLog(@"test1 %@", linkString);
    } linkColor:[UIColor redColor] hasUnderLine:YES range:NSMakeRange(0, 5)];
    [data addLinkAttributeWithBlock:^(NSString *linkString, NSRange range) {
        NSLog(@"test2 %@", linkString);
    } linkColor:[UIColor blueColor] hasUnderLine:NO range:NSMakeRange(5, 5)];
    
    self.label = [[MWLabel alloc] initWithFrame:CGRectMake(20, 200, 320, [data heightWithMaxWidth:320])];
    self.label.data = data;
    [self.view addSubview:self.label];
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(10.f, 100.f, 30.f, 30.f);
    testButton.backgroundColor = [UIColor redColor];
    [testButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
}

- (void)test {
    MWTextData *data = self.label.data;
    data.lineSpacing = 10.f+(rand()%10);
    data.paragraphSpacing = 20.f+(rand()%10);
    data.character = 4.f+(rand()%10);
    data.text = @"阿森松岛#wec#上档次哦IM噢IM吃什么吃我妈我是阿森松岛\n xscscwcc \nhttp://www.baidu.com";
    self.label.data = data;
    self.label.frame = CGRectMake(20, 200, 320, [self.label.data heightWithMaxWidth:320]);
}

@end
