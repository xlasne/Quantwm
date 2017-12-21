# Quantwm

[![CI Status](http://img.shields.io/travis/xlasne/Quantwm.svg?style=flat)](https://travis-ci.org/xlasne/Quantwm)
[![Version](https://img.shields.io/cocoapods/v/Quantwm.svg?style=flat)](http://cocoapods.org/pods/Quantwm)
[![License](https://img.shields.io/cocoapods/l/Quantwm.svg?style=flat)](http://cocoapods.org/pods/Quantwm)
[![Platform](https://img.shields.io/cocoapods/p/Quantwm.svg?style=flat)](http://cocoapods.org/pods/Quantwm)

Quantwm is a Swift framework, which takes binding concepts to a whole new level.
It aggregates the good concepts of many other leading frameworks in a simple and powerful architecture pattern, in order to manage efficiently the most complex IOS or MacOS into a fully decoupled, MVVM, data centric, contract-based, Flux-like, synchronous, stateful architecture, single-responsibility principle, well suited for complex or large team project.

As the framework manages all the dependencies between the model and its clients, and impose strict interaction rules aiming to eliminate as much as possible variability and dependencies between them, project can grow to large level of complexity while keeping code simple and stable. The drastic reduction of interactions between components and of application states reduce the exponential increase of possible state and execution scenario.

It is also a good pattern to follow for mid-level developers, because it answers to all the architecture question that arise when trying to follow MVVM pattern the first time.

It relies on several key concepts:
* Data Centric: All communication between View Controllers is done via the Data Model.
* Contract-based: Interaction between Data Model and clients is synchronous, and is based on of the 3 contracts:
  * Update transaction: Triggered by an Action (User UI input, system event, end of background processing), it allows any read or write, and delay the publish of priority and smart notifications at the end of the transaction.
  * Priority notification: Notification sent by the Data Model, based on a registration indicating which property are Read and what is the hard-coded priority of the scheduling of this notification. Allows to read or write anything in the Data Model.
  * Smart notification: Notification sent by the Data Model, based on a registration indicating which property are Read and Written. Allows to read or write only the registered properties. Scheduled after the Priority notifications, and ordered according to the read/write dependencies in order to be sent only once during the event loop, if any of the registered properties have changed.
* Thread-safe & Synchronous: because all interactions with the Data Model shall occur on the main thread. This guaranties that the notification content matches the current state of the data model, and eliminate any uncertainty versus the current state of the other controllers. It also eases debugging, because the action triggering the notification is always at the base of the call stack.
* Flux-like: Clear decoupling between the Action and the processing or refresh resulting from this Action.
* Stateful: Because the state of the application is the state of the model. Undo/Redo can be performed by rolling back and forth the model, and all the UI and View Hierarchy will be updated from it.
* MVVM based.

Quantwm can be used with several level of integration.
In its most advanced form, it relies heavily on Sourcery, in order to generate a Model Scheme from the model. This Model Scheme allows an easy generation of the read and write property path needed by Registration.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

To be completed.

## Installation

Quantwm is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Quantwm'
```

## Author

xlasne, xavier.lasne@gmail.com

## License

Quantwm is available under the MIT license. See the LICENSE file for more info.
