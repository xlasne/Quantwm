//
//  DelayedSumProcessor.swift
//  MVVM
//
//  Created by Xavier Lasne on 09/04/16.
//  Copyright © 2016 XL Software Solutions
//

// Owned by Data Model
// Example of performing processing in background
// After background update, update data model on the main thread
//  and triggers UI refresh via Context Mgr


import Foundation

class DelayedSumProcessor: NSObject
{

  weak var dataModel : DataModel?

  override init()
  {
    super.init()
  }

  deinit
  {
    self.dataModel?.repositoryObserver.displayUsage(owner:self)
  }

  func register()
  {
    let obs1 = KeypathDescription(root:DataModel.dataModelK, chain: [DataModel.number1K])
    let obs2 = KeypathDescription(root:DataModel.dataModelK, chain: [DataModel.number2K])
    self.dataModel?.repositoryObserver.registerObserver(
      target: self,
      selector: #selector(DelayedSumProcessor.startProcessing),
      keypathDescriptionSet: Set([obs1,obs2]),
      name: "DelayedSumProcessor")
  }

  func startProcessing()
  {
    let completionHandler = { (numVal:Int)->() in
      DispatchQueue.main.async {[weak self] _ in
        // No locking needed.
        // Modifications are performed while on the main thread which serialize update
        self?.dataModel?.sumOfNumber = numVal
        self?.dataModel?.repositoryObserver.refreshUI()
      }
    }

    if let number1 = self.dataModel?.observedSelf.number1,
      let number2 = self.dataModel?.observedSelf.number2
    {
        DispatchQueue.global().async {
        // DO SOMETHING ON THE BACKGROUND THREAD
        // Avoid threading conflict with Data Model
        sleep(2)
        let sumVal = number1 + number2
        completionHandler(sumVal)
      }
    }

  }
}
