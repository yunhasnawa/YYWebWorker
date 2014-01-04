//
//  YWEViewController.m
//  YYWebWorkerExample
//
//  Created by Yoppy Yunhasnawa on 1/4/14.
//  Copyright (c) 2014 Yoppy Yunhasnawa. All rights reserved.
//

#import "YWEViewController.h"
#import "YYWebWorker.h"

@interface YWEViewController ()

- (NSString*) username;
- (NSString*) password;
- (BOOL) isPOST;
- (void) sendSyncRequest;
- (void) sendAsyncRequest;
- (void) showResponse:(NSDictionary*) response;

@end

@implementation YWEViewController

NSString* const kURL = @"http://yunhasnawa.com/api/login.php";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set labels color for initial launch
    [[self lblPost] setTextColor:[UIColor greenColor]];
    [[self lblGet] setTextColor:[UIColor grayColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web request

- (void) sendSyncRequest
{
    YYWebRequestMethod method = [self isPOST] ? YYWebRequestMethodPOST : YYWebRequestMethodGET;
    
    NSDictionary* data = @{@"username":[self username], @"password":[self password]};
    
    NSDictionary* response;
    
    if(method == YYWebRequestMethodPOST)
    {
        response = [YYWebWorker sendPOSTSynchronousToURLString:kURL data:data];
    }
    else
    {
        response = [YYWebWorker sendGETSynchronousToURLString:kURL data:data];
    }
    
    // Show response to textView;
    
    self.txvResponse.text = [response description];
}

- (void) sendAsyncRequest
{
    YYWebRequestMethod method = [self isPOST] ? YYWebRequestMethodPOST : YYWebRequestMethodGET;
    
    NSDictionary* data = @{@"username":[self username], @"password":[self password]};
    
    if(method == YYWebRequestMethodPOST)
    {
        [YYWebWorker sendPOSTAsynchronousToURLString:kURL data:data delegateOrNil:self];
    }
    else
    {
        [YYWebWorker sendGETAsynchronousToURLString:kURL data:data delegateOrNil:self];
    }
}

#pragma mark - YYWebWorker delegate

- (void) webWorker:(YYWebWorker *)web didFinishReceivingAsynchronousResponseWithResult:(YYWebAsynchronousRequestResult)result error:(NSError *)error
{
    if(result == YYWebAsynchronousRequestResultOK)
    {
        // Get response
        
        NSDictionary* response = [web responseDictionaryFromJSON];
        
        // Show response to textView;
        [self showResponse:response];
    }
}

#pragma mark - Helper

- (BOOL) isPOST
{
    return [[self swcPost] isOn];
}

- (NSString*) username
{
    return [[self txtUsername] text];
}

- (NSString*) password
{
    return [[self txtPassword] text];
}

- (void) showResponse:(NSDictionary*) response
{
    NSString* text = [response description];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.txvResponse.text = text;
    });
}

#pragma mark - Actions

- (IBAction)onBtnSync_TouchUpInside:(id)sender
{
    [[self txvResponse] setText:@""];
    
    [self sendSyncRequest];
}

- (IBAction)onBtnAsync_TouchUpInside:(id)sender
{
    [[self txvResponse] setText:@""];
    
    [self sendAsyncRequest];
}

- (IBAction)onSwcPost_ValueChanged:(id)sender
{
    if([[self swcPost] isOn])
    {
        [[self lblPost] setTextColor:[UIColor greenColor]];
        [[self lblGet] setTextColor:[UIColor grayColor]];
    }
    else
    {
        [[self lblGet] setTextColor:[UIColor greenColor]];
        [[self lblPost] setTextColor:[UIColor grayColor]];
    }
}

#pragma mark - Text field delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
