//
//  MainViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 26/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

class MainViewController: BaseViewController, EntryFormFactoryProtocol, UITableViewDelegate, UITableViewDataSource {
    fileprivate var _entryFormFactory: EntryFormFactory? = nil
    fileprivate var _eeee: EntryForm? = nil
    @IBOutlet var mainTbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kDialogTitleForensiDoc
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "Btn-Settings"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MainViewController.settingsButtonTapped(_:)))
        
        self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        
        self.navigationController?.navigationBar.isTranslucent = true
        
        _entryFormFactory = EntryFormFactory(repository: ForensiDocEntryFormRepository(), delegate: self, doNotCheckForHiddenFields: false)
        self.mainTbl.dataSource = _entryFormFactory
        self.mainTbl.delegate = _entryFormFactory
    }
    
    @objc func settingsButtonTapped(_ sender: AnyObject) {
        let settingsViewController: SettingsViewController? = nil
        self.navigateToView(settingsViewController)
    }
    
    func getTableView(_ entryForm: EntryForm) -> UITableViewCell? {
        return .none
    }
    
    func selectedEntryForm(_ entryForm: EntryForm) {
        let entryFormDetails: EntryFormDetailsViewController = EntryFormDetailsViewController(nibName:"EntryFormDetailsView", bundle:nil)
        entryFormDetails.entryForm = entryForm
        
        DispatchQueue.main.async(execute: {
            self.navigationController?.pushViewController(entryFormDetails, animated: true)
        })
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
