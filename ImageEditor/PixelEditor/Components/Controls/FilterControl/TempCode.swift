//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

enum TempCode {
  
  static func layout(navigationView: NavigationView, slider: StepSlider, in view: UIView) {
    
    let containerGuide = UILayoutGuide()
    
    view.addLayoutGuide(containerGuide)
    view.addSubview(slider)
    view.addSubview(navigationView)
    
    slider.translatesAutoresizingMaskIntoConstraints = false
    
    navigationView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      
      containerGuide.topAnchor.constraint(equalTo: slider.superview!.topAnchor),
      containerGuide.rightAnchor.constraint(equalTo: slider.superview!.rightAnchor, constant: -44),
      containerGuide.leftAnchor.constraint(equalTo: slider.superview!.leftAnchor, constant: 44),
      
      slider.topAnchor.constraint(greaterThanOrEqualTo: containerGuide.topAnchor),
      slider.rightAnchor.constraint(equalTo: containerGuide.rightAnchor),
      slider.leftAnchor.constraint(equalTo: containerGuide.leftAnchor),
      slider.bottomAnchor.constraint(lessThanOrEqualTo: containerGuide.bottomAnchor),
      slider.centerYAnchor.constraint(equalTo: containerGuide.centerYAnchor),
      
      navigationView.topAnchor.constraint(equalTo: containerGuide.bottomAnchor),
      navigationView.rightAnchor.constraint(equalTo: navigationView.superview!.rightAnchor),
      navigationView.leftAnchor.constraint(equalTo: navigationView.superview!.leftAnchor),
      navigationView.bottomAnchor.constraint(equalTo: navigationView.superview!.bottomAnchor),
      ])

  }
}
