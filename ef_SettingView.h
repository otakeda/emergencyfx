//
//  ef_SettingView.h
//  emergencyfx
//
//  Created by otakeda on 2012/10/26.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ef_SettingView : UIViewController <UIPickerViewDelegate>
- (IBAction)btnClose:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *pikerFrom;
@property (weak, nonatomic) IBOutlet UITextView *txtMsg;


@end
