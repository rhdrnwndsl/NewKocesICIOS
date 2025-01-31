//
//  VerityController.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/28.
//

import UIKit

class VertiyController :UIViewController {

    let mKocesSdk:KocesSdk = KocesSdk.instance
    let mSqlite:sqlite = sqlite.instance
    var mDBbVerityTableResult:[DBVerityResult]?
    let VerityTableTitle:[String] = ["날짜","자동/수동","결과"]
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()
    
    @IBOutlet var VerityTable: UITableView! //무결성 결과 테이블
    override func viewDidLoad() {
        super.viewDidLoad()
        mDBbVerityTableResult = mSqlite.getVerityList()
        mDBbVerityTableResult?.sort( by: SortVeritylist)
        
        
        VerityTable.delegate = self
        VerityTable.dataSource = self
    }
    @IBAction func DissViewController_Clicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    ///무결성 검사 기록 데이터 최신 기준으로 소트 하기
    func SortVeritylist(first:DBVerityResult,second:DBVerityResult) -> Bool {
        return first.getDate() > second.getDate()
    }
    func readVerityData()
    {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
        //등록된 노티 개별 제거
//        NotificationCenter.default.removeObserver ( self, name : UIScene.didActivateNotification , object : nil )
//        NotificationCenter.default.removeObserver ( self, name : NSNotification.Name(rawValue: "BLEStatus") , object : nil )
    }
    
    @IBAction func DeviceVerity_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            let alertController = UIAlertController(title: "무결성검사", message: "연결이 되어 있지 않습니다. 연결 후 실행 해 주세요", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //만일 cat 연동일 경우
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            let alertController = UIAlertController(title: "무결성검사", message: "Cat 장비를 연결하였습니다. 지원하지 않는 모델입니다", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            mKocesSdk.GetVerity()
        }
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        switch bleStatus {

        case define.Disconnect:
                print("BLE_Status :", bleStatus)
//                let alertDisconnect = UIAlertController(title: "Disconnect", message: "재연결을 시도 하시겠습니까?", preferredStyle: .alert)
//                let disconnectOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
//                    self.mKocesSdk.bleConnect()
//                })
//                alertDisconnect.addAction(disconnectOK)
//                present(alertDisconnect, animated: true, completion: nil)
            break
        case define.PairingKeyFail:
            print("BLE_Status :", bleStatus)
            break
        case define.Receive:
            DeviceVerityRes(ResData: self.mKocesSdk.mReceivedData)
            break
        default:
            break
        }
    }
    
    //로딩 박스
    func AlertLoadingBox(title _title:String) {
        alertLoading = UIAlertController(title: _title, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        alertLoading.view.addSubview(activityIndicator)
        alertLoading.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: alertLoading.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: alertLoading.view.bottomAnchor, constant: -20).isActive = true

        present(alertLoading, animated: true, completion: nil)
    }
    
    /// 무결성 검사 파싱 함수, DB 업데이트 무결성 검사 리스트 갱신
    /// - Parameter _res: 무결성 검사 결과 데이터
    func DeviceVerityRes(ResData _res:[UInt8])
    {
        let receive: String = String(describing: _res)
        let receiveData = _res
        print("receive_data :", Utils.UInt8ArrayToHexCode(_value: _res,_option: true))

        if(receiveData[3] == Command.CMD_VERITY_RES)
        {
            //무결성검사가 정상인지 아닌지를 체크하여 메세지박스로 표시한다
            var _resultMessage:String = ""
            switch receiveData[4...5] {
            case [0x30,0x30]:
                _resultMessage = "무결성검사가 정상입니다"
                mKocesSdk.mVerityCheck = define.VerityMethod.Success.rawValue
                mDBbVerityTableResult = mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "0")
                //정상
                break
            case [0x30,0x31]:
                _resultMessage = "리더기 무결성 검증실패 제조사A/S요망"
                mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                mDBbVerityTableResult = mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "1")
                //실패
                break
            case [0x30,0x32]:
                _resultMessage = "리더기 무결성 검증실패 제조사A/S요망"
                mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                mDBbVerityTableResult = mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "1")
                //FK검증실패
                break
            default:
                break
            }
            mDBbVerityTableResult?.sort(by: SortVeritylist)
            VerityTable.reloadData()
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: false){ [self] in
                let alertController = UIAlertController(title: "무결성검사", message: _resultMessage, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}

///무결성 검사 테이블
extension VertiyController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let Count = mDBbVerityTableResult?.count else {
            return 1
        }
        return Count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceVerityTableCell", for: indexPath) as! DeviceVerityTableCell
        
        if indexPath.row == 0
        {
            cell.lbl_date.text = VerityTableTitle[0]
            cell.lbl_mode.text = VerityTableTitle[1]
            cell.lbl_result.text = VerityTableTitle[2]
        }
        else
        {
            let chars:[Character] = Array( (self.mDBbVerityTableResult?[indexPath.row - 1].getDate())!)
            let txtAuDate:String = String(chars[0...1]) + "/" + String(chars[2...3]) + "/" + String(chars[4...5]) + " " +
                String(chars[6...7]) + ":" + String(chars[8...9]) + ":" + String(chars[10...11])
            cell.lbl_date.text = txtAuDate
            
//            cell.lbl_date.text = self.mDBbVerityTableResult?[indexPath.row - 1].getDate()
            cell.lbl_mode.text = self.mDBbVerityTableResult?[indexPath.row - 1].getMode()
            cell.lbl_result.text = self.mDBbVerityTableResult?[indexPath.row - 1].getResult()
            cell.lbl_date.baselineAdjustment = .alignCenters
            cell.lbl_mode.baselineAdjustment = .alignCenters
            cell.lbl_result.baselineAdjustment = .alignCenters
        }
        return cell
    }
    ///처리 하지 않음
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        }
            
}
