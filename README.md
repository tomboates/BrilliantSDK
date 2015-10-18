# Brilliant

[![CI Status](http://img.shields.io/travis/Paul Berry/Brilliant.svg?style=flat)](https://travis-ci.org/Paul Berry/Brilliant)
[![Version](https://img.shields.io/cocoapods/v/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)
[![License](https://img.shields.io/cocoapods/l/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)
[![Platform](https://img.shields.io/cocoapods/p/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Make sure your project podfile has the line: use_framworks!

## Swift Getting Started
1. After installing the pod in your project, `import Brilliant` in the AppDelegate
2. Get APP_KEY from web dashboard: brilliantapp.com/settings
3. following the initialization, set User info:
    `Brilliant.sharedInstance.userEmail = "USER_EMAIL"
    Brilliant.sharedInstance.userDate = "USER_ACCOUNT_CREATION_DATE_AS_NSNUMBER"
    Brilliant.sharedInstance.userType = "USER_TYPE (OPTIONAL)" // can be any metric you want (i.e. free, paid, premium, driver, etc)`
4. in the `didFinishLaunchingWithOptions` method of the AppDelegate, add initialization with APP_KEY:
    `Brilliant.sharedInstance.initWithAppKey("YOUR_APP_KEY")`
5. add `Brilliant.sharedInstance.showNpsSurvey("EVENT_NAME")` wherever you'd like to show the NPS survey

## Objective-C Getting Started
1. After installing the pod in your project, `@import Brilliant;` in the AppDelegate
2. Get APP_KEY from web dashboard: brilliantapp.com/settings
3. before the singleton initialization, set User info:
    `Brilliant.sharedInstance.userEmail = "USER_EMAIL";
    Brilliant.sharedInstance.userDate = "USER_ACCOUNT_CREATION_DATE_AS_NSNUMBER";
    Brilliant.sharedInstance.userType = "USER_TYPE (OPTIONAL)"; // can be any metric you want (i.e. free, paid, premium, driver, etc)`
4. in the `didFinishLaunchingWithOptions` method of the AppDelegate, add initialization with APP_KEY:
    `Brilliant.sharedInstance.initWithAppKey("YOUR_APP_KEY")
5. add `[Brilliant.sharedInstance showNpsSurvey:@"EVENT_NAME"];` wherever you'd like to show the NPS survey

## Requirements

## Installation

Brilliant is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Brilliant"
```

NOTE: if project is in Objective-C, make sure the line use_frameworks! is added to your podfile.
## License

Brilliant is available under the MIT license. See the LICENSE file for more info.
