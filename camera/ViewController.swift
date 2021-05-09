//
//  ViewController.swift
//  camera
//
//  Created by Ahmed Adm on 26/09/1442 AH.
//

import UIKit
import AVFoundation

class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var cameraPrview:UIView!
    
    // session
    var session: AVCaptureSession?
    
    // video preview
    var previewLayer = AVCaptureVideoPreviewLayer()
        
    var front = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        cameraPrview.layer.addSublayer(previewLayer)
        cameraPermissionRequest()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraPrview.bounds
    }
    
    @IBAction func switchBtn(_ sender:Any ){
        // https://stackoverflow.com/questions/53995076/how-to-switch-camera-using-avfoundation/54020494
        session?.beginConfiguration()
        let currentInput = session?.inputs.first as? AVCaptureDeviceInput
        session?.removeInput(currentInput!)
        let newCameraDevice = currentInput?.device.position == .back ? getCamera(with: .front) : getCamera(with: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        session?.addInput(newVideoInput!)
        session?.commitConfiguration()
    }
    
    func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice] else {
            return nil
        }
        
        return devices.filter {
            $0.position == position
            }.first
    }
    
    private func cameraPermissionRequest(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video){ [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera(){
        let session = AVCaptureSession()
        
        var camera = getDevice(position: .back)
        
        if self.front {
            camera = getDevice(position: .front)
            self.front = false
        }
        
        if let device = camera{
            do{
                               
                let input = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
                session.sessionPreset = .cif352x288
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                
                session.startRunning()
                self.session = session
                
            }catch{
                print("error: \(error)")
            }
        }
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
               return deviceConverted
            }
        }
       return nil
    }

    // https://mobisoftinfotech.com/resources/mguide/h264-encode-decode-using-videotoolbox/
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }

}

