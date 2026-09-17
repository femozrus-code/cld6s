//
//  BootMenuViewController.m
//  ClaudeLegacy
//
#import "BootMenuViewController.h"
#import <objc/runtime.h>

static NSString *const kSelectedAltIconKey = @"BootMenu.SelectedAltIcon"; // nil/absent = primary icon
static NSString *const kCustomNameKey = @"BootMenu.CustomName";
static const void *kIconNameAssocKey = &kIconNameAssocKey;

@interface BootMenuViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSArray<NSString *> *iconNames; // nil represents "keep current"
@property (nonatomic, strong) NSMutableArray<UIButton *> *iconButtons;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, copy, nullable) NSString *selectedIcon;
@end

@implementation BootMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc) {
        return tc.userInterfaceStyle == UIUserInterfaceStyleDark
        ? [UIColor colorWithRed:31/255.0 green:31/255.0 blue:30/255.0 alpha:1.0]
        : [UIColor colorWithRed:0xF8/255.0 green:0xF7/255.0 blue:0xF3/255.0 alpha:1.0];
    }];

    self.iconNames = @[@"AltIconEmber", @"AltIconInk", @"AltIconMint", @"AltIconSand"];
    self.iconButtons = [NSMutableArray array];
    self.selectedIcon = [[NSUserDefaults standardUserDefaults] stringForKey:kSelectedAltIconKey];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"Before we open Claude";
    title.font = [UIFont boldSystemFontOfSize:22];
    title.numberOfLines = 0;

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Pick a home screen icon and a name for this app.";
    subtitle.font = [UIFont systemFontOfSize:14];
    subtitle.textColor = UIColor.secondaryLabelColor;
    subtitle.numberOfLines = 0;

    UILabel *iconLabel = [[UILabel alloc] init];
    iconLabel.text = @"HOME SCREEN ICON";
    iconLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    iconLabel.textColor = UIColor.secondaryLabelColor;

    UIStackView *iconRow = [[UIStackView alloc] init];
    iconRow.axis = UILayoutConstraintAxisHorizontal;
    iconRow.distribution = UIStackViewDistributionFillEqually;
    iconRow.spacing = 12;

    // "Keep current" tile — plain, no image lookup needed.
    UIButton *keepButton = [self makeIconTileWithTitle:@"Current" image:nil iconName:nil];
    [iconRow addArrangedSubview:keepButton];
    [self.iconButtons addObject:keepButton];

    for (NSString *name in self.iconNames) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@3x"] ofType:@"png"];
        UIImage *image = path ? [UIImage imageWithContentsOfFile:path] : nil;
        NSString *shortLabel = [name stringByReplacingOccurrencesOfString:@"AltIcon" withString:@""];
        UIButton *button = [self makeIconTileWithTitle:shortLabel image:image iconName:name];
        [iconRow addArrangedSubview:button];
        [self.iconButtons addObject:button];
    }

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"APP NAME (shown while loading)";
    nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    nameLabel.textColor = UIColor.secondaryLabelColor;

    UITextField *nameField = [[UITextField alloc] init];
    nameField.borderStyle = UITextBorderStyleRoundedRect;
    nameField.placeholder = @"Claude";
    nameField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kCustomNameKey];
    nameField.returnKeyType = UIReturnKeyDone;
    nameField.delegate = self;
    nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameField = nameField;

    NSString *note = @"Note: this renames the loading screen inside the app. "
        "iOS does not let apps rename the label under their own home screen "
        "icon, so that text will stay “Claude (debug)” there.";
    UILabel *noteLabel = [[UILabel alloc] init];
    noteLabel.text = note;
    noteLabel.font = [UIFont systemFontOfSize:12];
    noteLabel.textColor = UIColor.tertiaryLabelColor;
    noteLabel.numberOfLines = 0;

    UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [continueButton setTitle:@"Continue to Claude" forState:UIControlStateNormal];
    continueButton.backgroundColor = [UIColor colorWithRed:0.80 green:0.42 blue:0.28 alpha:1.0];
    [continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    continueButton.layer.cornerRadius = 12;
    continueButton.clipsToBounds = YES;
    [continueButton addTarget:self action:@selector(continueTapped) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        title, subtitle, iconLabel, iconRow, nameLabel, nameField, noteLabel
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 10;
    [stack setCustomSpacing:20 afterView:subtitle];
    [stack setCustomSpacing:20 afterView:iconRow];
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    [self.view addSubview:continueButton];
    continueButton.translatesAutoresizingMaskIntoConstraints = NO;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:32],

        [iconRow.heightAnchor constraintEqualToConstant:84],

        [continueButton.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [continueButton.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [continueButton.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-24],
        [continueButton.heightAnchor constraintEqualToConstant:50],
    ]];

    [self refreshSelectionHighlight];
}

- (UIButton *)makeIconTileWithTitle:(NSString *)title image:(nullable UIImage *)image iconName:(nullable NSString *)iconName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 14;
    button.layer.borderWidth = 2;
    button.layer.borderColor = UIColor.clearColor.CGColor;
    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.12];

    if (image) {
        [button setImage:image forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        button.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 20, 6);
    }

    UILabel *caption = [[UILabel alloc] init];
    caption.text = title;
    caption.font = [UIFont systemFontOfSize:10];
    caption.textAlignment = NSTextAlignmentCenter;
    caption.translatesAutoresizingMaskIntoConstraints = NO;
    [button addSubview:caption];
    [NSLayoutConstraint activateConstraints:@[
        [caption.leadingAnchor constraintEqualToAnchor:button.leadingAnchor],
        [caption.trailingAnchor constraintEqualToAnchor:button.trailingAnchor],
        [caption.bottomAnchor constraintEqualToAnchor:button.bottomAnchor constant:-4],
    ]];

    [button addTarget:self action:@selector(iconTileTapped:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(button, kIconNameAssocKey, iconName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return button;
}

- (void)iconTileTapped:(UIButton *)sender {
    NSString *iconName = objc_getAssociatedObject(sender, kIconNameAssocKey);
    self.selectedIcon = iconName;
    [[NSUserDefaults standardUserDefaults] setObject:iconName forKey:kSelectedAltIconKey];

    [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"[bootMenu] setAlternateIconName failed: %@", error);
        }
    }];

    [self refreshSelectionHighlight];
}

- (void)refreshSelectionHighlight {
    for (UIButton *button in self.iconButtons) {
        NSString *iconName = objc_getAssociatedObject(button, kIconNameAssocKey);
        BOOL selected = (iconName == self.selectedIcon) || (iconName && self.selectedIcon && [iconName isEqualToString:self.selectedIcon]);
        button.layer.borderColor = selected
            ? [UIColor colorWithRed:0.80 green:0.42 blue:0.28 alpha:1.0].CGColor
            : UIColor.clearColor.CGColor;
    }
}

- (void)continueTapped {
    [self.nameField resignFirstResponder];
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kCustomNameKey];

    void (^callback)(NSString *) = self.onContinue;
    [self dismissViewControllerAnimated:YES completion:^{
        if (callback) callback(name.length > 0 ? name : nil);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
