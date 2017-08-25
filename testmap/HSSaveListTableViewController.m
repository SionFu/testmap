//
//  HSSaveListTableViewController.m
//  testmap
//
//  Created by Fu_sion on 6/25/17.
//  Copyright © 2017 Fu_sion. All rights reserved.
//

#import "HSSaveListTableViewController.h"
#import "JHFileManger.h"
#import <QuickLook/QuickLook.h>
@interface HSSaveListTableViewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>
@property (nonatomic ,strong) NSMutableArray *contentArray;
@end

@implementation HSSaveListTableViewController

- (IBAction)editBtnClick:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"取消"]) {
        //  直接发送选中内容
        self.tableView.editing = NO;
        sender.title = @"编辑";
        self.navigationController.toolbar.hidden = YES;
        
    }else {
        
        //开启编辑模式
        self.tableView.editing = YES;
        self.navigationController.toolbar.hidden = NO;
        sender.title = @"取消";
    }
    
}
//选中所有项目
- (IBAction)selectAllItem:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"全选"]) {
        sender.title = @"反选";
        for (int i = 0; i < self.contentArray.count; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
    }else {
        sender.title = @"全选";
        for (int i = 0; i < self.contentArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}
//发送选中的项目
- (IBAction)sendSelectedItem:(UIBarButtonItem *)sender {
    
}
//删除选中的项目
- (IBAction)delSelectedItem:(UIBarButtonItem *)sender {
   NSArray *selectArray = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *selectData = [NSMutableArray new];
    
    for (NSIndexPath *indexPath in selectArray) {
        [selectData addObject:self.contentArray[indexPath.row]];
        //删除数据
        NSFileManager *manger = [NSFileManager defaultManager];
        NSString *filePath = self.contentArray[indexPath.row][@"filePath"];
        BOOL isSuccess = [manger removeItemAtPath:filePath error:nil];
        if (isSuccess) {
            NSLog(@"delete success");
        }else{
            NSLog(@"delete fail");
        }
        
        
    }
//    for (NSIndexPath *indexPath in selectArray) {
//        //删除视图数据
////        [self.contentArray removeObjectAtIndex:indexPath.row];
//    }
    //删除文件
    [self delFileWihtSelectWithArray:selectData];
    
    //删除视图cell
    [self.tableView deleteRowsAtIndexPaths:selectArray withRowAnimation:UITableViewRowAnimationAutomatic];


}
//删除文件
-(void)delFileWihtSelectWithArray:(NSArray *)fileArray {
     NSString *documentsPath =[self getDocumentsPath];
    NSFileManager *manger = [NSFileManager defaultManager];
    for (NSDictionary *fileName in fileArray) {
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName[@"title"]];
        BOOL isSuccess = [manger removeItemAtPath:filePath error:nil];
        if (isSuccess) {
            NSLog(@"delete success");
        }else{
            NSLog(@"delete fail");
        }
        
    }
}

#pragma mark - quicklook
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.contentArray[index][@"filePath"]];
}


-(NSString *)getDocumentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}
-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置表格可以多选
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    NSArray *filePathArray = [[JHFileManger new] showAllFile];
    self.contentArray = [NSMutableArray arrayWithArray:filePathArray];
  
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 200;
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

    return self.contentArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"saveCell" forIndexPath:indexPath];
    cell.textLabel.text = self.contentArray[indexPath.row][@"title"];
    // Configure the cell...
    
    return cell;
}

#pragma Mark didselect
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QLPreviewController *ql = [[QLPreviewController alloc]initWithNibName:nil bundle:nil];
    ql.navigationController.navigationBarHidden = YES;
    // Set data source
    ql.dataSource = self;
    ql.delegate = self;
    // Which item to preview
    [ql setCurrentPreviewItemIndex:indexPath.row];
    
    //    UINavigationController  *navigationController = [[UINavigationController alloc]initWithRootViewController:ql];
    // Push new viewcontroller, previewing the document
     self.navigationController.toolbar.hidden = YES;
    [self.navigationController pushViewController:ql animated:YES];
   
    
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
