//
//  VideoRecordingViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 24/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation
import AVFoundation

open class VideoRecordingViewController: BaseViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var doneAndSaveButton: UIButton!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var videoAttachment: EntryFormAttachment?
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var happenOnce = false
    var meterTimer: Timer?
    fileprivate var _generatedVideo: ((EntryFormAttachment) -> Void)?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    open var OnGeneratedVideo: ((EntryFormAttachment) -> Void)? {
        get {
            return _generatedVideo
        }
        set(value) {
            _generatedVideo = value
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !happenOnce {
            happenOnce = true
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            
            let devices = AVCaptureDevice.devices()
            
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if ((device as AnyObject).hasMediaType(AVMediaType.video)) {
                    // Finally check the position and confirm we've got the back camera
                    if((device as AnyObject).position == AVCaptureDevice.Position.back) {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            print("Capture device found")
                            beginSession()
                        } else {
                            AlertHelper.DisplayAlert(self, title: kErrorTitle, messages: [NSLocalizedString("No suitable device has been found to perform this operation.", comment: "Error message when trying to record video but there is no camera.")], callback: .none)
                        }
                    }
                }
            }
            
            if let ef = self.entryForm {
                self.videoAttachment = EntryFormAttachment.CreateForVideo(ef)
            }
        }
    }
    
    func updateDeviceSettings(_ focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLocked(lensPosition: focusValue, completionHandler: { (time) -> Void in
                    //
                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            } catch _ as NSError {
                
            }
        }
    }
    
    func touchPercent(_ touch : UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.main.bounds.size
        
        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPoint.zero
        
        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.location(in: self.view).x / screenSize.width
        touchPer.y = touch.location(in: self.view).y / screenSize.height
        
        // Return the populated CGPoint
        return touchPer
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let first = touches.first {
            let touchPer = touchPercent(first)
            //focusTo(Float(touchPer.x))
            updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPer = touchPercent(touch)
            //focusTo(Float(touchPer.x))
            updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            device.focusMode = .locked
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        configureDevice()
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
            //MARK: fix2020
             let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                let bounds: CGRect = self.view.frame;
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
                previewLayer.bounds=bounds;
                previewLayer.position=CGPoint(x: bounds.midX, y: bounds.midY);
                self.view.layer.addSublayer(previewLayer)
                self.view.bringSubviewToFront(self.stopButton)
                self.view.bringSubviewToFront(self.startButton)
                self.view.bringSubviewToFront(self.doneAndSaveButton)
                self.view.bringSubviewToFront(self.cancelButton)
                self.view.bringSubviewToFront(self.timerLabel)
                self.stopButton.isHidden = false
                self.startButton.isHidden = true
                captureSession.startRunning()
            
        } catch _ {
            
        }
        
    }
    
    open func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
    
    open func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    @objc func updateVideoMeter(_ timer:Timer) {
        if let videoFile = self.videoFileOutput {
            let dTotalSeconds: Float64  = CMTimeGetSeconds(videoFile.recordedDuration);
            
            let dHours = floor(dTotalSeconds / 3600);
            let dMinutes = floor(dTotalSeconds.truncatingRemainder(dividingBy: 3600) / 60);
            let dSeconds = floor((dTotalSeconds.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60));
            DispatchQueue.main.async(execute: {
                if dHours > 0 {
                    let displayedTimer = String(format: "%02.0f:%02.0f:%02.0f", dHours,dMinutes, dSeconds)
                    self.timerLabel.text = displayedTimer
                } else {
                    let displayedTimer = String(format: "%02.0f:%02.0f", dMinutes, dSeconds)
                    self.timerLabel.text = displayedTimer
                }
            })
        }
    }
    
    @IBAction func startButtonTapped(_ sender: AnyObject) {
        self.meterTimer?.invalidate()
        if let videoFile = self.videoFileOutput {
            if videoFile.isRecording {
                videoFile.stopRecording()
                DispatchQueue.main.async(execute: {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.startButton.isHidden = true
                        self.stopButton.isHidden = false
                        }, completion: .none)
                })
            } else if videoFile.recordedDuration.seconds > 0 {
                //Means we have recording that it's stopped. Ask whether we want a new one
                AlertHelper.DisplayConfirmationDialog(self, title: NSLocalizedString("Confirm", comment: "Title on the confirmation dialog"), messages: [NSLocalizedString("You already have recorded video. Do you want to start recording a new one?", comment: "Question asked when trying to record video while already have some recorded.")], okCallback: {
                        self.doStartTheActualRecording()
                    }, cancelCallback: .none)
            }
        } else {
            doStartTheActualRecording()
        }
    }
    
    func doStartTheActualRecording() {
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.2, animations: {
                self.doneAndSaveButton.isHidden = false
                self.startButton.isHidden = false
                self.stopButton.isHidden = true
                }, completion: .none)
        })

        self.videoAttachment?.clear()
        if let videoAtt = self.videoAttachment {
            let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
            
            self.videoFileOutput = AVCaptureMovieFileOutput()
            
            if let videoFile = self.videoFileOutput {
                for output in self.captureSession.outputs {
                    if let captureOutput = output as? AVCaptureOutput {
                        self.captureSession.removeOutput(captureOutput)
                    }
                }
                self.captureSession.addOutput(videoFile)
                
                let filePath = videoAtt.NSURLFile
                
                videoFile.startRecording(to: filePath, recordingDelegate: recordingDelegate!)
                self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                                         target:self,
                                                                         selector:#selector(VideoRecordingViewController.updateVideoMeter(_:)),
                                                                         userInfo:nil,
                                                                         repeats:true)
            }
        }
    }
    
    @IBAction func doneAndSaveButtonTapped(_ sender: AnyObject) {
        if let videoFile = self.videoFileOutput, videoFile.isRecording {
            videoFile.stopRecording()
        }
        self.meterTimer?.invalidate()
        AlertHelper.InputDialog(self, title: NSLocalizedString("Recording name", comment: "Recording name title message of dialog to ask for title"), okButtonTitle: kSave, cancelButtonTitle: kDiscard, message: [NSLocalizedString("Please enter name for the recording", comment: "Message on recording name title dialog")], placeholder: NSLocalizedString("Recording name", comment: "Recording name title placeholder on dialog"), okCallback: { (data) -> Void in
            if let name = data {
                if name.count == 0 {
                    AlertHelper.DisplayAlert(self, title: kErrorTitle, messages: [NSLocalizedString("Name is required!", comment: "Error message when saving video and no name entered")], callback: {
                        self.doneAndSaveButtonTapped(sender)
                    })
                } else {
                    self.dismiss(animated: true) { () -> Void in
                        if let videoAtt = self.videoAttachment {
                            videoAtt.Name = name
                            self.OnGeneratedVideo?(videoAtt)
                        }
                    }
                }
            }}, cancelCallback: {
                self.cancelButtonTapped(sender)
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        if let videoFile = self.videoFileOutput, videoFile.isRecording {
            videoFile.stopRecording()
        }
        self.videoAttachment?.clear()
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
}

