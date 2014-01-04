//
//  YWEViewController.h
//  YYWebWorkerExample
//
//  Created by Yoppy Yunhasnawa on 1/4/14.
//  Copyright (c) 2014 Yoppy Yunhasnawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYWebWorkerDelegate.h"

@interface YWEViewController : UIViewController<UITextFieldDelegate, YYWebWorkerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSync;
@property (strong, nonatomic) IBOutlet UIButton *btnAsync;
@property (strong, nonatomic) IBOutlet UITextView *txvResponse;
@property (strong, nonatomic) IBOutlet UISwitch *swcPost;
@property (strong, nonatomic) IBOutlet UILabel *lblPost;
@property (strong, nonatomic) IBOutlet UILabel *lblGet;

- (IBAction)onBtnSync_TouchUpInside:(id)sender;
- (IBAction)onBtnAsync_TouchUpInside:(id)sender;
- (IBAction)onSwcPost_ValueChanged:(id)sender;

@end
