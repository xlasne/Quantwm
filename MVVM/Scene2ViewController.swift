//
//  Scene2ViewController.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

// KEY POINTS
// - View Controller are not aware of the content / context of parent/child view controllers
// - View Controller belongs to the View Controller hierarchy, and may be present or not

// - View Controller only discuss with their matching View Model
// - View Controller are responsible for register/unregister with their matching view model

// - View Controller contains an Input Section with update toward view model and no UI refresh
// - View Controller contains a Refresh Section with UI refresh and no update

import Cocoa

class Scene2ViewController: NSViewController, NSTextFieldDelegate {

  override var nibName: String? {
    return "Scene2ViewController"
  }

  //View Model
  var sceneName : String = "Scene2ViewController"
  var viewModel : Scene2ViewModel?
  var keySetObserverId: NSUUID?

  @IBOutlet weak var textField: NSTextField!
  @IBOutlet weak var label: NSTextField!
  @IBOutlet weak var imageView: NSImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.

    self.textField.target = self
    self.textField.delegate = self
    self.textField.action = #selector(Scene2ViewController.numberFieldUpdated(_:))
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    guard let document = self.representedObject as? Document else { return }

    self.viewModel = Scene2ViewModel(dataModel: document.dataModel, viewController: self)

    self.viewModel?.updateActionAndRefresh(owner: self) {

      self.viewModel?.registerObserver(target: self,
                               registrationDesc: Scene2ViewController.refreshViewREG,
                               name:sceneName)

      self.viewModel?.registerObserver(target: self,
                               registrationDesc:Scene2ViewController.refreshColorREG,
                               name: sceneName+"Color")
      self.toogleColor()
    }
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    print("View Did Appear: Scene2ViewController")
  }


  override func viewWillDisappear() {
    self.viewModel?.unregisterAll(self)
    self.viewModel = nil
    super.viewWillDisappear()
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
    self.viewModel?.setValue2(numberStr, focus: sender)
  }

  func toogleColor()
  {
    self.viewModel?.toggleImageColor()
  }

  //MARK: - Refresh Section

  static let refreshViewREG = RegisterDescription(
    selector: #selector(Scene2ViewController.refreshView),
    keypathSet:
    Scene2ViewModel.getFocusKeypathSet +
      Scene2ViewModel.getValue2KeypathSet +
      Scene2ViewModel.getSumKeypathSet,
    name: nil,
    maximumAllowedRegistrationWithSameTypeSelector: 2)

  func refreshView()
  {
    if let vm = self.viewModel
    {
      let focus = viewModel?.getFocus()
      if focus != textField
      {
        textField.stringValue = vm.getValue2()
      } else {
        print("Scene2 VC: Focus ignored")
      }
      if let sumVal = vm.getSum()
      {
        label.stringValue = "Sum 1 + 2: \(sumVal)"
      } else {
        label.stringValue = "Sum 1 + 2: _"
      }
    }
  }


  //MARK: - Refresh Section
  static let refreshColorREG = RegisterDescription(
    selector: #selector(Scene2ViewController.refreshColor),
    keypathSet: Scene2ViewModel.getColorKeypathSet,
    name: nil,
    maximumAllowedRegistrationWithSameTypeSelector: 2)

  func refreshColor()
  {
    if let color = viewModel?.getColor()
    {
      let size = self.imageView.frame.size
      let image = Helper.generateRoundedCornerImage(color, size: size, inset: 4.0)
      self.imageView.image = image
    }
  }
}
