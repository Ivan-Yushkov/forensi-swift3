//
//  AudioRecordingViewController.swift
//  ForensiDoc

import Foundation
import AVFoundation


open class AudioRecordingViewController: BaseViewController {
    var recorder: AVAudioRecorder!
    
    var audioAttachment: EntryFormAttachment?
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneAndSave: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    
    
    @IBOutlet var statusLabel: UILabel!
    
    var meterTimer:Timer!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if let ef = self.entryForm {
            self.audioAttachment = EntryFormAttachment.CreateForAudio(ef)
        }
        
        doneAndSave.isHidden = true
        stopButton.isHidden = true
        recordButton.isHidden = false
        
        askForNotifications()
        checkHeadphones()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.recorder?.deleteRecording()
        self.audioAttachment?.clear()
        self.dismiss(animated: true, completion: .none)
    }
    
    func updateAudioMeter(_ timer:Timer) {
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            statusLabel.text = s
            recorder.updateMeters()
            // if you want to draw some graphics...
            //var apc0 = recorder.averagePowerForChannel(0)
            //var peak0 = recorder.peakPowerForChannel(0)
        }
    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
    }
    
    @IBAction func recordOrStop(_ sender: UIButton) {
        if recorder == nil {
            print("recording for the first time. recorder nil")
            DispatchQueue.main.async(execute: {
                UIView.animate(withDuration: 0.2, animations: {
                    self.doneAndSave.isHidden = false
                    self.recordButton.isHidden = true
                    self.stopButton.isHidden = false
                    }, completion: .none)
            })

            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("stop recording")
            recorder?.stop()
            DispatchQueue.main.async(execute: {
                UIView.animate(withDuration: 0.2, animations: {
                    self.doneAndSave.isHidden = false
                    self.recordButton.isHidden = false
                    self.stopButton.isHidden = false
                    }, completion: .none)
            })
            
        } else {
            AlertHelper.DisplayConfirmationDialog(self, title: NSLocalizedString("Confirm", comment: "Title on the confirmation dialog"), messages: [NSLocalizedString("You already have recorded audio. Do you want to start recording a new one?", comment: "Question asked when trying to record audio while already have some recorded.")], okCallback: {
                print("record again")
                self.doneAndSave.isHidden = false
                self.recordWithPermission(false)
                }, cancelCallback: .none)
        }
    }
    
    @IBAction func doneAndSaveTapped(_ sender: UIButton) {
        if let rec = self.recorder, recorder.isRecording {
            rec.stop()
        }
        
        if let ef = self.entryForm, let att = self.audioAttachment {
            AlertHelper.InputDialog(self, title: NSLocalizedString("Title", comment: "Title on the dialog to save audio"), okButtonTitle: kSave, cancelButtonTitle: kDiscard, message: [NSLocalizedString("Please enter title for the recording.", comment: "Message asking to enter recording title.")], placeholder: NSLocalizedString("Recordind title", comment: "Placeholder for the dialog on the recording audio"), okCallback: { (data) in
                if let title = data {
                    if title.characters.count == 0 {
                        AlertHelper.DisplayAlert(self, title: kErrorTitle, messages: [NSLocalizedString("Name is required!", comment: "Name is required message when saving audio and name is empty")], callback: { 
                            self.doneAndSaveTapped(sender)
                        })
                    } else {
                        att.Name = title
                        ef.addAttachment(att)
                        self.dismiss(animated: true, completion: .none)
                    }
                } else {
                    AlertHelper.DisplayAlert(self, title: NSLocalizedString("No title", comment: "No title title dialog when user did not input any recording title."), messages: [NSLocalizedString("You did not enter any title for the recording", comment: "Message when user does not enter any recording title.")], callback: .none)
                }
                }, cancelCallback: {
                    self.dismiss(animated: true, completion: .none)
            })
            
        } else {
            fatalError("Catastrophic error. entryForm or audioAttachment not set")
        }
    }
    
    func setupRecorder() {
        self.audioAttachment?.clear()
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 320000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        
        do {
            if let url = self.audioAttachment?.NSURLFile {
                recorder = try AVAudioRecorder(url: url as URL, settings: recordSettings)
                recorder.delegate = self
                recorder.isMeteringEnabled = true
                recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            }
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func recordWithPermission(_ setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                        target:self,
                        selector:#selector(AudioRecordingViewController.updateAudioMeter(_:)),
                        userInfo:nil,
                        repeats:true)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func askForNotifications() {
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(AudioRecordingViewController.background(_:)),
            name:NSNotification.Name.UIApplicationWillResignActive,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(AudioRecordingViewController.foreground(_:)),
            name:NSNotification.Name.UIApplicationWillEnterForeground,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(AudioRecordingViewController.routeChange(_:)),
            name:NSNotification.Name.AVAudioSessionRouteChange,
            object:nil)
    }
    
    func background(_ notification:Notification) {
        print("background")
    }
    
    func foreground(_ notification:Notification) {
        print("foreground")
    }
    
    
    func routeChange(_ notification:Notification) {
        print("routeChange \(String(describing: notification.userInfo))")
        
        if let userInfo = notification.userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
}


// MARK: AVAudioRecorderDelegate
extension AudioRecordingViewController : AVAudioRecorderDelegate {
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
        error: Error?) {
            
            if let e = error {
                print("\(e.localizedDescription)")
            }
    }
    
}
