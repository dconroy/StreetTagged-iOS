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

public class ImageCell: Cell<Bool>, CellType {

    public override func setup() {
        super.setup()
        backgroundColor = .white
        height = { 150 }
    }

    public override func update() {
        super.update()
        //backgroundColor = (row.value ?? false) ? .white : .black
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
public final class ImageRow: Row<ImageCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ImageCell>()
    }
}
