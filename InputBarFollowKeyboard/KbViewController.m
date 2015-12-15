//
//  ViewController.m
//  InputBarFollowKeyboard
//
//  Created by CY on 26/1/15.
//  Copyright (c) 2015年 LINYC. All rights reserved.
//

#import "KbViewController.h"
#import "YCInputBar.h"

@interface KbViewController ()

@end

@implementation KbViewController

- (void)viewDidLoad {
    [super viewDidLoad];



}

-(void)viewWillDisappear:(BOOL)animated{
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)kbAction:(id)sender {
  
    [YCInputBar initBar:self.view sendButtonTitle:@"发表" maxTextLength:500 andPlaceholder:@"说点啥" andBlock:^(UITextView *textEnum) {
        
        NSLog(@"%@",textEnum.text);
        
    }];
}
#pragma mark - YCBar delegate
-(BOOL)SendButtonClick:(UITextView *)textView
{
    if (textView.text.length == 0 && ![textView.text containsString:@"\n"]) {
        return NO;
    }
    return YES;
}
-(void)WhenHide
{
    //do something...
}

@end
