//
//  InputBar.m
//  InputBarFollowKeyboard
//
//  Created by CY on 26/1/15.
//  Copyright (c) 2015年 LINYC. All rights reserved.
//

#import "YCInputBar.h"
#import "UITextViewPlaceholder.h"
#define screenRect [UIScreen mainScreen].bounds


@implementation YCInputBar{
    /**
     *  附加在键盘上方的view
     */
    UIView *_viewInputBar;
    /**
     *  输入框
     */
    UITextViewPlaceholder *_txtInput;
    /**
     *  最大能输入的字符长度
     */
    NSInteger _maxLength;
    /**
     *  覆盖整个屏幕
     */
    UIView *_bgView;
    /**
     *  附加到bgView上面的按钮（frame和bgView一样），用来当用户点击bar的其他部分时收起键盘
     */
    UIButton *_hideBtn;
    /**
     *  保存键盘的y坐标
     */
    CGFloat _keyboardOriginY;
    /**
     *  send按钮
     */
    UIButton *_btnReply;
    /**
     *  要附加到的目标view
     */
    UIView *_mainView;
}


-(YCInputBar*)initBar:(UIView *)mainView sendButtonTitle:(NSString *)title maxTextLength:(NSInteger)length
{
    if (self = [super init]) {
        
        _mainView = mainView;
        _maxLength = length;
        
        //frame隐藏在屏幕下方
        _viewInputBar = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, 44)];
        _viewInputBar.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        
        _txtInput = [[UITextViewPlaceholder alloc]  initWithFrame:CGRectMake(8, 8, _viewInputBar.bounds.size.width-70, 28)];
        _txtInput.backgroundColor = [UIColor whiteColor];
        //设置该属性，让输入框随父view的尺寸改变而改变
        _txtInput.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        //边框圆角
        _txtInput.layer.cornerRadius = 5;
        _txtInput.layer.borderWidth = 0.8;
        _txtInput.layer.borderColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor];
        _txtInput.delegate=self;
        [_viewInputBar addSubview:_txtInput];
        
        _btnReply = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnReply.frame = CGRectMake(CGRectGetMaxX(_txtInput.frame)+8, 8, 46, 28);
        [_btnReply setTitle:title?title:@"发送" forState:UIControlStateNormal];
        _btnReply.enabled=NO;
        [_btnReply addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_viewInputBar addSubview:_btnReply];
        
        [mainView addSubview:_viewInputBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
#pragma mark - public function
-(void)ShowKeyboard
{
    [_txtInput becomeFirstResponder];
    [self textView:_txtInput shouldChangeTextInRange:NSRangeFromString(_txtInput.text) replacementText:_txtInput.text];
}
-(void)RemoveSelf
{
    [_viewInputBar removeFromSuperview];
    _viewInputBar = nil;
}
#pragma mark - private function
-(void)sendBtnClick
{
    //主view那边判断完再隐藏键盘
    BOOL b = [self.delegate SendButtonClick:_txtInput];
    if (b) {
        //        [self.txtInput resignFirstResponder];
        [self hideBtnClick];
        
        _txtInput.text = nil;
        
        _viewInputBar.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, 44);
        
    }
}
-(void)hideBtnClick
{
    [_txtInput resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(WhenHide)]) {
        [self.delegate WhenHide];
    }
}
#pragma mark - textView delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (newString.length > _maxLength) {
        return NO;
    }
    _btnReply.enabled = newString.length > 0;
    //没有输入时显示placeholder文本
    _txtInput.hidePlaceholderView = newString.length > 0;
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    //让textview随行数自动改变自身的高度
    CGSize txtViewsize = _txtInput.contentSize;
    if (txtViewsize.height >= 90) {
        return;
    }
    //如果第一行就改变高度 会使textView的高度变小 造成字体下沉。 我的设备时ios9 iphone5 所以我判断了在第二行才改变高度 
        if(txtViewsize.height>28)
    {
        CGRect barRect = _viewInputBar.frame;
        barRect.size.height = txtViewsize.height + 15;
        barRect.origin.y = _keyboardOriginY - barRect.size.height;
        _viewInputBar.frame = barRect;
    }
}
#pragma mark - keyboard notification
-(void)keyboardShow:(NSNotification*)notification
{
    NSDictionary *userinfos = [notification userInfo];
    NSValue *val = [userinfos objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect kbRect = [val CGRectValue];
    
    if (_bgView == nil) {
        
        _bgView = [[UIView alloc] initWithFrame:screenRect];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0;
        
        _hideBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _hideBtn.frame = _bgView.frame;
        _hideBtn.backgroundColor = [UIColor clearColor];
        [_hideBtn addTarget:self action:@selector(hideBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_hideBtn];
        
        [_mainView addSubview:_bgView];
        [_mainView bringSubviewToFront:_viewInputBar];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.hidden = NO;
        _bgView.alpha = 0.2;
    }];
    
    CGRect inputRect = _viewInputBar.frame;
    inputRect.origin.y = CGRectGetMinY(kbRect)-inputRect.size.height;
    [_viewInputBar setFrame:inputRect];
    
    _keyboardOriginY = kbRect.origin.y;
}
-(void)keyboardHide:(NSNotification*)notification
{
    
    NSDictionary *userinfos = [notification userInfo];
    NSValue *val = [userinfos objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect kbRect = [val CGRectValue];
    
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.alpha = 0;
        _bgView.hidden = YES;
    }];
    
    CGRect inputRect = _viewInputBar.frame;
    inputRect.origin.y = CGRectGetMinY(kbRect);
    [_viewInputBar setFrame:inputRect];
}

#pragma mark - setPropery
-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _txtInput.placeholder = placeholder;
}
#pragma mark -
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
