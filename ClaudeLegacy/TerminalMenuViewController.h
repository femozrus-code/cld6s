//
//  TerminalMenuViewController.h
//  ClaudeLegacy
//
//  The screen shown before claude.ai loads: a terminal-styled boot menu with
//  two commands, RUN CLD6S (starts loading claude.ai) and SETTINGS (opens the
//  icon/name customization screen without starting anything).
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TerminalMenuViewController : UIViewController

/// Called once the user taps "RUN CLD6S".
@property (nonatomic, copy, nullable) void (^onRun)(void);

@end

NS_ASSUME_NONNULL_END
