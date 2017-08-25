//
//  ViewController.m
//  testmap
//
//  Created by Fu_sion on 6/13/17.
//  Copyright © 2017 Fu_sion. All rights reserved.
//

#import "ViewController.h"
#import "HSNetManger.h"
#import "HSDataManger.h"
#import "HSinfoTableViewController.h"
#import "HSNetManger.h"
@interface ViewController ()<HSGetDataDelegate>
@property (weak, nonatomic) IBOutlet UITextField *localLabel;
@property (weak, nonatomic) IBOutlet UITextField *keyWordLabel;
@property (nonatomic, strong)HSNetManger *netManger;
//值显示手机信息
@property (weak, nonatomic) IBOutlet UISwitch *phoneNubOnlySwitch;
//显示消息
@property (weak, nonatomic) IBOutlet UILabel *showInfoLabel;

@end

@implementation ViewController
- (IBAction)searchBtn:(id)sender {
    
}
- (IBAction)phoneNubOnly:(UISwitch *)sender {
      NSLog(@"%@", sender.isOn ? @"ON" : @"OFF");
    if (sender.isOn) {
        self.showInfoLabel.text = @"只显示手机号码";
    }else {
        self.showInfoLabel.text = @"显示手机和固话";
    }

}

-(void)getDataSuccess {
    NSLog(@"1获取数据成功View");
}
-(void)getDataFaild {
    NSLog(@"获取数据失败");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    self.netManger = [HSNetManger new];
//    self.netManger.getDataDelegate = self;
//    [self.netManger getDataWithLocalWord:self.localLabel.text andKeyWord:self.keyWordLabel.text andPage:1];
//    [HSDataManger sharedHSDataManger].netManger = self.netManger;
     id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[HSinfoTableViewController class]]) {
//        HSinfoTableViewController *messageVC = (HSinfoTableViewController *)destVC;
        HSinfoTableViewController *infoView = segue.destinationViewController;
        infoView.keyWordStr = self.keyWordLabel.text;
        infoView.localStr = self.localLabel.text;
        infoView.phoneNubOnlyState = self.phoneNubOnlySwitch.isOn;
    }
    
    
}
//打开储存列表
- (IBAction)saveListBtnClick:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.toolbar.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
