//
//  ef_webView.h
//  emergencyfx
//
//  Created by otakeda on 2012/10/24.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ef_webView : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)btnClose:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator1;
//- (void) indicatorStart;
//- (void) indicatorEnd;
@end

