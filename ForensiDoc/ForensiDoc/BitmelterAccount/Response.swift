//
//  Response.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 22/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

struct Response {
    let data: Data
    var statusCode: Int = 500
    
    init(data: Data, urlResponse: URLResponse?) {
        self.data = data
                
        if let httpResponse = urlResponse as? HTTPURLResponse {
            statusCode = httpResponse.statusCode
        }
    }
}

func parseResponse(_ response: Response) -> Result<Data> {
    let successRange = 200..<300
    var error: NSError? = nil
    
    //TODO:Remove the line below
    if let datastring = NSString(data: response.data, encoding: String.Encoding.utf8.rawValue) {
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
            return .error(e)
        }
        
        return .error(NSError(domain: domainError, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:kUnknownErrorHasOccured]))
    }
    return Result(error, response.data)
}

func performRequest<A: JSONDecodable>(_ request: URLRequest, callback: @escaping (Result<A>) -> ()) -> URLSessionTask {
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, urlResponse, error in
        //MARK: fix2020
        //callback(parseResult(data, urlResponse: urlResponse, error: error as? NSError))
        callback(parseResult(data, urlResponse: urlResponse, error: error as NSError?))
    }) 
    task.resume()
    return task
}

func parseResult<A: JSONDecodable>(_ data: Data!, urlResponse: URLResponse!, error: NSError!) -> Result<A> {
    let responseResult: Result<Response> = Result(error, Response(data: data, urlResponse: urlResponse))
    return
        responseResult
            >>> parseResponse
            >>> decodeJSON
            >>> decodeObject
}
