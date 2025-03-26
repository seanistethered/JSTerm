//
//  TerminalView.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "TerminalView.h"
#import "MakeUUID.h"
#import "../JSKern/Handoff.h"

void jskern_kickstart(TerminalView *tcontroller);

@implementation TerminalLCD

- (instancetype)init
{
    self = [super init];
    _id = generateUInt64UUID();
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor blackColor];
    self.textColor = [UIColor whiteColor];
    self.tintColor = [UIColor whiteColor];
    [self setEditable:TRUE];
    self.font = [UIFont monospacedSystemFontOfSize:15.0 weight:UIFontWeightSemibold];
    self.keyboardType = UIKeyboardTypeASCIICapable;
    self.textContentType = nil;
    self.smartQuotesType = NO;
    self.smartDashesType = NO;
    self.smartInsertDeleteType = NO;
    self.autocorrectionType = NO;
    self.autocapitalizationType = NO;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self setUserInteractionEnabled:NO];
    self.delegate = self;
    return self;
}

- (void)setInput:(void (^)(NSString *input, TerminalLCD *tlcd))input
{
    _input = [input copy];
}

- (void)setDeletion:(void (^)(NSString *input, TerminalLCD *tlcd))deletion
{
    _deletion = [deletion copy];
}

- (void)setRefreshColor:(void (^)(UIColor *color, TerminalLCD *tlcd))refreshColor
{
    _refreshColor = [refreshColor copy];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (text.length == 0) {
        if (self.deletion) {
            self.deletion(text, self);
        }
    } else {
        if (self.input) {
            self.input(text, self);
        }
    }
    return NO;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self becomeFirstResponder];
        });
    }
}

@end

@implementation TerminalView

- (instancetype)init
{
    self = [super init];
    _machine = handoffMachine();
    _serials = [[NSMutableArray alloc] init];
    [self setupView];
    return self;
}

- (void)osprint:(NSString*)msg
{
    TerminalLCD *os_serial = [self getSerial:0];
    os_serial.text = [os_serial.text stringByAppendingFormat:@"[%.9f] %@\n",
                      [[_machine getClock] doubleValue],
                      msg];
}

- (TerminalLCD*)spawnSerial
{
    TerminalLCD *tlcd = [[TerminalLCD alloc] init];
    [self appendSerial:tlcd];
    _terminalText = tlcd;
    NSInteger cindex = [self findSerial:_terminalText];
    [[self getSerial:cindex] removeFromSuperview];
    tlcd.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:tlcd];
    [self updateDisplay];
    return tlcd;
}

- (void)updateDisplay
{
    NSInteger cindex = [self findSerial:_terminalText];
    NSString *content = [NSString stringWithFormat:@"tty%lu", (unsigned long)cindex];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.display setText: content];
    });
}

- (void)setupView
{
    // allocate new terminal lcd
    TerminalLCD *tlcd = [self spawnSerial];
    
    TerminalLCD *tlcd_prot = [self getSerial:0];
    
    [self osprint:[NSString stringWithFormat:@"%@ %@", _machine.JSTermKernelName, _machine.JSTermKernelVersion]];
    [self osprint:[NSString stringWithFormat:@"[serial]"]];
    [self osprint:[NSString stringWithFormat:@"allocated RootController at %p", self]];
    [self osprint:[NSString stringWithFormat:@"allocated TerminalLCD array at %p", _serials]];
    [self osprint:[NSString stringWithFormat:@"allocated main TerminalLCD at %p", tlcd_prot]];
    jskern_kickstart(self);
    
    [self addSubview:tlcd_prot];
    _terminalText = tlcd_prot;
}

- (void)handleLeft
{
    NSLog(@"Left detected in TerminalView");
    
    NSInteger cindex = [self findSerial:_terminalText];
    NSInteger count = [_serials count] - 1;
    if (cindex >= count) {
        NSLog(@"Out of bounds!");
        return;
    }
    
    [[self getSerial:cindex] removeFromSuperview];
    
    TerminalLCD *newtlcd = [self getSerial:cindex + 1];
    newtlcd.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:newtlcd];
    [newtlcd didMoveToWindow];
    _terminalText = newtlcd;
    [self updateDisplay];
}

- (void)handleRight
{
    NSLog(@"Right detected in TerminalView");
    
    NSInteger cindex = [self findSerial:_terminalText];
    if (cindex == 0) {
        NSLog(@"Out of bounds!");
        return;
    }
    
    [[self getSerial:cindex] removeFromSuperview];
    
    TerminalLCD *newtlcd = [self getSerial:cindex - 1];
    newtlcd.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:newtlcd];
    [newtlcd didMoveToWindow];
    _terminalText = newtlcd;
    [self updateDisplay];
}

- (void)setupControls
{
    // middle display
    _display = [[UILabel alloc] init];
    _display.frame = CGRectMake(self.bounds.size.width - 150, 25, 100, 25);
    _display.backgroundColor = [UIColor grayColor];
    _display.layer.cornerRadius = 5;
    _display.clipsToBounds = YES;
    _display.textAlignment = NSTextAlignmentCenter;
    [_display setText:@"tty0"];
    // right button
    _rightButton = [[UIButton alloc] init];
    _rightButton.frame = CGRectMake(self.bounds.size.width - 45, 25, 25, 25);
    _rightButton.backgroundColor = [UIColor grayColor];
    _rightButton.layer.cornerRadius = 5;
    _rightButton.clipsToBounds = YES;
    _rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_rightButton setTitle:@">" forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    // left button
    _leftButton = [[UIButton alloc] init];
    _leftButton.frame = CGRectMake(self.bounds.size.width - 180, 25, 25, 25);
    _leftButton.backgroundColor = [UIColor grayColor];
    _leftButton.layer.cornerRadius = 5;
    _leftButton.clipsToBounds = YES;
    _leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_leftButton setTitle:@"<" forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(handleRight) forControlEvents:UIControlEventTouchUpInside];
    // adding all to view
    [self addSubview:_display];
    [self addSubview:_rightButton];
    [self addSubview:_leftButton];
}

- (void)updateName:(NSString*)name
{
    [_display setText:name];
}

- (void)buttonRight
{
    TerminalView *parent = (TerminalView*)self.superview;
    [parent handleRight];
}

- (void)buttonLeft
{
    TerminalView *parent = (TerminalView*)self.superview;
    [parent handleLeft];
}

/*
 @Brief crutial functions to find, get and remove and append serials
 */
- (void)appendSerial:(TerminalLCD*)tlcd
{
    [_serials addObject:tlcd];
}

- (NSInteger)findSerial:(TerminalLCD*)tlcd
{
    return [_serials indexOfObject:tlcd];
}

- (void)removeSerial:(TerminalLCD*)tlcd
{
    [_serials removeObject:tlcd];
}

- (TerminalLCD*)getSerial:(NSInteger)index
{
    return [_serials objectAtIndex:index];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupControls];
}

@end
