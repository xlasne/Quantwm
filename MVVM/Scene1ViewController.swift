//
//  Scene1ViewController.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

// KEYPOINT 3
// - View Controller are not aware of the content / context of parent/child view controllers
// - View Controller belongs to the View Controller hierarchy, and may be present or not

// - View Controller only discuss with their matching View Model
// - View Controller are responsible for register/unregister with their matching view model

// - View Controller contains an Input Section with update toward view model and no UI refresh
// - View Controller contains a Refresh Section with UI refresh and no update

import Cocoa

class Scene1ViewController: NSViewController, NSTextFieldDelegate {

  override var nibName: String? {
    return "Scene1ViewController"
  }

  //View Model
  var viewModel : Scene1ViewModel?

  @IBOutlet weak var textField: NSTextField!
  @IBOutlet weak var label: NSTextField!

  @IBOutlet weak var showHideLeft: NSButton!
  @IBOutlet weak var showHideRight: NSButton!

  @IBOutlet weak var addTransient: NSButton!
  @IBOutlet weak var addArray: NSButton!
  @IBOutlet weak var transientLabel: NSTextField!
  @IBOutlet weak var transientArrayLabel: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    self.textField.target = self
    self.textField.delegate = self
    self.textField.action = #selector(Scene1ViewController.numberFieldUpdated(_:))

    self.addTransient.target = self
    self.addTransient.action = #selector(Scene1ViewController.transientButtonAction(_:))
    self.addArray.target = self
    self.addArray.action = #selector(Scene1ViewController.transientAddtoArrayButtonAction(_:))
    self.showHideLeft.target = self
    self.showHideLeft.action = #selector(Scene1ViewController.showHideView(_:))
    self.showHideRight.target = self
    self.showHideRight.action = #selector(Scene1ViewController.showHideView(_:))

  }

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let document = self.representedObject as? Document else { return }
    self.viewModel = Scene1ViewModel(dataModel: document.dataModel, viewController: self)

    // Registration
    self.viewModel?.updateActionAndRefresh(owner: self) {
      self.viewModel?.register(target: self,
                               registrationDesc: Scene1ViewController.refreshTextFieldREG)

      self.viewModel?.register(target: self,
                               registrationDesc: Scene1ViewController.refreshArraySumREG)

      self.viewModel?.register(target: self,
                               registrationDesc: Scene1ViewController.refreshTransientREG)

      self.viewModel?.register(target: self,
                               registrationDesc: Scene1ViewController.refreshInvSumREG)
    }
  }

  override func viewDidAppear() {
    super.viewDidAppear()
  }

  override func viewWillDisappear() {
    self.viewModel?.unregisterAll(self)
    super.viewWillDisappear()
    self.viewModel = nil
  }


  //MARK: - Input Section

  override func controlTextDidChange(obj: NSNotification) {
    if let sender = obj.object as? NSTextField where  sender == self.textField
    {
      self.numberFieldUpdated(sender)
    }
  }

  func numberFieldUpdated(sender: NSTextField)
  {
    let numberStr = self.textField.stringValue
    self.viewModel?.updateValue(numberStr, focus: sender)
  }

  func showHideView(sender: NSButton)
  {
    if sender == self.showHideLeft
    {
      self.viewModel?.toggleLeftView()
    }
    if sender == self.showHideRight
    {
      self.viewModel?.toggleRightView()
    }
  }

  func transientButtonAction(sender: NSButton)
  {
    self.viewModel?.toggleTransientAndRefresh()
  }

  func transientAddtoArrayButtonAction(sender: NSButton)
  {
    self.viewModel?.transientAddtoArray()
  }


  //MARK: - Refresh View

  static let refreshTextFieldREG = RegisterDescription(
    selector: #selector(Scene1ViewController.refreshTextField),
    keypathSet: Scene1ViewModel.getFocusKeypathSet + Scene1ViewModel.getValue1KeypathSet,
    name: "Scene1ViewControllerTextField")

  func refreshTextField()
  {
    guard let vm = self.viewModel else { return }
    let focus = vm.getFocus()
    if self.textField != focus {
      self.textField.stringValue = vm.value1
    } else {
      print("Scene1 VC: Focus ignored")
    }
  }

  //MARK: refreshSum

  static let refreshInvSumREG = RegisterDescription(
    selector: #selector(Scene1ViewController.refreshInvSum),
    keypathSet: Scene1ViewModel.getInvSumKeypathSet,
    name: "Scene1ViewControllerSum")

  func refreshInvSum()
  {
    guard let vm = self.viewModel else { return }
    if let sumVal = vm.getInvSum() {
      self.label.stringValue = "InvSum 1 + 2: \(sumVal)"
    } else {
      self.label.stringValue = "InvSum 1 + 2: _"
    }
  }

  //MARK: refreshTransient

  static let refreshTransientREG = RegisterDescription(
    selector: #selector(Scene1ViewController.refreshTransient),
    keypathSet: Scene1ViewModel.getTransientKeypathSet,
    name: "Scene1ViewControllerTransient")

  func refreshTransient()
  {
    guard let vm = self.viewModel else { return }
    if let transientVal = vm.getTransient() {
      self.transientLabel.stringValue = transientVal
    } else {
      self.transientLabel.stringValue = "no value defined"
    }
  }

  //MARK: refreshSum
  static let refreshArraySumREG = RegisterDescription(
    selector: #selector(Scene1ViewController.refreshArraySum),
    keypathSet: Scene1ViewModel.getArraySumKeypathSet,
    name: "Scene1ViewControllerArraySum")

  func refreshArraySum()
  {
    guard let vm = self.viewModel else { return }
    if let sumVal = vm.getArraySum() {
      self.transientArrayLabel.stringValue = "Sum: \(sumVal)"
    } else {
      self.transientArrayLabel.stringValue = "Sum: _"
    }
  }
  
}


