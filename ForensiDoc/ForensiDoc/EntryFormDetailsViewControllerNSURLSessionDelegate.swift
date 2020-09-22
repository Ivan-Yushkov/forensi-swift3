//
//  EntryFormDetailsViewControllerNSURLSessionDelegate.swift
//  ForensiDoc

import Foundation

extension EntryFormDetailsViewController: URLSessionDelegate {
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        var content: String = ""
        do {
            content = try NSString(contentsOf: location, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            content = ""
        }
        AlertHelper.CloseDialog(self.AlertProgress) {
            if content.characters.count > 0 {
                if let ef = self._entryFormFactory?.GetEntryFormForDownloadTask(downloadTask.taskIdentifier) {
                    if let reportContent = EncryptJsonForSubmit.DecryptContentForEntryForm(ef, content: content) {
                        self._entryFormFactory?.finishedGeneratingReport(downloadTask.taskIdentifier, reportContent: reportContent)
                        self.shouldReload()
                        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Success", comment: "Title on dialog once report has been successfully generated"), messages: [NSLocalizedString("The report has been generated successfully.", comment: "")], callback: .none)
                    } else {
                        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Could not decrypt generated report.", comment: "Error message displayed when could not decrypt generated report")], callback: .none)
                    }
                } else {
                    AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Could not find corresponding report for this task.", comment: "Error message displayed when could not find corresponding report for this task")], callback: .none)
                }
            } else {
                AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Error while reading content of generated report", comment: "Error message displayed when having error while reading content of generated report.")], callback: .none)
            }
        }
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if let err = error {
            self._entryFormFactory?.completedGeneratingReportWithError(task.taskIdentifier, error: err)
            AlertHelper.CloseDialog(self.AlertProgress) {
                AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Error while generating report. See below for details.", comment: "Error message while generating report."),err.localizedDescription], callback: .none)
            }
        }
    }
    
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self._entryFormFactory?.downloadingGeneratedReport(downloadTask.taskIdentifier, bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}
