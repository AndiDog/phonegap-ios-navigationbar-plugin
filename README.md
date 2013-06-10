Navigation bar for Cordova on iOS
=================================

This plugin lets you create and control a native navigation bar and its buttons.

License
-------

[MIT license](http://www.opensource.org/licenses/mit-license.html)

Contributors
------------

This plugin was put together from the incomplete NativeControls plugin and other sources. See NavigationBar.m for the history.

Versions
--------

Choose the right folder according to your Cordova version:

- 2.0.0 (not developed anymore) for Cordova 2.0.0
- 2.1.0 (not developed anymore), tested with Cordova 2.1.0 and 2.2.0
- 2.4.0 (not developed anymore), tested with Cordova 2.4.0
- 2.7.0, tested with Cordova 2.7.0

Installing the plugin
---------------------

- Copy *.xib, *.m and *.h files to your project's "Plugins" folder (should already exist and contain a README file if you used the Cordova project template)
- They have to be added to the project as well, so drag them from the "Plugins" folder (in Finder) to the same folder (in Xcode) and select to create references
- Open "Resources/Cordova.plist" and under "Plugins", add a key with the plugin name "NavigationBar" and a string value of "NavigationBar" (I guess it's the plugin's main class name)

Note regarding orientation changes and the tab bar plugin
---------------------------------------------------------

If the tab bar plugin is used together with this plugin and the tab bar is positioned on top (defaults to bottom), it's necessary to resize the navigation bar automatically:

```javascript
window.addEventListener("resize", function() {
    var navBar = cordova.require("cordova/plugin/iOSNavigationBar")
    navBar.resize()
), false)
```

Using the tab bar and navigation bar plugin together
----------------------------------------------------

In order to use the [tab bar plugin](https://github.com/AndiDog/phonegap-ios-tabbar-plugin) and [navigation bar plugin](https://github.com/AndiDog/phonegap-ios-navigationbar-plugin) together, you must initialize both plugins before calling any of their methods, i.e. before creating a navigation/tab bar. For example right when your application starts:

```javascript
document.addEventListener("deviceready", function() {
    console.log("Cordova ready")

    var navBar = cordova.require("cordova/plugin/iOSNavigationBar")
    var tabBar = cordova.require("cordova/plugin/iOSTabBar")

    navBar.init()
    tabBar.init()

    navBar.create()
    tabBar.create()

    // ...
```

This is because both plugins are aware of each other and resize Cordova's web view accordingly, but therefore they have to know the web view's initial dimensions. If for example you only initialize the tab bar plugin, create the tab bar and later decide to also create a navigation bar, the navigation bar plugin would think the original web view size is 320x411 instead of 320x460 (on iPhone). Layouting *could* be done using the screen size as well but it's currently implemented like this.

Example
-------

This example shows how to use the navigation bar:

```javascript
document.addEventListener("deviceready", function() {
    console.log("Cordova ready")

    var navBar = cordova.require("cordova/plugin/iOSNavigationBar")

    navBar.init()

    navBar.create()
    // or to apply a certain style (one of "Black", "BlackOpaque", "BlackTranslucent", "Default"):
    navBar.create("BlackOpaque")
    // or with a yellow tint color (note: parameters might be changed to one object in a later version)
    navBar.create('BlackOpaque', {tintColorRgba: '255,255,0,255'})

    navBar.hideLeftButton()
    navBar.hideRightButton()

    navBar.setTitle("My heading")
    // or with a logo image
    navBar.setLogo("SomeImageFileFromResourcesOrURL.png")

    navBar.showLeftButton()
    navBar.showRightButton()

    // Create left navigation button with a title (you can either have a title or an image, not both!)
    navBar.setupLeftButton("Text", null, function() {
        alert("left nav button tapped")
    })

    // Create right navigation button from a system-predefined button (see the full list in NativeControls.m)
    // or from an image
    navBar.setupRightButton(
        null,
        "barButton:Bookmarks", // or your own file like "/www/stylesheets/images/ajax-loader.png",
        function() {
            alert("right nav button tapped")
        }
    )

    // You can also enable/disable a button
    navBar.setLeftButtonEnabled(false)
    navBar.setRightButtonEnabled(true) // enabled (default)

    // or change the tint color (>= iOS 5)
    navBar.setLeftButtonTint('255,0,0,128') // strong red
    navBar.setRightButtonTint('20,180,0,60') // green

    navBar.show()
}, false)
```

How to create a custom button (such as an arrow-shaped back button)
-------------------------------------------------------------------

There are [several ways](http://stackoverflow.com/questions/227078/creating-a-left-arrow-button-like-uinavigationbars-back-style-on-a-uitoolba) to create a back button at runtime without having to use `UINavigationController`, but only one of them seems to be okay if you want your app to be approved: A custom button background image.

![Screenshot](./example.png)

The above screenshot has a navigation bar with two such custom buttons. The left one actually has a background image very similar to the black iOS navigation bar. A stretchable picture (such as [this](http://imgur.com/yibWD) or [that one](http://imgur.com/K2LUS) which were used above) should be used because the plugin automatically sets the button size according to the text size (but not smaller than the original picture). You can define left/right margins which shall not be stretched if the button width changes. Important: iOS 5.0 supports defining two different values for the left/right margins. In earlier iOS versions, the plugins takes the larger value (13 pixels in the example below), so please test if your background image looks fine with older versions (install and use the iPhone 4.3 simulator, for example).

Note: Vertical margins are supported by iOS but not implemented in the plugin � tell me if you would like that feature. I think you should keep navigation bar buttons at a fixed height (30px on normal 320x480 iPhone display).

Put the button image in the "Resources" folder of your project. Here's some example code on how to use it:

```javascript
navBar.setupLeftButton(
    "Baaack",
    "blackbutton.png",
    function() {
      alert('leftnavbutton tapped')
    },
    {
      useImageAsBackground: true,
      fixedMarginLeft: 13, // 13 pixels on the left side are not stretched (the left-arrow shape)
      fixedMarginRight: 5 // and 5 pixels on the right side (all room between these margins is used for the text label)
    }
)

navBar.setupRightButton(
    null, // with a custom background image, it's possible to set no title at all
    "greenbutton.png",
    function() {
      alert('rightnavbutton tapped')
    },
    {
      useImageAsBackground: true,
      fixedMarginLeft: 5,
      fixedMarginRight: 13
    }
)
```
