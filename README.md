# SimBuddy

## Your Simulator’s BFF

Have you ever added code like this to your app?

```
print(Bundle.main.resourcePath)
print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
```

Or been frustrated that you can't add that code because you're in the middle of debugging?

Yeah. Me too. Too many times.

The locations show above, and many others, are available from Xcode using the `xcrun simctl` command. Every application on every device on every platform can be queried. But these lookups are difficult for developers because the information is structured around automatically generated GUIDs. The GUID you're looking for changes every time a new OS is available, a device is added, or an application is installed. And we do that a lot!

There are other tools available to help you navigate the Simulator, but they all do much more than I really need and take up space in my menu bar even though they are used infrequently. Additionally, none of these tools help find the "On My iPhone/iPad" container used by the Files app: a folder that I use whenever I'm testing import and export code.

By now, you probably know where this is going: yes, I wrote my utility and call it _SimBuddy_. It's a [FREE download](https://files.iconfactory.net/software/beta/SimBuddy.zip) on the [Iconfactory](https://iconfactory.com).

_SimBuddy_ uses two popup menus for navigation: the first shows which devices are running in the Simulator and the second shows all the applications installed on that device (yours are listed at the top of the menu). Once you make a choice with those popups, you can use the buttons at the bottom of the window to navigate in the Finder. If you are using app group containers for sharing information between an extension/widget and your main app, you open those folders by selecting the ID and using "Open".

If the _Terminal_ is more your thing, you can hold down the option key while clicking a button and a path to the folder is put on the clipboard. Paste that into a command line and away you go!

It's not a complicated app, as you can see from the [source code](https://github.com/chockenberry/SimBuddy). But it's one that I'm very happy to have in my developer toolbox now. I hope you enjoy it, too!

P.S. I love putting Easter eggs in apps. This time it's the [icon](https://github.com/chockenberry/SimBuddy/blob/main/SimBuddy/Assets.xcassets/AppIcon.appiconset/AppIcon512x512%402x.png).
