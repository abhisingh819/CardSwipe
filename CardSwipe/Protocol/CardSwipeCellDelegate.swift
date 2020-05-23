//
//  CardSwipeCellDelegate.swift
//  CardSwipe
//
//  Created by Abhinav Singh on 4/26/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit

protocol CardSwipeCellDelegate: class {
    func actionOnButtonClick(text:String, forIndex: Int)
    func cellDidOpen(cell: UITableViewCell)
    func cellDidClose(cell: UITableViewCell)
}
