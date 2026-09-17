//
//  SettingsViewController.h
//  ClaudeLegacy
//
//  Lets you pick one of a few bundled home screen icon designs (via
//  UIApplication's official alternate-icon API — no filesystem trickery, so
//  it can't break the app) and a nickname shown while claude.ai is loading.
//  Reachable from the terminal boot menu's SETTINGS command, and from the
//  settings button next to "Paste login link" once claude.ai is open.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsViewController : UIViewController
@end

NS_ASSUME_NONNULL_END
