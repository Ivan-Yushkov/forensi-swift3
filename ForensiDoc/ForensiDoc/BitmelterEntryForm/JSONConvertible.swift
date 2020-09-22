//
//  JSONConvertible.swift
//  BitmelterEntryForm

import Foundation

public protocol JSONConvertible {
    func toReportJSON() -> JSON
    func toJSON() -> JSON
    func toDictionary() -> [String : AnyObject]
    func toReportDictionary() -> [String : AnyObject]
}