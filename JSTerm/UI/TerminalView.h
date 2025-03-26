//
//  TerminalView.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef JSKERN_TERMINALVIEW
#define JSKERN_TERMINALVIEW

#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"
#import "../JSKern/Machine.h"

@interface TerminalLCD : UITextView <UITextViewDelegate>

@property (nonatomic, readonly) UInt64 id;
@property (nonatomic) BOOL cursorHidden;
@property (nonatomic, copy) void (^input)(NSString *input, TerminalLCD *tlcd);
@property (nonatomic, copy) void (^deletion)(NSString *input, TerminalLCD *tlcd);
@property (nonatomic, copy) void (^refreshColor)(UIColor *color, TerminalLCD *tlcd);

- (instancetype)init;

- (void)setInput:(void (^)(NSString *input, TerminalLCD *tlcd))input;
- (void)setDeletion:(void (^)(NSString *input, TerminalLCD *tlcd))deletion;
- (void)setRefreshColor:(void (^)(UIColor *color, TerminalLCD *tlcd))refreshColor;

- (void)didMoveToWindow;

@end

@interface TerminalView : UIView

@property (nonatomic, strong) TerminalLCD *terminalText;
@property (nonatomic, strong) UILabel *display;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) NSString *capturedInput;
@property (nonatomic, strong) Machine *machine;

// serials
@property (nonatomic, strong) NSMutableArray<TerminalLCD *> *serials;

- (void)setupView;

/*
 @Brief crutial functions to find, get and remove and append serials
 */
- (void)appendSerial:(TerminalLCD*)tlcd;
- (NSInteger)findSerial:(TerminalLCD*)tlcd;
- (void)removeSerial:(TerminalLCD*)tlcd;
- (TerminalLCD*)getSerial:(NSInteger)index;
- (void)osprint:(NSString*)msg;
- (TerminalLCD*)spawnSerial;

- (void)handleLeft;
- (void)handleRight;

@end

#endif


