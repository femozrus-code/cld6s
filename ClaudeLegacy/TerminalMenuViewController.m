//
//  TerminalMenuViewController.m
//  ClaudeLegacy
//
#import "TerminalMenuViewController.h"
#import "SettingsViewController.h"

@interface TerminalMenuViewController ()
@property (nonatomic, strong) UILabel *cursorLabel;
@end

@implementation TerminalMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    UIFont *mono = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightRegular];
    UIFont *monoBig = [UIFont monospacedSystemFontOfSize:18 weight:UIFontWeightBold];
    UIColor *green = [UIColor colorWithRed:0.20 green:0.95 blue:0.45 alpha:1.0];
    UIColor *dimGreen = [UIColor colorWithRed:0.20 green:0.95 blue:0.45 alpha:0.55];

    UILabel *banner = [[UILabel alloc] init];
    banner.numberOfLines = 0;
    banner.font = monoBig;
    banner.textColor = green;
    banner.text =
        @"================================\n"
        @"   C L D 6 S   T E R M I N A L\n"
        @"================================";

    UILabel *status = [[UILabel alloc] init];
    status.numberOfLines = 0;
    status.font = mono;
    status.textColor = dimGreen;
    status.text =
        @"> device : iPhone 6s\n"
        @"> os     : iOS 15.8\n"
        @"> jb     : dopamine\n"
        @"> status : ready";

    UIButton *runButton = [self makeCommandButtonTitle:@"[ RUN CLD6S ]" color:green];
    [runButton addTarget:self action:@selector(runTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton *settingsButton = [self makeCommandButtonTitle:@"[ SETTINGS ]" color:dimGreen];
    [settingsButton addTarget:self action:@selector(settingsTapped) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        banner, status, runButton, settingsButton
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 22;
    stack.alignment = UIStackViewAlignmentLeading;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintLessThanOrEqualToAnchor:safe.trailingAnchor constant:-24],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-20],
        [runButton.widthAnchor constraintGreaterThanOrEqualToConstant:220],
        [settingsButton.widthAnchor constraintGreaterThanOrEqualToConstant:220],
    ]];
}

- (UIButton *)makeCommandButtonTitle:(NSString *)title color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightBold];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.layer.borderWidth = 1;
    button.layer.borderColor = color.CGColor;
    button.contentEdgeInsets = UIEdgeInsetsMake(10, 16, 10, 16);
    return button;
}

- (void)runTapped {
    void (^callback)(void) = self.onRun;
    if (callback) callback();
}

- (void)settingsTapped {
    SettingsViewController *settings = [[SettingsViewController alloc] init];
    settings.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settings animated:YES completion:nil];
}

@end
