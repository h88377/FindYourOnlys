# FindYourOnlys

![Find Your Onlys Banner](https://user-images.githubusercontent.com/66559497/170659460-254e0f4b-1414-46cc-8569-c316739458b4.png)

<p align="left">
    <img src="https://img.shields.io/badge/platform-iOS-lightgray">
    <img src="https://img.shields.io/badge/release-v1.0.1-green">
</p>

<p align="left">
    <a href="https://apps.apple.com/tw/app/findyouronlys/id1619734464">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"></a>
</p>

## About
Lists all stray animals and shelters in Taiwan and provides a pet-finding platform for users to find their pets.
In addition, users can share their lovely pets to the sharing community to show how happy they are.

## Features

### Adopted animals information

* Integrated the detailed information of the stray animals in the shelters in Taiwan and the features of filtering, adding to favorites and sharing, so that you are able to find the right pet via this App.

### Put adoption into practice

* Locate the shelters nearby where you are and navigate to where you want to go.
* Locate the pet you selected and navigate to the location of the pet.
* Search other shelters by cities name. 
* Contact the shelter via phone.

### Pet-finding platform

* Post missing and finding articles of lost pets in the pet-finding community and share to other social media Apps to find your pets.

### Keep tracking after adoption

* The features of friends and chat rooms to keep tracking after adoption.

### Share your happiness

* Share your lovely pets to the sharing community to show how happy you are.

## Screenshots

![screenshot 3](https://user-images.githubusercontent.com/66559497/170659605-9e255f77-8c2d-4652-bf53-80ccfa5eedf9.png)
![screenshot 2](https://user-images.githubusercontent.com/66559497/170659598-ac76398d-316c-46fa-9f2c-9ebd42f68d15.png)
![sceenshot 1](https://user-images.githubusercontent.com/66559497/170659585-b035e5e6-03d4-4c03-bc99-a3c826b012b0.png)

## Techniques
* Implemented MVVM design pattern as App’s architecture to make view controller’s responsibility more clear and lightweight. Furthermore, making the entire project more maintainable, reusable, and testable.

* Implemented class inheritance, method overloading and overriding, access control, and polymorphism throughout the App to put OOP concept into practice.

* Established pagination feature to enhance user experience while fetching stray animals’ data by RESTful APIs. 

* Stored, managed, and synchronized data with Firebase. For anonymous users, stored favorite pets' data in local storage via Core Data.

* Used Map Kit to locate users and shelters and calculate the navigation routes.

* Took advantage of Google ML Kit to achieve animal detection feature to avoid non-animal content being posted.

## Libraries
* [Firebase](https://github.com/firebase/firebase-ios-sdk)    
* [Kingfisher](https://github.com/onevcat/Kingfisher)     
* [GoogleMLKit/ImageLabeling](https://github.com/googlesamples/mlkit)      
* [FirebaseCrashlytics](https://github.com/firebase/firebase-ios-sdk)     
* [Lottie](https://github.com/airbnb/lottie-ios)  
* [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)  
* [SwiftLint](https://github.com/realm/SwiftLint) 

## Version
> 1.0.1  

##Release Notes
Version | Date        | Note
------- | ----------- |------
1.0.0   | 2022/05/12  | First released on App Store.
1.0.1   | 2022/05/23  | Added new feature and optimized UI. 

## Requirements
> Xcode 11 or later  
> iOS 13.0 or later  
> Swift 4 or later

## Contact
Wayne Cheng｜h88377@gmail.com   

## Licence
Copyright 2022 WayneCheng.  
FindYourOnlys is released under the MIT license. See [LICENSE]() for details.

