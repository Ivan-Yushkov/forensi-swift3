//
//  EntryFormDetailsViewController.swift
//  ForensiDoc

import Foundation
import MessageUI

class EntryFormDetailsViewController: BaseViewController, EntryFormDetailFactoryProtocol, MFMailComposeViewControllerDelegate {
    var _entryFormFactory: EntryFormDetailsFactory?
    fileprivate var _entryForm: EntryForm?
    fileprivate var _isMainView: Bool = false
    fileprivate var session: Foundation.URLSession?
    fileprivate var _alert: AnyObject?
    
    @IBOutlet var mainTbl: UITableView!
    
    var isMainView: Bool {
        get{
            return _isMainView
        }
        set {
            _isMainView = newValue
        }
    }
    
    internal var AlertProgress: AnyObject? {
        get{
            return _alert
        }
        set {
            _alert = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bundleIdentifier = Bundle.main.bundleIdentifier, bundleIdentifier.count > 0 {
            let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: bundleIdentifier)
            sessionConfiguration.httpMaximumConnectionsPerHost = 5
            
            self.session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: .none)
        } else {
            assertionFailure("Bundle identifier cannot be empty string!!!")
        }
        
        if isMainView {
            self.title = kDialogTitleForensiDoc
            let settingsButton = UIBarButtonItem(image: UIImage(named: "Btn-Settings"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(EntryFormDetailsViewController.settingsButtonTapped(_:)))
            self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        }
        
        //MARK: add report
        let newReportButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(EntryFormDetailsViewController.newReportTapped(_:)))
        self.navigationItem.setRightBarButton(newReportButton, animated: true)
        
        var entryFormId = 0
        if let ef = _entryForm {
            entryFormId = ef.FormId
        }
        
        //packed TableView
        _entryFormFactory = EntryFormDetailsFactory(tableView:self.mainTbl, repository: ForensiDocEntryFormRepository(), formId: entryFormId, delegate: self)
        self.mainTbl.dataSource = _entryFormFactory
        self.mainTbl.delegate = _entryFormFactory
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _entryFormFactory?.reload()
    }
        
    @objc func settingsButtonTapped(_ sender: AnyObject) {
        let settingsViewController: SettingsViewController? = nil
        self.navigateToView(settingsViewController)
    }
    
    @objc func newReportTapped(_ sender: AnyObject) {
        addNewEditEntryForm(entryForm, isAddingNew: true)
    }
    
    func getTableView(_ entryForm: EntryForm) -> UITableViewCell? {
        return .none
    }
    
    func shouldReload() {
        self.mainTbl.reloadData()
    }
    
    func viewEntryForm(_ entryForm: EntryForm) {
        addNewEditEntryForm(entryForm, isAddingNew: false)
    }
    
    func generateReportForEntryForm(_ entryForm: EntryForm) {
        if let _ = self.splitViewController?.view {
            AlertHelper.DisplayProgress(self, title: NSLocalizedString("Generating report", comment: ""), messages: [NSLocalizedString("Encrypting...", comment: "")], cancelCallback: .none, onDisplay: { (alert) in
                DebugLog.DLog("Begin of report generate process.")
                let encryptedData = EncryptJsonForSubmit.Encrypt(entryForm)
                AlertHelper.CloseDialog(alert, completion: { 
                    if let request = GenerateReportHelper.GetRequestForReport(encryptedData) {
                        if let downloadTask = self.session?.downloadTask(with: request) {
                            self._entryFormFactory?.beginGeneratingReportForEntryForm(downloadTask.taskIdentifier, entryForm: entryForm)
                            AlertHelper.DisplayProgress(self, title: NSLocalizedString("Generating report", comment: ""), messages: [NSLocalizedString("Uploading to server...", comment: "")], cancelCallback: .none, onDisplay: { (alert) in
                                self.AlertProgress = alert
                                downloadTask.resume()
                            })
                        }
                    } else {
                        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Unable to start generate report request", comment: ""), "Error (UTSGRR)"], callback: .none)
                    }
                })
            })
        }
    }
    
    func runActionForEntryFormWithGeneratedReport(_ entryForm: EntryForm) {
        if let reportNSURL = entryForm.GeneratedReportNSURL(), MFMailComposeViewController.canSendMail() {
             let fileName = reportNSURL.lastPathComponent 
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                
                //Set the subject and message of the email
                mailComposer.setSubject(NSLocalizedString("ForensiDoc report", comment: "Generated report email subject"))
                mailComposer.setMessageBody(NSLocalizedString("Please find the attached generated report.", comment: "Generated report message body"), isHTML: false)
                
                if let fileData = try? Data(contentsOf: reportNSURL as URL) {
                    mailComposer.addAttachmentData(fileData, mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", fileName: fileName)
                    self.present(mailComposer, animated: true, completion: nil)
                }
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func addNewEditEntryForm(_ entryForm: EntryForm?, isAddingNew: Bool) {
        if let entryForm = entryForm {
            if isAddingNew {
                
                if let rawJson = entryForm.toJSON().rawString(.utf8, options: .prettyPrinted) {
                    ///
                    let newEF = EntryForm(jsonSpec: rawJson, doNotCheckForHiddenFields: false)
                    if newEF.EnsureSavedInFolderSet() {
                        newEF.EnsureHiddenGroupsSet()
                        newEF.EnsureUUIDSet()
                        let newEntryForm: NewEntryFormViewController = NewEntryFormViewController(nibName:"NewEntryFormView", bundle: .none)
                        newEntryForm.entryForm = newEF
                        
                        DispatchQueue.main.async(execute: {
                            self.navigationController?.pushViewController(newEntryForm, animated: true)
                        })
                    }
                }
            } else {
                let newEntryForm: NewEntryFormViewController = NewEntryFormViewController(nibName:"NewEntryFormView", bundle: .none)
                newEntryForm.entryForm = entryForm
                
                DispatchQueue.main.async(execute: {
                    self.navigationController?.pushViewController(newEntryForm, animated: true)
                })
            }
        } else {
            //TODO:Popup message saying that we probably did not manage to create folder
        }
    }
}
