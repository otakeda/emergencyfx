//
//  ef_ViewController.h
//  emergencyfx
//
//  Created by otakeda on 2012/10/22.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ef_ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UITextView *txt4Debug;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnReload;
- (IBAction)btnReloaddo:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *webIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
- (int)getWarnCount;
- (void)updateData;
@end

NSArray *defaultList;      //初期表示および表示順の設定のため
NSArray *descList;      // 画面表示
NSArray *gotList;       //jsonデータを入れておく（キー）
//    NSArray *gotValue;
NSMutableData *receivedData;
NSDictionary *json_set;
