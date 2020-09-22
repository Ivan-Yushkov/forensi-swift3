//
//  SettingsViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 20/01/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var settingsTable: UITableView!
    var sectionAccount = -1
    var sectionMultipleForms = -1
    var sectionFormSettings = -1
    var sectionFormFirstLevelGroupsVisibility = -1
    var sectionDebug = -1
    var sectionAbout = -1
    
    let cellIdentifier = "myCell"
    let entryFormFactory = EntryFormFactory(repository: ForensiDocEntryFormRepository(), delegate: .none, doNotCheckForHiddenFields: true)
    let bitmelterAccountManager = BitmelterAccountManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kDialogTitleSettings
        self.settingsTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
    }
    
}
