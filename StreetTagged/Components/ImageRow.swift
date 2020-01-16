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

/*
public class ImageCell: Cell<UIImage>, CellType {
    //public var imView : UIImageView?
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func setup() {
        super.setup()
        backgroundColor = .white
        height = { 150 }
        
        //imView = UIImageView(frame:CGRect(x: 10, y: 10, width: 100, height: 100))
        //imView!.backgroundColor = .red
        //self.addSubview(imView!)
    }

    public override func update() {
        super.update()
        print("update")
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
public final class ImageRow: Row<ImageCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ImageCell>(nibName: "CustomCell" , bundle: Bundle.main)
    }
}*/

// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
open class CustomCell: Cell<Bool>, CellType {
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var label: UILabel!

    /*required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }*/
    
    public override func setup() {
        super.setup()
        //switchControl.addTarget(self, action: #selector(CustomCell.switchValueChanged), for: .valueChanged)
    }

    func switchValueChanged(){
        //row.value = switchControl.on
        row.updateCell() // Re-draws the cell which calls 'update' bellow
    }

    public override func update() {
        super.update()
        backgroundColor = (row.value ?? false) ? .white : .black
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
public final class CustomRow: Row<CustomCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CustomCell>(nibName: "CustomCell")
    }
}
