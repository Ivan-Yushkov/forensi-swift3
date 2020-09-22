//
//  EntryFormReportDownloadInfo.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormReportDownloadInfo {
    open var downloadTask: URLSessionDownloadTask?
    open var taskResumeData: Data?
    open var downloadProgress: Double = 0.0
    open var isDownloading: Bool = false
    open var downloadComplete: Bool = false
    open var taskIdentifier: Int = 0
}
