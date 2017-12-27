# Quantwm

[![CI Status](http://img.shields.io/travis/xlasne/Quantwm.svg?style=flat)](https://travis-ci.org/xlasne/Quantwm)
[![Version](https://img.shields.io/cocoapods/v/Quantwm.svg?style=flat)](http://cocoapods.org/pods/Quantwm)
[![License](https://img.shields.io/cocoapods/l/Quantwm.svg?style=flat)](http://cocoapods.org/pods/Quantwm)
[![Platform](https://img.shields.io/cocoapods/p/Quantwm.svg?style=flat)](http://cocoapods.org/pods/Quantwm)

Quantwm is a Swift framework, which takes binding concepts to a whole new level.
It aggregates the good concepts of many other leading frameworks in a simple and powerful architecture pattern, in order to manage efficiently the most complex IOS or MacOS into a fully decoupled, MVVM, data centric, contract-based, Flux-like, synchronous, stateful architecture, with single-responsibility principle, well suited for complex or large team project.

As the framework manages all the dependencies between the model and its clients, and impose strict interaction rules aiming to eliminate as much as possible variability and dependencies between them, project can grow to large level of complexity while keeping code simple and stable. The reduction of interactions between components and application states reduce the exponential increase of possible state and execution scenario.

It is also a good pattern to follow for mid-level developers, because it answers to all the architecture question that arise when trying to follow MVVM pattern the first time.

It relies on several key concepts:
* Data Centric: All communication between View Controllers is done via the Data Model.
* Contract-based: Interaction between Data Model and clients is synchronous, and is based on one of the 3 contracts:
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

### Sourcery configuration
- Install sourcery 0.8.0 via CocoaPods
- Include  Sourcery_QuantwmProperties.stencil in YourProject/CodeGen/Templates directory
- Include  Sourcery_QuantwmModel.stencil in the YourProject/CodeGen/Templates directory
- Create YourProject/CodeGen/Generated directory
- Include Sourcery in your build phase before the compilation steps, with this command line:

```ruby
./Pods/Sourcery/bin/sourcery
    --sources YourProject
    --templates YourProject/CodeGen/Templates
    --output YourProject/CodeGen/Generated
```
- Build your project, and include the file CodeGen/Generated/Sourcery_QuantwmModel.generated.Swift in your project.

- Include the SourceryProtocols.swift file in your project, in order to have sourcery autogenerating these protocols for you.

```swift
protocol QWNode_S: QWNode {}
protocol QWRoot_S: QWRoot {}
protocol QWMediatorOwner_S: QWMediatorOwner {}
```

### Model QWNode instrumentation

For each class or struct belonging to the model and containing monitored properties:
- include QWNode_S protocol.
- add the sourcery inline inside (beware to correctly set the name of your class when copy-pasting this line)

```swift
class MyClass: QWNode_S {

  // sourcery:inline:MyClass.QuantwmDeclarationInline
  // sourcery:end  
}
```

- On build, Sourcery will implement QWNode Protocol between the inline Sourcery commands:

```swift
class MyClass: QWNode_S {

  // sourcery:inline:MyClass.QuantwmDeclarationInline
  // MARK: - Sourcery

  // QWNode protocol
  func getQWCounter() -> QWCounter {
    return qwCounter
  }
  let qwCounter = QWCounter(name:"PlaylistsCollection")
  func getPropertyArray() -> [QWProperty] {
      return PlaylistsCollectionQWModel.getPropertyArray()
  }
  // sourcery:end  
}
```

- Your Model shall have a root class, containing all the monitored properties.
This root class shall have the QWRoot_S protocol, and be a class, not a struct.




### Model Property generation

Then, for each monitored property of your QWNode:

- Make the property fileprivate (recommended)
- Start the name of the property with _ character.
- Add a sourcery command before your property
- Build:

```swift
class MyClass: QWNode_S {

  // sourcery: property
  fileprivate var _total: Int = -1

  // sourcery:inline:MyClass.QuantwmDeclarationInline

  ...

  // Quantwm Property: total
  static let totalK = QWPropProperty(
      propertyKeypath: \PlaylistsCollection.total,
      description: "_total")
  var total : Int {
    get {
      self.qwCounter.read(PlaylistsCollection.totalK)
      return _total
    }
    set {
      self.qwCounter.write(PlaylistsCollection.totalK)
      _total = newValue
    }
  }
  // sourcery:end  
}
```

Sourcery property command are composed of a main command,
followed by optional modifiers.

The main command is one of these 3 commands:
// sourcery: property
// sourcery: node
// sourcery: sharedProperty = "MyClass.propertyK"
// sourcery: root

Use property command to monitor a value type
Use node command to monitor a reference type, and the reference type shall be compliant with QWNode protocol.
Use sharedProperty command to share a property counter with an other property of your class. An update of any property sharing the same counter will increment this counter.

Use root command to deifne the root of your Model, in the QWRoot class.
```swift
// sourcery: root
static let dataModelK = QWRootProperty(rootType: DataModel.self,
                                       rootId: "dataModel")
```

Then the modifiers are:

// sourcery: contextual
Will be used in a future version of Quantwm, to indicate properties whose update shall not trigger a save of the document.

// sourcery: readOnly
If your property is readOnly, it will not generate the setter. This is useful for computed properties.

// sourcery: readOnly
If your property is readOnly, it will not generate the setter. This is useful for computed properties.






Computed Properties:

For the moment, Quantwm only support Read Only computed properties.



```swift
// MARK: - Computed Properties
// Shall be read-only
// Dependencies shall be added manually and injected in Model via sourcery dependency annotation.

static let selectedPlaylistDependencies =
    QWModel.root.selectedPlaylistId_Read +
    PlaylistsCollection.playlistsDataSourceMap(root: QWModel.root.playlistsCollection)

// sourcery: property
// sourcery: readOnly
// sourcery: dependency = "DataModel.selectedPlaylistDependencies"
fileprivate var _selectedPlaylist: Playlist? {
    if let playlistId = selectedPlaylistId {
        return playlistsCollection.playlist(playlistId: playlistId)
    }
    return nil
}
```swift







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
