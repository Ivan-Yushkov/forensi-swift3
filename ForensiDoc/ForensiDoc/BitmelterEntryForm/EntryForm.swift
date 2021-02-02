//
//  EntryForm.swift
//  BitmelterEntryForm

import Foundation


open class EntryForm: JSONConvertible {
    public static let ATTACHMENT_ADDED_NOTIFICATION = "ATTACHMENT_ADDED_NOTIFICATION"
   // public static var signatureJson = [Any]()
    
    fileprivate var _fields: [Any] = []
    fileprivate var _hiddenGroups = [String]()
    fileprivate var _hasSetHiddenGroupd = false
    fileprivate var _settings: [Any] = []
    fileprivate var _title: String = ""
    fileprivate var _saveUUID: String = ""
    fileprivate var _formId: Int = 0
    fileprivate var _encryptionPassword: String = ""
    fileprivate var _savedAsTitle: String = ""
    fileprivate var _savedAsSubTitle: String = ""
    fileprivate var _savedAsExtraDetails: String = ""
    fileprivate var _reportTemplate: String = ""
    fileprivate var _saveDisplayTitlePattern: String = ""
    fileprivate var _save_display_subtitle_pattern: String = ""
    fileprivate var _save_display_extra_details_pattern: String = ""
    fileprivate let _eventsManager = EventManager()
    fileprivate var _attachmentSpec = EntryFormAttachmentSpec()
    fileprivate var _attachments = [EntryFormAttachment]()
    fileprivate var _firstLevelEntryFormGroups = [EntryBaseFormGroup]()
    fileprivate var allTitleFields:[String:Any?] = [String:Any?]()
    fileprivate var allSubtitleFields:[String:Any?] = [String:Any?]()
    fileprivate var allExtraInformationFields:[String:Any?] = [String:Any?]()
    fileprivate var _downloadReportInfo: EntryFormReportDownloadInfo
    fileprivate var _reportDate = "default"
    fileprivate var foldersCount: Int = 0
    
    fileprivate init() {
        SavedInFolder = ""
        _downloadReportInfo = EntryFormReportDownloadInfo()
    }
    
    public init(jsonSpec: String, doNotCheckForHiddenFields: Bool) {
        SavedInFolder = ""
        _downloadReportInfo = EntryFormReportDownloadInfo()
        
        //MARK: fix2020
        
        if let dataFromString = jsonSpec.data(using: String.Encoding.utf8, allowLossyConversion: false),
            let json = try? JSON(data: dataFromString) {
            _title = json["title"].stringValue
            _formId = json["formid"].intValue
            
            _reportDate = json["reportDate"].stringValue
            
            _saveUUID = json["save_uuid"].stringValue
            _reportTemplate = json["report_template"].stringValue
            SavedInFolder = json["saved_in_folder"].stringValue
            _savedAsTitle = json["saved_as_title"].stringValue
            _encryptionPassword = json["encryption_password"].stringValue
            _hasSetHiddenGroupd = json["has_set_hidden_groups"].boolValue
            
            let processHiddenGroups = !doNotCheckForHiddenFields && !_hasSetHiddenGroupd
            
            _saveDisplayTitlePattern = json["save_display_title_pattern"].stringValue
            let extractedFields = MiscHelpers.ExtractFieldsFromFormula(_saveDisplayTitlePattern)
            for extractedField in extractedFields {
                self.allTitleFields[extractedField] = ""
                self._eventsManager.listenTo(extractedField, action: { (information: Any?) -> () in
                    let f = MiscHelpers.FormatFormula(&self.allTitleFields, fieldId: extractedField, value: information, formula: self._saveDisplayTitlePattern)
                    let allFieldsCnt = self.allTitleFields.count
                    let calculate = f.cnt == allFieldsCnt
                    if calculate {
                        self._savedAsTitle = f.calculateFormula
                    } else {
                        self._savedAsTitle = ""
                        
                        //NSLocalizedString("Untitled case", comment: "Title on the report when we cannot make the title based on data provided")
                    }
                })
            }
            _save_display_subtitle_pattern = json["save_display_subtitle_pattern"].stringValue
            let extractedFieldsSubtitle = MiscHelpers.ExtractFieldsFromFormula(_save_display_subtitle_pattern)
            for extractedField in extractedFieldsSubtitle {
                self.allSubtitleFields[extractedField] = ""
                self._eventsManager.listenTo(extractedField, action: { (information: Any?) -> () in
                    let f = MiscHelpers.FormatFormula(&self.allSubtitleFields, fieldId: extractedField, value: information, formula: self._save_display_subtitle_pattern)
                    let allFieldsCnt = self.allSubtitleFields.count
                    let calculate = f.cnt == allFieldsCnt
                    if calculate {
                        self._savedAsSubTitle = f.calculateFormula
                    } else {
                        self._savedAsSubTitle = ""
                    }
                })
            }
            
            _save_display_extra_details_pattern = json["save_display_extra_details_pattern"].stringValue
            let extractedFieldsExtraDetails = MiscHelpers.ExtractFieldsFromFormula(_save_display_extra_details_pattern)
            for extractedField in extractedFieldsExtraDetails {
                self.allExtraInformationFields[extractedField] = ""
                self._eventsManager.listenTo(extractedField, action: { (information: Any?) -> () in
                    let f = MiscHelpers.FormatFormula(&self.allExtraInformationFields, fieldId: extractedField, value: information, formula: self._save_display_extra_details_pattern)
                    let allFieldsCnt = self.allExtraInformationFields.count
                    let calculate = f.cnt == allFieldsCnt
                    if calculate {
                        self._savedAsExtraDetails = f.calculateFormula
                    } else {
                        self._savedAsExtraDetails = ""
                    }
                })
            }
            
            for setting in json["settings"].arrayValue {
                if let settingField = setting.ExtractFormField(self._eventsManager, entryForm: self, checkHiddenGroups: processHiddenGroups) {
                    _settings.append(settingField)
                }
            }
            
            for field in json["spec"]["fields"].arrayValue {
                if let formField = field.ExtractFormField(self._eventsManager, entryForm: self, checkHiddenGroups: processHiddenGroups) {
                    if processHiddenGroups {
                        if formField is EntryFormGroup {
                            let entryFormGroup = formField as! EntryFormGroup
                            if EntryFormSettingsHelper.IsGroupHidden(_formId, groupName: entryFormGroup.Id) {
                                _hiddenGroups.append(entryFormGroup.Id)
                            }
                        }
                        if formField is EntryFormMultipleEntry {
                            let entryFormMultipleEntry = formField as! EntryFormMultipleEntry
                            if EntryFormSettingsHelper.IsGroupHidden(_formId, groupName: entryFormMultipleEntry.Id) {
                                _hiddenGroups.append(entryFormMultipleEntry.Id)
                            }
                        }
                    }
                    _fields.append(formField)
                }
            }
            
            for att in json["attachments"].arrayValue {
                _attachments.append(EntryFormAttachment(spec: att, entryForm: self))
            }
            
            _attachmentSpec = EntryForm.LoadEntryFormAttachmentSpec(json["spec"]["allowed_attachments"], eventManager: _eventsManager)
        }
        let _ = self.uuid
    }
    
    open class func LoadEntryFormAttachment(_ spec: JSON?, entryForm: EntryForm) -> EntryFormAttachment? {
        if let _spec = spec {
            return EntryFormAttachment(spec: _spec,entryForm: entryForm)
        }
        return .none
    }
    
    open var Settings: [Any] {
        get {
            return _settings
        }
    }
    
    open var DownloadInfo: EntryFormReportDownloadInfo {
        get {
            return _downloadReportInfo
        }
    }
    
    open func GeneratedReportNSURL() -> URL? {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documents.count > 0 {
            let document = documents[0]
            let fileList = listFilesFromDocumentsFolder(self.SavedInFolder)
            foldersCount = fileList.count
            for file in fileList {
                let u = URL(fileURLWithPath: document).appendingPathComponent(self.SavedInFolder).appendingPathComponent(file)
                let fileExtension = u.pathExtension
                if fileExtension.caseInsensitiveCompare("docx") == .orderedSame {
                    return u
                }
            }
        }
        return .none
    }
    
    open func DeleteItSelf() -> Bool {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documents.count > 0 {
            let fileManager:FileManager = FileManager.default
            let document = documents[0]
            let fileList = listFilesFromDocumentsFolder(self.SavedInFolder)
            //TODO: change name (U1 digit) by files with same date
            foldersCount = fileList.count
            for file in fileList {
                let u = URL(fileURLWithPath: document).appendingPathComponent(self.SavedInFolder).appendingPathComponent(file)
                do{
                    try fileManager.removeItem(at: u)
                }catch{
                    return false
                }
            }
            //Delete empty folder
            let path = URL(fileURLWithPath: document).appendingPathComponent(self.SavedInFolder).path
                do{
                    try fileManager.removeItem(atPath: path)
                }catch{
                    return false
                }
        
        }
        return true
    }
    
    open func SaveDownloadedReportResponse(_ reportResponseContent: String) {
        //MARK: fix2020
        if let dataFromString = reportResponseContent.data(using: String.Encoding.utf8, allowLossyConversion: false), let reportJson = try? JSON(data: dataFromString) {
            let filename = reportJson["filename"].stringValue
            let reportDataBase64 = reportJson["data"].stringValue
            let error = reportJson["error"].boolValue
            if !error && filename.count > 0 && reportDataBase64.count > 0 {
                let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let u = URL(fileURLWithPath: documents).appendingPathComponent(self.SavedInFolder,isDirectory: true).appendingPathComponent(filename)
                if let data = Data(base64Encoded: reportDataBase64, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
                    do{
                        DeleteExistingReportIfExists()
                        try data.write(to: u, options: .atomic)//data.write(u, options: .atomic)
                    }catch {
                        //TODO:Do something about error
                    }
                }
            }
        }
    }
    
    fileprivate func DeleteExistingReportIfExists() {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documents.count > 0 {
            let document = documents[0]
            let fileManager:FileManager = FileManager.default
            let fileList = listFilesFromDocumentsFolder(self.SavedInFolder)
            for file in fileList {
                let u = URL(fileURLWithPath: document).appendingPathComponent(self.SavedInFolder).appendingPathComponent(file)
                 let fileExtension = u.pathExtension
                 if fileExtension.caseInsensitiveCompare("docx") == .orderedSame {
                    do{
                        try fileManager.removeItem(at: u)
                    }catch {
                        
                    }
                }
            }
        }
    }
    
    fileprivate func listFilesFromDocumentsFolder(_ inFolder: String?) -> [String] {
        let dirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if dirs.count > 0 {
            var dir = dirs[0]
            if let folder = inFolder {
                let path = URL(fileURLWithPath: dir).appendingPathComponent(folder).path
                
                dir = path
            }
            let fileList: [AnyObject]?
            do {
                fileList = try FileManager.default.contentsOfDirectory(atPath: dir) as [AnyObject]
            } catch _ as NSError {
                fileList = nil
            }
            if fileList != nil{
                return fileList as! [String]
            }
            
        }
        let fileList = [""]
        return fileList
    }
    
    
    open class func LoadEntryFormAttachmentSpec(_ spec: JSON?, eventManager: EventManager?) -> EntryFormAttachmentSpec {
        if let s = spec {
            return EntryFormAttachmentSpec(spec: s, eventManager: eventManager)
        }
        
        return EntryFormAttachmentSpec()
    }
    
    open var SavedInFolder: String
    
    fileprivate func SuffixSavedInFolderWithNumber() {
        let components = SavedInFolder.components(separatedBy: "-")
        if components.count > 0 {
            let lastComponent = components[components.count - 1]
            if var number = lastComponent.toInt() {
                number = number + 1
                SavedInFolder = "\(SavedInFolder)-\(number)"
            } else {
                SavedInFolder = "\(SavedInFolder)-1"
            }
        } else {
            SavedInFolder = "\(SavedInFolder)-1"
        }
    }
    
    open var EncryptionPassword: String {
        get {
            return _encryptionPassword
        }
    }
    
    open var EventsManager: EventManager {
        get {
            return self._eventsManager
        }
    }
    
    open func EnsureHiddenGroupsSet() {
        self._hasSetHiddenGroupd = true
    }
    
    open func EnsureUUIDSet() {
        self._saveUUID = UUID().uuidString
    }
    
    
    //create folder and date
    open func EnsureSavedInFolderSet() -> Bool {
        if self._encryptionPassword.count == 0 {
            self._encryptionPassword = MiscHelpers.RandomStringWithLength(36)
        }
        
        if self.SavedInFolder.count == 0 {
            let format = DateFormatter()
            format.dateFormat="yyyy-MM-dd-HH-mm-ss"
            let folderName = format.string(from: Date())
//MARK: Set the report date
            let df = DateFormatter()
            df.dateFormat = "ddMMyyyy"
            
            let fileList = listFilesFromDocumentsFolder(self.SavedInFolder)
            foldersCount = fileList.count
            //TODO: set _savedAsTitle correctly, change U1
            reportDate = df.string(from: Date())
            _savedAsTitle = "U\(foldersCount + 1) " + reportDate
            let fileManager = FileManager.default
//MARK: fix2020
           // let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  else { return false }
            
                
           // guard let thePath = paths.first else { return false }
           // let documentsDirectory = URL(fileURLWithPath: thePath)
           // let documentsDirectory: AnyObject = paths[0] as AnyObject
           
            let dataPath = documentDirectoryUrl.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: dataPath.path) {
                do {
                    try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
                    self.SavedInFolder = folderName
                    return true
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
            return false
        } else {
           print(foldersCount)
        }
        return true
    }
    
    open var Title: String {
        get {
            return _title
        }
    }
    
    open var reportDate: String {
        get {
//            let f = DateFormatter()
//            f.dateStyle = .short
            return _reportDate//f.string(from: _reportDate)
        }
        set {
            _reportDate = newValue
        }
    }
    
    open var SavedAsTitle: String {
        get {
            if _savedAsTitle.count > 0 {
                return _savedAsTitle
            }
            return NSLocalizedString("Untitled case", comment: "Title on the report when we cannot make the title based on data provided")
        }
    }
    
    open var SavedAsSubtitle: String {
        get {
            if _savedAsSubTitle.count > 0 {
                return _savedAsSubTitle
            }
            return NSLocalizedString("Please fill in all the required fields", comment: "Message on the subtitle of the report if not all required fields are populated")
        }
    }
    
    open var SavedAsExtraInformation: String {
        get {
            if _savedAsExtraDetails.count > 0 {
                return _savedAsExtraDetails
            }
            return ""
        }
    }
    
    open var FormId: Int {
        get {
            return _formId
        }
    }
    
    open var uuid: String {
        get {
            if _saveUUID.count > 0 {
                return _saveUUID
            }
            let uuid = UUID().uuidString
            _saveUUID = uuid
            return uuid
        }
    }
    
    open func canAddAttachments() -> Bool {
        return self._attachmentSpec.AllowsAttachments
    }
    
    open var AttachmentsSpec: EntryFormAttachmentSpec {
        get {
            return self._attachmentSpec
        }
    }
    
    open func addAttachment(_ attachment: EntryFormAttachment) {
        self._attachments.append(attachment)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EntryForm.ATTACHMENT_ADDED_NOTIFICATION), object: attachment)
    }
    
    open var Attachments: [EntryFormAttachment] {
        get {
            return _attachments
        }
    }
    
    open func DeleteAttachment(_ attachment: EntryFormAttachment) {
        if let idx = _attachments.firstIndex(where: {$0.SavedAsFileName == attachment.SavedAsFileName}) {
            attachment.clear()
            _attachments.remove(at: idx)
        }
    }
    
    open var Fields: [Any] {
        get {
            return _fields
        }
    }
    
    lazy open var FirstLevelGroups: [EntryBaseFormGroup] = {
        if self._firstLevelEntryFormGroups.count == 0 {
            for field in self._fields {
                if field is EntryFormGroup {
                    let entryFormGroup = field as! EntryFormGroup
                    self._firstLevelEntryFormGroups.append(entryFormGroup)
                }
                if field is EntryFormMultipleEntry {
                    let entryFormGroup = field as! EntryFormMultipleEntry
                    if !entryFormGroup.group.isEmpty {
                        self._firstLevelEntryFormGroups.append(entryFormGroup)
                    }
                }
            }
        }
        return self._firstLevelEntryFormGroups
    }()
    
    open func isValid() -> Bool {
        for field in Fields {
            if field is Validable {
                let j = field as! Validable
                if !j.isValidObject() {
                    return false
                }
            }
        }
        return true
    }
    
    open func GetField(_ fieldKey: String) -> Any? {
        return getFieldInternal(Fields, fieldKey: fieldKey)
    }
    
    open func GetFieldValue(_ fieldKey: String) -> String? {
        if let field = getFieldInternal(Fields, fieldKey: fieldKey) {
            if let f = MiscHelpers.CastEntryFormField(field, Int.self) {
                return f.displaySelectedValue()
            } else if let f = MiscHelpers.CastEntryFormField(field, Float.self) {
                return f.displaySelectedValue()
            } else if let f = MiscHelpers.CastEntryFormField(field, Double.self) {
                return f.displaySelectedValue()
            } else if let f = MiscHelpers.CastEntryFormField(field, String.self) {
                return f.displaySelectedValue()
            }
        }
        return .none
    }
    
    fileprivate func getFieldInternal(_ fields: [Any], fieldKey: String) -> Any? {
        for (_,field) in fields.enumerated() {
            if let f = MiscHelpers.CastEntryFormField(field, Int.self) {
                if f.id == fieldKey {
                    return f
                }
            } else if let f = MiscHelpers.CastEntryFormField(field, Float.self) {
                if f.id == fieldKey {
                    return f
                }
            } else if let f = MiscHelpers.CastEntryFormField(field, Double.self) {
                if f.id == fieldKey {
                    return f
                }
            } else if let f = MiscHelpers.CastEntryFormField(field, String.self) {
                if f.id == fieldKey {
                    return f
                }
            } else if field is EntryFormGroup {
                let fieldGroup = field as! EntryFormGroup
                if let fieldInternalResult = getFieldInternal(fieldGroup.fields, fieldKey: fieldKey) {
                    return fieldInternalResult
                }
                
            }
        }
        return .none
    }
    
    open func toReportJSON() -> JSON {
        var ret = [String: AnyObject]()
        
        let hiddenFields = [String]() //TODO:Get hidden fields from settings based on report
        
        var hiddenSetting = [String: AnyObject]()
        hiddenSetting["value"] = hiddenFields as AnyObject
        
        var settingsPart = [String: AnyObject]()
        settingsPart["hidden"] = hiddenSetting as AnyObject
        
        for setting in self._settings {
            if let sEF = MiscHelpers.CastEntryFormField(setting, String.self) {
                if let sValue = EntryFormSettingsHelper.GetEntryFormSettingValue(FormId, key: sEF.id, String.self) {
                    var sValueDict = [String: AnyObject]()
                    sValueDict["value"] = sValue as AnyObject
                    sValueDict["type"] = "String" as AnyObject
                    settingsPart[sEF.id] = sValueDict as AnyObject
                }
            } else if let sEF = MiscHelpers.CastEntryFormField(setting, Int.self) {
                if let sValue = EntryFormSettingsHelper.GetEntryFormSettingValue(FormId, key: sEF.id, Int.self) {
                    var sValueDict = [String: AnyObject]()
                    sValueDict["value"] = sValue as AnyObject
                    sValueDict["type"] = "Int" as AnyObject
                    settingsPart[sEF.id] = sValueDict as AnyObject
                }
            } else if let sEF = MiscHelpers.CastEntryFormField(setting, Double.self) {
                if let sValue = EntryFormSettingsHelper.GetEntryFormSettingValue(FormId, key: sEF.id, Double.self) {
                    var sValueDict = [String: AnyObject]()
                    sValueDict["value"] = sValue as AnyObject
                    sValueDict["type"] = "Double" as AnyObject
                    settingsPart[sEF.id] = sValueDict as AnyObject
                }
            } else if let sEF = MiscHelpers.CastEntryFormField(setting, Float.self) {
                if let sValue = EntryFormSettingsHelper.GetEntryFormSettingValue(FormId, key: sEF.id, Float.self) {
                    var sValueDict = [String: AnyObject]()
                    sValueDict["value"] = sValue as AnyObject
                    sValueDict["type"] = "Float" as AnyObject
                    settingsPart[sEF.id] = sValueDict as AnyObject
                }
            }
        }
        
        var templatePart = [String: AnyObject]()
        templatePart["value"] = self._reportTemplate as AnyObject
        
        settingsPart["template"] = templatePart as AnyObject
        
        ret["settings"] = settingsPart as AnyObject
        
        var fields = getDictionaryFields(Fields)
        
        //Add image attachments to fields
        var attachmentPhotosCollection = [AnyObject]()
        var attachmentDrawingsCollection = [AnyObject]()
        var attachmentAudioCollection = [AnyObject]()
        var attachmentVideoCollection = [AnyObject]()
        
        for attachment in self.Attachments {
            if attachment.AttachmentType == EntryFormAttachmentType.image {
                attachmentPhotosCollection.append(attachment.toReportDictionary() as AnyObject)
            } else if attachment.AttachmentType == EntryFormAttachmentType.drawing {
                attachmentDrawingsCollection.append(attachment.toReportDictionary() as AnyObject)
            } else if attachment.AttachmentType == EntryFormAttachmentType.audio {
                attachmentAudioCollection.append(attachment.toReportDictionary() as AnyObject)
            } else if attachment.AttachmentType == EntryFormAttachmentType.video {
                attachmentVideoCollection.append(attachment.toReportDictionary() as AnyObject)
            }
        }
        var attachmentPhotos = [String: AnyObject]()
        attachmentPhotos["value"] = attachmentPhotosCollection as AnyObject
        fields["attachment_photos"] = attachmentPhotos as AnyObject
        
        var attachmentDrawings = [String: AnyObject]()
        attachmentDrawings["value"] = attachmentDrawingsCollection as AnyObject
        fields["attachment_drawings"] = attachmentDrawings as AnyObject
        
        var attachmentAudios = [String: AnyObject]()
        attachmentAudios["value"] = attachmentAudioCollection as AnyObject
        fields["attachment_audio"] = attachmentAudios as AnyObject
        
        var attachmentVideos = [String: AnyObject]()
        attachmentVideos["value"] = attachmentVideoCollection as AnyObject
        fields["attachment_video"] = attachmentVideos as AnyObject
        
        
        //Fields
        ret["fields"] = fields as AnyObject
        
        return JSON(ret)
    }
    
    open func toJSON() -> JSON {
        let json: JSON = JSON(toDictionary())
        
        return json
    }
    
    open func toDictionary() -> [String : AnyObject] {
        return getDictionary()
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        return [String: AnyObject]()
    }
    
    func getDictionary() -> [String: AnyObject] {
        var ret = [String: AnyObject]()
        
        ret["title"] = Title as AnyObject
        ret["formid"] = FormId as AnyObject
        ret["save_uuid"] = uuid as AnyObject
        ret["report_template"] = self._reportTemplate as AnyObject
        ret["saved_as_title"] = self._savedAsTitle as AnyObject
        ret["saved_in_folder"] = self.SavedInFolder as AnyObject
        ret["reportDate"] = self._reportDate as AnyObject
        ret["save_display_title_pattern"] = self._saveDisplayTitlePattern as AnyObject
        ret["save_display_subtitle_pattern"] = self._save_display_subtitle_pattern as AnyObject
        ret["save_display_extra_details_pattern"] = self._save_display_extra_details_pattern as AnyObject
        ret["encryption_password"] = self.EncryptionPassword as AnyObject
        ret["has_set_hidden_groups"] = self._hasSetHiddenGroupd as AnyObject
        
        var spec = [String: AnyObject]()
        let fields = getFields(Fields)
        
        var settings = [AnyObject]()
        for _s in self._settings {
            if _s is JSONConvertible {
                let j = _s as! JSONConvertible
                settings.append(j.toDictionary() as AnyObject)
            }
        }
        ret["settings"] = settings as AnyObject
        
        spec["fields"] = fields as AnyObject
        spec["allowed_attachments"] = _attachmentSpec.toDictionary() as AnyObject
        ret["spec"] = spec as AnyObject
        
        var attachments = [AnyObject]()
        for attachment in self.Attachments {
            attachments.append(attachment.toDictionary() as AnyObject)
        }
        
        ret["attachments"] = attachments as AnyObject
        
        return ret
    }
    
    func getDictionaryFields(_ fields: [Any]) -> [String: AnyObject] {
        var ret = [String: AnyObject]()
        for field in fields {
            if field is JSONConvertible {
                let j = field as! JSONConvertible
                for kv in j.toReportDictionary() {
                    ret[kv.0] = kv.1
                }
            } else if let f = field as? [String: AnyObject] {
                for kv in f {
                    ret[kv.0] = kv.1
                }
            }
        }
        return ret
    }
    
    func getFields(_ fields: [Any]) -> [AnyObject] {
        return MiscHelpers.GetFieldsForJSON(fields, useReportDictionary: false)
    }
}
