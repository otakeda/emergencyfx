//
//  ef_SettingView.m
//  emergencyfx
//
//  Created by otakeda on 2012/10/26.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import "ef_SettingView.h"

@interface ef_SettingView ()

@end

@implementation ef_SettingView

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

- (IBAction)btnClose:(id)sender {
 [self dismissViewControllerAnimated:YES completion:nil];
}
@end
