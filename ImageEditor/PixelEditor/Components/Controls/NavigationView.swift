//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import Foundation
import UIKit

open class NavigationView : UIStackView {

  public var didTapDoneButton: () -> Void = {}
  public var didTapCancelButton: () -> Void = {}

  private let saveButton = UIButton(type: .system)
  private let cancelButton = UIButton(type: .system)
  
  private let feedbacker = UIImpactFeedbackGenerator(style: .light)

  public init() {

    super.init(frame: .zero)

    axis = .horizontal
    distribution = .fillEqually

    heightAnchor.constraint(equalToConstant: 50).isActive = true

    addArrangedSubview(cancelButton)
    addArrangedSubview(saveButton)

    cancelButton.setTitle(L10n.cancel, for: .normal)
    saveButton.setTitle(L10n.done, for: .normal)

    cancelButton.setTitleColor(Style.default.black, for: .normal)
    saveButton.setTitleColor(Style.default.black, for: .normal)

    cancelButton.titleLabel!.font = UIFont.systemFont(ofSize: 17)
    saveButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17)

    cancelButton.addTarget(self, action: #selector(_didTapCancelButton), for: .touchUpInside)
    saveButton.addTarget(self, action: #selector(_didTapSaveButton), for: .touchUpInside)
  }

  public required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc
  private func _didTapSaveButton() {
    didTapDoneButton()
    feedbacker.impactOccurred()
  }

  @objc
  private func _didTapCancelButton() {
    didTapCancelButton()
    feedbacker.impactOccurred()
  }
}
