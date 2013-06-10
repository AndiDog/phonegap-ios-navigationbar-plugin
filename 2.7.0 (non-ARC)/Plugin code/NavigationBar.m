/*
 NavigationBar.m

 Work based on the NativeControls plugin (Jesse MacFadyen, MIT licensed) and additions made by Hiedi Utley
 (https://github.com/hutley/HelloPhoneGap1.0/) and zSprawl (https://github.com/zSprawl/NativeControls/).

 Navigation bar API cleaned, improved and moved in a separate plugin by Andreas Sommer
 (AndiDog, https://github.com/AndiDog/phonegap-ios-navigationbar-plugin).
 */

#import "NavigationBar.h"
#import <UIKit/UITabBar.h>
#import <QuartzCore/QuartzCore.h>

// For older versions of Cordova, you may have to use: #import "CDVDebug.h"
#import <Cordova/CDVDebug.h>

@implementation NavigationBar
#ifndef __IPHONE_3_0
@synthesize webView;
#endif
@synthesize navBarController;

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (NavigationBar*)[super initWithWebView:theWebView];
    if(self)
    {
        // -----------------------------------------------------------------------
        // This code block is the same for both the navigation and tab bar plugin!
        // -----------------------------------------------------------------------

        navBarHeight = 44.0f;
        tabBarHeight = 49.0f;

        // -----------------------------------------------------------------------
    }
    return self;
}

- (void)dealloc
{
    if (navBar)
        [navBar release];

    if (navBarController)
        [navBarController release];

    [super dealloc];
}

// NOTE: Returned object is owned
-(UIBarButtonItem*)backgroundButtonFromImage:(NSString*)imageName title:(NSString*)title fixedMarginLeft:(float)fixedMarginLeft fixedMarginRight:(float)fixedMarginRight target:(id)target action:(SEL)action
{
    UIButton *backButton = [[UIButton alloc] init];
    UIImage *imgNormal = [UIImage imageNamed:imageName];

    // UIImage's resizableImageWithCapInsets method is only available from iOS 5.0. With earlier versions, the
    // stretchableImageWithLeftCapWidth is used which behaves a bit differently.
    if([imgNormal respondsToSelector:@selector(resizableImageWithCapInsets)])
        imgNormal = [imgNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0, fixedMarginLeft, 0, fixedMarginRight)];
    else
        imgNormal = [imgNormal stretchableImageWithLeftCapWidth:MAX(fixedMarginLeft, fixedMarginRight) topCapHeight:0];

    [backButton setBackgroundImage:imgNormal forState:UIControlStateNormal];

    backButton.titleLabel.textColor = [UIColor whiteColor];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    backButton.titleLabel.textAlignment = UITextAlignmentCenter;

    CGSize textSize = [title sizeWithFont:backButton.titleLabel.font];

    float buttonWidth = MAX(imgNormal.size.width, textSize.width + fixedMarginLeft + fixedMarginRight);//imgNormal.size.width > (textSize.width + fixedMarginLeft + fixedMarginRight)
                        //? imgNormal.size.width : (textSize.width + fixedMarginLeft + fixedMarginRight);
    backButton.frame = CGRectMake(0, 0, buttonWidth, imgNormal.size.height);

    CGFloat marginTopBottom = (backButton.frame.size.height - textSize.height) / 2;
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(marginTopBottom, fixedMarginLeft, marginTopBottom, fixedMarginRight)];

    [backButton setTitle:title forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    [backButton release];
    // imgNormal is autoreleased

    return backButtonItem;
}

-(void)correctWebViewFrame
{
    if(!navBar)
        return;

    const bool navBarShown = !navBar.hidden;
    bool tabBarShown = false;
    bool tabBarAtBottom = true;

    UIView *parent = [navBar superview];
    for(UIView *view in parent.subviews)
        if([view isMemberOfClass:[UITabBar class]])
        {
            tabBarShown = !view.hidden;

            // Tab bar height is customizable
            if(tabBarShown)
            {
                tabBarHeight = view.bounds.size.height;

                // Since the navigation bar plugin plays together with the tab bar plugin, and the tab bar can as well
                // be positioned at the top, here's some magic to find out where it's positioned:
                tabBarAtBottom = true;
                if([view respondsToSelector:@selector(tabBarAtBottom)])
                    tabBarAtBottom = [view performSelector:@selector(tabBarAtBottom)];
            }

            break;
        }

    // -----------------------------------------------------------------------------
    // IMPORTANT: Below code is the same in both the navigation and tab bar plugins!
    // -----------------------------------------------------------------------------

    const CGRect parentSize = self.webView.superview.bounds;
    const CGFloat left = parentSize.origin.x; // will be 0
    CGFloat top = parentSize.origin.y; // will be 0
    const CGFloat right = left + parentSize.size.width;
    CGFloat bottom = top + parentSize.size.height;

    // -----------------------------------------------------------------------------

    // NOTE: Following part again for navigation bar plugin only

    if(navBarShown)
    {
        if(tabBarShown)
        {
            if(tabBarAtBottom)
            {
                bottom -= tabBarHeight;
            }
            else
            {
                // If tab/navigation bar plugin used together and !tabBarAtBottom, the tab bar is placed above!
                top += tabBarHeight;
            }
        }

        [navBar setFrame:CGRectMake(left, top, right - left, navBarHeight)];
        top += navBarHeight;
    }

    // NOTE: Common code again

    [self.webView setFrame:CGRectMake(left, top, right - left, bottom - top)];
}

/*********************************************************************************/

-(void) create:(CDVInvokedUrlCommand*)command
{
    if(navBar)
        return;

    navBarController = [[CDVNavigationBarController alloc] init];
    navBar = (UINavigationBar*)[navBarController view];

    const NSDictionary *options = command ? [command.arguments objectAtIndex:0] : nil;

    if(options)
    {
        id style = [options objectForKey:@"style"];

        if(style && style != [NSNull null])
        {
            if([style isEqualToString:@"BlackTranslucent"])
                navBar.barStyle = UIBarStyleBlackTranslucent;
            else if([style isEqualToString:@"BlackOpaque"])
                navBar.barStyle = UIBarStyleBlackOpaque;
            else if([style isEqualToString:@"Black"])
                navBar.barStyle = UIBarStyleBlack;
            // else the default will be used
        }

        id tint = [options objectForKey:@"tintColorRgba"];

        if(tint && tint != [NSNull null])
        {
            NSArray *rgba = [tint componentsSeparatedByString:@","];
            navBar.tintColor = [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                                               green:[[rgba objectAtIndex:1] intValue]/255.0f
                                                blue:[[rgba objectAtIndex:2] intValue]/255.0f
                                               alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
        }
    }

    [navBarController setDelegate:self];

    // Navigation bar frame size will be set later in show method!

    [[[self webView] superview] addSubview:[navBarController view]];
    [navBar setHidden:YES];
}

+ (UIBarButtonSystemItem)getUIBarButtonSystemItemForString:(NSString*)imageName
{
    UIBarButtonSystemItem systemItem = -1;

    if([imageName isEqualToString:@"barButton:Action"])        systemItem = UIBarButtonSystemItemAction;
    else if([imageName isEqualToString:@"barButton:Add"])           systemItem = UIBarButtonSystemItemAdd;
    else if([imageName isEqualToString:@"barButton:Bookmarks"])     systemItem = UIBarButtonSystemItemBookmarks;
    else if([imageName isEqualToString:@"barButton:Camera"])        systemItem = UIBarButtonSystemItemCamera;
    else if([imageName isEqualToString:@"barButton:Cancel"])        systemItem = UIBarButtonSystemItemCancel;
    else if([imageName isEqualToString:@"barButton:Compose"])       systemItem = UIBarButtonSystemItemCompose;
    else if([imageName isEqualToString:@"barButton:Done"])          systemItem = UIBarButtonSystemItemDone;
    else if([imageName isEqualToString:@"barButton:Edit"])          systemItem = UIBarButtonSystemItemEdit;
    else if([imageName isEqualToString:@"barButton:FastForward"])   systemItem = UIBarButtonSystemItemFastForward;
    else if([imageName isEqualToString:@"barButton:FixedSpace"])    systemItem = UIBarButtonSystemItemFixedSpace;
    else if([imageName isEqualToString:@"barButton:FlexibleSpace"]) systemItem = UIBarButtonSystemItemFlexibleSpace;
    else if([imageName isEqualToString:@"barButton:Organize"])      systemItem = UIBarButtonSystemItemOrganize;
    else if([imageName isEqualToString:@"barButton:PageCurl"])      systemItem = UIBarButtonSystemItemPageCurl;
    else if([imageName isEqualToString:@"barButton:Pause"])         systemItem = UIBarButtonSystemItemPause;
    else if([imageName isEqualToString:@"barButton:Play"])          systemItem = UIBarButtonSystemItemPlay;
    else if([imageName isEqualToString:@"barButton:Redo"])          systemItem = UIBarButtonSystemItemRedo;
    else if([imageName isEqualToString:@"barButton:Refresh"])       systemItem = UIBarButtonSystemItemRefresh;
    else if([imageName isEqualToString:@"barButton:Reply"])         systemItem = UIBarButtonSystemItemReply;
    else if([imageName isEqualToString:@"barButton:Rewind"])        systemItem = UIBarButtonSystemItemRewind;
    else if([imageName isEqualToString:@"barButton:Save"])          systemItem = UIBarButtonSystemItemSave;
    else if([imageName isEqualToString:@"barButton:Search"])        systemItem = UIBarButtonSystemItemSearch;
    else if([imageName isEqualToString:@"barButton:Stop"])          systemItem = UIBarButtonSystemItemStop;
    else if([imageName isEqualToString:@"barButton:Trash"])         systemItem = UIBarButtonSystemItemTrash;
    else if([imageName isEqualToString:@"barButton:Undo"])          systemItem = UIBarButtonSystemItemUndo;

    return systemItem;
}

-(void) init:(CDVInvokedUrlCommand*)command
{
    // Dummy function, see initWithWebView
}

// NOTE: Returned object is owned
- (UIBarButtonItem*)makeButtonWithOptions:(const NSDictionary*)options title:(NSString*)title imageName:(NSString*)imageName actionOnSelf:(SEL)actionOnSelf
{
    NSNumber *useImageAsBackgroundOpt = [NSNumber numberWithInt:1];
    float fixedMarginLeft = 13;
    float fixedMarginRight = 13;

    if(options)
    {
        useImageAsBackgroundOpt = [options objectForKey:@"useImageAsBackground"];
        id fixedMarginLeftOpt = [options objectForKey:@"fixedMarginLeft"];
        id fixedMarginRightOpt = [options objectForKey:@"fixedMarginRight"];

        if(fixedMarginLeftOpt && fixedMarginLeftOpt != [NSNull null])
            fixedMarginLeft = [fixedMarginLeftOpt floatValue];
        if(fixedMarginRightOpt && fixedMarginRightOpt != [NSNull null])
            fixedMarginRight = [fixedMarginRightOpt floatValue];
    }

    bool useImageAsBackground = useImageAsBackgroundOpt ? [useImageAsBackgroundOpt boolValue] : false;

    if((title && [title length] > 0) || useImageAsBackground)
    {
        if(useImageAsBackground && imageName && [imageName length] > 0)
        {
            return [self backgroundButtonFromImage:imageName title:title
                                             fixedMarginLeft:fixedMarginLeft fixedMarginRight:fixedMarginRight
                                             target:self action:actionOnSelf];
        }
        else
        {
            return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:actionOnSelf];
        }
    }
    else if (imageName && [imageName length] > 0)
    {
        UIBarButtonSystemItem systemItem = [NavigationBar getUIBarButtonSystemItemForString:imageName];

        if(systemItem != -1)
            return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:actionOnSelf];
        else
            return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:actionOnSelf];
    }
    else
    {
        // Fail silently
        NSLog(@"Invalid setup{Left/Right}Button parameters\n");
        return nil;
    }
}

- (void)setupLeftButton:(CDVInvokedUrlCommand*)command
{
    NSString * title = [command.arguments objectAtIndex:0];
    NSString * imageName = [command.arguments objectAtIndex:1];
    const NSDictionary *options = [command.arguments objectAtIndex:2];

    UIBarButtonItem *newButton = [self makeButtonWithOptions:options title:title imageName:imageName actionOnSelf:@selector(leftButtonTapped)];
    navBarController.navItem.leftBarButtonItem = newButton;
    navBarController.leftButton = newButton;
    [newButton release];
}

- (void)setupRightButton:(CDVInvokedUrlCommand*)command
{
    NSString * title = [command.arguments objectAtIndex:0];
    NSString * imageName = [command.arguments objectAtIndex:1];
    const NSDictionary *options = [command.arguments objectAtIndex:2];

    UIBarButtonItem *newButton = [self makeButtonWithOptions:options title:title imageName:imageName actionOnSelf:@selector(rightButtonTapped)];
    navBarController.navItem.rightBarButtonItem = newButton;
    navBarController.rightButton = newButton;
    [newButton release];
}

- (void)hideLeftButton:(CDVInvokedUrlCommand*)command
{
    const NSDictionary *options = [command.arguments objectAtIndex:0];
    bool animated = [[options objectForKey:@"animated"] boolValue];

    [[navBarController navItem] setLeftBarButtonItem:nil animated:animated];
}

- (void)setLeftButtonEnabled:(CDVInvokedUrlCommand*)command
{
    if(navBarController.navItem.leftBarButtonItem)
    {
        id enabled = [command.arguments objectAtIndex:0];
        navBarController.navItem.leftBarButtonItem.enabled = [enabled boolValue];
    }
}

- (void)setLeftButtonTint:(CDVInvokedUrlCommand*)command
{
    if(!navBarController.navItem.leftBarButtonItem)
        return;

    if(![navBarController.navItem.leftBarButtonItem respondsToSelector:@selector(setTintColor:)])
    {
        NSLog(@"setLeftButtonTint unsupported < iOS 5");
        return;
    }

    id tint = [command.arguments objectAtIndex:0];
    NSArray *rgba = [tint componentsSeparatedByString:@","];
    UIColor *tintColor = [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                                         green:[[rgba objectAtIndex:1] intValue]/255.0f
                                          blue:[[rgba objectAtIndex:2] intValue]/255.0f
                                         alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
    navBarController.navItem.leftBarButtonItem.tintColor = tintColor;
}

- (void)setLeftButtonTitle:(CDVInvokedUrlCommand*)command
{
    NSString *title = [command.arguments objectAtIndex:0];
    if(navBarController.navItem.leftBarButtonItem)
        navBarController.navItem.leftBarButtonItem.title = title;
}

- (void)showLeftButton:(CDVInvokedUrlCommand*)command
{
    const NSDictionary *options = [command.arguments objectAtIndex:0];
    bool animated = [[options objectForKey:@"animated"] boolValue];

    [[navBarController navItem] setLeftBarButtonItem:[navBarController leftButton] animated:animated];
}

- (void)hideRightButton:(CDVInvokedUrlCommand*)command
{
    const NSDictionary *options = [command.arguments objectAtIndex:0];
    bool animated = [[options objectForKey:@"animated"] boolValue];

    [[navBarController navItem] setRightBarButtonItem:nil animated:animated];
}

- (void)setRightButtonEnabled:(CDVInvokedUrlCommand*)command
{
    if(navBarController.navItem.rightBarButtonItem)
    {
        id enabled = [command.arguments objectAtIndex:0];
        navBarController.navItem.rightBarButtonItem.enabled = [enabled boolValue];
    }
}

- (void)setRightButtonTint:(CDVInvokedUrlCommand*)command
{
    if(!navBarController.navItem.rightBarButtonItem)
        return;

    if(![navBarController.navItem.rightBarButtonItem respondsToSelector:@selector(setTintColor:)])
    {
        NSLog(@"setRightButtonTint unsupported < iOS 5");
        return;
    }

    id tint = [command.arguments objectAtIndex:0];
    NSArray *rgba = [tint componentsSeparatedByString:@","];
    UIColor *tintColor = [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                                         green:[[rgba objectAtIndex:1] intValue]/255.0f
                                          blue:[[rgba objectAtIndex:2] intValue]/255.0f
                                         alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
    navBarController.navItem.rightBarButtonItem.tintColor = tintColor;
}

- (void)setRightButtonTitle:(CDVInvokedUrlCommand*)command
{
    NSString *title = [command.arguments objectAtIndex:0];
    if(navBarController.navItem.rightBarButtonItem)
        navBarController.navItem.rightBarButtonItem.title = title;
}

- (void)showRightButton:(CDVInvokedUrlCommand*)command
{
    const NSDictionary *options = [command.arguments objectAtIndex:0];
    bool animated = [[options objectForKey:@"animated"] boolValue];

    [[navBarController navItem] setRightBarButtonItem:[navBarController rightButton] animated:animated];
}

-(void) leftButtonTapped
{
    NSString * jsCallBack = [NSString stringWithFormat:@"cordova.require('cordova/plugin/iOSNavigationBar').leftButtonTapped();"];
    [self writeJavascript:jsCallBack];
}

-(void) rightButtonTapped
{
    NSString * jsCallBack = [NSString stringWithFormat:@"cordova.require('cordova/plugin/iOSNavigationBar').rightButtonTapped();"];
    [self writeJavascript:jsCallBack];
}

-(void) show:(CDVInvokedUrlCommand*)command
{
    if (!navBar)
        [self create:nil];

    if ([navBar isHidden])
    {
        [navBar setHidden:NO];
        [self correctWebViewFrame];
    }
}


-(void) hide:(CDVInvokedUrlCommand*)command
{
    if (navBar && ![navBar isHidden])
    {
        [navBar setHidden:YES];
        [self correctWebViewFrame];
    }
}

/**
 * Resize the navigation bar (this should be called on orientation change)
 * This is important in playing together with the tab bar plugin, especially because the tab bar can be placed on top
 * or at the bottom, so the navigation bar bounds also need to be changed.
 */
- (void)resize:(CDVInvokedUrlCommand*)command
{
    [self correctWebViewFrame];
}

-(void) setTitle:(CDVInvokedUrlCommand*)command
{
    if(!navBar)
        return;

    NSString  *title = [command.arguments objectAtIndex:0];
    [navBarController navItem].title = title;

    // Reset otherwise overriding logo reference
    [navBarController navItem].titleView = NULL;
}

-(void) setLogo:(CDVInvokedUrlCommand*)command
{
    NSString *logoURL = [command.arguments objectAtIndex:0];
    UIImage *image = nil;

    if (logoURL && ![logoURL isEqual: @""])
    {
        if ([logoURL hasPrefix:@"http://"] || [logoURL hasPrefix:@"https://"])
        {
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoURL]];
            image = [UIImage imageWithData:data];
        }
        else
            image = [UIImage imageNamed:logoURL];

        if (image)
        {
            UIImageView * view = [[[UIImageView alloc] initWithImage:image] autorelease];
            view.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            [[navBarController navItem] setTitleView:view];
        }
        else
            NSLog(@"Nav bar logo %@ not found or could not be loaded", logoURL);
    }
}

@end
