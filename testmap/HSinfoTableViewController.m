//
//  HSinfoTableViewController.m
//  testmap
//
//  Created by Fu_sion on 6/14/17.
//  Copyright © 2017 Fu_sion. All rights reserved.
//

#import "HSinfoTableViewController.h"
#import "HSDataManger.h"
#import "HSNetManger.h"
#import "MBProgressHUD+KR.h"
#import "MJRefresh.h"
#import "HSDetalViewController.h"
@interface HSinfoTableViewController ()<HSGetDataDelegate>
@property (nonatomic, strong)HSNetManger *netManger;
//获取数据内容
@property(nonatomic, strong)NSMutableArray *dataArray;
//整理后的数据
@property(nonatomic, strong)NSMutableArray *fixDataArray;
//获取数据序列数 总和
@property(nonatomic, assign)int listNub;
//页数
@property(nonatomic, assign)NSInteger pageNub;
//选中的数据
@property(nonatomic, strong)NSDictionary *selectDicInDataArrayDic;
@end

@implementation HSinfoTableViewController
-(NSDictionary *)selectDicInDataArrayDic {
    if (_selectDicInDataArrayDic == nil) {
        _selectDicInDataArrayDic = [NSDictionary dictionary];
    }return _selectDicInDataArrayDic;
}
-(NSArray *)fixDataArray {
    if (_fixDataArray == nil) {
        _fixDataArray = [NSMutableArray array];
    }return _fixDataArray;
}
-(NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }return _dataArray;
}

-(NSInteger)pageNub {
    if (_pageNub == 0) {
        _pageNub = 2;
    }return _pageNub;
}
-(void)getDataSuccess {
    //停止下拉刷新
    [self.tableView.mj_header endRefreshing];
    //停止上拉刷新
    [self.tableView.mj_footer endRefreshing];
    
    [self.dataArray addObjectsFromArray:[HSDataManger sharedHSDataManger].getDicData[@"pois"]];
    //判断字典中的数组和字符串
    NSArray *lastDataArray = [NSArray arrayWithArray:[HSDataManger sharedHSDataManger].getDicData[@"pois"]];
    if (lastDataArray.count == 0) {
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        [MBProgressHUD showSuccess:[NSString stringWithFormat:@"已加载完所有数据!总共有%lu条数据",(unsigned long)self.fixDataArray.count] toView:self.tableView];
        [self.tableView.mj_footer removeFromSuperview];
    }else {
        [self loadMoreDeal];
    }
    for (int i = 0; i < lastDataArray.count; i ++){
        NSDictionary *dataDic = lastDataArray[i];
        id tempObj = [dataDic objectForKey:@"tel"];
         NSString *str = [NSString stringWithFormat:@"%@",[tempObj class]];
        if ([str isEqualToString:@"__NSCFString"]) {
//            NSLog(@"%@",dataDic[@"tel"]);
                    NSString *telStr = [NSString stringWithFormat:@"%@",dataDic[@"tel"]];
                    if([telStr rangeOfString:@";"].location !=NSNotFound){
                        //如果电话字段内有多个电话号码
//                        NSRange range = [telStr rangeOfString:@";"];
                       NSString *telNum = [self segmentationStr:telStr];
                        NSLog(@"2:%@,返回分割电话\n%@",telStr,telNum);
                        //多个电话号码中有手机号码
                        if (![telNum isEqualToString:@""]) {
                            [self.fixDataArray addObject:[NSNumber numberWithInt:i+self.listNub]];
                        }
                    }else {
                        //电话字段内只有一个号码
                        NSLog(@"1:%@",telStr);
                        if ([[self getTelFirstNubWithTelNub:telStr] isEqualToString:telStr]) {
                            //add To ListArray
                            [self.fixDataArray addObject:[NSNumber numberWithInt:i+self.listNub]];
                        }
                    }
        }

    }
    self.listNub += (int)lastDataArray.count;
    [self.tableView reloadData];
//    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    if (self.fixDataArray.count == 0) {
        [MBProgressHUD showSuccess:@"查无数据!" toView:self.tableView];
    }
//    NSLog(@"获取数据成功%@",self.fixDataArray);
}
//储存查找出来的数据内容
- (IBAction)saveBtnClick:(UIBarButtonItem *)sender {
//    [self creatFile];
    NSString *contentStr = @"";
    NSString *contentStrNub = @"";
    for (int i = 0 ; i < self.fixDataArray.count; i ++) {
        NSNumber *indexNum = self.fixDataArray[i];
        NSInteger indexTer = [indexNum intValue];
       
        NSString *telStr = self.dataArray[indexTer][@"tel"];
        if (self.phoneNubOnlyState) {
            contentStrNub = [NSString stringWithFormat:@"%@",[self segmentationStr:telStr]];
        }else {
            contentStrNub = [NSString stringWithFormat:@"%@",telStr];
        }
        
        contentStr = [NSString stringWithFormat:@"%@\n%@:%@ ",contentStr,self.dataArray[indexTer][@"name"],contentStrNub];
    }
    [self writeFileWithContent:contentStr AndFileName:[NSString stringWithFormat:@"%@-%@.txt",self.localStr,self.keyWordStr]];
//    [self writeFileWithContent:contentStrNub AndFileName:[NSString stringWithFormat:@"%@-%@-Nub.txt",self.localStr,self.keyWordStr]];
}
- (NSString *)getDocumentsPath {
    //获取DocumentsPath路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths.firstObject;
    return path;
}
- (void)creatFile {
    NSString *documentsPath = [self getDocumentsPath];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.txt",self.localStr,self.keyWordStr]];
    BOOL isSuccess = [fileManger createFileAtPath:filePath contents:nil attributes:nil];
    if (isSuccess) {
//        [MBProgressHUD showSuccess:@"创建文件成功"];
        NSLog(@"FilePath:%@",filePath);
    }else {
        [MBProgressHUD showSuccess:@"创建文件失败"];
    }
}
- (void)writeFileWithContent:(NSString *)contents AndFileName:(NSString *)fileName {
    NSString *documentPath = [self getDocumentsPath];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    BOOL isSuccess = [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (isSuccess) {
        NSLog(@"writeSuccess");
        NSLog(@"FilePath:%@",filePath);
        [MBProgressHUD showSuccess:@"保存文件成功!"  toView:self.tableView];
    }else {
        NSLog(@"writefail");
    }
}
-(void)getDataFaild {
    //停止下拉刷新
    [self.tableView.mj_header endRefreshing];
    //停止上拉刷新
    [self.tableView.mj_footer endRefreshing];
    NSLog(@"获取数据失败");
}
//以";"分割字符 并返回手机号码
-(NSString *)segmentationStr:(NSString *)str
{
    NSArray *array = [str componentsSeparatedByString:@";"];
    NSMutableString *returnNum = [NSMutableString string];
    for (NSMutableString *telNum in array) {
        if ([self getTelFirstNubWithTelNub:telNum] == telNum){
        returnNum = [NSMutableString stringWithFormat:@"%@;%@",telNum,returnNum];
    }
    }
    return returnNum;
}
//返回手机号码 是手机号码返回手机号码 否则返回 空值
-(NSString *)getTelFirstNubWithTelNub:(NSString *)telNub {
    NSString *firtNub = [telNub substringToIndex:1];
    if ([firtNub isEqualToString:@"1"]) {
        return telNub;
    }else {
        if (self.phoneNubOnlyState) {
            return nil;
        } else {
            return telNub;
        }
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageNub = 0;
    [self getDataWithPage:1];
    [self AddRefreshControl];
    self.netManger = [HSDataManger sharedHSDataManger].netManger;
    self.netManger.getDataDelegate = self;
    [MBProgressHUD showMessage:@"正在加载..." toView:self.tableView];
    //声明重用
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    self.dataArray = [HSDataManger sharedHSDataManger].getDicData[@"pois"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
#pragma mark -- 和界面相关的方法
-(void)AddRefreshControl{
    //下拉刷新
//    self.tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDeal)];
    //执行刷新的动作
//    [self.tableView.mj_header beginRefreshing];
    //上拉加载
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDeal)];
    
}
- (void)loadNewDeal {
    //将计数计数改为0
    [self getDataWithPage:1];
    
}
- (void)loadMoreDeal {
    //将计数计数相加  数组也是相加
    [self getDataWithPage:self.pageNub ++];
    
}
- (void)getDataWithPage:(NSInteger)page {
    self.netManger = [HSNetManger new];
    self.netManger.getDataDelegate = self;
    [self.netManger getDataWithLocalWord:self.localStr andKeyWord:self.keyWordStr andPage:page];
    [HSDataManger sharedHSDataManger].netManger = self.netManger;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fixDataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSNumber *indexNum = self.fixDataArray[indexPath.row];
    NSInteger indexTer = [indexNum intValue];
    NSString *phoneNubStr = self.dataArray[indexTer][@"tel"];
    
    if (self.phoneNubOnlyState) {
      phoneNubStr = [self segmentationStr:phoneNubStr];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",self.dataArray[indexTer][@"name"],phoneNubStr];
//    cell.detailTextLabel.text = @"123";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *indexNum = self.fixDataArray[indexPath.row];
    NSInteger indexTer = [indexNum intValue];
    self.selectDicInDataArrayDic = self.dataArray[indexTer];
    [self performSegueWithIdentifier:@"showDetalView" sender:nil];
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HSDetalViewController *infoView = segue.destinationViewController;
    infoView.selectDataDic = self.selectDicInDataArrayDic;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
