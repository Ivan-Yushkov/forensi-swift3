//
//  Response.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 22/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

struct Response {
    let data: NSData
    var statusCode: Int = 500
    
    init(data: NSData, urlResponse: NSURLResponse?) {
        self.data = data
                
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            statusCode = httpResponse.statusCode
        }
    }
}

func parseResponse(response: Response) -> Result<NSData> {
    let successRange = 200..<300
    var error: NSError? = nil
    
    //TODO:Remove the line below
    if let datastring = NSString(data: response.data, encoding: NSUTF8StringEncoding) {
        NSLog("%@", datastring)
    }
    
    if !successRange.contains(response.statusCode) {
        switch response.statusCode {
        case 400:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kRequestBadRequest])
        case 401:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kRequestUnauthorized])
        case 403:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kRequestForbiden])
        case 404:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kRequestNotFound])
        case 405:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kRequestMethodNotAllowed])
        case 408:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kRequestTimeout])
        case 500:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kServerInternalServerError])
        case 503:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kServerServiceUnavailable])
        default:
            error = NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kUnknownErrorHasOccured])
        }
        
        if let e = error {
            return .Error(e)
        }
        
        return .Error(NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kUnknownErrorHasOccured]))
    }
    return Result(error, response.data)
}

func performRequest<A: JSONDecodable>(request: NSURLRequest, callback: (Result<A>) -> ()) -> NSURLSessionTask {
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, urlResponse, error in
        callback(parseResult(data, urlResponse: urlResponse, error: error))
    }
    task.resume()
    return task
}

func parseResult<A: JSONDecodable>(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) -> Result<A> {
    let responseResult: Result<Response> = Result(error, Response(data: data, urlResponse: urlResponse))
    return
        responseResult
            >>> parseResponse
            >>> decodeJSON
            >>> decodeObject
}
