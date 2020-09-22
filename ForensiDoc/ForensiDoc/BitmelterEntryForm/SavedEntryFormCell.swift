//
//  SavedEntryFormCell.swift
//  BitmelterEntryForm
//
//  Created by Andrzej Czarkowski on 07/09/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

public protocol SavedEntryFormCellShouldGenerateReportDelegate {
    func generateReportForEntryForm(_ entryForm: EntryForm)
    func runActionForEntryFormWithGeneratedReport(_ entryForm: EntryForm)
}

open class SavedEntryFormCell: UITableViewCell {
    fileprivate var delegate: SavedEntryFormCellShouldGenerateReportDelegate? = .none
    fileprivate var entryForm: EntryForm? = .none
    
    
    @IBOutlet var reportTitle: UILabel!
    @IBOutlet var reportSubtitle: UILabel!
    @IBOutlet var reportExtraInformation: UILabel!
    
    @IBOutlet var generateReportBtn: UIButton!
    @IBOutlet var actionReportBtn: UIButton!
    
    
    @IBAction func generateRportTapped(_ sender: AnyObject) {
        if let d = delegate, let ef = entryForm {
            d.generateReportForEntryForm(ef)
        }
    }
    
    @IBAction func actionReportBtnTapped(_ sender: AnyObject) {
        if let d = delegate, let ef = entryForm {
            d.runActionForEntryFormWithGeneratedReport(ef)
        }
    }
    
    open func setSavedEntryFormCell(_ delegate: SavedEntryFormCellShouldGenerateReportDelegate, entryForm: EntryForm) {
        self.delegate = delegate
        self.entryForm = entryForm
        self.reportTitle.text =  entryForm.SavedAsTitle
        self.reportSubtitle.text = entryForm.SavedAsSubtitle
        self.reportExtraInformation.text = entryForm.SavedAsExtraInformation
        self.generateReportBtn.isEnabled = entryForm.isValid()
        if let _ = entryForm.GeneratedReportNSURL() {
            self.actionReportBtn.isEnabled = true
        } else {
            self.actionReportBtn.isEnabled = false
        }
    }
}
