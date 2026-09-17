//
//  BootMenuViewController.h
//  ClaudeLegacy
//
//  Shown before claude.ai loads. Lets you pick one of a few bundled home
//  screen icon designs (via UIApplication's official alternate-icon API —
//  no filesystem trickery, so it can't break the app) and a nickname shown
//  while the app is loading.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BootMenuViewController : UIViewController

/// Called once the user taps "Continue to Claude".
@property (nonatomic, copy, nullable) void (^onContinue)(NSString *_Nullable chosenName);

@end

NS_ASSUME_NONNULL_END
