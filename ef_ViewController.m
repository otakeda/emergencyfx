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
    ef_AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
   appDelegate.viewController = self;
    
    [self.view sendSubviewToBack:self.topImage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnReloaddo:(id)sender {
    [self updateData];
    
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
    
    UIAlertView *alertView
    = [[UIAlertView alloc] initWithTitle:nil
                                 message:@"受信データエラー"
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
    
    //    NSDictionary
    json_set = [parser objectWithString:html error:&error];
    if(!json_set){
        NSLog(@"%@",[error description]);
        [alertView show];
        self.lblStatus.text = @"受信データエラー";
    }else{
        NSLog(@"%@",[json_set description]);
        // 受信したデータをUITextViewに表示する。
        self.txt4Debug.text = html;
        self.lblStatus.text = @"OK";
        [self.tblView reloadData];    //バックグラウンドのときはこの先にいってない
    }
    [self performSelectorInBackground:@selector(indicatorStop) withObject:nil];
    
//    [html release];
//    [parser release];
//    [alertView release];
    
}

- (NSInteger)numberOfSections {
    return 1; // セクションは1個とします
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"1時間足／２４時間平均";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"BB２σライン超えると自動で通知";
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
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //	UITableViewCell *cell;
    NSString *cur_name = [defaultList objectAtIndex:indexPath.row];
    //	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cur_name] autorelease];
    NSLog(@"cur_name:%@",cur_name);
    
    // セルを再利用するためのコード
    UITableViewCell *cell = [self.tblView dequeueReusableCellWithIdentifier:cur_name];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cur_name];
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
                cell.imageView.image =[UIImage imageNamed:@"up1.png"];
                //                cell.detailTextLabel.text = @" ↑";
                break;
            case 2:
                cell.textLabel.textColor = [UIColor redColor];
                //                cell.detailTextLabel.text = @" ↑↑";
                cell.imageView.image =[UIImage imageNamed:@"up2.png"];
                break;
            case 3:
                cell.textLabel.textColor = [UIColor magentaColor];
                //                cell.detailTextLabel.text = @" ↑↑↑";
                cell.imageView.image =[UIImage imageNamed:@"up3.png"];
                break;
            case -1:
                cell.textLabel.textColor = [UIColor yellowColor];
                cell.imageView.image = nil;
                cell.imageView.image =[UIImage imageNamed:@"down1.png"];
                
                break;
            case -2:
                cell.textLabel.textColor = [UIColor redColor];
                //                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" ↓"];
                //                cell.detailTextLabel.text = @" ↓↓";
                cell.imageView.image =[UIImage imageNamed:@"down2.png"];
                break;
            case -3:
                cell.textLabel.textColor = [UIColor magentaColor];
                //                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" ↓"];
                //                cell.detailTextLabel.text = @" ↓↓↓";
                cell.imageView.image =[UIImage imageNamed:@"down3.png"];
                break;
            default:
                //                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" "];
                //                cell.detailTextLabel.text = cur_name;
                cell.textLabel.textColor = [UIColor blackColor];
                cell.imageView.image =[UIImage imageNamed:@"none.png"];
//                cell.detailTextLabel.text = @"000000000";

                
                //    warnCount++;
                
                
        }
    }
    else
    {
//        cell.textLabel.text = [defaultList objectAtIndex: indexPath.row];
        cell.textLabel.text = [descList objectAtIndex: indexPath.row];
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
    
    webPage.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

//    [self presentModalViewController:webPage animated:YES ];
    [self presentViewController:webPage animated:YES completion:nil];

    
    webPage.webView.hidden=NO;
    NSString *urls = [[NSString alloc] initWithFormat:@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row] ];
    
    NSLog(@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row]);
    //    webView.backgroundColor = [UIColor clearColor]; // お好みに応じて
//    webView.scalesPageToFit = YES; // お好みに応じて
    [webPage.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];

    
    
            /*
    
    
    [self.view bringSubviewToFront:webView];
    webView.hidden=NO;
    NSString *urls = [[NSString alloc] initWithFormat:@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row] ];
    
    NSLog(@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row]);
    //    webView.backgroundColor = [UIColor clearColor]; // お好みに応じて
    webView.scalesPageToFit = YES; // お好みに応じて
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];
    
    btnClose.hidden=NO;
    [self.view bringSubviewToFront:btnClose];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //すぐに非選択状態にする
    */
}
 


@end
