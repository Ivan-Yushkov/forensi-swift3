//
//  SettingsViewControllerTableViewDataSource.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 20/01/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation
import MessageUI

extension SettingsViewController: EntryFormFieldDoneEditing, MFMailComposeViewControllerDelegate {
    var actions: [[Selector]] {
        get {
            let section0 = [
                #selector(SettingsViewController.editAccountDetailsTapped(_:)),
                #selector(SettingsViewController.changePasswordTapped(_:)),
                #selector(SettingsViewController.signOutTapped(_:))
            ]
            return  [section0]
        }
    }
    
    func editAccountDetailsTapped(_ sender: AnyObject?) {
        let accountDetailsViewController: AccountDetailsViewController? = nil
        self.navigateToView(accountDetailsViewController)
    }
    
    func changePasswordTapped(_ sender: AnyObject?) {
        AlertHelper.DisplayConfirmationDialog(self, title: "Confirm", messages: ["Do you want to change your password?"], okCallback: { () -> Void in
            
            }, cancelCallback: nil)
    }
    
    func signOutTapped(_ sender: AnyObject?) {
        AlertHelper.DisplayConfirmationDialog(self, title: "Confirm", messages: ["Do you want to sign out?"], okCallback: { () -> Void in
            
            }, cancelCallback: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == sectionAbout {
            let aboutViewController: AboutViewController? = nil
            self.navigateToView(aboutViewController)
        }else if indexPath.section == sectionDebug {
            DebugLog.DLog("Start of preparing debug data")
            let allEntryForms = MiscHelpers.GetAllEntryFormsForDebug()
            DebugLog.DLog("End of preparing debug data")
            if allEntryForms.count > 0 {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                
                //Set the subject and message of the email
                mailComposer.setSubject(NSLocalizedString("Debug data", comment: "Generated report email subject for debug data"))
                mailComposer.setMessageBody(NSLocalizedString("Please find the attached debug data.", comment: "Generated report message body for debug data"), isHTML: false)
                if let debugUrl = MiscHelpers.DebugLogNSURL() {
                    var error: NSError?
                    if (debugUrl as NSURL).checkResourceIsReachableAndReturnError(&error) {
                        if let debugData = try? Data(contentsOf: debugUrl as URL) {
                            mailComposer.addAttachmentData(debugData, mimeType: "text/plain", fileName: "debug.log")
                        }
                    }
                }
              
             /*
                for entryForm in allEntryForms {
                    let uuidString = UUID().uuidString
                    let uuidFileName = "\(uuidString)-post.txt"
                    let uuidFileNameSave = "\(uuidString)-rep.txt"
                    if let entryFormData = entryForm.postData.data(using: String.Encoding.utf8), let entryFormSaveData =  entryForm.jsonSave.data(using: String.Encoding.utf8) {
                        let base64Data = entryFormSaveData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        if let base64Data = base64Data.data(using: String.Encoding.utf8) {
                           // let gZippedEntryFormData = try! entryFormData.gzippedData()
                           // let gZippedBase64Data = try! base64Data.gzippedData()
                           // mailComposer.addAttachmentData(gZippedEntryFormData, mimeType: "text/plain", fileName: uuidFileName)
                           
                           // mailComposer.addAttachmentData(gZippedBase64Data, mimeType: "text/plain", fileName: uuidFileNameSave)
                           
                        }
                    }
                }
                */
                DebugLog.DLog("End of preparing debug data")
                self.present(mailComposer, animated: true, completion: nil)
            } else {
                AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error title on dialog"), messages: [NSLocalizedString("There is nothing to send", comment: "")], callback: .none)
            }
        } else if indexPath.section == sectionAccount {
            var s: Selector?
            if indexPath.section < actions.endIndex && indexPath.row < actions[indexPath.section].endIndex {
                s = actions[indexPath.section][indexPath.row]
            }
            
            if let sel = s {
                if self.canPerformAction(sel, withSender: nil) {
                    _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: sel, userInfo: nil, repeats: false)
                }
            }
        } else if indexPath.section == self.sectionMultipleForms {
            //TODO:This needs to be done at later stage
        } else if self.entryFormFactory.EntryForms.count > 0 {
            let onlyOneEntryForm = self.entryFormFactory.EntryForms[0]
            if indexPath.section == self.sectionFormSettings {
                if indexPath.row <= onlyOneEntryForm.Settings.endIndex {
                    let setting = onlyOneEntryForm.Settings[indexPath.row]
                    if let ff = MiscHelpers.CastEntryFormField(setting, Int.self) {
                        if let existingValue = EntryFormSettingsHelper.GetEntryFormSetting(onlyOneEntryForm.FormId, key: ff.id, Int.self) {
                            ff.values = existingValue
                        }
                        ViewsHelpers.HandleFormField(self, entryForm: onlyOneEntryForm, entryFormBaseFieldType: ff, doneEditing: self)
                    } else if let ff = MiscHelpers.CastEntryFormField(setting, Float.self) {
                        if let existingValue = EntryFormSettingsHelper.GetEntryFormSetting(onlyOneEntryForm.FormId, key: ff.id, Float.self) {
                            ff.values = existingValue
                        }
                        ViewsHelpers.HandleFormField(self, entryForm: onlyOneEntryForm, entryFormBaseFieldType: ff, doneEditing: self)
                    } else if let ff = MiscHelpers.CastEntryFormField(setting, Double.self) {
                        if let existingValue = EntryFormSettingsHelper.GetEntryFormSetting(onlyOneEntryForm.FormId, key: ff.id,Double.self) {
                            ff.values = existingValue
                        }
                        ViewsHelpers.HandleFormField(self, entryForm: onlyOneEntryForm, entryFormBaseFieldType: ff, doneEditing: self)
                    } else if let ff = MiscHelpers.CastEntryFormField(setting, String.self) {
                        if let existingValue = EntryFormSettingsHelper.GetEntryFormSetting(onlyOneEntryForm.FormId, key: ff.id,String.self) {
                            ff.values = existingValue
                        }
                        ViewsHelpers.HandleFormField(self, entryForm: onlyOneEntryForm, entryFormBaseFieldType: ff, doneEditing: self)
                    }
                }
            }
        }

    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionsCount = 0
        if self.bitmelterAccountManager.UsingUsernameAndPassword {
            self.sectionAccount = sectionsCount
            sectionsCount += 1
        }
        if self.entryFormFactory.HasMultipleEntryForms {
            self.sectionMultipleForms = sectionsCount
            sectionsCount += 1
        } else {
            if self.entryFormFactory.EntryForms.count > 0 {
                let onlyOneEntryForm = self.entryFormFactory.EntryForms[0]
                if onlyOneEntryForm.Settings.count > 0 {
                    self.sectionFormSettings = sectionsCount
                    sectionsCount += 1
                }
                if onlyOneEntryForm.FirstLevelGroups.count > 0 {
                    self.sectionFormFirstLevelGroupsVisibility = sectionsCount
                    sectionsCount += 1
                }
            }
        }
        
        //TODO:This is only for debug purposes
        //self.sectionDebug = sectionsCount
        //sectionsCount = sectionsCount + 1
        
        //About section
        self.sectionAbout = sectionsCount
        sectionsCount = sectionsCount + 1
        
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sectionAbout {
            return NSLocalizedString("About", comment: "Title of About section")
        } else if section == sectionDebug {
            return NSLocalizedString("Debug", comment: "This is only used while debugging")
        } else if section == sectionAccount {
            return NSLocalizedString("Account", comment: "Title of account section in Settings")
        } else if section == sectionMultipleForms {
            return NSLocalizedString("Forms", comment: "Title of forms section in Settings if there are multiple forms")
        } else if self.entryFormFactory.EntryForms.count > 0 {
            if section == self.sectionFormSettings {
                return NSLocalizedString("Form Settings", comment: "Title of form settings section in Settings if there is only single form and it has settings")
            }
            if section == self.sectionFormFirstLevelGroupsVisibility {
                return NSLocalizedString("Group Settings ", comment: "Title of forms section in Settings if there are multiple forms")
            }
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionAbout {
            return 1
        } else if section == sectionDebug {
            return 1
        } else if section == sectionAccount {
            return 3
        } else if section == sectionMultipleForms {
            return self.entryFormFactory.EntryForms.count
        } else if self.entryFormFactory.EntryForms.count > 0 {
            let onlyOneEntryForm = self.entryFormFactory.EntryForms[0]
            if section == self.sectionFormSettings {
                return onlyOneEntryForm.Settings.count
            }
            if section == self.sectionFormFirstLevelGroupsVisibility {
                return onlyOneEntryForm.FirstLevelGroups.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c: UITableViewCell
        var accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            c = cell
        } else {
            c = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
        }
        
        var title = "Title"
        
        if indexPath.section == sectionAbout {
            title = NSLocalizedString("About ForensiDoc", comment: "Title of the about ForensiDoc cell in Settings")
        } else if indexPath.section == sectionDebug {
            title = NSLocalizedString("Send debug details", comment: "Title of the debug cell in settings")
        } else if indexPath.section == sectionAccount {
            if indexPath.row == 0 {
                title = NSLocalizedString("Edit Account Details", comment: "Edit account details row title in Settings")
            } else if indexPath.row == 1 {
                title = NSLocalizedString("Change Password", comment: "Change password row title in Settings")
            } else if indexPath.row == 2 {
                title = NSLocalizedString("Sign out", comment: "Sign out row title in Settings")
            }
        } else if indexPath.section == sectionMultipleForms {
            if indexPath.row <= self.entryFormFactory.EntryForms.endIndex {
                let entryForm = self.entryFormFactory.EntryForms[indexPath.row]
                title = entryForm.Title
            }
        } else if self.entryFormFactory.EntryForms.count > 0 {
            let onlyOneEntryForm = self.entryFormFactory.EntryForms[0]
            if indexPath.section == self.sectionFormSettings {
                if indexPath.row <= onlyOneEntryForm.Settings.endIndex {
                    let setting = onlyOneEntryForm.Settings[indexPath.row]
                    if let ff = MiscHelpers.CastEntryFormField(setting, Int.self) {
                        title = ff.title
                    } else if let ff = MiscHelpers.CastEntryFormField(setting, Float.self) {
                        title = ff.title
                    } else if let ff = MiscHelpers.CastEntryFormField(setting, Double.self) {
                        title = ff.title
                    } else if let ff = MiscHelpers.CastEntryFormField(setting, String.self) {
                        title = ff.title
                    }
                }
            }
            if indexPath.section == self.sectionFormFirstLevelGroupsVisibility {
                accessoryType = .none
                if indexPath.row <= onlyOneEntryForm.FirstLevelGroups.endIndex {
                    let group = onlyOneEntryForm.FirstLevelGroups[indexPath.row]
                    title = group.title
                    let s = UISwitch(frame: CGRect.zero)
                    s.tag = indexPath.row
                    s.isOn = !EntryFormSettingsHelper.IsGroupHidden(onlyOneEntryForm.FormId, groupName: group.Id)
                    let wrapper = EntryFormUISwitchWrapper()
                    wrapper.SelectedEntryForm = onlyOneEntryForm
                    wrapper.SelectedGroupId = group.Id
                    s.formInfo = wrapper
                    s.addTarget(self, action: #selector(SettingsViewController.handleSwitchChange(_:)), for: UIControlEvents.touchUpInside)
                    c.accessoryView = s
                }
            }
        }
        
        c.selectionStyle = UITableViewCellSelectionStyle.blue
        c.textLabel?.text = title
        c.accessoryType = accessoryType
        
        return c
    }
    
    func handleSwitchChange(_ s: UISwitch?) {
        if let _switch = s {
            if let formWrapper = _switch.formInfo {
                if let selectedForm = formWrapper.SelectedEntryForm, let selectedGroup = formWrapper.SelectedGroupId {
                    EntryFormSettingsHelper.SetGroupHidden(selectedForm.FormId, groupName: selectedGroup, value: !_switch.isOn)
                }
            }
        }
    }
    
    
    func handleEditedForm<T: EntryFormFieldContainer>(_ entryForm: EntryForm, entryFormField: T) {
        if let f = MiscHelpers.CastEntryFormField(entryFormField, Int.self) {
            EntryFormSettingsHelper.SaveEntryFormSettings(entryForm.FormId, key: f.id, value: f.values)
        } else if let f = MiscHelpers.CastEntryFormField(entryFormField, Float.self) {
            EntryFormSettingsHelper.SaveEntryFormSettings(entryForm.FormId, key: f.id, value: f.values)
        } else if let f = MiscHelpers.CastEntryFormField(entryFormField, Double.self) {
            EntryFormSettingsHelper.SaveEntryFormSettings(entryForm.FormId, key: f.id, value: f.values)
        } else if let f = MiscHelpers.CastEntryFormField(entryFormField, String.self) {
            EntryFormSettingsHelper.SaveEntryFormSettings(entryForm.FormId, key: f.id, value: f.values)
        }
    }
    
    func shouldAskForTitle() -> Bool {
        return false
    }
    
    func allowEmptyData()-> Bool {
        return true
    }

}
