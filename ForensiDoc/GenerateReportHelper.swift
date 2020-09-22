//
//  GenerateReportHelper.swift
//  ForensiDoc

import Foundation

open class GenerateReportHelper {
    open class func GetRequestForReport(_ reportData: String) -> URLRequest? {
        if let url = URL(string: "https://forensidoc.com/api/report/generate") {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            
            if let data = reportData.data(using: String.Encoding.ascii) {
                DebugLog.DLog("Number of characters in body -> \(data.count)")
                request.httpBody = data
                return request as URLRequest
            }
        }
        
        return .none
    }
}
