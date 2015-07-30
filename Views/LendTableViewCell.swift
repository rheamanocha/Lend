//
//  LendTableViewCell.swift
//  Lend
//
//  Created by Rhea on 7/30/15.
//  Copyright (c) 2015 Rhea. All rights reserved.
//

import Foundation
import UIKit

class LendTableViewCell: UITableViewCell {
    
    // initialize the date formatter only once, using a static computed property
    static var dateFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
        }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var note: Note? {
        didSet {
            if let note = note, titleLabel = titleLabel, dateLabel = dateLabel {
                self.titleLabel.text = note.title
                self.dateLabel.text = LendTableViewCell.dateFormatter.stringFromDate(note.modificationDate)
            }
        }
    }
    
}
