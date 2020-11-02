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
    fileprivate var delegate: SavedEntryFormCellShouldGenerateReportDelegate?
    fileprivate var entryForm: EntryForm?
    
    
    @IBOutlet var reportTitle: UILabel!
    @IBOutlet var reportSubtitle: UILabel!
    @IBOutlet var reportExtraInformation: UILabel!
    
    @IBOutlet var generateReportBtn: UIButton!
    @IBOutlet var actionReportBtn: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func generateRportTapped(_ sender: AnyObject) {
        if let delegate = delegate, let entryForm = entryForm {
            delegate.generateReportForEntryForm(entryForm)
        }
    }
    
    @IBAction func actionReportBtnTapped(_ sender: AnyObject) {
        if let delegate = delegate, let entryForm = entryForm {
            delegate.runActionForEntryFormWithGeneratedReport(entryForm)
        }
    }
    
    open func setSavedEntryFormCell(_ delegate: SavedEntryFormCellShouldGenerateReportDelegate, entryForm: EntryForm) {
        self.delegate = delegate
        self.dateLabel.text = entryForm.reportDate
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
