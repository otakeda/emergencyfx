//
//  ef_ViewController.h
//  emergencyfx
//
//  Created by otakeda on 2012/10/22.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ef_ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;  //更新日とか更新ボタン直下に表示
@property (weak, nonatomic) IBOutlet UITextView *txt4Debug;  // 隠してるデバッグ用テキスト
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnReload;  //更新ボタン
- (IBAction)btnReloaddo:(id)sender;  //更新ボタン押した
@property (weak, nonatomic) IBOutlet UIImageView *topImage;  //背景画像

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *webIndicator;  //真ん中のくるくる
@property (weak, nonatomic) IBOutlet UITableView *tblView;  // table
- (int)getWarnCount;  //警告数のカウント delegateから呼ぶ
- (void)updateData;   //サーバから最新JSONデータとってくる
@end

NSArray *defaultList;      //初期表示および表示順の設定のため
NSArray *descList;      // 画面表示
NSArray *gotList;       //jsonデータを入れておく（キー）
//    NSArray *gotValue;
NSMutableData *receivedData;
NSDictionary *json_set;
