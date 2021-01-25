//
//  EntryFormDetailsFactory.swift
//  BitmelterEntryForm

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public protocol EntryFormDetailFactoryProtocol {
    func getTableView(_ entryForm: EntryForm) -> UITableViewCell?
    func viewEntryForm(_ entryForm: EntryForm)
    func shouldReload()
    func generateReportForEntryForm(_ entryForm: EntryForm)
    func runActionForEntryFormWithGeneratedReport(_ entryForm: EntryForm)
}

open class EntryFormDetailsFactory : NSObject, UITableViewDataSource, UITableViewDelegate, SavedEntryFormCellShouldGenerateReportDelegate {
    fileprivate let _repository: EntryFormRepository
    fileprivate let _formId: Int
    fileprivate let _tableViewDataSource: UITableViewDataSource? = .none
    fileprivate let _delegate: EntryFormDetailFactoryProtocol?
    fileprivate var _tableView: UITableView?
    fileprivate var _entryForms: Array<EntryForm>
    fileprivate let _textCellIdentifier: String
    
    public init(tableView: UITableView, repository: EntryFormRepository, formId: Int, delegate: EntryFormDetailFactoryProtocol?){
        _formId = formId
        _delegate = delegate
        _textCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _repository = repository
        _tableView = tableView
        _entryForms = repository.LoadSavedFormForFormId(formId)
        super.init()
        self.reloadEverything(true)
        
        var nibName = "SavedEntryFormCell"
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            nibName = nibName + "_iPad"
        }
        
        let bundle: Bundle = Bundle.main
        let nib = UINib(nibName: nibName, bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: _textCellIdentifier)
    }
    
    open func reload() {
       self.reloadEverything(false)
    }
    
    open func finishedGeneratingReport(_ taskIdentifier: Int, reportContent: String) {
        for ef in self._entryForms {
            if ef.DownloadInfo.taskIdentifier == taskIdentifier {
                ef.DownloadInfo.downloadComplete = true
                ef.DownloadInfo.isDownloading = false
                ef.SaveDownloadedReportResponse(reportContent)
                break
            }
        }
    }
    
    open func completedGeneratingReportWithError(_ taskIdentifier: Int, error: NSError) {
        for ef in self._entryForms {
            if ef.DownloadInfo.taskIdentifier == taskIdentifier {
                ef.DownloadInfo.downloadComplete = true
                ef.DownloadInfo.isDownloading = false
                break
            }
        }
    }
    
    open func GetEntryFormForDownloadTask(_ taskIdentifier: Int) -> EntryForm? {
        for ef in self._entryForms {
            if ef.DownloadInfo.taskIdentifier == taskIdentifier {
                return ef
            }
        }
        return .none
    }
    
    open func downloadingGeneratedReport(_ taskIdentifier: Int, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for ef in self._entryForms {
            if ef.DownloadInfo.taskIdentifier == taskIdentifier {
                if totalBytesExpectedToWrite != 0 {
                    ef.DownloadInfo.downloadProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite);
                }
                break
            }
        }
    }
    
    open func beginGeneratingReportForEntryForm(_ taskIdentifier: Int, entryForm: EntryForm) {
        for ef in self._entryForms {
            if ef.uuid == entryForm.uuid {
                ef.DownloadInfo.taskIdentifier = taskIdentifier
                ef.DownloadInfo.isDownloading = true
                break
            }
        }
    }
    
    fileprivate func getOwnCell() -> SavedEntryFormCell? {
        let bundle: Bundle = Bundle.main
        var nibName = "SavedEntryFormCell"
        if ViewsHelpers.IsiPad() {
            nibName = "SavedEntryFormCell_iPad"
        }
        let objects = bundle.loadNibNamed(nibName, owner: self, options: nil)
        if objects?.count > 0 {
            if let c = objects![0] as? SavedEntryFormCell {
                return c
            }
        }
        return .none
    }
    
    private func sortEntryFormsArray(array: [EntryForm]) -> [EntryForm] {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        var sortedArray = [EntryForm]()
        
        sortedArray = array.sorted(by: {
            let a = $0.SavedInFolder
            let b = $1.SavedInFolder
            return df.date(from: a) < df.date(from: b)
        })
        
        return sortedArray
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _entryForms.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        let sorted = sortEntryFormsArray(array: _entryForms)
        let entryForm = sorted[indexPath.row] //_entryForms[indexPath.row]
        
        if let d = _delegate {
            if let cell = d.getTableView(entryForm) {
                return cell
            }
        }
        
        var cell: SavedEntryFormCell?
        
        //TODO:Register cell in the constructor I guess
        if let cDeque = tableView.dequeueReusableCell(withIdentifier: _textCellIdentifier) as? SavedEntryFormCell {
            cell = cDeque
        } else {
            cell = getOwnCell()
        }
        
        cell?.contentView.isUserInteractionEnabled = true
        
        if let ret = cell {
            cell?.setSavedEntryFormCell(self, entryForm: entryForm)
            //ret.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
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
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let entryForm = _entryForms[indexPath.row]
            _repository.DeleteEntryForm(entryForm)
            _entryForms = _repository.LoadSavedFormForFormId(_formId)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            tableView.endUpdates()
        }
    }
    
    fileprivate func shouldDisplayEntryFormForIndexPath(_ indexPath: IndexPath){
        if let delegate = _delegate {
            let ef = _entryForms[indexPath.row]
            delegate.viewEntryForm(ef)
        }
    }
    
    fileprivate func reloadEverything(_ inInit: Bool) {
        if !inInit {
            _entryForms = _repository.LoadSavedFormForFormId(_formId)
            _delegate?.shouldReload()
        }
    }
    
    open func generateReportForEntryForm(_ entryForm: EntryForm) {
        if let d = _delegate {
            d.generateReportForEntryForm(entryForm)
        }
    }
    
    open func runActionForEntryFormWithGeneratedReport(_ entryForm: EntryForm) {
        if let d = _delegate {
            d.runActionForEntryFormWithGeneratedReport(entryForm)
        }
    }
}
