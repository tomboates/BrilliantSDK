# Brilliant

[![CI Status](http://img.shields.io/travis/Paul Berry/Brilliant.svg?style=flat)](https://travis-ci.org/Paul Berry/Brilliant)
[![Version](https://img.shields.io/cocoapods/v/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)
[![License](https://img.shields.io/cocoapods/l/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)
[![Platform](https://img.shields.io/cocoapods/p/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)

## Installation

Brilliant is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Brilliant"
```

NOTE: if project is in Objective-C, make sure the line `use_frameworks!` is added to your podfile.

## Swift Getting Started
1. After installing the pod in your project, `import Brilliant` in the AppDelegate
2. Set user info in the `didFinishLaunchingWithOptions` method of the AppDelegate (MUST DO BEFORE SINGLETON INITIALIZATION):
    `Brilliant.sharedInstance.userEmail = "INSERT EMAIL STRING"`
    `Brilliant.sharedInstance.userDate = "INSERT USER ACCOUNT CREATION DATE AS NSNUMBER"` (a timestamp wrapped in NSNumber() i.e. `NSNumber(double: NSDate().timeIntervalSince1970)`)
    `Brilliant.sharedInstance.userType = "INSERT USER TYPE STRING"` (it can be any metric you want (i.e. free, paid, premium, etc)
3. In order to create a Rate The App link at the end of the survey for those who choose 9 or 10, get the 9 digit apple store id from itunes connect. In the `didFinishLaunchingWithOptions` method of the AppDelegate, add the app store id:
    `Brilliant.sharedInstance.appStoreId = "INSERT 9 DIGIT APP STORE ID"`
4. Get your private app key from the web dashboard: brilliantapp.com/settings
5. In the `didFinishLaunchingWithOptions` method of the AppDelegate, add the initialization with APP_KEY
    `Brilliant.sharedInstance.createWithAppKey("INSERT APP KEY FROM WEB")`
6. `import Brilliant` in the view controller you'd like the show the NPS Survey
6. Add `Brilliant.sharedInstance.showNpsSurvey("INSERT EVENT NAME")` to pop up the modal, supply an event name for analytics (i.e. "Friend Request Accepted")

## Objective-C Getting Started
1. After installing the pod in your project, `@import Brilliant;` in the AppDelegate
2. Set user info in the `didFinishLaunchingWithOptions` method of the AppDelegate (MUST DO BEFORE SINGLETON INITIALIZATION):
    `Brilliant.sharedInstance.userEmail = "INSERT EMAIL STRING";`
    `Brilliant.sharedInstance.userDate = "INSERT USER ACCOUNT CREATION DATE AS NSNUMBER";` (a timestamp wrapped in NSNumber())
    `Brilliant.sharedInstance.userType = "INSERT USER TYPE STRING";` (it can be any metric you want (i.e. free, paid, premium, etc)
3. In order to create a Rate The App link at the end of the survey for those who choose 9 or 10, get the 9 digit apple store id from itunes connect. In the `didFinishLaunchingWithOptions` method of the AppDelegate, add the app store id:
    `Brilliant.sharedInstance.appStoreId = "INSERT 9 DIGIT APP STORE ID";`
4. Get your private app key from the web dashboard: brilliantapp.com/settings
5. In the `didFinishLaunchingWithOptions` method of the AppDelegate, add the initialization with APP_KEY
    `[Brilliant.sharedInstance createWithAppKey:"INSERT APP KEY FROM WEB"];`
6. `import Brilliant` in the view controller you'd like the show the NPS Survey
6. Add `[Brilliant.sharedInstance showNpsSurvey:"INSERT EVENT NAME"]` to pop up the modal, supply an event name for analytics (i.e. "Friend Request Accepted")

## Additional Information
In Brilliant.swift, set `private static var kDEBUG = true` to enable debugging mode with printout messages.

## License

Brilliant is available under the MIT license. See the LICENSE file for more info.
