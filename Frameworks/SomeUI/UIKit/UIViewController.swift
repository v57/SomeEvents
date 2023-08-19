//
//  UIViewController.swift
//  Some
//
//  Created by Дмитрий Козлов on 2/13/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

extension UIViewController {
  public func push(_ viewController: UIViewController?) {
    guard let viewController = viewController else { return }
    navigationController?.pushViewController(viewController, animated: true)
  }
  public func present(_ viewController: UIViewController?) {
    guard let viewController = viewController else { return }
    self.present(viewController, animated: true, completion: nil)
  }
  public static var root: UIViewController? {
    return UIApplication.shared.windows.first?.rootViewController
  }
}
