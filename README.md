# Brilliant

[![CI Status](http://img.shields.io/travis/Paul Berry/Brilliant.svg?style=flat)](https://travis-ci.org/Paul Berry/Brilliant)
[![Version](https://img.shields.io/cocoapods/v/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)
[![License](https://img.shields.io/cocoapods/l/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)
[![Platform](https://img.shields.io/cocoapods/p/Brilliant.svg?style=flat)](http://cocoapods.org/pods/Brilliant)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

1. After installing the pod in your project, `import Brilliant` in the AppDelegate
2. Get APP_KEY from web dashboard: brilliantapp.com/settings
3. in the `didFinishLaunchingWithOptions` method of the AppDelegate, add initialization with APP_KEY:
    `Brilliant.sharedInstance.initWithAppKey("YOUR_APP_KEY_HERE")`
4. following the initialization, set User info:
    `Brilliant.sharedInstance.userEmail = "USER_EMAIL"
    Brilliant.sharedInstance.userAcctCreationDate = "USER_ACCOUNT_CREATION_DATE"
    Brilliant.sharedInstance.userType = "USER_TYPE (OPTIONAL)" // can be any metric you want (i.e. free, paid, premium, driver, etc)`

5. add `Brilliant.sharedInstance.showNpsSurvey("EVENT_NAME_HERE")` wherever you'd like to show the NPS survey

## Requirements

## Installation

Brilliant is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Brilliant"
```

## License

Brilliant is available under the MIT license. See the LICENSE file for more info.
