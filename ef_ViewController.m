//
//  ef_ViewController.m
//  emergencyfx
//
//  Created by otakeda on 2012/10/22.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import "ef_ViewController.h"
#import "../Classes/SBJson.h"
#import "ef_AppDelegate.h"
#import "ef_webView.h"
#import "ef_Cell.h"

@interface ef_ViewController ()

@end

@implementation ef_ViewController

- (void)viewDidUnload {
    [self setLblStatus:nil];
    [self setTxt4Debug:nil];
    [self setBtnReload:nil];
    [self setWebIndicator:nil];
    [self setTblView:nil];
    [self setTopImage:nil];
    [super viewDidUnload];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //delegateからViewController内のメソッド呼ぶため
    ef_AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.viewController = self;
    
    //top画像のはみ出た部分を下に
    [self.view sendSubviewToBack:self.topImage];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnReloaddo:(id)sender {
    [self updateData];
    
    //通知判定へ。
    ef_AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];    
    [appDelegate determineNotif];
}



///////////ここからメイン
- (int)getWarnCount{
    
    int warnCount=0;
    if (!json_set) return 0;
    
    for (id key in json_set){
        int val = [[json_set objectForKey:key] intValue];
        if ((val > 1)||(val<-1)) warnCount++;
    }
    return warnCount;
}


- (void) indicatorStart{
    [self.view bringSubviewToFront:self.webIndicator];
    [self.webIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}
- (void) indicatorStop{
    [self.webIndicator stopAnimating];
    [self.view sendSubviewToBack:self.webIndicator ];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
- (void)updateData{
    
    [self performSelectorInBackground:@selector(indicatorStart) withObject:nil];
    
    //リロード連打防止で１秒スリープ
    [NSThread sleepForTimeInterval:1.0];
    
    self.txt4Debug.text=nil;
    // 送信したいURLを作成し、Requestを作成します。
    NSURL *url = [NSURL URLWithString:@"http://leanprojectman.com/php/n3/fxjson.php"];
    NSURLRequest  *request = [[NSURLRequest alloc] initWithURL:url];
    
    // NSURLConnectionのインスタンスを作成したら、すぐに
    // 指定したURLへリクエストを送信し始めます。
    // delegate指定すると、サーバーからデータを受信したり、
    // エラーが発生したりするとメソッドが呼び出される。
    NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // 作成に失敗する場合には、リクエストが送信されないので
    // チェックする
    if (!aConnection) {
        NSLog(@"connection error.");
        UIAlertView *alertView
        = [[UIAlertView alloc] initWithTitle:nil
                                     message:@"通信エラー"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [alertView show];
//        [alertView release];
    }else
        NSLog(@"succeed to create connection ");
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response {
    
    // receiveDataはフィールド変数
    receivedData = [[NSMutableData alloc] init];
}
// データ受信したら何度も呼び出されるメソッド。
// 受信したデータをreceivedDataに追加する
- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error{
    NSLog(@"Connection failed! Error - %@ %d %@",
          [error domain],
          [error code],
          [error localizedDescription]);
    self.txt4Debug.text = @"ネットワークに接続できません";
    self.lblStatus.text = @"ネットワークに接続できません";
    [self performSelectorInBackground:@selector(indicatorStop) withObject:nil];
    
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html=
    [[NSString alloc] initWithBytes:receivedData.bytes
                             length:receivedData.length
                           encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSError *error;
    
    // 受信したデータをUITextViewに表示する。
    self.txt4Debug.text = html;
    // JSON形式のデータをDictionary型にセット
    json_set = [parser objectWithString:html error:&error];
    if(!json_set){
        NSLog(@"受信データエラー: %@",[error description]);
        UIAlertView *alertView
        = [[UIAlertView alloc] initWithTitle:nil
                                     message:@"受信データエラー"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [alertView show];
        self.lblStatus.text = @"受信データエラー";
    }else{
        NSLog(@"%@",[json_set description]);

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
        [dateFormatter setLocale:locale];
        
        NSDate *date = [NSDate date];
        
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        NSLog(@"Current Time: %@", formattedDateString);
        
        self.lblStatus.text = [@"update:" stringByAppendingString:formattedDateString];
        [self.tblView reloadData];    //バックグラウンドのときはこの先にいってない
    }
    [self performSelectorInBackground:@selector(indicatorStop) withObject:nil];
}

- (NSInteger)numberOfSections {
    return 1; // セクションは1個とします
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"1時間足／24時間平均";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"BB２σライン超えると自動通知";
}
// 最初の１回しかよばれなさそう
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cnt;
    if (json_set){
        cnt = [json_set count];
    }
    else
    {
        if (!defaultList)
            defaultList = [[NSArray alloc] initWithObjects:
                           @"USDJPY", @"EURJPY", @"EURUSD", @"AUDJPY",
                           @"GBPJPY", @"NZDJPY", @"CADJPY", @"CHFJPY",@"GBPUSD",@"USDCHF",
                           nil];
        descList = [[NSArray alloc] initWithObjects:
                                @"USD/JPY",@"EUR/JPY", @"EUR/USD", @"AUD/JPY", @"GBP/JPY", @"NZD/JPY",
                                @"CAD/JPY", @"CHF/JPY", @"GBP/USD", @"USD/CHF",nil];
        cnt= [defaultList count];
    }
	return cnt;
}
//
//  tableView:cellForRowAtIndexPath
//    CellにNSArrayに登録されている文字列を設定
//    本メソッドは、UITableViewDataSourceプロトコルを採用しているのでコールされる。
//  スクロールして見えたときにも随時呼ばれるので注意！！
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cur_name = [defaultList objectAtIndex:indexPath.row];
    NSLog(@"%s : cur_name:%@", __PRETTY_FUNCTION__,cur_name);
    
    // セルを再利用するためのコード
//    UITableViewCell *cell = [self.tblView dequeueReusableCellWithIdentifier:cur_name];
    ef_Cell *cell = [self.tblView dequeueReusableCellWithIdentifier:cur_name];
    NSString *img_name= [[NSString alloc] initWithFormat:@"%@.png",cur_name];

    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cur_name];
        cell = [[ef_Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cur_name];
    }
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.detailTextLabel.hidden=NO;
    cell.detailTextLabel.textColor=[UIColor redColor];
    cell.detailTextLabel.textAlignment=UITextAlignmentRight;
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (json_set)
    {
        cell.textLabel.text = [descList objectAtIndex: indexPath.row];
        
        int val = [[json_set objectForKey:cur_name] intValue];
        
        gotList = [json_set allKeys];
        //        gotValue = [json_set allValues];
        switch (val){
            case 1:
                cell.textLabel.textColor = [UIColor yellowColor];
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @"⬆";
                break;
            case 2:
                cell.textLabel.textColor = [UIColor redColor];
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @"⬆⬆";
                break;
            case 3:
                cell.textLabel.textColor = [UIColor magentaColor];
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @"⬆⬆⬆";
                break;
            case -1:
                cell.textLabel.textColor = [UIColor yellowColor];
                cell.imageView.image = nil;
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @"⬇";
                
                break;
            case -2:
                cell.textLabel.textColor = [UIColor redColor];
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @"⬇⬇";
                break;
            case -3:
                cell.textLabel.textColor = [UIColor magentaColor];
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @"⬇⬇⬇";
                break;
            default:
                //                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" "];
                //                cell.detailTextLabel.text = cur_name;
                cell.textLabel.textColor = [UIColor blackColor];
                cell.imageView.image =[UIImage imageNamed:img_name];
                cell.detailTextLabel.text = @" ";

                
                //    warnCount++;
                
                
        }
    }
    else
    {
//        cell.textLabel.text = [defaultList objectAtIndex: indexPath.row];
        cell.textLabel.text = [descList objectAtIndex: indexPath.row];
        cell.imageView.image =[UIImage imageNamed:@"none.png"];

    }
	return cell;
}
//
//  tableView:didSelectRowAtIndexPath
//    選択されたCellの文字列をToolBarにあるLabelにセットし表示する。
//    本メソッドは、UITableViewDelegateプロトコルを採用しているのでコールされる。
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    ef_webView *webPage = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
    
    //画面遷移時の動き
    webPage.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    [self presentViewController:webPage animated:YES completion:nil];
    
    webPage.webView.hidden=NO;
    NSString *urls = [[NSString alloc] initWithFormat:@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row] ];
    
NSLog(@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row]);
//    webView.backgroundColor = [UIColor clearColor]; // お好みに応じて
//    webView.scalesPageToFit = YES; // お好みに応じて
    [webPage.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];

}
 


@end
