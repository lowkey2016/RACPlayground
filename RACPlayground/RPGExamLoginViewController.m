//
//  RPGExamLoginViewController.m
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import "RPGExamLoginViewController.h"
#import "PRGExamSignInService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RPGExamLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) PRGExamSignInService *signInService;
@property (nonatomic, strong) RACSignal *validUsernameSignal;
@property (nonatomic, strong) RACSignal *validPasswordSignal;
@property (nonatomic, strong) RACSignal *signInSignal;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapInMainView;

@end

@implementation RPGExamLoginViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupMainView];
    [self setupSignals];
}

- (void)setupData {
    self.signInService = [PRGExamSignInService new];
}

- (void)setupMainView {
    _usernameTextField.delegate = self;
    _passwordTextField.delegate = self;
    self.errorLabel.hidden = YES;
}

- (void)setupSignals {
    
    /**
     *  1.
     */
    
    @weakify(self)
    
    self.validUsernameSignal =
    [_usernameTextField.rac_textSignal map:^id(NSString *text) {
        // 这里的 map 接收了 NSString 的输入，返回了一个 NSNumber 的输出
        // 就是一个映射操作
        @strongify(self)
        return @([self isValidUsername:text]);
    }];
    
    self.validPasswordSignal =
    [_passwordTextField.rac_textSignal map:^id(NSString *text) {
        @strongify(self)
        return @([self isValidPassword:text]);
    }];
    
    
    /**
     *  2.
     */
    
    // RAC宏允许直接把信号的输出应用到对象的属性上
    // RAC宏有两个参数，第一个是需要设置属性值的对象，第二个是属性名
    // 每次信号产生一个next事件，传递过来的值都会应用到该属性上
    RAC(_usernameTextField, backgroundColor) =
    [_validUsernameSignal map:^id(NSNumber *isValid) {
        return isValid.boolValue ? [UIColor clearColor] : [UIColor lightGrayColor];
    }];
    
    RAC(_passwordTextField, backgroundColor) =
    [_validPasswordSignal map:^id(NSNumber *isValid) {
        return isValid.boolValue ? [UIColor clearColor] : [UIColor lightGrayColor];
    }];
    
    
    /**
     *  3.
     */
    
    // combineLatest:reduce: 方法把 validUsernameSignal 和 validPasswordSignal 产生的最新的值聚合在一起，并生成一个新的信号
    // 每次这两个源信号的任何一个产生新值时，reduce block 都会执行，block 的返回值会发给下一个信号
    RACSignal *signInActiveSignal =
    [RACSignal combineLatest:@[_validUsernameSignal, _validPasswordSignal]
                      reduce:^id(NSNumber *isUsernameValid, NSNumber *isPasswordValid) {
                          return @(isUsernameValid.boolValue && isPasswordValid.boolValue);
                      }];
    [signInActiveSignal subscribeNext:^(NSNumber *signInActive) {
        _signinButton.enabled = signInActive.boolValue;
    }];
    
    self.signInSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        [self.signInService
         signInWithUsername:self.usernameTextField.text
         password:self.passwordTextField.text
         completionBlock:^(BOOL success) {
             [subscriber sendNext:@(success)];
             [subscriber sendCompleted];
         }];
        
        return nil;
    }];
    
    
    /**
     *  4.
     */
    
    [[[[_signinButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(id x) {
           // doNext: 触发信号后的下一步操作
           // 注意 doNext 并不会订阅信号，该信号还是冷信号
           @strongify(self)
           self.signinButton.enabled = NO;
           self.errorLabel.hidden = YES;
       }]
      flattenMap:^RACStream *(id value) {
          // flatternMap 根据传入的值 value 创建一个新的信号 newSignal
          // 后面该通道流出的值将由 newSignal 内部发出，如 sendNext / sendCompleted 等
          // 这里执行了从 oldSignal 到 newSignal 的 map ，但是二者并没有先后顺序关系，是平行的
          // 所以叫 flatternMap ，扁平化的 map
          // ref: http://mojijs.com/2015/06/197197/index.html
          @strongify(self)
          return self.signInSignal;
      }]
     subscribeNext:^(NSNumber *signInSucc) {
         @strongify(self)
         if (signInSucc.boolValue) {
             [self performSegueWithIdentifier:@"loginsucc" sender:self];
         }
         else {
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign In Fail" message:nil preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
             [alertController addAction:confirmAction];
             [self presentViewController:alertController animated:YES completion:nil];
             
             self.errorLabel.hidden = NO;
         }
     }];
    
    
    /**
     *  5.
     */
    
    [_tapInMainView.rac_gestureSignal subscribeNext:^(id x) {
        @strongify(self)
        
        [self.usernameTextField endEditing:YES];
        [self.passwordTextField endEditing:YES];
    }];
    
    RACSignal *returnSignalForTextField = [self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)];
    [returnSignalForTextField subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        
        UITextField *textfield = tuple.first;
        if (textfield == self.usernameTextField) {
            [self.usernameTextField resignFirstResponder];
            [self.passwordTextField becomeFirstResponder];
        }
        else if (textfield == self.passwordTextField) {
            [self.passwordTextField resignFirstResponder];
#warning - TODO 调用登录操作
        }
    }];
}

#pragma mark - Common Methods

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

@end
