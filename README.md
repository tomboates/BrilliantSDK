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
1. After installing the pod in your project, `@import Brilliant` in the AppDelegate
2. Configure Brilliant in the `didFinishLaunchingWithOptions` method of the AppDelegate:  
    
    `Brilliant.createInstance("INSERT KEY HERE", appStoreId: "INSERT APP STORE ID", userEmail: "INSERT EMAIL", userType: "INSERT UESR TYPE", userDate: NSDate.distantPast())`  
    

3. Get your private app key from the web dashboard: brilliantapp.com/settings  
4. `@import Brilliant` in the view controller you'd like the show the NPS Survey  
6. Add `Brilliant.sharedInstance.showNpsSurvey({INSERT_EVENT_NAME})` to pop up the modal, supply an event name for analytics (i.e. "Friend Request Accepted")

## Objective-C Getting Started
1. After installing the pod in your project, `#import Brilliant;` in the AppDelegate  
2. Set user info in the `didFinishLaunchingWithOptions` method of the AppDelegate (MUST DO BEFORE SINGLETON INITIALIZATION):  

`[Brilliant createInstance:{appId} appStoreId: {INSERT APP STORE ID}, userEmail: {INSERT EMAIL}, userType: {INSERT UESR TYPE}, userDate: {USER CREATION DATE}]`
    
3. Get your private app key from the web dashboard: brilliantapp.com/settings  
4. `#import Brilliant;` in the view controller you'd like the show the NPS Survey
5. Add `[Brilliant.sharedInstance showNpsSurvey:@"Button Clicked"]` to pop up the modal, supply an event name for analytics (i.e. "Friend Request Accepted")

## License

Brilliant is available under the MIT license. See the LICENSE file for more info.
