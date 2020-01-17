//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import Foundation
import UIKit

open class DoodleControlBase : ControlBase {

}

public final class DoodleControl : DoodleControlBase {

  private let navigationView = NavigationView()

  public override func setup() {

    super.setup()

    backgroundColor = Style.default.control.backgroundColor

    addSubview(navigationView)

    navigationView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      navigationView.rightAnchor.constraint(equalTo: navigationView.superview!.rightAnchor),
      navigationView.leftAnchor.constraint(equalTo: navigationView.superview!.leftAnchor),
      navigationView.bottomAnchor.constraint(equalTo: navigationView.superview!.bottomAnchor),
      navigationView.topAnchor.constraint(greaterThanOrEqualTo: navigationView.superview!.topAnchor),
      ])

    navigationView.didTapCancelButton = { [weak self] in

      self?.pop(animated: true)
    }

    navigationView.didTapDoneButton = { [weak self] in

      self?.pop(animated: true)
    }
  }
}
