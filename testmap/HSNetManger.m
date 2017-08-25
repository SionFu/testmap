//
//  HSNetManger.m
//  testmap
//
//  Created by Fu_sion on 6/15/17.
//  Copyright © 2017 Fu_sion. All rights reserved.
//

#import "HSNetManger.h"
#import "HSDataManger.h"
@implementation HSNetManger
-(void)getDataWithLocalWord:(NSString *)localWord andKeyWord:(NSString *)keyWord andPage:(NSInteger)page  {
    NSString *url = [NSString stringWithFormat:@"%@&keywords=%@&city=%@&output=json&offset=40&page=%ld&key=%@&extensions=all",SITEURL,keyWord,localWord, (long)page, KEY];
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)url, NULL, NULL,  kCFStringEncodingUTF8 ));
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    [manger GET:encodedString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [HSDataManger sharedHSDataManger].getDicData = responseObject;
        [self.getDataDelegate getDataSuccess];
        NSLog(@"%@",url);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.getDataDelegate getDataFaild];
    }];
}
@end

