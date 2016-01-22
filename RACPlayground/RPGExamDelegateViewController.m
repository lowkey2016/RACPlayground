//
//  RPGExamDelegateViewController.m
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import "RPGExamDelegateViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RPGExamDelegateViewController () <UITextFieldDelegate>

@property (nonatomic, strong) RACSignal *delegateSignal;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation RPGExamDelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameTextField.delegate = self;
    // 注意这里要为 self rac_signalxxx
    self.delegateSignal = [self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)];
    [_delegateSignal subscribeNext:^(RACTuple *tuple) {
        // 信号订阅晚于 delegate 调用
        NSLog(@"RAC UITextFieldDelegate Signal: tuple = %@", tuple);
    }];
    
    RACSignal *selectorSignal = [self rac_signalForSelector:@selector(test)];
    [selectorSignal subscribeNext:^(id x) {
        NSLog(@"RAC Selector Signal");
    }];
    [self performSelector:@selector(test) withObject:nil afterDelay:5];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%s", __FUNCTION__);
}

- (void)test {
    NSLog(@"test");
}

@end
