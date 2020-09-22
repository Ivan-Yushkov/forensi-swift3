//
//  BitmelterEntryForm.swift
//  BitmelterEntryForm

import Foundation

public protocol EntryFormFactoryProtocol {
    func getTableView(_ entryForm: EntryForm) -> UITableViewCell?
    func selectedEntryForm(_ entryForm: EntryForm)
}

open class EntryFormFactory : NSObject, UITableViewDataSource, UITableViewDelegate{
    fileprivate let _repository: EntryFormRepository
    fileprivate let _tableViewDataSource: UITableViewDataSource? = .none
    fileprivate let _delegate: EntryFormFactoryProtocol?
    fileprivate var _entryForms: Array<EntryForm>
    fileprivate let _textCellIdentifier: String
    
    fileprivate override init(){
        _delegate = .none
        _repository = EmptyFormRepository()
        _entryForms = Array<EntryForm>()
        _textCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    
    open var HasMultipleEntryForms: Bool {
        get {
            return _entryForms.count > 1
        }
    }
    
    open var EntryForms: [EntryForm] {
        get {
            return _entryForms
        }
    }
    
    public init(repository: EntryFormRepository, delegate: EntryFormFactoryProtocol?, doNotCheckForHiddenFields: Bool){
        _delegate = delegate
        _textCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _repository = repository
        let specs = repository.LoadJSONFormSpecs()
        _entryForms = Array<EntryForm>()
        for spec in specs {
            _entryForms.append(EntryForm(jsonSpec: spec, doNotCheckForHiddenFields: doNotCheckForHiddenFields))
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _entryForms.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let ef = _entryForms[indexPath.row]
        if let d = _delegate {
            if let c = d.getTableView(ef) {
                return c
            }
        }
        
        var c: UITableViewCell? = .none
        
        //TODO:Register cell in the constructor I guess
        if let cDeque = tableView.dequeueReusableCell(withIdentifier: _textCellIdentifier) {
            c = cDeque
        } else {
            c = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: _textCellIdentifier)
        }
        
        if let ret = c {
            ret.textLabel?.text = ef.Title
            ret.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return ret
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        shouldDisplayEntryFormForIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        shouldDisplayEntryFormForIndexPath(indexPath)
    }
    
    fileprivate func shouldDisplayEntryFormForIndexPath(_ indexPath: IndexPath){
        if let delegate = _delegate {
            let ef = _entryForms[indexPath.row]
            delegate.selectedEntryForm(ef)
        }
    }
}

