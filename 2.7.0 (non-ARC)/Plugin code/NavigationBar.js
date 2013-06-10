cordova.define("cordova/plugin/iOSNavigationBar", function(require, exports, module) {
    var exec = require("cordova/exec");

    var NavigationBar = function() {
        this.leftButtonCallback = null;
        this.rightButtonCallback = null;
    }

    /**
     * Create a navigation bar.
     *
     * @param style: One of "BlackTransparent", "BlackOpaque", "Black" or "Default". The latter will be used if no style is given.
     */
    NavigationBar.prototype.create = function(style, options)
    {
        options = options || {};
        if(!("style" in options))
            options.style = style || "Default";

        exec(null, null, "NavigationBar", "create", [options]);
    };

    /**
     * Must be called before any other method in order to initialize the plugin.
     */
    NavigationBar.prototype.init = function()
    {
        exec(null, null, "NavigationBar", "init", []);
    };

    NavigationBar.prototype.resize = function() {
        exec(null, null, "NavigationBar", "resize", []);
    };

    /**
     * Assign either title or image to the left navigation bar button, and assign the tap callback
    */
    NavigationBar.prototype.setupLeftButton = function(title, image, onselect, options)
    {
        this.leftButtonCallback = onselect;
        exec(null, null, "NavigationBar", "setupLeftButton", [title || "", image || "", options || {}]);
    };

    /**
     * @param options: May contain the key "animated" (boolean)
     */
    NavigationBar.prototype.hideLeftButton = function(options)
    {
        options = options || {}
        if(!("animated" in options))
            options.animated = false

        exec(null, null, "NavigationBar", "hideLeftButton", [options])
    };

    NavigationBar.prototype.setLeftButtonEnabled = function(enabled)
    {
        exec(null, null, "NavigationBar", "setLeftButtonEnabled", [enabled])
    };

    NavigationBar.prototype.setLeftButtonTint = function(tintColorRgba)
    {
        exec(null, null, "NavigationBar", "setLeftButtonTint", [tintColorRgba])
    };

    NavigationBar.prototype.setLeftButtonTitle = function(title)
    {
        exec(null, null, "NavigationBar", "setLeftButtonTitle", [title])
    };

    NavigationBar.prototype.showLeftButton = function(options)
    {
        options = options || {}
        if(!("animated" in options))
            options.animated = false

        exec(null, null, "NavigationBar", "showLeftButton", [options])
    };

    /**
     * Internal function called by the plugin
     */
    NavigationBar.prototype.leftButtonTapped = function()
    {
        if(typeof(this.leftButtonCallback) === "function")
            this.leftButtonCallback()
    };

    /**
     * Assign either title or image to the right navigation bar button, and assign the tap callback
    */
    NavigationBar.prototype.setupRightButton = function(title, image, onselect, options)
    {
        this.rightButtonCallback = onselect;
        exec(null, null, "NavigationBar", "setupRightButton", [title || "", image || "", options || {}]);
    };


    NavigationBar.prototype.hideRightButton = function(options)
    {
        options = options || {}
        if(!("animated" in options))
            options.animated = false

        exec(null, null, "NavigationBar", "hideRightButton", [options])
    };

    NavigationBar.prototype.setRightButtonEnabled = function(enabled)
    {
        exec(null, null, "NavigationBar", "setRightButtonEnabled", [enabled])
    };

    NavigationBar.prototype.setRightButtonTint = function(tintColorRgba)
    {
        exec(null, null, "NavigationBar", "setRightButtonTint", [tintColorRgba])
    };

    NavigationBar.prototype.setRightButtonTitle = function(title)
    {
        exec(null, null, "NavigationBar", "setRightButtonTitle", [title])
    };

    NavigationBar.prototype.showRightButton = function(options)
    {
        options = options || {}
        if(!("animated" in options))
            options.animated = false

        exec(null, null, "NavigationBar", "showRightButton", [options])
    };

    /**
     * Internal function called by the plugin
     */
    NavigationBar.prototype.rightButtonTapped = function()
    {
        if(typeof(this.rightButtonCallback) === "function")
            this.rightButtonCallback()
    };

    NavigationBar.prototype.setTitle = function(title)
    {
        exec(null, null, "NavigationBar", "setTitle", [title]);
    };

    NavigationBar.prototype.setLogo = function(imageURL)
    {
        exec(null, null, "NavigationBar", "setLogo", [imageURL]);
    };

    /**
     * Shows the navigation bar. Make sure you called create() first.
     */
    NavigationBar.prototype.show = function() {
        exec(null, null, "NavigationBar", "show", []);
    };

    /**
     * Hides the navigation bar. Make sure you called create() first.
     */
    NavigationBar.prototype.hide = function() {
        exec(null, null, "NavigationBar", "hide", []);
    };

    module.exports = new NavigationBar();
});
