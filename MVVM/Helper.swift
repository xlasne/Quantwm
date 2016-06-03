//
//  Helper.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

import AppKit


class Helper
{

  class func addToContainerView(myView: NSView, subView subViewZ: NSView?) {
    if let subView = subViewZ
    {
      myView.addSubview(subView)

      let views = ["view": myView, "subView": subView]

      subView.translatesAutoresizingMaskIntoConstraints = false

      let constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subView]-0-|", options: .AlignAllCenterY, metrics: nil, views: views)
      myView.addConstraints(constH)
      let constW = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subView]-0-|", options: .AlignAllCenterX, metrics: nil, views: views)
      myView.addConstraints(constW)
    }
  }

  class func documentForViewController(viewController: NSViewController) -> Document?
  {
    guard let window = viewController.view.window else { return nil}
    guard let document = NSDocumentController.sharedDocumentController().documentForWindow(window) as? Document else { return nil }
    return document
  }

  class func generateRoundedCornerImage(color: NSColor, size: CGSize, inset : CGFloat) -> NSImage
  {
    let image = NSImage(size: size)
    image.lockFocus()

    let x = inset
    let y = inset
    let w = size.width  - 2 * inset
    let h = size.height - 2 * inset
    let rect = NSMakeRect(x,y,w,h)

    let ovalPath = NSBezierPath(roundedRect: rect, xRadius: 4,yRadius: 4)
    color.setFill()
    ovalPath.fill()

    image.unlockFocus()
    return image
  }


}
