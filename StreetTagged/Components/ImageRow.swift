//
//  ImageRow.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Eureka

open class ImageCell: Cell<UIImage>, CellType {
    @IBOutlet weak var image_View: UIImageView!

    public override func setup() {
        super.setup()
        backgroundColor = .white
        height = { 150 }
    }

    public override func update() {
        super.update()
        if (row.value != nil) {
            image_View.image = row.value!
        } else {

        }
    }
}

public final class ImageRow: Row<ImageCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ImageCell>(nibName: "CustomCell")
    }
}
