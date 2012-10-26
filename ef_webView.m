//
//  ef_webView.m
//  emergencyfx
//
//  Created by otakeda on 2012/10/24.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import "ef_webView.h"

@interface ef_webView ()

@end

@implementation ef_webView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setIndicator1:nil];
    [super viewDidUnload];
}
//画面の上の小さいindicator
-(void)webViewDidStartLoad:(UIWebView*)webView{
//    webView.hidden=YES;
//    [self.view sendSubviewToBack:webView];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelectorInBackground:@selector(indicatorStart) withObject:nil];
    [NSThread sleepForTimeInterval:3.0];
}

// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self performSelectorInBackground:@selector(indicatorStop) withObject:nil];
    //[self.view bringSubviewToFront:webView];
    //webView.hidden=NO;
}

- (void) indicatorStart{
    [self.view bringSubviewToFront:self.indicator1];
    [self.indicator1 startAnimating];
    

}
- (void) indicatorStop{
    [self.indicator1 stopAnimating];
    [self.view sendSubviewToBack:self.indicator1 ];
}
- (IBAction)btnClose:(id)sender {
      [self dismissViewControllerAnimated:YES completion:nil];
}
@end
