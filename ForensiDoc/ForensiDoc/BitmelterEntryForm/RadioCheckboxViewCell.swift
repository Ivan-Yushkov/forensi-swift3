//
//  RadioCheckboxViewCell.swift
//  BitmelterEntryForm
//
//  Created by Andrzej Czarkowski on 22/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

open class RadioCheckboxViewCell: UITableViewCell {
    @IBOutlet var off: UIImageView!
    @IBOutlet var on: UIImageView!
    @IBOutlet var optionTitle: UILabel!
    
    open func setImagesAsRadio(_ isRadio: Bool) {
        let bundle = Bundle.main
        if isRadio {
            if let radioOn = UIImage(named: "Radio-On", in: bundle, compatibleWith: nil) {
                on.image = radioOn
            }
            if let radioOff = UIImage(named: "Radio-Off", in: bundle, compatibleWith: nil) {
                off.image = radioOff
            }
        } else {
            if let checkboxOn = UIImage(named: "Checkbox-On", in: bundle, compatibleWith: nil) {
                on.image = checkboxOn
            }
            if let checkboxOff = UIImage(named: "Checkbox-Off", in: bundle, compatibleWith: nil) {
                off.image = checkboxOff
            }
        }
    }
    
    open func setValueSelected(_ isSelected: Bool) {
        if isSelected {
            on.alpha = 1.0
            off.alpha = 0.0
        } else {
            on.alpha = 0.0
            off.alpha = 1.0
        }
    }
}
