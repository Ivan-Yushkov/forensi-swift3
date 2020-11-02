//
//  ForensiDocEntryFormRepository.swift
//  ForensiDoc

import Foundation

internal class ForensiDocEntryFormRepository : EntryFormRepository{
    func LoadJSONFormSpecs() -> [String]{
        var ret = [String]()
        var cnt = 1
        let fileManager = FileManager.default
        while true {
            if let path = Bundle.main.path(forResource: "forensidoc_\(cnt)", ofType: "json") {
                if fileManager.fileExists(atPath: path) {
                    if let content = try? String(contentsOfFile:path, encoding: String.Encoding.utf8) {
                        ret.append(content)
                    } else {
                        break
                    }
                } else {
                    break
                }
            } else {
                break
            }
            cnt = cnt + 1
        }
        
        return ret
    }
    
    func DeleteEntryForm(_ form: EntryForm) {
        _ = form.DeleteItSelf()
    }
    
    func LoadSavedFormForFormId(_ formId: Int) -> [EntryForm] {
        var ret = [EntryForm]()
        if let content2 = MiscHelpers.ContentOfFileWithName("test-rep", type:"json"){
            let testEntryForm = EntryForm(jsonSpec: content2, doNotCheckForHiddenFields: false)
            ret.append(testEntryForm)
            return ret
        }
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documents.count > 0 {
            let document = documents[0]
            let fileManager:FileManager = FileManager.default
            let fileList = listFilesFromDocumentsFolder(.none)
            var dirArray = [String]()
            for file in fileList {
                var isDir : ObjCBool = false
                
                let path = URL(fileURLWithPath: document).appendingPathComponent(file).path
                if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        dirArray.append(file)
                    }
                }
                
            }
            for dir in dirArray {
                let fileList = listFilesFromDocumentsFolder(dir)
                for file in fileList {
                    let u = URL(fileURLWithPath: document).appendingPathComponent(dir).appendingPathComponent(file)
                    let path = u.path
                    print(path)
                    if fileManager.fileExists(atPath: path) {
                        if let data = fileManager.contents(atPath: path) {
                            if let efs = NSKeyedUnarchiver.unarchiveObject(with: data) as? EntryFormSave {
                                if let ef = efs.ef {
                                    ret.append(ef)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        return ret
    }
    
    func SaveEntryForm(_ form: EntryForm) -> Bool {
        NSLog("Will save entry form to -> %@", form.SavedInFolder)
        if form.SavedInFolder.count > 0 {
            //let df = DateFormatter()
            //form.reportDate = df.string(from: Date())
            //form.reportDate = "12/3/45"
            let efs = EntryFormSave(entryForm: form)
            
            do {
            let newData = try NSKeyedArchiver.archivedData(withRootObject: efs, requiringSecureCoding: false)
                
            } catch {
                print(error.localizedDescription)
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: efs)
            
            let saveFileName = "\(form.uuid)-\(form.FormId).ef"
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            let u = URL(fileURLWithPath: documents).appendingPathComponent(form.SavedInFolder,isDirectory: true).appendingPathComponent(saveFileName)
            let writePath = u.path
            print("writePath is \(writePath)")
            
            do {
             try data.write(to: u,  options: .atomic)
            
            //let writeResult = data(writeToFile: writePath, optio)
            return true
            } catch let error {
                print("\(error)")
                return false
            }
        } else {
            return false
        }
    }
    func listFilesFromDocumentsFolder(_ inFolder: String?) -> [String] {
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
            return fileList as! [String]
        }else{
            let fileList = [""]
            return fileList
        }
    }
}
