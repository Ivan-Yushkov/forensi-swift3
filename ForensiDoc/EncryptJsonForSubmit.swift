//
//  EncryptJsonForSubmit.swift
//  ForensiDoc

import Foundation

class EncryptJsonForSubmit {
    static let token = "7C6C733D-A464-4872-BA96-A82376C6ACB0"
    
    internal class func Encrypt(_ entryForm: EntryForm) -> String {
        DebugLog.DLog("Encrypting form id \(entryForm.uuid) with password \(entryForm.EncryptionPassword).")
        if let content = MiscHelpers.ContentOfFileWithName("test-post", type:"txt"){
            return content
        }
        let rsa: RSA = RSA()
        let password = entryForm.EncryptionPassword
        
        let json = entryForm.toReportJSON()
        if let jsonString = json.rawString(String.Encoding.utf8.rawValue, options:
            JSONSerialization.WritingOptions.prettyPrinted) {
            if let jsonData = jsonString.data(using: String.Encoding.utf8) {
                let ciphertext = RNCryptor.encryptData(data: jsonData as NSData, password: password)
                let data = ciphertext.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                // Data should look like this
                // { "secret": { "token": "token_for_the_api_auth", "password": "psw_to_decrypt_payload" }, "data": data }
                // the secret is encrypted with the public key
                // the payload has been already encrypted with the password
                
                let secret = [ "token": token, "password": password ]
                let secret_json = try! JSONSerialization.data(withJSONObject: secret, options: [])
                let secret_string = NSString(data: secret_json, encoding: String.Encoding.utf8.rawValue)! as String
                
                let encrypted_secret = rsa.encrypt(to: secret_string)
                
                let request = [ "secret": encrypted_secret, "data": data ]
                let request_json = try! JSONSerialization.data(withJSONObject: request, options: [])
                let request_string = request_json.base64EncodedString(options: [])
                
                return request_string
            }
        }
        
        return ""
    }
    
    internal class func DecryptContentForEntryForm(_ entryForm: EntryForm, content: String) -> String? {
        DebugLog.DLog("Content to decrypt -> \(content)")
        do{
            DebugLog.DLog("Decrypting form id \(entryForm.uuid) with password \(entryForm.EncryptionPassword).")
            if let cc = Data(base64Encoded: content, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
                DebugLog.DLog("Decrypting form id \(entryForm.uuid) cc.")
                /*
                let data = try RNCryptor.decryptData(cc, password: "enter password from json")
                */
                let data = try RNCryptor.decryptData(data: cc as NSData, password: entryForm.EncryptionPassword)
                DebugLog.DLog("Decrypting form id \(entryForm.uuid) data.")
                if let loaded = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
                    DebugLog.DLog("Decrypting form id \(entryForm.uuid) loaded.")
                    if let base64Decoded = Data(base64Encoded: loaded as String, options:   NSData.Base64DecodingOptions(rawValue: 0))
                        .map({ NSString(data: $0, encoding: String.Encoding.utf8.rawValue) }) {
                        DebugLog.DLog("Decrypting form id \(entryForm.uuid) base64Decoded.")
                        if let decodedReportContent = base64Decoded as? String {
                            DebugLog.DLog("Decrypting form id \(entryForm.uuid) decodedReportContent. All OK.")
                            return decodedReportContent
                        }
                        
                    }
                }
            } else {
                DebugLog.DLog("Unable to create NSData \(content)")
            }
        } catch RNCryptorError.HMACMismatch {
          DebugLog.DLog("RNCryptorError.HMACMismatch")
        } catch RNCryptorError.InvalidCredentialType {
          DebugLog.DLog("RNCryptorError.InvalidCredentialType")
        } catch RNCryptorError.MemoryFailure {
          DebugLog.DLog("RNCryptorError.MemoryFailure")
        } catch RNCryptorError.MessageTooShort {
          DebugLog.DLog("RNCryptorError.MessageTooShort")
        } catch RNCryptorError.UnknownHeader {
          DebugLog.DLog("RNCryptorError.UnknownHeader")
        } catch {
            DebugLog.DLog("Unable to decrypt. Unknown error \(content)")
        }
        
        DebugLog.DLog("Unable to Decrypt returning .None")
    
        return .none
    }
}
