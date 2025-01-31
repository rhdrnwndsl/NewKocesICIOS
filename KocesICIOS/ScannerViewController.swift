//
//  ScannerViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/05/01.
//

import Foundation
import UIKit
import AVFoundation

enum ScannerStatus {
    case success(_ code: String?)
    case fail
    case stop(_ isButtonTap: Bool)
}

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var readerView: UIView!
    @IBOutlet weak var readButton: JButton!
    var mKakaoSdk:KaKaoPaySdk = KaKaoPaySdk()
    var mCatSdk:CatSdk = CatSdk()
    var mPaySdk:PaySdk = PaySdk()
    var mSdk:String = ""
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var centerGuideLineView: UIView?
    
    var captureSession: AVCaptureSession?
    
    var readCount = 0
    
    var isRunning: Bool {
        guard let captureSession = self.captureSession else {
            self.fail()
            return false
        }

        return captureSession.isRunning
    }

    let metadataObjectTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .code93, .code128, .ean8, .ean13, .aztec, .pdf417, .itf14, .dataMatrix, .interleaved2of5, .qr]

    private func initialSetupView() {
        view.clipsToBounds = true
        self.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            self.fail()
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error.localizedDescription)
            self.fail()
            return
        }

        guard let captureSession = self.captureSession else {
            self.fail()
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            self.fail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = self.metadataObjectTypes
        } else {
            self.fail()
            return
        }
        
        self.setPreviewLayer()
        self.setCenterGuideLineView()
        self.setButtonTitle()
        
        if isRunning {
            readButton.isSelected = false
            stop(isButtonTap: true)
        } else {
            readButton.isSelected = true
            start()
        }
    }
    
    private func setPreviewLayer() {
        guard let captureSession = self.captureSession else {
            self.fail()
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = view.layer.frame

        readerView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    private func setCenterGuideLineView() {
        let centerGuideLineView = UIView()
        centerGuideLineView.translatesAutoresizingMaskIntoConstraints = false
        centerGuideLineView.backgroundColor = #colorLiteral(red: 1, green: 0.5411764706, blue: 0.2392156863, alpha: 1)
        readerView.addSubview(centerGuideLineView)
        readerView.bringSubviewToFront(centerGuideLineView)

        centerGuideLineView.trailingAnchor.constraint(equalTo: readerView.trailingAnchor).isActive = true
        centerGuideLineView.leadingAnchor.constraint(equalTo: readerView.leadingAnchor).isActive = true
        centerGuideLineView.centerYAnchor.constraint(equalTo: readerView.centerYAnchor).isActive = true
        centerGuideLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        self.centerGuideLineView = centerGuideLineView
    }
    
    private func setButtonTitle() {
        readButton.setTitle("시작", for: .normal)
        readButton.setTitle("종료", for: .selected)
        readButton.backgroundColor = UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0)
        readButton.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
        readButton.setTitleColor(UIColor(displayP3Red: 233/255, green:81/255, blue: 23/255, alpha: 100.0), for: .selected)
        readButton.translatesAutoresizingMaskIntoConstraints = false
        readerView.bringSubviewToFront(readButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.readButton.layer.masksToBounds = true

        initialSetupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isRunning {
            stop(isButtonTap: false)
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.previewLayer?.frame = self.view.bounds
        if ((previewLayer?.connection?.isVideoOrientationSupported) != nil) {
            self.previewLayer?.connection?.videoOrientation = self.interfaceOrientation(toVideoOrientation: UIApplication.shared.statusBarOrientation)
        }
    }

    func interfaceOrientation(toVideoOrientation orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            break
        }

        print("Warning - Didn't recognise interface orientation (\(orientation))")
        return .portrait
    }
    
    public func initSetting(Sdk _sdk:String)
    {
        mSdk = _sdk
    }
    
    @IBAction func clicked_Scan(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        if isRunning {
            stop(isButtonTap: true)
        } else {
            start()
        }

        sender.isSelected = isRunning
    }

}

extension ScannerViewController {
    func start() {
        self.captureSession?.startRunning()
    }
    
    func stop(isButtonTap: Bool) {
        self.captureSession?.stopRunning()
        
        ScannerComplete(status: .stop(isButtonTap))
    }
    
    func fail() {
        ScannerComplete(status: .fail)
        self.captureSession = nil
        self.previewLayer = nil
        self.centerGuideLineView = nil
    }
    
    func found(code: String) {
        ScannerComplete(status: .success(code))
    }
    
    func ScannerComplete(status: ScannerStatus)
    {
        switch status {
        case let .success(code):
            guard let code = code else {
                self.dismiss(animated: true){ [self] in
                    switch(mSdk) {
                    case "KAKAO":
                        mKakaoSdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                        break
                    case "CAT":
                        mCatSdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                        break
                    case "MEMBER":
                        mPaySdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                        break
                    case "POINT":
                        mPaySdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                        break
                    default:
                        //아직없음
                        break
                    }
               
                    self.captureSession = nil
                    self.previewLayer = nil
                    self.centerGuideLineView = nil
                }
                return
            }
            
            self.dismiss(animated: true){ [self] in
                switch(mSdk) {
                case "KAKAO":
                    mKakaoSdk.Res_Scanner(Result: true, Message: "인식성공", Scanner: code)
                    break
                case "CAT":
                    mCatSdk.Res_Scanner(Result: true, Message: "인식성공", Scanner: code)
                    break
                case "MEMBER":
                    mPaySdk.Res_Scanner(Result: true, Message: "인식성공", Scanner: code)
                    break
                case "POINT":
                    mPaySdk.Res_Scanner(Result: true, Message: "인식성공", Scanner: code)
                    break
                default:
                    //아직없음
                    break
                }
             
                self.captureSession = nil
                self.previewLayer = nil
                self.centerGuideLineView = nil
            }
        case .fail:
            self.dismiss(animated: true){ [self] in
                switch(mSdk) {
                case "KAKAO":
                    mKakaoSdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                    break
                case "CAT":
                    mCatSdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                    break
                case "MEMBER":
                    mPaySdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                    break
                case "POINT":
                    mPaySdk.Res_Scanner(Result: false, Message: "QR코드 or 바코드를 인식하지 못했습니다", Scanner: "")
                    break
                default:
                    //아직없음
                    break
                }
             
                self.captureSession = nil
                self.previewLayer = nil
                self.centerGuideLineView = nil
            }
        case let .stop(isButtonTap):
            if isButtonTap {
//                self.readButton.isSelected = readerView.isRunning
                self.dismiss(animated: true){ [self] in
                    switch(mSdk) {
                    case "KAKAO":
                        mKakaoSdk.Res_Scanner(Result: false, Message: "바코드 읽기를 멈추었습니다", Scanner: "")
                        break
                    case "CAT":
                        mCatSdk.Res_Scanner(Result: false, Message: "바코드 읽기를 멈추었습니다", Scanner: "")
                        break
                    case "MEMBER":
                        mPaySdk.Res_Scanner(Result: false, Message: "바코드 읽기를 멈추었습니다", Scanner: "")
                        break
                    case "POINT":
                        mPaySdk.Res_Scanner(Result: false, Message: "바코드 읽기를 멈추었습니다", Scanner: "")
                        break
                    default:
                        //아직없음
                        break
                    }
           
                    self.captureSession = nil
                    self.previewLayer = nil
                    self.centerGuideLineView = nil
                }
            } else {
//                self.readButton.isSelected = readerView.isRunning
//                mKakaoSdk.Res_Scanner(Result: false, Message: "바코드 읽기를 멈추었습니다", Scanner: "")
//                self.dismiss(animated: false, completion: nil)
                return
            }
        }

//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
//
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stop(isButtonTap: false)
        
        if let metadataObject = metadataObjects.first {
            if readCount == 0 {
                readCount = 1
            } else {
                return
            }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}
