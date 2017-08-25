//
//  HSDetalViewController.m
//  testmap
//
//  Created by Fu_sion on 6/16/17.
//  Copyright © 2017 Fu_sion. All rights reserved.
//

#import "HSDetalViewController.h"
#import "HSinfoTableViewController.h"
//#import "HSDataManger.h"
@interface HSDetalViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photosImageView;
@property (weak, nonatomic) IBOutlet UILabel *namaTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
//可以显示手机号码直接拨打
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@end

@implementation HSDetalViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVC = segue.destinationViewController;
    //判断是否为这个控制器
    if ([destVC isKindOfClass:[HSinfoTableViewController class]]) {
        HSinfoTableViewController *messageVC = (HSinfoTableViewController *)destVC;
         //传值
//        messageVC.friendJid = sender;
        
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"%@",self.selectDataDic);
    self.namaTextLabel.text = [self checkDataIsStringWithId:self.selectDataDic[@"name"]];
    self.title = self.namaTextLabel.text;
    self.numberLabel.text = [self checkDataIsStringWithId:self.selectDataDic[@"tel"]];
    self.addressLabel.text = [self checkDataIsStringWithId:self.selectDataDic[@"address"]];
    self.infoTextView.text = [self checkDataIsStringWithId:self.selectDataDic[@"tel"]];
//    self.infoTextView.dataDetectorTypes = UIDataDetectorTypeAll;
//    self.photosImageView.image = [UIImage ima]
}

- (void)telphone {
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"186xxxx6979"];
    //            NSLog(@"str======%@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:nil completionHandler:nil];
}
-(NSString *)checkDataIsStringWithId:(id)tempObj {
    NSString *str = [NSString stringWithFormat:@"%@",[tempObj class]];
    if ([str isEqualToString:@"__NSCFString"]) {
        return (NSString *)tempObj;
    }else {
        return @"暂无";
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
