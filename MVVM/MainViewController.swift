//
//  ViewController.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//


import Cocoa

class MainViewController: NSViewController {

  // MARK: Interfaces
  weak var document: Document?
  var viewModel: MainViewModel?

  @IBOutlet weak var viewTop : NSView!
  @IBOutlet weak var viewBottomLeft : NSView!
  @IBOutlet weak var viewBottomRight : NSView!

  var vc1 : Scene1ViewController?
  var vc2 : Scene2ViewController?
  var vc3 : Scene2ViewController?

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let document = Helper.documentForViewController(self) else { return }
    self.document = document
    self.viewModel = MainViewModel(dataModel: document.dataModel, viewController: self)

    self.viewModel?.updateActionAndRefresh(owner: self) {
      self.viewModel?.registerObserver(target: self,
                               registrationDesc: MainViewController.refreshUIREG)
    }
  }

  override func viewWillDisappear() {
    self.viewModel?.unregisterAll(self)
    super.viewWillDisappear()
    self.viewModel = nil
  }


  //MARK: refreshSum
  static let refreshUIREG = RegisterDescription(
    selector: #selector(MainViewController.refreshUI),
    keypathSet: MainViewModel.leftViewPresentKeypathSet +
      MainViewModel.rightViewPresentKeypathSet,
    name: "MainViewController",
    configurationPriority: 1)

  func refreshUI()
  {
    // Enclosed in a Update transaction when called by refreshUIREG

    // Parent View Controller shall create and initialize their child view controller
    // with their matching view models, then let them handle their live via their own view model

    self.displayTopView()
    self.displayLeftView()
    self.displayRightView()
  }

  func displayTopView()
  {
    if self.vc1 == nil {
      let vc1 = Scene1ViewController()
      vc1.representedObject = document
      self.vc1 = vc1
      self.addChildViewController(vc1)
      Helper.addToContainerView(self.viewTop, subView: vc1.view)
    }
  }

  func displayLeftView()
  {
    guard let isPresent = self.viewModel?.leftViewPresent else { return }
    if !isPresent
    {
      if let vc = self.vc2 {
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
        self.vc2 = nil
      }
    } else {
      if self.vc2 == nil {
        let vc2 = Scene2ViewController()
        self.vc2 = vc2
        vc2.representedObject = document
        vc2.sceneName = "Scene2ViewController"
        self.addChildViewController(vc2)
        Helper.addToContainerView(self.viewBottomLeft, subView: vc2.view)
      }
    }
  }

  func displayRightView()
  {
    guard let isPresent = self.viewModel?.rightViewPresent else { return }
    if !isPresent
    {
      if let vc = self.vc3 {
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
        self.vc3 = nil
      }
    } else {
      if self.vc3 == nil {
        let vc3 = Scene2ViewController()
        vc3.representedObject = document
        vc3.sceneName = "Scene3ViewController"
        self.vc3 = vc3
        self.addChildViewController(vc3)
        Helper.addToContainerView(self.viewBottomRight, subView: vc3.view)
      }
    }
  }
  
}


