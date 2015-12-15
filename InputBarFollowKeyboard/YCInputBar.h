//
//  InputBar.h
//  InputBarFollowKeyboard
//
//  Created by CY on 26/1/15.
//  Copyright (c) 2015年 LINYC. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^endtextBlock)(UITextView *textEnum);
@class YCInputBar;

@protocol YCInputBarDelegate <NSObject>

@required
/**
 *  点击发送按钮后执行
 *
 *  @param textView 将当前文本框控件传给实现了委托方法的对象
 *
 *  @return 委托执行后返回一个BOOL值来决定是否要隐藏键盘，同时键盘隐藏后要做的事（执行WhenHide）
 */
-(BOOL)SendButtonClick:(UITextView*)textView;

@optional
//输入框隐藏的时候要做的事
-(void)WhenHide;

@end

@interface YCInputBar : NSObject<UITextViewDelegate>
/**
 *  初始化控件，默认隐藏在界面下方
 *
 *  @param mainView 要附加到的view
 *  @param title    按钮的文字
 *  @param length   限制最大输入长度
 *  @param placeholder 提示语句
 *  @param endtextBlock 确定按钮后执行的block
 *  @return 返回当前控件实例，
 */

//类方法 
+(void)initBar:(UIView*)mainView sendButtonTitle:(NSString*)title maxTextLength:(NSInteger)length andPlaceholder:(NSString *)placeholder andBlock:(endtextBlock)endtextBlock;



#pragma mark——————————————————以下方法已经在类方法中实现 不需要再实现.

//对象方法
-(YCInputBar*)initBar:(UIView*)mainView sendButtonTitle:(NSString*)title maxTextLength:(NSInteger)length andPlaceholder:(NSString *)placeholder andBlock:(endtextBlock)endtextBlock;

/**
 *  调用键盘
 */
-(void)ShowKeyboard;

/**
 *  由于目前只是隐藏键盘，实际上没有移除，还占用内存，所以当不需要的时候（比如pop掉当前界面时）调用此方法进行移除
 */
-(void)RemoveSelf;


@end
