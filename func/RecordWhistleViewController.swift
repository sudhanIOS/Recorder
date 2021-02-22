//
//  RecordWhistleViewController.swift
//  func
//
//  Created by Hariharasudhan J on 11/02/21.
//

import UIKit
import AVFoundation

class RecordWhistleViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var stackView: UIStackView!
    
    @IBOutlet weak var sliderNew: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Record your whistle"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)

            recordingSession = AVAudioSession.sharedInstance()

            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.loadRecordingUI()
                            self.loadPlayUI()
                        } else {
                            self.loadFailUI()
                        }
                    }
                }
            } catch {
                self.loadFailUI()
            }
    }
    override func loadView() {
        view = UIView()

        view.backgroundColor = UIColor.gray

        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)
    }
    func loadPlayUI() {
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Play", for: .normal)
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0

        stackView.addArrangedSubview(failLabel)
    }
    func loadSlider() {
        slider = UISlider(frame: CGRect(x: 0, y: 50, width: 250, height: 250))
        slider.maximumValue = Float (audioPlayer!.duration)
        slider.translatesAutoresizingMaskIntoConstraints = false
        self.view .addSubview(slider)
        
    }
    func finishRecording(success: Bool) {
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)

        whistleRecorder.stop()
        whistleRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)

            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    @objc func nextTapped() {

    }
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    class func getWhistleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("whistle2.m4a")
    }
    func startRecording() {
        // 1
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)

        // 2
        recordButton.setTitle("Tap to Stop", for: .normal)

        // 3
        let audioURL = RecordWhistleViewController.getWhistleURL()
        print(audioURL.absoluteString)

        // 4
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            // 5
            whistleRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    @objc func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    @objc func playTapped() {
        merge()
                    
                    var error : NSError?
            let audioURL = RecordWhistleViewController.getWhistleURL()
            do {
                    try audioPlayer = AVAudioPlayer.init(contentsOf: audioURL)
                } catch {
                    print("Error1", error.localizedDescription)
                }
                    audioPlayer?.delegate = self
                    
                    if let err = error{
                    }else{
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                        audioPlayer?.volume = 1.0
                        audioPlayer?.delegate = self
loadSlider()
                        
                    }
                }
    func concatenateFiles(audioFiles: [NSURL], completion: (_ concatenatedFile: NSURL?) -> ()) {
        

        

        // Concatenate audio files into one file
        var nextClipStartTime = CMTime.zero
        let composition = AVMutableComposition()
        let track = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        // Add each track
        for recording in audioFiles {
            let asset = AVURLAsset(url: NSURL(fileURLWithPath: recording.path!) as URL, options: nil)
            if let assetTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
                let timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
                
                do {
                    try track!.insertTimeRange(timeRange, of: assetTrack, at: nextClipStartTime)
                    nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRange.duration)
                } catch {
                    print("Error concatenating file - \(error)")
                    completion(nil)
                    return
                }
            }
        }

        // Export the new file
        if let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documents = NSURL(string: paths.first!)

            if let fileURL = documents?.appendingPathComponent("file_name.caf") {
                // Remove existing file
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    print("Removed \(fileURL)")
                } catch {
                    print("Could not remove file - \(error)")
                }

                // Configure export session output
                exportSession.outputURL = NSURL.fileURL(withPath: fileURL.path)
                exportSession.outputFileType = AVFileType.caf

                // Perform the export
                exportSession.exportAsynchronously() { () -> Void in
                    if exportSession.status == .completed {
                        print("Export complete")
                    
                       
                        return
                    } else if exportSession.status == .failed {
                        print("Export failed - \(exportSession.error)")
                    }

                    return
                }
            }
        }
    }
    func merge(){
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioUrl = RecordWhistleViewController.getDocumentsDirectory().appendingPathComponent("whistle.m4a")

        let audioUrl1 = RecordWhistleViewController.getDocumentsDirectory().appendingPathComponent("whistle1.m4a")
        let audioUrl2 = RecordWhistleViewController.getDocumentsDirectory().appendingPathComponent("whistle2.m4a")
        let recordingUrl = RecordWhistleViewController.getDocumentsDirectory().appendingPathComponent("recorded.m4a")


        // getDocumentsDirectory().appendingPathComponent("whistle2.m4a")
        compositionAudioTrack!.append(url: audioUrl)

        compositionAudioTrack!.append(url: audioUrl1)
        compositionAudioTrack!.append(url: audioUrl2)

        if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) {
            assetExport.outputFileType = AVFileType.m4a
            assetExport.outputURL = recordingUrl
            assetExport.exportAsynchronously(completionHandler: {
                                                switch assetExport.status
                                                {
                                                case AVAssetExportSessionStatus.failed:
                                                    print("failed \(String(describing: assetExport.error))")
                                                case AVAssetExportSessionStatus.cancelled:
                                                    print("cancelled \(String(describing: assetExport.error))")
                                                case AVAssetExportSessionStatus.unknown:
                                                    print("unknown\(String(describing: assetExport.error))")
                                                case AVAssetExportSessionStatus.waiting:
                                                    print("waiting\(String(describing: assetExport.error))")
                                                case AVAssetExportSessionStatus.exporting:
                                                    print("exporting\(String(describing: assetExport.error))")
                                                default:
                                                    print("complete")
                                                }            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AVMutableCompositionTrack {
    func append(url: URL) {
        let newAsset = AVURLAsset(url: url)
        let range = CMTimeRangeMake(start: CMTime.zero, duration: newAsset.duration)
        let end = timeRange.end
        print(end)
        if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
            try! insertTimeRange(range, of: track, at: end)
        }
        
    }
}
