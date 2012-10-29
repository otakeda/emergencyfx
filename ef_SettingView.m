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
    // Pickerのデフォルト値
    [self.pikerFrom selectRow:9 inComponent:0 animated:YES];
    [self.pikerFrom selectRow:8 inComponent:1 animated:YES];
    
    //メッセージを一番上にもってくる
    [self.view bringSubviewToFront:self.txtMsg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClose:(id)sender {
    // 画面close
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidUnload {
    
    [self setPikerFrom:nil];
    [self setTxtMsg:nil];
    [super viewDidUnload];
}

// ピッカービューのコンポーネント(列)の数を返す
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}
// ピッカービューの行の数を返す
- (NSInteger) pickerView: (UIPickerView*)pView numberOfRowsInComponent:(NSInteger) component {
    
    return 12;
}
// ピッカービューの行のタイトルを返す
- (NSString*)pickerView: (UIPickerView*) pView titleForRow:(NSInteger) row forComponent:(NSInteger)component {
    
    switch (component) {
        case 0: return [NSString stringWithFormat:@" %0d:00", row];
        case 1: return [NSString stringWithFormat:@" %0d:00", row+12];
    }
    return @"";
}

@end
