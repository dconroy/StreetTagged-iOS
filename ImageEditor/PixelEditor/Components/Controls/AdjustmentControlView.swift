//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

open class AdjustmentControlBase : ControlBase {

}

public final class AdjustmentControl : AdjustmentControlBase {

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

      self?.context.action(.endAdjustment(save: false))
        self?.pop(animated: true)
    }

    navigationView.didTapDoneButton = { [weak self] in

      self?.context.action(.endAdjustment(save: true))
        self?.pop(animated: true)
    }

  }

  public override func didMoveToSuperview() {
    super.didMoveToSuperview()

    if superview != nil {
      context.action(.setMode(.adjustment))
    } else {
      context.action(.setMode(.preview))
    }

  }

}

