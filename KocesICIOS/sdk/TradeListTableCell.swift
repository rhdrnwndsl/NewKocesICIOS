//
//  TradeListTableCell.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/07.
//

import Foundation
import UIKit
class TradeListTableCell:UITableViewCell{
    private var _id:Int = 0
    var id:Int {  get{ return _id }
        set(value){ _id = value }
    }
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_money: UILabel!
    @IBOutlet weak var lbl_type: UILabel!
    @IBOutlet weak var lbl_cancel: UILabel!
    
}
