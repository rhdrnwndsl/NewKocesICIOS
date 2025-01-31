//
//  Setting.swift
//  osxapp
//
//  Created by 金載龍 on 2020/12/31.
//

import Foundation


class Setting{
    static let shared = Setting()
    public let AppVer: String = "1000"  //앱버전
    public var AppName: String?
    public var ApptoApp: String = ""
    public var WebtoApp: String = ""
    
    //TCP SERVER IP
    public static let HOST_STORE_DOWNLOAD_IP: String = "211.192.167.38" //실서버
//    public static let HOST_STORE_DOWNLOAD_IP: String = "211.192.167.87" //테스트서버
    public static let HOST_STORE_DOWNLOAD_PORT :Int = 10555
    
    /** workingkey */
    public var WorkingKeyIndex:String = "01"
    public var WorkingKey:String = ""
    /** 세금, 할부 설정 */
    public var Tax_VAT:Int = 10     //부가세 10 설정
    public var InstallMentMinimum: Int = 0  //할부 최소 금액
//    public var InstallMentMinimum: Int = 49999  //할부 최소 금액
    /** 서명 데이터 관련 변수 */
    public var g_sDigSignInfo:String = ""
    
    /** 단말기 제품 코드버전 정보 */
    public var mCodeVersionNumber:String = ""
    
    /** 가맹점데이터 */
    public var mMchdata:String = ""
    
    /** 캐쉬의 인풋메쏘드, 캐쉬거래에서 EOT 미수신으로 망취소를 날릴때 저장된 인풋메쏘드가 필요하다 */
    public var mInputCashMethod:String = "";
    
     /** 캐쉬의 개인/법인구분자, 캐쉬거래에서 EOT 미수신으로 망취소를 날릴때 저장된 개인/법인구분자가 필요하다 */
    public var mPrivateOrCorp:String = "";
    
    /** 결제 시 카드입력대기시간. 앱투앱으로 해당인자를 가져온다. 디폴트 값은 30 */
    public var mDgTmout:String = "30"
    
    /** 결제 시 사인데이터입니다. 앱투앱으로 해당인자를 가져온다. */
    public var mDscData:String = ""
    
    /** 리턴할 웹앱 주소 */
    public var mWebAPPReturnAddr:String = "";
    
    /** 앱투앱/웹투앱으로 데이터 전송시 받은 데이터. 데이터를 다시 앱/웹으로 보낼는게 실패 시 거래취소를 위해 받아둔다. */
    var tmpMoney:String = "0"
    var tmpTax:String = "0"
    var tmpSvc:String = "0"
    var tmpTxf:String = "0"
    var tmpInstallment:String = "0"
    var tmpInsYn:String = "1"
    var tmpTid:String = ""
    
    
    private init()
    {
        WorkingKeyIndex = getDefaultUserData(_key: define.WORKINGKEY_INDEX)
        WorkingKey = getDefaultUserData(_key: define.WORKINGKEY)
    }
    
    /**
     사용자 데이터 저장
     - parameter _data:String 저장 데이터
     - parameter _key:키 값
     - returns: bool:성공,실패
     */
    @discardableResult
    func setDefaultUserData(_data:String,_key:String)-> Bool {
        let userData = UserDefaults.standard
        userData.setValue(_data,forKey: _key)
        return userData.synchronize()
    }
    /**
     사용자데이터가져오기
     - parameter _key:키 값
     - returns: bool:성공,실패
     */
    func getDefaultUserData(_key:String) -> String {
        guard let value = UserDefaults.standard.string(forKey:_key) else { return "" }
        return value
    }
    
    func getInstance() -> Setting {
        return Setting.shared
    }
    
    
}
