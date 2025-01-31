//
//  PaySdk.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/24.
//

import Foundation
import UIKit

/// 결제 관련 기능을 수행 하는 핵심 클래스
class PaySdk
{
    /**KocesSdk,tcpSdk 를 싱글톤으로 가져온다 */
    static let instance:PaySdk =  PaySdk()
    var paylistener: PayResultDelegate?
    
    /** 신용=1/현금=2 */
    var TradeType:Int = 0
    /** 거래금액 */
    var mMoney:Int = 0
    /** 할부개월 */
    var mInstallment:Int = 0
    /** 세금 */
    var mTax:String = ""
    /** 봉사료 */
    var mServiceCharge:String = ""
    /** 면세료 */
    var mTaxfree:String = ""
    /** 개인/법인 구분(신용X) 1:개인 2:법인 3:자진발급 4:원천 */
    var mPrivateBusinessType :Int = 0
    /** tid */
    var mTid:String = ""
    var mStoreName = "";
    var mStoreAddr = "";
    var mStoreNumber = "";
    var mStorePhone = "";
    var mStoreOwner = "";
    
    /** (앱투앱으로 실행시 앱투앱에서 받는다) 서명데이터 결과값을 받을 시 결과 키값 */
    var REQUEST_SIGNPAD:Int = 10001
    /** UI화면에 표시 또는 APP TO APP 데이터 전달용 HashMap 결과 데이터 */
    var sendData:[String:String] = [:]
    /** ic fallbackk 처리할때 폴백인지 아닌지 미리체크 */
    var isFallBack:Bool = false
    /** 은련결제시 패스워드 입력을 체크 */
    var isUnionpayNeedPassword:Bool = false

    /** 현금영수증입력형태 */
    var mCashInputType:String = ""
    /** cancel 관련 정보  */
    var mCancelInfo:String = ""
    var mCancelReason:String = ""
    var mInputMethod:String = ""
    var mPtCardCode:String = ""
    var mPtAcceptNumber:String = ""
    var mKocesTradeCode:String = ""
    var mBusinessData:String = ""
    var mBangi:String = ""
    var mICCancelInfo:String = ""
    var mICType:String = ""
    var mICInputMethod:String = ""
    var mICKocesTranUniqueNum:String = ""
    var mICPassword:String = ""
    var mCompCode:String = ""
    /** 망취소 발생시 카운트함 -> 현금쪽은 망취소 발생하여 해당 내역을 다시 수신하면 거래성공으로 간주해버리기때문에 */
//    var mEotCancel:Int = 0    해당 변수는 kocesSdk 내부에 선언해두었다
    
    /** 포인트거래 시 전문번호 */
    var  mPointCompName:String = "";
    var  mPointComdPasswdYN:String = "";
    var  mPointTrdType:String = "";
    var  mPointQrNo:String = "";

    var  mPointPassWd:String = "";

    /** 거래 시 사용되는 데이터 */
    var mTmicno:[UInt8] = Array()
    var mEncryptInfo: [UInt8] = Array()
    var mKsn_track2data:[UInt8] = Array()
    var mEMVTradeType:String = ""
    var mIcreqData: [UInt8] = Array()
    var mFallbackreason:String = ""
    var mUnionPasswd:String = ""
    var mMchdata:String = ""
    var mCodeVersion:String = ""
    var mCashTrack:[UInt8] = Array()
    var mCashTrack2data:[UInt8] = Array()
    /** 2차제너레이션 시 사용되는 데이터 */
    var mARD:[UInt8] = Array()
    var mIAD:[UInt8] = Array()
    var mIS: [UInt8] = Array()
    /** 같은 커맨드가 2회연속 호출되는 경우를 방지 */
    var LASTCOMAND:UInt8 = 0x00;
    
    /** 현재 화면이 앱투앱인지 아닌지를 체크 DB 저장을 위해서 */
    var mDBAppToApp:Bool = false
    
    /** 결제 시 서명입력을 할지를 정합니다. 앱투앱/웹투엡으로 해당인자를 가져온다. 디폴트 값은 1 =서명  0=무서명 */
    var mDscYn:String = "1"
    
    /** 신용결제 시 폴백처리를 할지를 정합니다. 앱투앱/웹투엡으로 해당인자를 가져온다. 디폴트 값은 0=미사용 1=사용*/
    var mFBYn:String = "0"
    
    /** 원거래일자. 취소시 원거래일자 항목을 삽입하기 위해 사용한다. 해당 데이터는 프린트시 출력에 표시하기 위한 내용이다 */
    var mOriAudate:String = ""
    
    /** 원거래일자. 취소시 거래내역을 업데이트를 위한 비교구반자 들 중 하나 */
    var mOriAuNum:String = ""
    
    /** 망취소발생하여 거래를 취소했다는 것을 알려주는 내용 */
    var m2TradeCancel:Bool = false
    
    var mDeley = 0.5
    /** ApptoAppActivity 또는 PaymentActivity 로 데이터를 보내기 위한 리스너 */
    //리스너 부분은 일단 패스 차후에 구현
    // private SerialInterface.PaymentListener mPaymentListener;

    /**
     * PaymentSdk 생성
     * @param _tradeType 현금/신용
     * @param _PaymentListener 리스너
     */
    
    public init(){
       
        
    }
    
   
    /** 사용되는 변수들 초기화 */
    func Clear()
    {
        PaySdk.instance.mMoney = 0;
        PaySdk.instance.mInstallment = 0;
        PaySdk.instance.mPrivateBusinessType = 0
        PaySdk.instance.mTax = ""
        PaySdk.instance.mServiceCharge = ""
        PaySdk.instance.mTaxfree = ""
        PaySdk.instance.mCancelInfo = ""
        PaySdk.instance.mCancelReason = ""
        PaySdk.instance.mInputMethod = ""
        PaySdk.instance.mPtCardCode = ""
        PaySdk.instance.mPtAcceptNumber = ""
        PaySdk.instance.mBusinessData = ""
        PaySdk.instance.mBangi = ""
        PaySdk.instance.mKocesTradeCode = ""
        PaySdk.instance.mICCancelInfo = ""
        PaySdk.instance.mICType = ""
        PaySdk.instance.mICInputMethod = ""
        PaySdk.instance.mICKocesTranUniqueNum = ""
        PaySdk.instance.mICPassword = ""
        PaySdk.instance.m2TradeCancel = false

        for i in 0 ..< PaySdk.instance.mKsn_track2data.count {
            PaySdk.instance.mKsn_track2data[i] = 0x00
        }
        for i in 0 ..< PaySdk.instance.mKsn_track2data.count {
            PaySdk.instance.mKsn_track2data[i] = 0xFF
        }
        for i in 0 ..< PaySdk.instance.mKsn_track2data.count {
            PaySdk.instance.mKsn_track2data[i] = 0x00
        }

        for i in 0 ..< PaySdk.instance.mCashTrack2data.count {
            PaySdk.instance.mCashTrack2data[i] = 0x00
        }
        for i in 0 ..< PaySdk.instance.mCashTrack2data.count {
            PaySdk.instance.mCashTrack2data[i] = 0xFF
        }
        for i in 0 ..< PaySdk.instance.mCashTrack2data.count {
            PaySdk.instance.mCashTrack2data[i] = 0x00
        }
        
        for i in 0 ..< PaySdk.instance.mEncryptInfo.count {
            PaySdk.instance.mEncryptInfo[i] = 0x00
        }
        for i in 0 ..< PaySdk.instance.mEncryptInfo.count {
            PaySdk.instance.mEncryptInfo[i] = 0xFF
        }
        for i in 0 ..< PaySdk.instance.mEncryptInfo.count {
            PaySdk.instance.mEncryptInfo[i] = 0x00
        }
        
        //PaySdk.instance.mTmicno = []
        PaySdk.instance.mEncryptInfo = []
        PaySdk.instance.mKsn_track2data = []
        PaySdk.instance.mIcreqData = []
        PaySdk.instance.mCashTrack = []
        PaySdk.instance.mCashTrack2data = []
        
        PaySdk.instance.mFallbackreason = ""
        Setting.shared.g_sDigSignInfo = ""
        PaySdk.instance.mUnionPasswd = ""
        PaySdk.instance.mEMVTradeType = ""
        PaySdk.instance.mMchdata = ""
        PaySdk.instance.mCompCode = ""
        PaySdk.instance.mCodeVersion=""


        PaySdk.instance.mARD = []
        PaySdk.instance.mIAD = []
        PaySdk.instance.mIS = []

        PaySdk.instance.isUnionpayNeedPassword = false
        
        /** 현금영수증 관련 */
        PaySdk.instance.mCashInputType = ""
        PaySdk.instance.mDscYn = "1"
        
        PaySdk.instance.mFBYn = "0"
        PaySdk.instance.mOriAudate = ""
        PaySdk.instance.mOriAuNum = ""
        
        PaySdk.instance.mStoreName = "";
        PaySdk.instance.mStoreAddr = "";
        PaySdk.instance.mStoreNumber = "";
        PaySdk.instance.mStorePhone = "";
        PaySdk.instance.mStoreOwner = "";
    }

    /** 사용하지 않음 */
    func Reset()
    {

    }
    
    /** 현재 뷰컨트롤러 확인한다 */
    func CurrentViewController() -> String {
        let topController: UIViewController = Utils.topMostViewController()!
        let topControllerName: String = String(describing: topController.self)
        return topControllerName
//        if topControllerName.contains("Credit") {
//            debugPrint(topControllerName)
//        }
    }
    
    /**
     * 현금 영수증 제일 처음 시작 부분
     * @param _ctx 현재 엑티비티
     * @param _Tid tid
     * @param _money 거래금액
     * @param _tax 세금
     * @param _serviceCharge 봉사료
     * @param _taxfree 면세료
     * @param _privateorbusiness 개인/법인
     * @param _reciptIndex
     * @param _CancelInfo 취소정보
     * @param _InputMethod 입력방법(키인)
     * @param _cancelReason 취소사유
     * @param _ptCardCode 포인트카드
     * @param _ptAcceptNum 포인트번호
     * @param _BusinessData 가맹점데이터
     * @param _bangi
     * @param _KocesTradeUnique 코세스거래고유번호
     * @param _Target 장치가 카드리더기=1 사인패드=2 멀티사인패드=3 멀티서명패드=4
     */
    func CashRecipt(Tid _Tid:String,Money _money:String,Tax _tax:Int,ServiceCharge _serviceCharge:Int,TaxFree _taxfree:Int,PrivateOrBusiness _privateorbusiness:Int,ReciptIndex _reciptIndex:String,CancelInfo _CancelInfo:String,OriDate _oriDate:String,InputMethod _InputMethod:String,CancelReason _cancelReason:String
                    ,ptCardCode _ptCardCode:String,ptAcceptNum _ptAcceptNum:String,BusinessData _BusinessData:String,Bangi _bangi:String,KocesTradeUnique _KocesTradeUnique:String,payLinstener _paymentlistener:PayResultDelegate,
                    StoreName _mStoreName:String, StoreAddr _mStoreAddr:String,StoreNumber _mStoreNumber:String,StorePhone _mStorePhone:String,StoreOwner _mStoreOwner:String)
    {
        //시작전에 항상 클리어 한다.
        Clear()
        
        PaySdk.instance.mStoreName = _mStoreName;
        PaySdk.instance.mStoreAddr = _mStoreAddr;
        PaySdk.instance.mStoreNumber = _mStoreNumber;
        PaySdk.instance.mStorePhone = _mStorePhone;
        PaySdk.instance.mStoreOwner = _mStoreOwner;
        
        PaySdk.instance.paylistener = _paymentlistener
        PaySdk.instance.mCancelInfo = _CancelInfo;
        PaySdk.instance.mCancelReason = _cancelReason;
        PaySdk.instance.mInputMethod = _InputMethod;
        PaySdk.instance.mPtCardCode = _ptCardCode;
        PaySdk.instance.mPtAcceptNumber = _ptAcceptNum;
        PaySdk.instance.mKocesTradeCode = _KocesTradeUnique;
        PaySdk.instance.mBusinessData = _BusinessData;
        PaySdk.instance.mBangi = _bangi;
        PaySdk.instance.mTid = _Tid;
        PaySdk.instance.mTax = String(_tax);
        PaySdk.instance.mServiceCharge = String(_serviceCharge);
        PaySdk.instance.mTaxfree = String(_taxfree);
        if !_CancelInfo.isEmpty {
            PaySdk.instance.mOriAudate = _oriDate
            var _tmpAunum = _CancelInfo.replacingOccurrences(of: _oriDate, with: "")
            _tmpAunum.removeFirst()
            _tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();
            PaySdk.instance.mOriAuNum = _tmpAunum
        }
        
        if String(describing: _paymentlistener).contains("AppToApp") {
            PaySdk.instance.mDBAppToApp = true
        } else  {
            PaySdk.instance.mDBAppToApp = false
        }
        
        // 문자열 공백제거
        let _icMoney = _money.replacingOccurrences(of: " ", with: "")
        
        PaySdk.instance.mMoney = Int(_icMoney)!;
//        let CovertMoney = Utils.leftPad(str: _icMoney, fillChar: "0", length: 10)
        let CovertMoney:String = Utils.leftPad(str: String(PaySdk.instance.mMoney), fillChar: "0", length: 10)
//        let CovertMoney = _icMoney
        PaySdk.instance.mPrivateBusinessType = _privateorbusiness;

        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "BLE장비가 연결되어 있지않습니다. BLE장비를 연결해 주세요"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 장비가 연결되어 있습니다. BLE 연결 후 재시도 해 주십시오"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        var TotalMoney:Int = Int(_icMoney)! + _tax + _serviceCharge
        var _iscancel = false
        if PaySdk.instance.mCancelInfo != "" {
            _iscancel = true
        }
        Utils.CardAnimationViewControllerInit(Message: "MSR카드를 읽어주세요", isButton: true, CountDown: Setting.shared.mDgTmout, TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        
//        mPosSdk.__PosInit("99",null,mPosSdk.AllDeviceAddr());  //먼저 장비를 초기화 시킨다.
        KocesSdk.instance.DeviceInit(VanCode: "99")
        
        KocesSdk.instance.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        /** 초기화 후 2초 뒤에 실행 */
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) { [self] in
            var type = "06"; //거래구분
            if(_privateorbusiness==3)
            {
                type = "09";
            }
            PaySdk.instance.LASTCOMAND = Command.CMD_IC_REQ;
            KocesSdk.instance.BleCash(Type: type, Money: CovertMoney, Date: Utils.getDate(format: "yyyyMMddHHmmss"), UsePad: "0", CashIC: "0", PrintCount: _reciptIndex, SignType: "0", MinPasswd: "01", MaxPasswd: "40", WorkingKeyIndex: define.WORKING_KEY_INDEX, WorkingKey: define.WORKING_KEY, CashICRnd: define.CASHIC_RANDOM_NUMBER)

        }

    }

    /**
     신용 제일 처음 시작부분
     */
    func CreditIC(Tid _Tid:String,Money _money:String,Tax _tax:Int,ServiceCharge _serviceCharge:Int,TaxFree _txf:Int,InstallMent _installment:String,OriDate _oriDate:String,
                  CancenInfo _cancelInfo:String,mchData _mchData:String,KocesTreadeCode _kocesTradeCode:String,CompCode _compCode:String,SignDraw _signDraw:String,FallBackUse _fallBackUse:String,payLinstener _paymentlistener:PayResultDelegate,
                  StoreName _mStoreName:String, StoreAddr _mStoreAddr:String,StoreNumber _mStoreNumber:String,StorePhone _mStorePhone:String,StoreOwner _mStoreOwner:String)
    {
        //시작전에 항상 클리어 한다.
        Clear()
        
        PaySdk.instance.mStoreName = _mStoreName;
        PaySdk.instance.mStoreAddr = _mStoreAddr;
        PaySdk.instance.mStoreNumber = _mStoreNumber;
        PaySdk.instance.mStorePhone = _mStorePhone;
        PaySdk.instance.mStoreOwner = _mStoreOwner;
        
        PaySdk.instance.paylistener = _paymentlistener
        PaySdk.instance.mTid = _Tid;
        PaySdk.instance.mICCancelInfo = _cancelInfo
        PaySdk.instance.mTax = String(_tax)
        PaySdk.instance.mServiceCharge = String(_serviceCharge);
        PaySdk.instance.mTaxfree = String(_txf);
        PaySdk.instance.mMchdata = _mchData;
        PaySdk.instance.mICKocesTranUniqueNum = _kocesTradeCode;
        PaySdk.instance.mCompCode = _compCode
        PaySdk.instance.mDscYn = _signDraw
        PaySdk.instance.mFBYn = _fallBackUse
        if !_cancelInfo.isEmpty {

            PaySdk.instance.mOriAudate = _oriDate
            var _tmpAunum = _cancelInfo.replacingOccurrences(of: _oriDate, with: "")
            _tmpAunum.removeFirst()
            _tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();
            PaySdk.instance.mOriAuNum = _tmpAunum
        }
        
        if String(describing: _paymentlistener).contains("AppToApp") {
            PaySdk.instance.mDBAppToApp = true
        } else  {
            PaySdk.instance.mDBAppToApp = false
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "BLE장비가 연결되어 있지않습니다. BLE장비를 연결해 주세요"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 장비가 연결되어 있습니다. BLE 연결 후 재시도 해 주십시오"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }

        if  _money != ""  //금액이 이상한 경우
        {
            let trimmedString = _money.trimmingCharacters(in: .whitespaces)
            PaySdk.instance.mMoney = Int(trimmedString)!

            if PaySdk.instance.mMoney < 0 || PaySdk.instance.mMoney > 900000000  //금액은 최대 9억을 넘을 수 없다.
            {
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "입력한 금액은 결제 할 수 없습니다"
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return;
            }
        }
        else
        {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "입력한 금액은 결제 할 수 없습니다"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        if _installment != ""  //할부금액이 이상한 경우
        {
            PaySdk.instance.mInstallment = Int(_installment)!

            if PaySdk.instance.mInstallment==0 {}
                else
                {
                    if PaySdk.instance.mInstallment < 2 || PaySdk.instance.mInstallment > 99 //할부의 경우에는 최대 99개월을 넘길 수 없다.
                    {
                        Clear()
                        var resDataDic:[String:String] = [:]
                        resDataDic["Message"] = "할부 개월이 정상적이지 않습니다"
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                        return;
                    }
                }
        }
        
        let CovertMoney:String = Utils.leftPad(str: String(PaySdk.instance.mMoney), fillChar: "0", length: 10)
        var TotalMoney:Int = PaySdk.instance.mMoney + _tax + _serviceCharge
        var _iscancel = false
        if PaySdk.instance.mICCancelInfo != "" {
            _iscancel = true
        }
        Utils.CardAnimationViewControllerInit(Message: "IC카드를 넣어주세요", isButton: true, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        
        KocesSdk.instance.DeviceInit(VanCode: "99")

        KocesSdk.instance.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        /** 초기화 후 2초 뒤에 실행 */
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) {

            PaySdk.instance.LASTCOMAND = Command.CMD_IC_REQ;
            PaySdk.instance.mICType = "01"
            /* 신용거래요청(카드단말기) */
            KocesSdk.instance.BleCredit(Type: PaySdk.instance.mICType, Money: CovertMoney , Date: Utils.getDate(format: "yyyyMMddHHmmss"), UsePad: "0", CashIC: "0", PrintCount: "0000", SignType: "0", MinPasswd: "00", MaxPasswd: "06", WorkingKeyIndex: define.WORKING_KEY_INDEX, WorkingKey: define.WORKING_KEY, CashICRnd: define.CASHIC_RANDOM_NUMBER)


        }
    }
    
    /**
     포인트 제일 처음 시작부분
     */
    func PointPay(TrdType _trdType:String,Tid _Tid:String,Money _money:String,OriDate _oriDate:String,CancenInfo _cancelInfo:String,mchData _mchData:String,CompCode _compCode:String,CompName _compName:String,PasswdYN _passwdYN:String,payLinstener _paymentlistener:PayResultDelegate,
                  StoreName _mStoreName:String, StoreAddr _mStoreAddr:String,StoreNumber _mStoreNumber:String,StorePhone _mStorePhone:String,StoreOwner _mStoreOwner:String,Qr _qr:String, IsQr _isqr:Bool)
    {
        //시작전에 항상 클리어 한다.
        Clear()
        
        PaySdk.instance.mStoreName = _mStoreName;
        PaySdk.instance.mStoreAddr = _mStoreAddr;
        PaySdk.instance.mStoreNumber = _mStoreNumber;
        PaySdk.instance.mStorePhone = _mStorePhone;
        PaySdk.instance.mStoreOwner = _mStoreOwner;
        
        PaySdk.instance.paylistener = _paymentlistener
        PaySdk.instance.mTid = _Tid;
        PaySdk.instance.mICCancelInfo = _cancelInfo
        PaySdk.instance.mMchdata = _mchData;
        PaySdk.instance.mCompCode = _compCode
        
        PaySdk.instance.mPointCompName = _compName
        PaySdk.instance.mPointComdPasswdYN = _passwdYN
        PaySdk.instance.mPointQrNo = _qr
        PaySdk.instance.mPointTrdType = _trdType
      
        if !_cancelInfo.isEmpty {
            PaySdk.instance.mOriAudate = _oriDate
            var _tmpAunum = _cancelInfo.replacingOccurrences(of: _oriDate, with: "")
            _tmpAunum.removeFirst()
            _tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();
            PaySdk.instance.mOriAuNum = _tmpAunum
        }
        
        if String(describing: _paymentlistener).contains("AppToApp") {
            PaySdk.instance.mDBAppToApp = true
        } else  {
            PaySdk.instance.mDBAppToApp = false
        }

        if  _money != ""  //금액이 이상한 경우
        {
            let trimmedString = _money.trimmingCharacters(in: .whitespaces)
            PaySdk.instance.mMoney = Int(trimmedString)!

            if PaySdk.instance.mMoney < 0 || PaySdk.instance.mMoney > 900000000  //금액은 최대 9억을 넘을 수 없다.
            {
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "입력한 금액은 결제 할 수 없습니다"
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return;
            }
        }
        else
        {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "입력한 금액은 결제 할 수 없습니다"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "BLE장비가 연결되어 있지않습니다. BLE장비를 연결해 주세요"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 장비가 연결되어 있습니다. BLE 연결 후 재시도 해 주십시오"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        
        let CovertMoney:String = Utils.leftPad(str: String(PaySdk.instance.mMoney), fillChar: "0", length: 10)
        var TotalMoney:Int = PaySdk.instance.mMoney
        var _iscancel = false
        if PaySdk.instance.mICCancelInfo != "" {
            _iscancel = true
        }
        Utils.CardAnimationViewControllerInit(Message: "포인트카드를 읽혀주세요", isButton: true, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        
        KocesSdk.instance.DeviceInit(VanCode: "99")

        KocesSdk.instance.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        /** 초기화 후 2초 뒤에 실행 */
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) {

            PaySdk.instance.LASTCOMAND = Command.CMD_IC_REQ;
            //"01"신용ic "02"은련ic "03"현금IC "04"포인트/멤버십 "05"투카드(신용+포인트)
            //"06"현금영수증 "07"폴백MSR "08"RF "09"현금영수증(자진발급) "10"은련폴백MSR
            //"11"현금IC카드조회 "12"가맹점자체MS전용회원카드
            PaySdk.instance.mICType = "04"
            
            if _isqr {
                Utils.ScannerOpen(Sdk: "POINT")
                return
            }
            /* 신용거래요청(카드단말기) */
            KocesSdk.instance.BleCredit(Type: PaySdk.instance.mICType, Money: CovertMoney , Date: Utils.getDate(format: "yyyyMMddHHmmss"), UsePad: "0", CashIC: "0", PrintCount: "0000", SignType: "0", MinPasswd: "00", MaxPasswd: "06", WorkingKeyIndex: define.WORKING_KEY_INDEX, WorkingKey: define.WORKING_KEY, CashICRnd: define.CASHIC_RANDOM_NUMBER)


        }
    }
    
    
    /**
     멤버십 제일 처음 시작부분
     */
    func MemberPay(TrdType _trdType:String,Tid _Tid:String,Money _money:String,OriDate _oriDate:String,CancenInfo _cancelInfo:String,mchData _mchData:String,payLinstener _paymentlistener:PayResultDelegate,StoreName _mStoreName:String, StoreAddr _mStoreAddr:String,StoreNumber _mStoreNumber:String,StorePhone _mStorePhone:String,StoreOwner _mStoreOwner:String,Qr _qr:String, IsQr _isqr:Bool)
    {
        //시작전에 항상 클리어 한다.
        Clear()
        
        PaySdk.instance.mStoreName = _mStoreName;
        PaySdk.instance.mStoreAddr = _mStoreAddr;
        PaySdk.instance.mStoreNumber = _mStoreNumber;
        PaySdk.instance.mStorePhone = _mStorePhone;
        PaySdk.instance.mStoreOwner = _mStoreOwner;
        
        PaySdk.instance.paylistener = _paymentlistener
        PaySdk.instance.mTid = _Tid;
        PaySdk.instance.mICCancelInfo = _cancelInfo
        PaySdk.instance.mMchdata = _mchData;

        PaySdk.instance.mPointQrNo = _qr
        PaySdk.instance.mPointTrdType = _trdType
      
        if !_cancelInfo.isEmpty {
            PaySdk.instance.mOriAudate = _oriDate
            var _tmpAunum = _cancelInfo.replacingOccurrences(of: _oriDate, with: "")
            _tmpAunum.removeFirst()
            _tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();
            PaySdk.instance.mOriAuNum = _tmpAunum
        }
        
        if String(describing: _paymentlistener).contains("AppToApp") {
            PaySdk.instance.mDBAppToApp = true
        } else  {
            PaySdk.instance.mDBAppToApp = false
        }

        if  _money != ""  //금액이 이상한 경우
        {
            let trimmedString = _money.trimmingCharacters(in: .whitespaces)
            PaySdk.instance.mMoney = Int(trimmedString)!

            if PaySdk.instance.mMoney < 0 || PaySdk.instance.mMoney > 900000000  //금액은 최대 9억을 넘을 수 없다.
            {
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "입력한 금액은 결제 할 수 없습니다"
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return;
            }
        }
        else
        {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "입력한 금액은 결제 할 수 없습니다"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        if _qr != "" {
            PaySdk.instance.mInputMethod = "K"
            Req_tcp_Member(TrdType: _trdType, Tid: _Tid, CancelInfo: _cancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: [UInt8](PaySdk.instance.mPointQrNo.utf8), idEncrpyt: [UInt8](), memberProductCode: "")
            return
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "BLE장비가 연결되어 있지않습니다. BLE장비를 연결해 주세요"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 장비가 연결되어 있습니다. BLE 연결 후 재시도 해 주십시오"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return;
        }
        
        
        let CovertMoney:String = Utils.leftPad(str: String(PaySdk.instance.mMoney), fillChar: "0", length: 10)
        var TotalMoney:Int = PaySdk.instance.mMoney
        var _iscancel = false
        if PaySdk.instance.mICCancelInfo != "" {
            _iscancel = true
        }
        Utils.CardAnimationViewControllerInit(Message: "멤버십카드를 읽혀주세요", isButton: true, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        
        KocesSdk.instance.DeviceInit(VanCode: "99")

        KocesSdk.instance.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        /** 초기화 후 2초 뒤에 실행 */
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) {

            PaySdk.instance.LASTCOMAND = Command.CMD_IC_REQ;
            //"01"신용ic "02"은련ic "03"현금IC "04"포인트/멤버십 "05"투카드(신용+포인트)
            //"06"현금영수증 "07"폴백MSR "08"RF "09"현금영수증(자진발급) "10"은련폴백MSR
            //"11"현금IC카드조회 "12"가맹점자체MS전용회원카드
            PaySdk.instance.mICType = "04"
            
            if _isqr {
                Utils.ScannerOpen(Sdk: "MEMBER")
                return
            }
            /* 신용거래요청(카드단말기) */
            KocesSdk.instance.BleCredit(Type: PaySdk.instance.mICType, Money: CovertMoney , Date: Utils.getDate(format: "yyyyMMddHHmmss"), UsePad: "0", CashIC: "0", PrintCount: "0000", SignType: "0", MinPasswd: "00", MaxPasswd: "06", WorkingKeyIndex: define.WORKING_KEY_INDEX, WorkingKey: define.WORKING_KEY, CashICRnd: define.CASHIC_RANDOM_NUMBER)


        }
    }
    
    /**
     스캐너 결과값
     */
    func Res_Scanner(Result _result:Bool, Message _msg:String, Scanner _scanner:String)
    {
        if _result != true {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = _msg
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return
        }
        PaySdk.instance.mPointQrNo = _scanner
        
        
        
        if _scanner.isEmpty {
            Clear()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "바코드 데이터를 가져오지 못했습니다"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return
        }

        if !_scanner.isEmpty {
            PaySdk.instance.mInputMethod = "K"
            if PaySdk.instance.mPointTrdType == Command.CMD_MEMBER_USE_REQ ||
                PaySdk.instance.mPointTrdType == Command.CMD_MEMBER_SEARCH_REQ ||
                PaySdk.instance.mPointTrdType == Command.CMD_MEMBER_CANCEL_REQ {
                Req_tcp_Member(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mICCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: [UInt8](PaySdk.instance.mPointQrNo.utf8), idEncrpyt: [UInt8](), memberProductCode: "")
            } else {
                //포인트
            }
                
         
        }
        
        
    }
    
    /**
       * 단말기로부터 현금거래 데이터를 받음
       * @param _res 데이터
       * @param justNumber 현금/IC현금 체크
       */
    func Res_CashRecipt(ResData _res:[UInt8],CashOrMsrCheck justNumber:Bool)
    {
          if(!justNumber) {
//              Command.ProtocolInfo protocolInfo = new Command.ProtocolInfo(res);
//              if (protocolInfo.Command != Command.CMD_IC_RES) {
//                  return;
//              }
//
//              ByteArray b = new ByteArray(protocolInfo.Contents);
            var res:[UInt8] = _res;
            res.removeSubrange(0..<4)
            //단말 인증 번호가 32개가 올라오지만 그 중에서 앞 16자리만 사용하고 나머지는 APPID로 채운다.
            var TmlcNo = [UInt8]()
            let startindex = res.index(res.startIndex, offsetBy: 0)
            let endindex = res.index(res.startIndex, offsetBy: 16)
            TmlcNo = Array(res[startindex..<endindex])
            //let appid: String = Setting.shared.getDefaultUserData(_key: define.APP_ID)
            let appid: String = define.KOCES_ID
            TmlcNo.append(contentsOf: Array(appid.utf8))
            res.removeSubrange(0..<32)

            //앞에 여섯자리면 서버에 전송 한다.
            let Track:[UInt8] = Array(res[0...5])
            res.removeSubrange(0..<6)
            PaySdk.instance.mCashTrack = Track
            //그래서 나머지 34바이트를 버린다.
            res.removeSubrange(0..<34)
            
            let Ksn:[UInt8] = Array(res[0...9])
            res.removeSubrange(0..<10)

            let Track2_Data:[UInt8] = Array(res[0...47])
            res.removeSubrange(0..<48)

            res.remove(at: 0);res.removeSubrange(0..<2);
            res.removeSubrange(0..<2);res.removeSubrange(0..<6);
            res.removeSubrange(0..<23);res.removeSubrange(0..<11);
            res.removeSubrange(0..<4);res.removeSubrange(0..<35);
            res.removeSubrange(0..<7);res.removeSubrange(0..<5);
            res.removeSubrange(0..<7);res.removeSubrange(0..<5);
            res.removeSubrange(0..<3);res.removeSubrange(0..<9);
            res.removeSubrange(0..<5);res.removeSubrange(0..<4);
            res.removeSubrange(0..<5);res.removeSubrange(0..<9);
            res.removeSubrange(0..<6);res.removeSubrange(0..<6);
            res.removeSubrange(0..<4);res.removeSubrange(0..<11);
            res.removeSubrange(0..<4);res.removeSubrange(0..<18);
            res.removeSubrange(0..<5);res.removeSubrange(0..<7);
            res.removeSubrange(0..<40);res.removeSubrange(0..<10);
            res.removeSubrange(0..<48); let result_code:String = Utils.utf8toHangul(str: [res[0], res[1]]);  res.removeSubrange(0..<2);
            res.removeSubrange(0..<16);
      
            var _ksn_track2data = [UInt8]()
            _ksn_track2data.append(contentsOf: Ksn)
            _ksn_track2data.append(contentsOf: Track2_Data)
            PaySdk.instance.mCashTrack2data = _ksn_track2data

            var _resultCode:String = Command.Check_IC_result_code(Res: result_code);  //result 코드를 확인 해서 처리 한다. 입력 메소드를 판단한다.

              //여기까지 왔다면 장비는 다 사용한 것으로 판단하여 초기화 시킨다.
//              DeviceReset();
            KocesSdk.instance.DeviceInit(VanCode: "99")
            if (_resultCode == "K" || _resultCode == "00" || _resultCode == "R" || _resultCode == "M" || _resultCode == "E" || _resultCode == "F")
            {
                PaySdk.instance.mInputMethod = _resultCode;
                if (_resultCode == "00") {
                    PaySdk.instance.mInputMethod = "S";
                }

                  /* 단말기로 받은 현금거래정보를 서버로 보낸다 */
                Req_tcp_Cash(Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: PaySdk.instance.mInputMethod, Id: Track, idEncrpyt: _ksn_track2data, PB: String(PaySdk.instance.mPrivateBusinessType), CancelReason: PaySdk.instance.mCancelReason, ptCardCode: PaySdk.instance.mPtCardCode, ptAcceptNum: PaySdk.instance.mPtAcceptNumber, businessData: PaySdk.instance.mBusinessData, Bangi: PaySdk.instance.mBangi, KocesTradeNumber: PaySdk.instance.mKocesTradeCode)
                
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                
//                  Req_tcp_Cash(mTid,mCancelInfo, mInputMethod, Track, _ksn_track2data.value(), String.valueOf(mPB), mCancelReason, mPtCardCode, mPtAcceptNumber, mBusinessData, mBangi, mKocesTradeCode);
                
            } else {
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = _resultCode
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return;
            }
 
          }
          else
          {
            var res:[UInt8] = _res;
            res.removeSubrange(0..<4)
            let length:String = Utils.utf8toHangul(str: [res[0], res[1]]);  res.removeSubrange(0..<2);
            let number:String = Utils.utf8toHangul(str: res);
            PaySdk.instance.mCashTrack = Array(res[0...(Int(length)!-1)])
            res.removeSubrange(0 ..< Int(length)!);
            PaySdk.instance.mInputMethod = "K";
            Req_tcp_Cash(Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: PaySdk.instance.mInputMethod, Id: PaySdk.instance.mCashTrack, idEncrpyt: [UInt8](), PB: String(PaySdk.instance.mPrivateBusinessType), CancelReason: PaySdk.instance.mCancelReason, ptCardCode: PaySdk.instance.mPtCardCode, ptAcceptNum: PaySdk.instance.mPtAcceptNumber, businessData: PaySdk.instance.mBusinessData, Bangi: PaySdk.instance.mBangi, KocesTradeNumber: PaySdk.instance.mKocesTradeCode)
//              Req_tcp_Cash(mTid,mCancelInfo, mInputMethod, number.getBytes(), null, String.valueOf(mPB), mCancelReason, mPtCardCode, mPtAcceptNumber, mBusinessData, mBangi, mKocesTradeCode);

          }
      }
    
    /**
     * 단말기로부터 받은 신용거래 정보를 서버로 보낸다
     * @param _res
     */
    func Res_Credit( _res:[UInt8]) {
        var res = _res
        res.removeSubrange(0..<4)
        //단말 인증 번호가 32개가 올라오지만 그 중에서 앞 16자리만 사용하고 나머지는 APPID로 채운다.
        var TmlcNo = [UInt8]()
        let startindex = res.index(res.startIndex, offsetBy: 0)
        let endindex = res.index(res.startIndex, offsetBy: 16)
        TmlcNo = Array(res[startindex..<endindex])
        //let appid: String = Setting.shared.getDefaultUserData(_key: define.APP_ID)
        let appid: String = define.KOCES_ID
        TmlcNo.append(contentsOf: Array(appid.utf8))
        res.removeSubrange(0..<32)
        
        //track(40) ksn(10) track2(48) emvtradetype(1) ...
        var tmpTrack:[UInt8] = Array(res[0...39])
        res.removeSubrange(0..<40)
        
        let Ksn:[UInt8] = Array(res[0...9])
        res.removeSubrange(0..<10)
        
        let Track2_Data:[UInt8] = Array(res[0...47])
        res.removeSubrange(0..<48)
        
        let EMVTradeType:[UInt8] = [res[0]]
        res.remove(at: 0)
        
        let Pos_Entry_mode_code:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)
        
        let Card_sequence_num:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)
        
        let Add_Pos_info:[UInt8] = Array(res[0...5])
        res.removeSubrange(0..<6)
        
        res.removeSubrange(0..<2)
        let Issuer_Script_result:[UInt8] = Array(res[0...20])
        res.removeSubrange(0..<21)
        
        res.removeSubrange(0..<2)
        let tmpApp_Crypt:[UInt8] = Array(res[0...8])
        res.removeSubrange(0..<9)
        
        res.removeSubrange(0..<2)
        let tmpCrypt_info_data:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)

        res.removeSubrange(0..<2)
        let tmpIssuer_app_data:[UInt8] = Array(res[0...32])
        res.removeSubrange(0..<33)
        
        res.removeSubrange(0..<2)
        let tmpUnpred_num:[UInt8] = Array(res[0...4])
        res.removeSubrange(0..<5)
        
        res.removeSubrange(0..<2)
        let tmpATC:[UInt8] = Array(res[0...2])
        res.removeSubrange(0..<3)
        
        res.remove(at: 0)
        let tmpTVR:[UInt8] = Array(res[0...5])
        res.removeSubrange(0..<6)
        
        res.remove(at: 0)
        let tmpT_date:[UInt8] = Array(res[0...3])
        res.removeSubrange(0..<4)
        
        res.remove(at: 0)
        let tmpT_type:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)
        
        res.removeSubrange(0..<2)
        let tmpT_Amount:[UInt8] = Array(res[0...6])
        res.removeSubrange(0..<7)
        
        res.removeSubrange(0..<2)
        let tmpT_Currency:[UInt8] = Array(res[0...2])
        res.removeSubrange(0..<3)
        
        res.remove(at: 0)
        let tmpAIP:[UInt8] = Array(res[0...2])
        res.removeSubrange(0..<3)
        
        res.removeSubrange(0..<2)
        let tmpTerminal_country:[UInt8] = Array(res[0...2])
        res.removeSubrange(0..<3)
        
        res.removeSubrange(0..<2)
        let tmpAmount_other:[UInt8] = Array(res[0...6])
        res.removeSubrange(0..<7)
        
        res.removeSubrange(0..<2)
        let tmpCVM_result:[UInt8] = Array(res[0...3])
        res.removeSubrange(0..<4)
        
        res.removeSubrange(0..<2)
        let tmpTerminal_Capabilities:[UInt8] = Array(res[0...3])
        res.removeSubrange(0..<4)
        
        res.removeSubrange(0..<2)
        let tmpTerminal_type:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)
        
        res.removeSubrange(0..<2)
        let tmpIFD_serial_num:[UInt8] = Array(res[0...8])
        res.removeSubrange(0..<9)
        
        res.removeSubrange(0..<2)
        let tmpTransaction_category:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)
        
        res.remove(at: 0)
        let tmpDedicated_filename:[UInt8] = Array(res[0...16])
        res.removeSubrange(0..<17)

        res.removeSubrange(0..<2)
        let tmpTerminal_app_version_num:[UInt8] = Array(res[0...2])
        res.removeSubrange(0..<3)
        
        res.removeSubrange(0..<2)
        let tmpTransaction_sequence_counter:[UInt8] = Array(res[0...4])
        res.removeSubrange(0..<5)
        
        res.removeSubrange(0..<40)//track2
        
        let tmpPaywaveFFIValueTag:[UInt8] = Array(res[0...1])
        res.removeSubrange(0..<2)
        let tmpPaywaveFFIValue:[UInt8] = Array(res[0...4])
        res.removeSubrange(0..<5)
        let tmpInputType:[UInt8] = [res[0]]
        res.remove(at: 0)
        let tmpFiller:[UInt8] = Array(res[0...49])
        res.removeSubrange(0..<50)
        
        let result_code:String = Utils.utf8toHangul(str: [res[0], res[1]])
        res.removeSubrange(0..<2)
        
        let tmpCode_version:[UInt8] = Array(res[0...15])
        res.removeSubrange(0..<16)
        
//        res.removeSubrange(0..<23)
        res.removeSubrange(0..<2);res.remove(at: 0); //signlength //FS
        res.removeSubrange(0..<2);res.removeSubrange(0..<2); //passwordlength //workingkeyindex
        res.removeSubrange(0..<16);  //Encrypted_password
        
        var _tmpicreqData = [UInt8]()
        _tmpicreqData.append(contentsOf: Pos_Entry_mode_code)
        _tmpicreqData.append(contentsOf: Card_sequence_num)
        var _last:Int = 0
        if Add_Pos_info[0] == 0 || Add_Pos_info[0] ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            let _emv:String = Utils.utf8toHangul(str: EMVTradeType)
            if _emv == "F" {
                let _tmp:[UInt8] = [0x90, 0x91]
                _tmpicreqData.append(contentsOf: _tmp)
            } else {
                _last = Int(Add_Pos_info[0])
                _tmpicreqData.append(contentsOf: Array(Add_Pos_info[0..._last]))
            }
        }
        
        if Int(Issuer_Script_result[0]) == 0 || Int(Issuer_Script_result[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(Issuer_Script_result[0])
            _tmpicreqData.append(contentsOf: Array(Issuer_Script_result[0..._last]))
        }
        
        if Int(tmpApp_Crypt[0]) == 0 || Int(tmpApp_Crypt[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpApp_Crypt[0])
            _tmpicreqData.append(contentsOf: Array(tmpApp_Crypt[0..._last]))
        }

        if Int(tmpCrypt_info_data[0]) == 0 || Int(tmpCrypt_info_data[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpCrypt_info_data[0])
            _tmpicreqData.append(contentsOf: Array(tmpCrypt_info_data[0..._last]))
        }

        if Int(tmpIssuer_app_data[0]) == 0 || Int(tmpIssuer_app_data[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpIssuer_app_data[0])
            _tmpicreqData.append(contentsOf: Array(tmpIssuer_app_data[0..._last]))
        }

        if Int(tmpUnpred_num[0]) == 0 || Int(tmpUnpred_num[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpUnpred_num[0])
            _tmpicreqData.append(contentsOf: Array(tmpUnpred_num[0..._last]))
        }
        
        if Int(tmpATC[0]) == 0 || Int(tmpATC[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpATC[0])
            _tmpicreqData.append(contentsOf: Array(tmpATC[0..._last]))
        }
        
        if Int(tmpTVR[0]) == 0 || Int(tmpTVR[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTVR[0])
            _tmpicreqData.append(contentsOf: Array(tmpTVR[0..._last]))
        }

        if Int(tmpT_date[0]) == 0 || Int(tmpT_date[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpT_date[0])
            _tmpicreqData.append(contentsOf: Array(tmpT_date[0..._last]))
        }

        if Int(tmpT_type[0]) == 0 || Int(tmpT_type[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpT_type[0])
            _tmpicreqData.append(contentsOf: Array(tmpT_type[0..._last]))
        }

        if Int(tmpT_Amount[0]) == 0 || Int(tmpT_Amount[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpT_Amount[0])
            _tmpicreqData.append(contentsOf: Array(tmpT_Amount[0..._last]))
        }

        if Int(tmpT_Currency[0]) == 0 || Int(tmpT_Currency[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpT_Currency[0])
            _tmpicreqData.append(contentsOf: Array(tmpT_Currency[0..._last]))
        }

        if Int(tmpAIP[0]) == 0 || Int(tmpAIP[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpAIP[0])
            _tmpicreqData.append(contentsOf: Array(tmpAIP[0..._last]))
        }
        
        if Int(tmpTerminal_country[0]) == 0 || Int(tmpTerminal_country[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTerminal_country[0])
            _tmpicreqData.append(contentsOf: Array(tmpTerminal_country[0..._last]))
        }
        
        if Int(tmpAmount_other[0]) == 0 || Int(tmpAmount_other[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpAmount_other[0])
            _tmpicreqData.append(contentsOf: Array(tmpAmount_other[0..._last]))
        }

        if Int(tmpCVM_result[0]) == 0 || Int(tmpCVM_result[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpCVM_result[0])
            _tmpicreqData.append(contentsOf: Array(tmpCVM_result[0..._last]))
        }

        if Int(tmpTerminal_Capabilities[0]) == 0 || Int(tmpTerminal_Capabilities[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTerminal_Capabilities[0])
            _tmpicreqData.append(contentsOf: Array(tmpTerminal_Capabilities[0..._last]))
        }

        if Int(tmpTerminal_type[0]) == 0 || Int(tmpTerminal_type[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTerminal_type[0])
            _tmpicreqData.append(contentsOf: Array(tmpTerminal_type[0..._last]))
        }

        if Int(tmpIFD_serial_num[0]) == 0 || Int(tmpIFD_serial_num[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
//            _last = Int(tmpIFD_serial_num[0])
            _last = 8
            /** 일단 _last 를 8 로 채운다 */
            _tmpicreqData.append(contentsOf: Array(tmpIFD_serial_num[0..._last]))
        }

        if Int(tmpTransaction_category[0]) == 0 || Int(tmpTransaction_category[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTransaction_category[0])
            _tmpicreqData.append(contentsOf: Array(tmpTransaction_category[0..._last]))
        }

        if Int(tmpDedicated_filename[0]) == 0 || Int(tmpDedicated_filename[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpDedicated_filename[0])
            _tmpicreqData.append(contentsOf: Array(tmpDedicated_filename[0..._last]))
        }

        if Int(tmpTerminal_app_version_num[0]) == 0 || Int(tmpTerminal_app_version_num[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTerminal_app_version_num[0])
            _tmpicreqData.append(contentsOf: Array(tmpTerminal_app_version_num[0..._last]))
        }

        if Int(tmpTransaction_sequence_counter[0]) == 0 || Int(tmpTransaction_sequence_counter[0]) ==  32 {
            _tmpicreqData.append(0x00)
        } else {
            _last = Int(tmpTransaction_sequence_counter[0])
            _tmpicreqData.append(contentsOf: Array(tmpTransaction_sequence_counter[0..._last]))
        }
        
        if(tmpPaywaveFFIValueTag[0] == 0x9f && tmpPaywaveFFIValueTag[1] == 0x6e)
        {
            if (tmpPaywaveFFIValue.isEmpty){
                _tmpicreqData.append(0x00)
            } else {
                _last = Int(tmpPaywaveFFIValue[0])
                _tmpicreqData.append(contentsOf: Array(tmpPaywaveFFIValue[0..._last]))
            }
            
            
        }
        else
        {
            _tmpicreqData.append(0x00)
        }

        var _ksn_track2data = [UInt8]()
        _ksn_track2data.append(contentsOf: Ksn)
        _ksn_track2data.append(contentsOf: Track2_Data)
        
        PaySdk.instance.mTmicno = TmlcNo
        PaySdk.instance.mEncryptInfo = tmpTrack;
        PaySdk.instance.mKsn_track2data = _ksn_track2data
        PaySdk.instance.mIcreqData = _tmpicreqData
        if Utils.UInt8ArrayToStr(UInt8Array: tmpCode_version) == "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"{
            PaySdk.instance.mCodeVersion = "                "
    //        Utils.utf8toHangul(str: tmpCode_version)
            Setting.shared.mCodeVersionNumber = "                "
        } else {
            PaySdk.instance.mCodeVersion = Utils.utf8toHangul(str: tmpCode_version)
    //        Utils.utf8toHangul(str: tmpCode_version)
            Setting.shared.mCodeVersionNumber = Utils.utf8toHangul(str: tmpCode_version)
        }
        
        //emv data
        if EMVTradeType[0] == 0x00 || EMVTradeType[0] == 0x20 || EMVTradeType[0] == 0x30 {
            PaySdk.instance.mEMVTradeType = " ";
        } else {
            PaySdk.instance.mEMVTradeType = Utils.utf8toHangul(str: EMVTradeType)
        }

        switch result_code {
        case "K ":
            PaySdk.instance.mICInputMethod = "K"
            break
        case "00":
            PaySdk.instance.mICInputMethod = "I"
            break
        case "R ":
            PaySdk.instance.mICInputMethod = "R"
            break
        case "M ":
            PaySdk.instance.mICInputMethod = "M"
            break
        case "E ":
            PaySdk.instance.mICInputMethod = "E"
            break
        case "F ":
            PaySdk.instance.mICInputMethod = "F"
            break
        case "99":
            PaySdk.instance.mICInputMethod = "R"
            break
        case "08":
            Clear()
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0xFF
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            _ksn_track2data = []
            _ksn_track2data.removeAll()
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0xFF
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            tmpTrack = []
            tmpTrack.removeAll()
            _tmpicreqData.removeAll()
            res.removeAll()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "카드읽기가 취소되었습니다"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return
        case "09":
            //IC카드입니다. IC 우선 거래해 주세요 여기서 다시 거래를 시작한다 이번에는 "01" -> "02"
//            Utils.customAlertBoxClear()
            var TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
            var _iscancel = false
            if PaySdk.instance.mICCancelInfo != "" {
                _iscancel = true
            }
            Utils.CardAnimationViewControllerInit(Message: "IC카드입니다. IC 우선 거래해 주세요", isButton: true, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
            DispatchQueue.main.asyncAfter(deadline: .now() + mDeley){ [self] in
                PaySdk.instance.mICType = "02"
//                Utils.customAlertBoxInit(Title: "거래불가", Message: "IC카드입니다. IC 우선 거래해 주세요", LoadingBar: true, GetButton: "")
                let bleMoney = Utils.leftPad(str: String(PaySdk.instance.mMoney), fillChar: "0", length: 10)
//                let bleMoney = String(self.mMoney)
                KocesSdk.instance.BleCredit(Type: PaySdk.instance.mICType, Money: bleMoney , Date: Utils.getDate(format: "yyyyMMddHHmmss"), UsePad: "0", CashIC: "0", PrintCount: "0000", SignType: "0", MinPasswd: "00", MaxPasswd: "06", WorkingKeyIndex: define.WORKING_KEY_INDEX, WorkingKey: define.WORKING_KEY, CashICRnd: define.CASHIC_RANDOM_NUMBER)

            }
            return

        case "10":
            //사용자 카드관련 정보 초기화
            Clear()
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0xFF
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            _ksn_track2data = []
            _ksn_track2data.removeAll()
            
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0xFF
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            tmpTrack = []
            tmpTrack.removeAll()
            _tmpicreqData.removeAll()
            res.removeAll()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "거래불가 카드입니다. 다른카드로 거래해 주세요"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return
        case "11":
            //사용자 카드관련 정보 초기화
            Clear()
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0xFF
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            _ksn_track2data = []
            _ksn_track2data.removeAll()
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0xFF
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            tmpTrack = []
            tmpTrack.removeAll()
            _tmpicreqData.removeAll()
            res.removeAll()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "거래불가 카드입니다. 다른카드로 거래해 주세요"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return
        case "12":
            //사용자 카드관련 정보 초기화
            Clear()
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0xFF
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            _ksn_track2data = []
            _ksn_track2data.removeAll()
            
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0xFF
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            tmpTrack = []
            tmpTrack.removeAll()
            _tmpicreqData.removeAll()
            res.removeAll()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "거래불가 카드입니다. 해외은련 카드 지원불가"
            PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            return
        default:
            break
        }

        //ic오류로 인한 폴백사유
        if(result_code == ("01") || result_code == ("02") || result_code == ("03") || result_code == ("04") ||
                result_code == ("05") || result_code == ("06") || result_code == ("07"))
        {
            //폴백 미사용이라면 폴백처리 없이 거래를 종료한다
            if PaySdk.instance.mFBYn == "1" {
                Clear()
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                _ksn_track2data.removeAll()
                for i in 0 ..< tmpTrack.count {
                    tmpTrack[i] = 0x00
                }
                for i in 0 ..< tmpTrack.count {
                    tmpTrack[i] = 0xFF
                }
                for i in 0 ..< tmpTrack.count {
                    tmpTrack[i] = 0x00
                }
                tmpTrack = []
                tmpTrack.removeAll()
                _tmpicreqData.removeAll()
                res.removeAll()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "폴백 거래는 사용자의 요청으로 인해 중지되었습니다. 거래를 종료합니다."
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return
            }
            
            //fallback은 여기서만 폴백이유를 받는다
            PaySdk.instance.mFallbackreason = result_code
            if PaySdk.instance.mEMVTradeType == "C" {
                PaySdk.instance.mICType = "02"
            } else {
                PaySdk.instance.mICType = "01"
            }

//            Utils.customAlertBoxClear()
            var TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
            var _iscancel = false
            if PaySdk.instance.mICCancelInfo != "" {
                _iscancel = true
            }
            Utils.CardAnimationViewControllerInit(Message: "IC오류입니다. 마그네틱을 읽혀주세요", isButton: true, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
            DispatchQueue.main.asyncAfter(deadline: .now() + mDeley){ [self] in
                var icType = ""
                if PaySdk.instance.mICType == "01" { icType = "07"; } else { icType = "10"; }
//                Utils.customAlertBoxInit(Title: "거래불가", Message: "IC오류입니다. 마그네틱을 읽혀주세요", LoadingBar: true, GetButton: "")
                let bleMoney = Utils.leftPad(str: String(PaySdk.instance.mMoney), fillChar: "0", length: 10)
//                                let bleMoney = String(self.mMoney)
                KocesSdk.instance.BleCredit(Type: icType, Money: bleMoney , Date: Utils.getDate(format: "yyyyMMddHHmmss"), UsePad: "0", CashIC: "0", PrintCount: "0000", SignType: "0", MinPasswd: "00", MaxPasswd: "06", WorkingKeyIndex: define.WORKING_KEY_INDEX, WorkingKey: define.WORKING_KEY, CashICRnd: define.CASHIC_RANDOM_NUMBER)

            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0xFF
            }
            for i in 0 ..< _ksn_track2data.count {
                _ksn_track2data[i] = 0x00
            }
            _ksn_track2data = []
            _ksn_track2data.removeAll()
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0xFF
            }
            for i in 0 ..< tmpTrack.count {
                tmpTrack[i] = 0x00
            }
            tmpTrack = []
            tmpTrack.removeAll()
            _tmpicreqData.removeAll()
            return
        }

        
        // 금액이 5만원 이상, 이하인 경우
        var TaxConvert:Int = 0 ;
        if(!PaySdk.instance.mTax.isEmpty) {
            TaxConvert = Int(PaySdk.instance.mTax) ?? 0
        }
        var SrvCharge:Int = 0;
        if(!PaySdk.instance.mServiceCharge.isEmpty) {
            SrvCharge = Int(PaySdk.instance.mServiceCharge) ?? 0
        }
        let TotalMoney:Int = PaySdk.instance.mMoney + TaxConvert + SrvCharge;
        
        var compareMoney = 0
        if String(describing: PaySdk.instance.paylistener).contains("AppToApp") {
            compareMoney = 50000    //앱투앱이면 5만원이상 일때 사인패드
            /** 이제 앱투앱이라도 5만원 고정이 아닌 본앱의 세금설정에 따라서 머니값을 정한다 */
            if Setting.shared.getDefaultUserData(_key: define.UNSIGNED_SETMONEY) == "" {
                compareMoney = 50000
            } else {
                compareMoney = Int(Setting.shared.getDefaultUserData(_key: define.UNSIGNED_SETMONEY)) ?? 50000
            }
        } else  {
            //앺투앱이 아니라면 세금설정을 체크.
            if Setting.shared.getDefaultUserData(_key: define.UNSIGNED_SETMONEY) == "" {
                compareMoney = 50000
            } else {
                compareMoney = Int(Setting.shared.getDefaultUserData(_key: define.UNSIGNED_SETMONEY)) ?? 50000
            }
        }
        
        if String(describing: PaySdk.instance.paylistener).contains("AppToApp")
        {
            if TotalMoney > compareMoney
            {
                if PaySdk.instance.mDscYn == "0" || PaySdk.instance.mDscYn == "1"{
                    Setting.shared.g_sDigSignInfo = "B"
                    //사인패드를 불러온다
        //            Utils.customAlertBoxClear()
                    if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                        Utils.topMostViewController()?.dismiss(animated: true) { [self] in
                            var storyboard:UIStoryboard?
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            } else {
                                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                            }
                            guard let signPad = storyboard!.instantiateViewController(withIdentifier: "SignatureController") as? SignatureController else {return}
                            signPad.sdk = "PaySdk"
                            signPad.money = String(TotalMoney)
                            if PaySdk.instance.mICCancelInfo != "" {
                                signPad.iscancel = true
                            } else {
                                signPad.iscancel = false
                            }
                            signPad.view.backgroundColor = .white
                            signPad.modalPresentationStyle = .fullScreen
                            Utils.topMostViewController()?.present(signPad, animated: true, completion: nil)
                        }
                    }
                } else if PaySdk.instance.mDscYn == "2" {
                    Setting.shared.g_sDigSignInfo = "B"
    //                let _stringImg:Data = Setting.shared.mDscData.data(using: .iso2022JP)!
    //                let _uint8Img = Array(_stringImg)
    //                let data : Data = Data(base64Encoded: Setting.shared.mDscData, options: .ignoreUnknownCharacters)!
    //                let _uint8Img = Array(data)
                    let _uint8Img = [UInt8](Setting.shared.mDscData.utf8)
                    Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: _uint8Img,_CodeNversion: "", _cancelInfo: mICCancelInfo,_kocesUnique: "");
                }

                
            }
            else
            {
                Setting.shared.g_sDigSignInfo = "5"
                Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: [UInt8](),_CodeNversion: "", _cancelInfo: mICCancelInfo,_kocesUnique: "");
            }
        }
        else
        {
            if TotalMoney > compareMoney {
                if PaySdk.instance.mDscYn == "0" || PaySdk.instance.mDscYn == "1"{
                    Setting.shared.g_sDigSignInfo = "B"
                    //사인패드를 불러온다
        //            Utils.customAlertBoxClear()
                    if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                        Utils.topMostViewController()?.dismiss(animated: true) { [self] in
                            var storyboard:UIStoryboard?
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            } else {
                                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                            }
                            guard let signPad = storyboard!.instantiateViewController(withIdentifier: "SignatureController") as? SignatureController else {return}
                            signPad.sdk = "PaySdk"
                            signPad.money = String(TotalMoney)
                            if PaySdk.instance.mICCancelInfo != "" {
                                signPad.iscancel = true
                            } else {
                                signPad.iscancel = false
                            }
                            signPad.view.backgroundColor = .white
                            signPad.modalPresentationStyle = .fullScreen
                            Utils.topMostViewController()?.present(signPad, animated: true, completion: nil)
                        }
                    }
                } else if PaySdk.instance.mDscYn == "2" {
                    Setting.shared.g_sDigSignInfo = "B"
    //                let _stringImg:Data = Setting.shared.mDscData.data(using: .iso2022JP)!
    //                let _uint8Img = Array(_stringImg)
    //                let data : Data = Data(base64Encoded: Setting.shared.mDscData, options: .ignoreUnknownCharacters)!
    //                let _uint8Img = Array(data)
                    let _uint8Img = [UInt8](Setting.shared.mDscData.utf8)
                    Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: _uint8Img,_CodeNversion: "", _cancelInfo: mICCancelInfo,_kocesUnique: "");
                }

                
            }
            else
            {
                Setting.shared.g_sDigSignInfo = "5"
                Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: [UInt8](),_CodeNversion: "", _cancelInfo: mICCancelInfo,_kocesUnique: "");
            }
        }
        
        

        //사용된 데이터 초기화
        for i in 0 ..< _ksn_track2data.count {
            _ksn_track2data[i] = 0x00
        }
        for i in 0 ..< _ksn_track2data.count {
            _ksn_track2data[i] = 0xFF
        }
        for i in 0 ..< _ksn_track2data.count {
            _ksn_track2data[i] = 0x00
        }
        _ksn_track2data = []
        _ksn_track2data.removeAll()
        for i in 0 ..< tmpTrack.count {
            tmpTrack[i] = 0x00
        }
        for i in 0 ..< tmpTrack.count {
            tmpTrack[i] = 0xFF
        }
        for i in 0 ..< tmpTrack.count {
            tmpTrack[i] = 0x00
        }
        tmpTrack = []
        tmpTrack.removeAll()
        _tmpicreqData.removeAll()
    }
    
    /**
       * 단말기로부터 포인트거래 데이터를 받음
       * @param _res 데이터
       * @param justNumber 현금/IC현금 체크
       */
    func Res_Point(ResData _res:[UInt8],CashOrMsrCheck justNumber:Bool)
    {
          if(!justNumber) {
//              Command.ProtocolInfo protocolInfo = new Command.ProtocolInfo(res);
//              if (protocolInfo.Command != Command.CMD_IC_RES) {
//                  return;
//              }
//
//              ByteArray b = new ByteArray(protocolInfo.Contents);
            var res:[UInt8] = _res;
            res.removeSubrange(0..<4)
            //단말 인증 번호가 32개가 올라오지만 그 중에서 앞 16자리만 사용하고 나머지는 APPID로 채운다.
            var TmlcNo = [UInt8]()
            let startindex = res.index(res.startIndex, offsetBy: 0)
            let endindex = res.index(res.startIndex, offsetBy: 16)
            TmlcNo = Array(res[startindex..<endindex])
            //let appid: String = Setting.shared.getDefaultUserData(_key: define.APP_ID)
            let appid: String = define.KOCES_ID
            TmlcNo.append(contentsOf: Array(appid.utf8))
            res.removeSubrange(0..<32)

            //앞에 여섯자리면 서버에 전송 한다.
            let Track:[UInt8] = Array(res[0...5])
            res.removeSubrange(0..<6)
            PaySdk.instance.mCashTrack = Track
            //그래서 나머지 34바이트를 버린다.
            res.removeSubrange(0..<34)
            
            let Ksn:[UInt8] = Array(res[0...9])
            res.removeSubrange(0..<10)

            let Track2_Data:[UInt8] = Array(res[0...47])
            res.removeSubrange(0..<48)

            res.remove(at: 0);res.removeSubrange(0..<2);
            res.removeSubrange(0..<2);res.removeSubrange(0..<6);
            res.removeSubrange(0..<23);res.removeSubrange(0..<11);
            res.removeSubrange(0..<4);res.removeSubrange(0..<35);
            res.removeSubrange(0..<7);res.removeSubrange(0..<5);
            res.removeSubrange(0..<7);res.removeSubrange(0..<5);
            res.removeSubrange(0..<3);res.removeSubrange(0..<9);
            res.removeSubrange(0..<5);res.removeSubrange(0..<4);
            res.removeSubrange(0..<5);res.removeSubrange(0..<9);
            res.removeSubrange(0..<6);res.removeSubrange(0..<6);
            res.removeSubrange(0..<4);res.removeSubrange(0..<11);
            res.removeSubrange(0..<4);res.removeSubrange(0..<18);
            res.removeSubrange(0..<5);res.removeSubrange(0..<7);
            res.removeSubrange(0..<40);res.removeSubrange(0..<10);
            res.removeSubrange(0..<48); let result_code:String = Utils.utf8toHangul(str: [res[0], res[1]]);  res.removeSubrange(0..<2);
              res.removeSubrange(0..<16);res.removeSubrange(0..<2);
              res.removeSubrange(0..<1);res.removeSubrange(0..<2);
              res.removeSubrange(0..<2);
              //앞에 16자리는 패스워드다 서버에 전송 한다.
              let PassWd:[UInt8] = Array(res[0...15])
              res.removeSubrange(0..<16)
              PaySdk.instance.mPointPassWd = ""
              if PaySdk.instance.mPointComdPasswdYN == "1" {
                  if PaySdk.instance.mPointTrdType == Command.CMD_POINT_USE_REQ {
                      PaySdk.instance.mPointPassWd = Utils.utf8toHangul(str: PassWd)
                  }
              }
      
            var _ksn_track2data = [UInt8]()
            _ksn_track2data.append(contentsOf: Ksn)
            _ksn_track2data.append(contentsOf: Track2_Data)
            PaySdk.instance.mCashTrack2data = _ksn_track2data

            var _resultCode:String = Command.Check_IC_result_code(Res: result_code);  //result 코드를 확인 해서 처리 한다. 입력 메소드를 판단한다.

              //여기까지 왔다면 장비는 다 사용한 것으로 판단하여 초기화 시킨다.
//              DeviceReset();
            KocesSdk.instance.DeviceInit(VanCode: "99")
            if (_resultCode == "K" || _resultCode == "00" || _resultCode == "R" || _resultCode == "M" || _resultCode == "E" || _resultCode == "F" || _resultCode == "S" || _resultCode == "I")
            {
                PaySdk.instance.mInputMethod = _resultCode;
                if (_resultCode == "00") {
                    PaySdk.instance.mInputMethod = "S";
                }

                  /* 단말기로 받은 포인트거래정보를 서버로 보낸다 */
                Req_tcp_Point(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: PaySdk.instance.mCashTrack2data, ptCardCode: PaySdk.instance.mCompCode, PayType: "02", businessData: PaySdk.instance.mBusinessData)
                
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                
            } else {
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = _resultCode
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return;
            }
 
          }
          else
          {
            var res:[UInt8] = _res;
            res.removeSubrange(0..<4)
            let length:String = Utils.utf8toHangul(str: [res[0], res[1]]);  res.removeSubrange(0..<2);
            let number:String = Utils.utf8toHangul(str: res);
            PaySdk.instance.mCashTrack = Array(res[0...(Int(length)!-1)])
            res.removeSubrange(0 ..< Int(length)!);
            PaySdk.instance.mInputMethod = "K";
              Req_tcp_Point(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: [UInt8](), ptCardCode: PaySdk.instance.mCompCode, PayType: "02", businessData: PaySdk.instance.mBusinessData)


          }
      }
    
    /**
       * 단말기로부터 멤버십거래 데이터를 받음
       * @param _res 데이터
       * @param justNumber 현금/IC현금 체크
       */
    func Res_Member(ResData _res:[UInt8],CashOrMsrCheck justNumber:Bool)
    {
          if(!justNumber) {
//              Command.ProtocolInfo protocolInfo = new Command.ProtocolInfo(res);
//              if (protocolInfo.Command != Command.CMD_IC_RES) {
//                  return;
//              }
//
//              ByteArray b = new ByteArray(protocolInfo.Contents);
            var res:[UInt8] = _res;
            res.removeSubrange(0..<4)
            //단말 인증 번호가 32개가 올라오지만 그 중에서 앞 16자리만 사용하고 나머지는 APPID로 채운다.
            var TmlcNo = [UInt8]()
            let startindex = res.index(res.startIndex, offsetBy: 0)
            let endindex = res.index(res.startIndex, offsetBy: 16)
            TmlcNo = Array(res[startindex..<endindex])
            //let appid: String = Setting.shared.getDefaultUserData(_key: define.APP_ID)
            let appid: String = define.KOCES_ID
            TmlcNo.append(contentsOf: Array(appid.utf8))
            res.removeSubrange(0..<32)

            //앞에 여섯자리면 서버에 전송 한다.
            let Track:[UInt8] = Array(res[0...5])
            res.removeSubrange(0..<6)
            PaySdk.instance.mCashTrack = Track
            //그래서 나머지 34바이트를 버린다.
            res.removeSubrange(0..<34)
            
            let Ksn:[UInt8] = Array(res[0...9])
            res.removeSubrange(0..<10)

            let Track2_Data:[UInt8] = Array(res[0...47])
            res.removeSubrange(0..<48)

            res.remove(at: 0);res.removeSubrange(0..<2);
            res.removeSubrange(0..<2);res.removeSubrange(0..<6);
            res.removeSubrange(0..<23);res.removeSubrange(0..<11);
            res.removeSubrange(0..<4);res.removeSubrange(0..<35);
            res.removeSubrange(0..<7);res.removeSubrange(0..<5);
            res.removeSubrange(0..<7);res.removeSubrange(0..<5);
            res.removeSubrange(0..<3);res.removeSubrange(0..<9);
            res.removeSubrange(0..<5);res.removeSubrange(0..<4);
            res.removeSubrange(0..<5);res.removeSubrange(0..<9);
            res.removeSubrange(0..<6);res.removeSubrange(0..<6);
            res.removeSubrange(0..<4);res.removeSubrange(0..<11);
            res.removeSubrange(0..<4);res.removeSubrange(0..<18);
            res.removeSubrange(0..<5);res.removeSubrange(0..<7);
            res.removeSubrange(0..<40);res.removeSubrange(0..<10);
            res.removeSubrange(0..<48); let result_code:String = Utils.utf8toHangul(str: [res[0], res[1]]);  res.removeSubrange(0..<2);
              res.removeSubrange(0..<16);res.removeSubrange(0..<2);
              res.removeSubrange(0..<1);res.removeSubrange(0..<2);
              res.removeSubrange(0..<2);
              //앞에 16자리는 패스워드다 서버에 전송 한다.
              let PassWd:[UInt8] = Array(res[0...15])
              res.removeSubrange(0..<16)
              PaySdk.instance.mPointPassWd = ""
//              if PaySdk.instance.mPointComdPasswdYN == "1" {
//                  if PaySdk.instance.mPointTrdType == Command.CMD_POINT_USE_REQ {
//                      PaySdk.instance.mPointPassWd = Utils.utf8toHangul(str: PassWd)
//                  }
//              }
      
            var _ksn_track2data = [UInt8]()
            _ksn_track2data.append(contentsOf: Ksn)
            _ksn_track2data.append(contentsOf: Track2_Data)
            PaySdk.instance.mCashTrack2data = _ksn_track2data

            var _resultCode:String = Command.Check_IC_result_code(Res: result_code);  //result 코드를 확인 해서 처리 한다. 입력 메소드를 판단한다.

              //여기까지 왔다면 장비는 다 사용한 것으로 판단하여 초기화 시킨다.
//              DeviceReset();
            KocesSdk.instance.DeviceInit(VanCode: "99")
            if (_resultCode == "K" || _resultCode == "00" || _resultCode == "R" || _resultCode == "M" || _resultCode == "E" || _resultCode == "F" || _resultCode == "S" || _resultCode == "I")
            {
                PaySdk.instance.mInputMethod = _resultCode;
                if (_resultCode == "00") {
                    PaySdk.instance.mInputMethod = "S";
                }

                  /* 단말기로 받은 멤버십거래정보를 서버로 보낸다 */
                Req_tcp_Member(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: PaySdk.instance.mCashTrack2data, memberProductCode: "" )
                
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                
            } else {
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0xFF
                }
                for i in 0 ..< _ksn_track2data.count {
                    _ksn_track2data[i] = 0x00
                }
                _ksn_track2data = []
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = _resultCode
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                return;
            }
 
          }
          else
          {
            var res:[UInt8] = _res;
            res.removeSubrange(0..<4)
            let length:String = Utils.utf8toHangul(str: [res[0], res[1]]);  res.removeSubrange(0..<2);
            let number:String = Utils.utf8toHangul(str: res);
            PaySdk.instance.mCashTrack = Array(res[0...(Int(length)!-1)])
            res.removeSubrange(0 ..< Int(length)!);
            PaySdk.instance.mInputMethod = "K";
              Req_tcp_Member(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: [UInt8](),  memberProductCode: "" )


          }
      }
    
    /**
       * 단말기로 받은 현금거래정보를 서버로 보낸다
       * @param _Tid
       * @param _CancelInfo
       * @param _InputMethod
       * @param _id
       * @param _idEncrpyt
       * @param _PB
       * @param _CancelReason
       * @param _ptCardCode
       * @param _ptAcceptNum
       * @param _businessData
       * @param _Bangi
       * @param _KocesTradeNumber
       */
    func Req_tcp_Cash(Tid _Tid:String,CancelInfo _CancelInfo:String,InputMethod _InputMethod:String,Id _id:[UInt8],idEncrpyt _idEncrpyt:[UInt8],PB _PB:String,CancelReason _CancelReason:String,ptCardCode _ptCardCode:String,ptAcceptNum _ptAcceptNum:String,businessData _businessData:String,Bangi _Bangi:String,KocesTradeNumber _KocesTradeNumber:String)
      {
          var TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
          var _iscancel = false
          if PaySdk.instance.mCancelInfo != "" {
              _iscancel = true
          }
        Utils.CardAnimationViewControllerInit(Message: "서버에 요청중입니다", isButton: false, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley){ [self] in

            KocesSdk.instance.Cash(Command: !_CancelInfo.isEmpty ? Command.CMD_CASH_RECEIPT_CANCEL_REQ : Command.CMD_CASH_RECEIPT_REQ , Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelInfo: _CancelInfo, InputMethod: _InputMethod, Id: _id, Idencrypt: _idEncrpyt, Money: String(PaySdk.instance.mMoney), Tax: PaySdk.instance.mTax, ServiceCharge: PaySdk.instance.mServiceCharge, TaxFree: PaySdk.instance.mTaxfree, PrivateOrCorp: _PB, CancelReason: _CancelReason, pointCardCode: _ptCardCode, pointAceeptNum: _ptAcceptNum, businessData: _businessData, bangi: _Bangi, kocesNumber: _KocesTradeNumber,AppToApp: PaySdk.instance.mDBAppToApp)
        }
        
        
      }
    
    /**
       * 단말기로 받은 포인트거래정보를 서버로 보낸다
       * @param _Tid
       * @param _CancelInfo
       * @param _InputMethod
       * @param _id
       * @param _idEncrpyt
       * @param _PB
       * @param _CancelReason
       * @param _ptCardCode
       * @param _ptAcceptNum
       * @param _businessData
       * @param _Bangi
       * @param _KocesTradeNumber
       */
    func Req_tcp_Point(TrdType _trdType:String,Tid _Tid:String,CancelInfo _CancelInfo:String,InputMethod _InputMethod:String,PointCardNumber _pointCardNumber:[UInt8],idEncrpyt _idEncrpyt:[UInt8],ptCardCode _ptCardCode:String,PayType _payType:String,businessData _businessData:String)
      {
          var TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
          var _iscancel = false
          if PaySdk.instance.mICCancelInfo != "" {
              _iscancel = true
          }
        Utils.CardAnimationViewControllerInit(Message: "서버에 요청중입니다", isButton: false, CountDown: Setting.shared.mDgTmout, TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley){ [self] in

            KocesSdk.instance.PointPay(Command: _trdType, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _CancelInfo, InputType: _InputMethod, CardNumber: _pointCardNumber, EncryptInfo: _idEncrpyt, Money: String(PaySdk.instance.mMoney), PointCode: _ptCardCode, PayType: _payType, WorkingKeyIndex: "", Password: PaySdk.instance.mPointPassWd, PosData: _businessData, AppToApp: PaySdk.instance.mDBAppToApp)
        }
        
        
      }
    
    func Req_tcp_Member(TrdType _trdType:String,Tid _Tid:String,CancelInfo _CancelInfo:String,InputMethod _InputMethod:String,PointCardNumber _pointCardNumber:[UInt8],idEncrpyt _idEncrpyt:[UInt8],memberProductCode _memberProductCode:String)
      {
          var TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
          var _iscancel = false
          if PaySdk.instance.mICCancelInfo != "" {
              _iscancel = true
          }
        Utils.CardAnimationViewControllerInit(Message: "서버에 요청중입니다", isButton: false, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley){ [self] in

            KocesSdk.instance.MemberPay(Command: _trdType, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _CancelInfo, InputType: _InputMethod, CardNumber: _pointCardNumber, EncryptInfo: _idEncrpyt, Money: String(PaySdk.instance.mMoney), memberProductCode: "", dongul: "", PosData: "", AppToApp: PaySdk.instance.mDBAppToApp)
        }
        
        
      }
    
    /**
     사인패드에서 이미지를 그리면 이곳으로 보낸다
     */
    func Result_SignPad(signCheck _sign:Bool, signImage _signImage:[UInt8]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
            if _sign {
                debugPrint("signData :", Utils.UInt8ArrayToHexCode(_value: _signImage,_option: true))
                //사인데이터 1086 사이즈를 2배로 늘린다
                let _tmpsign = Utils.SignUin8ArrayToStringHexCode(_value: _signImage)
                Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: _tmpsign,_CodeNversion: "", _cancelInfo: mICCancelInfo,_kocesUnique: "");
//                Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: _signImage,_CodeNversion: "", _cancelInfo: mICCancelInfo,_kocesUnique: "");
            } else {
                Clear()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "서명오류입니다. 서명이 정상적으로 진행되지 않았습니다"
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            }
        }
    }
    
    /**
        * 단말기를 거치지 않고 다이렉트로 현금거래를 통신한다
        * @param _CancelReason 취소사유
        * @param _Tid tid
        * @param _AuDate 원승인일짜
        * @param _AuNo 원거래번호
        * @param _num 사용자번호
        * @param _Command 거래/취소
        * @param _MchData 가맹점데이터
        * @param _TrdAmt 거래금액
        * @param _TaxAmt 세금
        * @param _SvcAmt 봉사료
        * @param _TaxFreeAmt 면세금
        * @param _InsYn 개인/법인 구분(신용X) 1:개인 2:법인 3:자진발급 4:원천
        * @param _kocesNumber 코세스거래고유번호
        */
    func CashReciptDirectInput(CancelReason _CancelReason:String,Tid _Tid:String, AuDate _AuDate:String, AuNo _AuNo:String, Num _num:String, Command _Command:String, MchData _MchData:String, TrdAmt _TrdAmt:String, TaxAmt _TaxAmt:String, SvcAmt _SvcAmt:String, TaxFreeAmt _TaxFreeAmt:String, InsYn _InsYn:String,kocesNumber _kocesNumber:String,payLinstener _paymentlistener:PayResultDelegate,
                               StoreName _mStoreName:String, StoreAddr _mStoreAddr:String,StoreNumber _mStoreNumber:String,StorePhone _mStorePhone:String,StoreOwner _mStoreOwner:String)
    {
        //시작전에 항상 클리어 한다.
        Clear()
        
        PaySdk.instance.mStoreName = _mStoreName;
        PaySdk.instance.mStoreAddr = _mStoreAddr;
        PaySdk.instance.mStoreNumber = _mStoreNumber;
        PaySdk.instance.mStorePhone = _mStorePhone;
        PaySdk.instance.mStoreOwner = _mStoreOwner;
        
        PaySdk.instance.paylistener = _paymentlistener
        PaySdk.instance.mCancelReason = _CancelReason;
        PaySdk.instance.mKocesTradeCode = _kocesNumber;
        PaySdk.instance.mTid = _Tid;
        var _icMoney:String = _TrdAmt.replacingOccurrences(of: " ", with: "")
        var tmpTotalMoney:Int = 0
//        if _CancelReason != ""{ //2021-08-21 kim.jy 취소는 총 합계로 처리 한다.
//
//            PaySdk.instance.mTax = "0"
//            PaySdk.instance.mServiceCharge = "0"
//            PaySdk.instance.mTaxfree = "0"
//            tmpTotalMoney = Int(_TrdAmt)! + Int(_TaxAmt)! + Int(_SvcAmt)! + Int(_TaxFreeAmt)!
//            PaySdk.instance.mMoney = tmpTotalMoney
//            _icMoney = String(tmpTotalMoney)
//        }
//        else{
//            PaySdk.instance.mTax = _TaxAmt
//            PaySdk.instance.mServiceCharge = _SvcAmt
//            PaySdk.instance.mTaxfree = _TaxFreeAmt
//            PaySdk.instance.mMoney = Int(_icMoney)!
//        }
        
       
        PaySdk.instance.mPrivateBusinessType = Int(_InsYn)!
        
        if String(describing: _paymentlistener).contains("AppToApp") {
            PaySdk.instance.mDBAppToApp = true
            PaySdk.instance.mTax = _TaxAmt
            PaySdk.instance.mServiceCharge = _SvcAmt
            PaySdk.instance.mTaxfree = _TaxFreeAmt
            PaySdk.instance.mMoney = Int(_icMoney)!
        } else  {
            if _CancelReason != ""
            {
                PaySdk.instance.mDBAppToApp = false
                PaySdk.instance.mTax = "0"
                PaySdk.instance.mServiceCharge = "0"
                PaySdk.instance.mTaxfree = "0"
                tmpTotalMoney = Int(_TrdAmt)! + Int(_TaxAmt)! + Int(_SvcAmt)!
                PaySdk.instance.mMoney = tmpTotalMoney
                _icMoney = String(tmpTotalMoney)
            }
            else
            {
                PaySdk.instance.mDBAppToApp = false
                PaySdk.instance.mTax = _TaxAmt
                PaySdk.instance.mServiceCharge = _SvcAmt
                PaySdk.instance.mTaxfree = _TaxFreeAmt
                PaySdk.instance.mMoney = Int(_icMoney)!
            }
          
        }
//        let CovertMoney = Utils.leftPad(str: _icMoney, fillChar: "0", length: 10)
        let CovertMoney = _icMoney
        // 문자열 공백제거

        var _TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
        var _iscancel = false
        if PaySdk.instance.mCancelInfo != "" {
            _iscancel = true
        }
        Utils.CardAnimationViewControllerInit(Message: "서버에 요청중입니다", isButton: false, CountDown: Setting.shared.mDgTmout,TotalMoney: String(_TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        var id:[UInt8] = [UInt8]()
        for _ in 0 ..< 40 {
            id.append(0x20)
        }
        
        if !_num.isEmpty {
            id.replaceSubrange(0..<_num.count, with: [UInt8](_num.utf8))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) {[self] in
            if _Command == Command.CMD_CASH_RECEIPT_REQ {
                
                //현금영수증 : 개인/법인 구분('1' : 개인,  '2' : 법인, '3' : 자진, '4' : 원천, '5' : 반기지급명세) , 미설정 시 개인('1')로 처리
                KocesSdk.instance.Cash(Command: _Command, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelInfo: "", InputMethod: "K", Id: id, Idencrypt: [UInt8](), Money: CovertMoney, Tax: PaySdk.instance.mTax, ServiceCharge: PaySdk.instance.mServiceCharge, TaxFree: PaySdk.instance.mTaxfree, PrivateOrCorp: _InsYn, CancelReason: _CancelReason, pointCardCode: "", pointAceeptNum: "", businessData: _MchData, bangi: "", kocesNumber: "",AppToApp: PaySdk.instance.mDBAppToApp)

            }
            else if _Command == Command.CMD_CASH_RECEIPT_CANCEL_REQ {
                var CanRea = "0" + String(_AuDate.prefix(6)) + _AuNo
                
                if !_kocesNumber.isEmpty {
                    CanRea = "a" + String(_AuDate.prefix(6)) + _AuNo
                }
                PaySdk.instance.mOriAudate = _AuDate
                PaySdk.instance.mOriAuNum = _AuNo
                
                KocesSdk.instance.Cash(Command: _Command, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelInfo: CanRea, InputMethod: "K", Id: id, Idencrypt: [UInt8](), Money: CovertMoney, Tax: PaySdk.instance.mTax, ServiceCharge: PaySdk.instance.mServiceCharge, TaxFree: PaySdk.instance.mTaxfree, PrivateOrCorp: _InsYn, CancelReason: _CancelReason, pointCardCode: "", pointAceeptNum: "", businessData: _MchData, bangi: "", kocesNumber: _kocesNumber,AppToApp: PaySdk.instance.mDBAppToApp)

            }
        }

    }
    
    /**
     거래고유키로 신용취소시 다이렉트로 서버와 연결한다
     */
    func CreditDirectCancel(Command _Command:String,Tid _Tid:String,Date _date:String,OriDate _oriDate:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,CardNumber _CardNum:String,EncryptInfo _encryptInfo:[UInt8],Money _money:String,Tax _tax:String,ServiceCharge _svc:String,TaxFree _txf:String,Currency _currency:String,InstallMent _Installment:String,PosCertificationNumber _PoscertifiNum:String,TradeType _tradeType:String,EmvData _emvData:String,ResonFallBack _fallback:String,ICreqData _ICreqData:[UInt8],WorkingKeyIndex _keyIndex:String,Password _passwd:String,OilSurpport _oil:String,OilTaxFree _txfOil:String,DccFlag _Dccflag:String,DccReqInfo _DccreqInfo:String,PointCardCode _ptCode:String,PointCardNumber  _ptNum:String,PointCardEncprytInfo _ptCardEncprytInfo:[UInt8],SignInfo _SignInfo:String,SignPadSerial _signPadSerial:String,SignData _SignData:[UInt8],Certification _Cert:String,PosData _posData:String,KocesUid _kocesUid:String,UniqueCode _uniqueCode:String,payLinstener _paymentlistener:PayResultDelegate) {
        //시작전에 항상 클리어 한다.
        Clear()
        PaySdk.instance.paylistener = _paymentlistener
        PaySdk.instance.mTid = _Tid
        PaySdk.instance.mICCancelInfo = _ResonCancel
       
        PaySdk.instance.mMchdata = _posData;
        PaySdk.instance.mICKocesTranUniqueNum = _kocesUid;
        PaySdk.instance.mCompCode = _uniqueCode
        PaySdk.instance.mCodeVersion = _signPadSerial
        PaySdk.instance.mCompCode = _uniqueCode
        let trimmedString = _money.trimmingCharacters(in: .whitespaces)
        var TotalMoney:Int = 0
       
        PaySdk.instance.mInstallment = Int(_Installment)!
        
        Setting.shared.g_sDigSignInfo = "4"
        
        if !_ResonCancel.isEmpty {
            PaySdk.instance.mOriAudate = _oriDate
            var _tmpAunum = _ResonCancel.replacingOccurrences(of: _oriDate, with: "")
            _tmpAunum.removeFirst()
            _tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();_tmpAunum.removeFirst();
            PaySdk.instance.mOriAuNum = _tmpAunum
        }
        
        if String(describing: _paymentlistener).contains("AppToApp") {
            PaySdk.instance.mDBAppToApp = true
            PaySdk.instance.mTax = _tax.trimmingCharacters(in: .whitespaces)
            PaySdk.instance.mServiceCharge = _svc.trimmingCharacters(in: .whitespaces)
            PaySdk.instance.mTaxfree = _txf.trimmingCharacters(in: .whitespaces)
            TotalMoney = Int(trimmedString)!
            PaySdk.instance.mMoney = TotalMoney
        } else  {
            PaySdk.instance.mDBAppToApp = false
            PaySdk.instance.mTax = "0"          //2021-08-19 kim.jy 취소시 부가세, 봉사료, 비과세 0 원으로 전송
            PaySdk.instance.mServiceCharge = "0"
            PaySdk.instance.mTaxfree = "0"
            TotalMoney = Int(trimmedString)! + Int(_tax)! + Int(_svc)!
            PaySdk.instance.mMoney = TotalMoney
        }
//        let CovertMoney = Utils.leftPad(str: String(TotalMoney), fillChar: "0", length: 10)
        let CovertMoney = String(TotalMoney)
        var _TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
        var _iscancel = false
        if PaySdk.instance.mICCancelInfo != "" {
            _iscancel = true
        }
        Utils.CardAnimationViewControllerInit(Message: "서버에 요청중입니다", isButton: false, CountDown: Setting.shared.mDgTmout,TotalMoney: String(_TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
        var _Poscer = _PoscertifiNum
        if _Poscer.isEmpty {
//            _Poscer = Utils.AppTmlcNo()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) { [self] in
            KocesSdk.instance.Credit(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: _etc, ResonCancel: _ResonCancel, InputType: _inputType, CardNumber: String(_CardNum.prefix(6)), EncryptInfo: _encryptInfo, Money: CovertMoney, Tax: PaySdk.instance.mTax, ServiceCharge: PaySdk.instance.mServiceCharge, TaxFree: PaySdk.instance.mTaxfree, Currency: "410", InstallMent: _Installment, PosCertificationNumber: _Poscer, TradeType: _tradeType, EmvData: _emvData, ResonFallBack: _fallback, ICreqData: _ICreqData, WorkingKeyIndex: _keyIndex, Password: _passwd, OilSurpport: _oil, OilTaxFree: _txfOil, DccFlag: _Dccflag, DccReqInfo: _DccreqInfo, PointCardCode: _ptCode, PointCardNumber: _ptNum, PointCardEncprytInfo: _ptCardEncprytInfo, SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: _signPadSerial, SignData: _SignData, Certification: _Cert, PosData: _posData, KocesUid: _kocesUid, UniqueCode: _uniqueCode,MacAddr: Utils.getKeyChainUUID(), HardwareKey: Utils.getPosKeyChainUUIDtoBase64(Target: PaySdk.instance.mDBAppToApp == true ? .AppToApp:.KocesICIOSPay, Tid: _Tid),AppToApp: PaySdk.instance.mDBAppToApp)
        }

    }
    
    /**
     * 단말기로 부터 받은 신용거래정보를 서버로 보낸다
     * @param _Tid
     * @param _img
     * @param _CodeNversion
     * @param _cancelInfo
     * @param _kocesUnique
     */
    func Req_tcp_Credit(_Tid:String,_img:[UInt8],_CodeNversion:String, _cancelInfo:String, _kocesUnique:String) {
        var _iscancel = false
        if PaySdk.instance.mICCancelInfo != "" {
            _iscancel = true
        }
        var TotalMoney:Int = PaySdk.instance.mMoney + (Int(PaySdk.instance.mTax) ?? 0) + (Int(PaySdk.instance.mServiceCharge) ?? 0)
        Utils.CardAnimationViewControllerInit(Message: "서버에 요청중입니다", isButton: false, CountDown: Setting.shared.mDgTmout,TotalMoney: String(TotalMoney),IsCancel: _iscancel, Listener: PaySdk.instance.paylistener as! PayResultDelegate)
//        Utils.customAlertBoxInit(Title: "신용거래", Message: "서버에 요청중입니다", LoadingBar: true, GetButton: "확인")
        if(!_cancelInfo.isEmpty)
        {
            PaySdk.instance.mICCancelInfo = _cancelInfo
        }
        if(!_kocesUnique.isEmpty)
        {
            PaySdk.instance.mICKocesTranUniqueNum = _kocesUnique
        }
        if(!_CodeNversion.isEmpty)
        {
            PaySdk.instance.mCodeVersion = _CodeNversion
        }
        if(PaySdk.instance.mCodeVersion.isEmpty)
        {
            PaySdk.instance.mCodeVersion = Setting.shared.mCodeVersionNumber
        }
        if(PaySdk.instance.mMchdata.isEmpty)
        {
            PaySdk.instance.mMchdata = Setting.shared.mMchdata;
        }
        let tmpTmicno:String = Utils.utf8toHangul(str: PaySdk.instance.mTmicno)
        var tmpCardNumber:String = Utils.utf8toHangul(str: PaySdk.instance.mEncryptInfo)

        //포인트 암호화 정보가 없는 관계로 길이를 0000으로해서 보낸다
        /** 금액과 세금 할부관련한 내용을 가져와서 넣어주어야 한다. 현재는 임의의 값으로 넣어두었다 /jiw 21-01-29 */
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley){
            if(PaySdk.instance.mICCancelInfo.isEmpty)    //취소사유가 없는 경우 신용거래요청
            {
                if(PaySdk.instance.mEMVTradeType != "F")    //폴백거래인지아닌지
                {
                    PaySdk.instance.isFallBack = false;
                    //만일 emv거래값이 스페이스나 null값으로 들어왔을때 정상승인은 스와이프로 처리한다.
                    if(PaySdk.instance.mEMVTradeType == " " && PaySdk.instance.mICInputMethod == "I" ){PaySdk.instance.mICInputMethod = "S"}
                }
                else
                {
                    PaySdk.instance.isFallBack = true;
                }
                KocesSdk.instance.Credit(Command: Command.CMD_ICTRADE_REQ, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: PaySdk.instance.mICCancelInfo, InputType: PaySdk.instance.mICInputMethod, CardNumber: String(tmpCardNumber.prefix(6)), EncryptInfo: PaySdk.instance.mKsn_track2data, Money: String(PaySdk.instance.mMoney), Tax: PaySdk.instance.mTax, ServiceCharge: PaySdk.instance.mServiceCharge, TaxFree: PaySdk.instance.mTaxfree, Currency: "410", InstallMent: String(PaySdk.instance.mInstallment), PosCertificationNumber: tmpTmicno, TradeType: "", EmvData: PaySdk.instance.mEMVTradeType, ResonFallBack: "", ICreqData: PaySdk.instance.mIcreqData, WorkingKeyIndex: Setting.shared.getDefaultUserData(_key: define.WORKINGKEY_INDEX), Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: PaySdk.instance.mCodeVersion, SignData: _img, Certification: "", PosData: PaySdk.instance.mMchdata, KocesUid: "", UniqueCode: "",MacAddr: Utils.getKeyChainUUID(), HardwareKey: Utils.getPosKeyChainUUIDtoBase64(Target: PaySdk.instance.mDBAppToApp == true ? .AppToApp:.KocesICIOSPay, Tid: _Tid),AppToApp: PaySdk.instance.mDBAppToApp)
                
            }
            else    //거래취소 요청
            {
                if(PaySdk.instance.mEMVTradeType != "F")    //폴백거래인지아닌지
                {
                    PaySdk.instance.isFallBack = false;
                    //만일 emv거래값이 스페이스나 null값으로 들어왔을때 정상승인은 스와이프로 처리한다.
                    if(PaySdk.instance.mEMVTradeType == " " && PaySdk.instance.mICInputMethod == "I" ){PaySdk.instance.mICInputMethod = "S"}

                }
                else
                {
                    PaySdk.instance.isFallBack = true;
                }
                KocesSdk.instance.Credit(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: _Tid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: PaySdk.instance.mICCancelInfo, InputType: PaySdk.instance.mICInputMethod, CardNumber: String(tmpCardNumber.prefix(6)), EncryptInfo: PaySdk.instance.mKsn_track2data, Money: String(PaySdk.instance.mMoney), Tax: PaySdk.instance.mTax, ServiceCharge: PaySdk.instance.mServiceCharge, TaxFree: PaySdk.instance.mTaxfree, Currency: "410", InstallMent: String(PaySdk.instance.mInstallment), PosCertificationNumber: tmpTmicno, TradeType: "", EmvData: PaySdk.instance.mEMVTradeType, ResonFallBack: "", ICreqData: PaySdk.instance.mIcreqData, WorkingKeyIndex: Setting.shared.getDefaultUserData(_key: define.WORKINGKEY_INDEX), Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: PaySdk.instance.mCodeVersion, SignData: _img, Certification: "", PosData: PaySdk.instance.mMchdata, KocesUid: PaySdk.instance.mICKocesTranUniqueNum, UniqueCode: "",MacAddr: Utils.getKeyChainUUID(), HardwareKey: Utils.getPosKeyChainUUIDtoBase64(Target: PaySdk.instance.mDBAppToApp == true ? .AppToApp:.KocesICIOSPay, Tid: _Tid),AppToApp: PaySdk.instance.mDBAppToApp)
            }
            tmpCardNumber = ""
        }

    }
    
    func Res_Tcp_Cash(tcpStatus _status:tcpStatus,ResData _resData:[String:String]) {
        var productNum = PaySdk.instance.mTid.replacingOccurrences(of: " ", with: "") +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_resData["TrdDate"] ?? "") +
        (_resData["AuNo"] ?? "")
 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) { [self] in
            switch _resData["TrdType"] {

            case Command.CMD_CASH_RECEIPT_RES:
                //현금거래
                if _status == .sucess {
                    if KocesSdk.instance.mEotCheck != 0 {
                        PaySdk.instance.mCancelInfo = "1" + String(_resData["TrdDate"]?.prefix(6) ?? "") + _resData["AuNo"]!
                        PaySdk.instance.mCancelReason = "1"
                        let TotalMoney:Int = PaySdk.instance.mMoney + Int(PaySdk.instance.mTax)! + Int(PaySdk.instance.mServiceCharge)!
                        
                        PaySdk.instance.mMoney = TotalMoney
                        PaySdk.instance.mTax = "0"
                        PaySdk.instance.mServiceCharge = "0"
                        PaySdk.instance.mTaxfree = "0"
                        
                        PaySdk.instance.m2TradeCancel = true    //망취소발생
                        
                        // eot 받았을 때 데이터를 실어야 함. KocesTradeNumber 와 businessData 에 받은 값을 넣어주면 나머지는 해당내용대로 가면 된다.
                        Req_tcp_Cash(Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mCancelInfo, InputMethod: Setting.shared.mInputCashMethod, Id: PaySdk.instance.mCashTrack, idEncrpyt: PaySdk.instance.mCashTrack2data, PB: Setting.shared.mPrivateOrCorp, CancelReason: PaySdk.instance.mCancelReason, ptCardCode: "", ptAcceptNum: "", businessData: String(_resData["MchData"] ?? ""), Bangi: "", KocesTradeNumber: String(_resData["TradeNo"] ?? ""))
                        return
                    }
                    
                    //app to app이 아닌 경우에만 DB에 저장한다.
                    if !self.mDBAppToApp {
                        //현금영수증 타겟 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
      
                        var _현금영수증발급형태:define.TradeMethod = define.TradeMethod.NULL
//                        if _resData["CardNo"]!.count > 6 {
//                            _현금영수증발급형태 = define.TradeMethod.CashDirect
//                        } else {
//                            _현금영수증발급형태 = define.TradeMethod.CashMs
//                        }
                        if mInputMethod == "K" {
                            _현금영수증발급형태 = define.TradeMethod.CashDirect
                        } else if mInputMethod == "S" {
                            _현금영수증발급형태 = define.TradeMethod.CashMs
                        } else {
                            _현금영수증발급형태 = define.TradeMethod.CashDirect
                        }
                

                        sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                    StoreName: PaySdk.instance.mStoreName,
                                                    StoreAddr: PaySdk.instance.mStoreAddr,
                                                    StoreNumber: PaySdk.instance.mStoreNumber,
                                                    StorePhone: PaySdk.instance.mStorePhone,
                                                    StoreOwner: PaySdk.instance.mStoreOwner,
                                                    신용현금: define.TradeMethod.Cash,
                                                    취소여부: define.TradeMethod.NoCancel,
                                                    금액: self.mMoney,
                                                    선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                    세금: Int(self.mTax) ?? 0,
                                                    봉사료: Int(self.mServiceCharge) ?? 0,
                                                    비과세: Int(self.mTaxfree) ?? 0,
                                                    할부: self.mInstallment,
                                                    현금영수증타겟: getCashTarget(대상입력: PaySdk.instance.mPrivateBusinessType),
                                                    현금영수증발급형태: _현금영수증발급형태,
                                                    현금발급번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                    카드번호: "", 카드종류: "", 카드매입사: "", 카드발급사: "", 가맹점번호: "",
                                                    승인날짜:  _resData["TrdDate"]!,
                                                    원거래일자: _resData["OriDate"] ?? "",
                                                    승인번호: _resData["AuNo"]!, 원승인번호: "",
                                                    코세스고유거래키: _resData["TradeNo"]!,
                                                    응답메시지: _resData["Message"]!, KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                    PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                    ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                    _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
       
                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                      
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
               
                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
               
                break
            case Command.CMD_CASH_RECEIPT_CANCEL_RES:
                //현금취소거래
                
                if PaySdk.instance.m2TradeCancel == true {
                    //망취소발생
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = (_resData["Message"] ?? "")
                    resDataDic["TrdType"] = Command.CMD_CASH_RECEIPT_CANCEL_RES
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                    Clear()
                    return
                }
                
                if _status == .sucess {
                    //app to app이 아닌 경우에만 DB에 저장한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                    if !self.mDBAppToApp {
             
                        var _현금영수증발급형태:define.TradeMethod = define.TradeMethod.NULL
//                        if _resData["CardNo"]!.count > 6 {
//                            _현금영수증발급형태 = define.TradeMethod.CashDirect
//                        } else {
//                            _현금영수증발급형태 = define.TradeMethod.CashMs
//                        }
                        if mInputMethod == "K" {
                            _현금영수증발급형태 = define.TradeMethod.CashDirect
                        } else if mInputMethod == "S" {
                            _현금영수증발급형태 = define.TradeMethod.CashMs
                        } else {
                            _현금영수증발급형태 = define.TradeMethod.CashDirect
                        }
                        
                        sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                    StoreName: PaySdk.instance.mStoreName,
                                                    StoreAddr: PaySdk.instance.mStoreAddr,
                                                    StoreNumber: PaySdk.instance.mStoreNumber,
                                                    StorePhone: PaySdk.instance.mStorePhone,
                                                    StoreOwner: PaySdk.instance.mStoreOwner,
                                                    신용현금: define.TradeMethod.Cash,
                                                    취소여부: define.TradeMethod.Cancel,
                                                    금액: self.mMoney,
                                                    선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                    세금: Int(self.mTax) ?? 0,
                                                    봉사료: Int(self.mServiceCharge) ?? 0,
                                                    비과세: Int(self.mTaxfree) ?? 0,
                                                    할부: self.mInstallment,
                                                    현금영수증타겟: getCashTarget(대상입력: PaySdk.instance.mPrivateBusinessType),
                                                    현금영수증발급형태: _현금영수증발급형태,
                                                    현금발급번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                    카드번호: "", 카드종류: "", 카드매입사: "", 카드발급사: "", 가맹점번호: "",
                                                    승인날짜: _resData["TrdDate"]!,
                                                    원거래일자: PaySdk.instance.mOriAudate,
                                                    승인번호: _resData["AuNo"]!,
                                                    원승인번호: PaySdk.instance.mOriAuNum,
                                                    코세스고유거래키: _resData["TradeNo"]!, 응답메시지: _resData["Message"]!,
                                                    KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                    PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                    ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                    _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
              
                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
               
                break
            default:
                PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                break
            }
            //끝났으니 값들을 모두 정리한다
            Clear()
        }
    }
    
    /**
     결과를 해당 뷰컨트롤러로 보낸다
     - Parameters:
     - _status: <#_status description#>
     - _resData: <#_resData description#>
     */
    func Res_Tcp_Credit(tcpStatus _status:tcpStatus,ResData _resData:[String:String])
    {
        var productNum = PaySdk.instance.mTid.replacingOccurrences(of: " ", with: "") +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_resData["TrdDate"] ?? "") +
        (_resData["AuNo"] ?? "")
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) { [self] in
            switch _resData["TrdType"] {
            case Command.CMD_IC_OK_RES:
                //신용거래
                if _status == .sucess {
                    if KocesSdk.instance.mEotCheck != 0 {
                        PaySdk.instance.mICCancelInfo = "I" + String(_resData["TrdDate"]?.prefix(6) ?? "") + _resData["AuNo"]!
                        
                        //2021-08-19 kim.jy
                        let TotalMoney:Int = PaySdk.instance.mMoney + Int(PaySdk.instance.mTax)! + Int(PaySdk.instance.mServiceCharge)!
                        PaySdk.instance.mMoney = TotalMoney
                        PaySdk.instance.mTax = "0"
                        PaySdk.instance.mServiceCharge = "0"
                        PaySdk.instance.mTaxfree = "0"
                        
                        PaySdk.instance.m2TradeCancel = true    //망취소발생
                        
                        Req_tcp_Credit(_Tid: PaySdk.instance.mTid,_img: [UInt8](),_CodeNversion: "", _cancelInfo: PaySdk.instance.mICCancelInfo,_kocesUnique: "")
                        return
                    }
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                     
                        if _resData["CardKind"]! == "3" || _resData["CardKind"]! == "4"  {

                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Credit,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"]!,
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"]!,
                                                        카드매입사: _resData["InpNm"]!,
                                                        카드발급사: _resData["OrdNm"]!,
                                                        가맹점번호: _resData["MchNo"]!,
                                                        승인날짜: _resData["TrdDate"]!,
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"]!, 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"]!, 응답메시지: _resData["Message"]!, KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Credit,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"]!,
                                                        카드매입사: _resData["InpNm"]!,
                                                        카드발급사: _resData["OrdNm"]!,
                                                        가맹점번호: _resData["MchNo"]!,
                                                        승인날짜: _resData["TrdDate"]!,
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"]!, 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"]!, 응답메시지: _resData["Message"]!, KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
              

                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
               
                break
            case Command.CMD_IC_CANCEL_RES:
                
                if PaySdk.instance.m2TradeCancel == true { //망취소발생
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = (_resData["Message"] ?? "")
                    resDataDic["TrdType"] = Command.CMD_IC_CANCEL_RES
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                    Clear()
                    return
                }
                
                //신용취소거래
                if _status == .sucess {
                    
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                    
                        if _resData["CardKind"]! == "3" || _resData["CardKind"]! == "4" {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Credit,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"]!,
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"]!,
                                                        카드매입사: _resData["InpNm"]!,
                                                        카드발급사: _resData["OrdNm"]!,
                                                        가맹점번호: _resData["MchNo"]!,
                                                        승인날짜: _resData["TrdDate"]!,
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"]!,
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"]!, 응답메시지: _resData["Message"]!, KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Credit,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"]!,
                                                        카드매입사: _resData["InpNm"]!,
                                                        카드발급사: _resData["OrdNm"]!,
                                                        가맹점번호: _resData["MchNo"]!,
                                                        승인날짜: _resData["TrdDate"]!,
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"]!,
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"]!, 응답메시지: _resData["Message"]!, KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
                   
                
                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
               
                break
            case Command.CMD_POINT_EARN_RES:
                break
            case Command.CMD_POINT_EARN_CANCEL_RES:
                break
            case Command.CMD_POINT_USE_RES:
                break
            case Command.CMD_POINT_USE_CANCEL_RES:
                break
            case Command.CMD_POINT_SEARCH_RES:
                break
            case Command.CMD_MEMBER_USE_RES:
                break
            case Command.CMD_MEMBER_CANCEL_RES:
                break
            case Command.CMD_MEMBER_SEARCH_RES:
                break
            default:
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                break
            }
            
            //끝났으니 값들을 모두 정리한다
            Clear()
        }
    }
    
    /**
     결과를 해당 뷰컨트롤러로 보낸다
     - Parameters:
     - _status: <#_status description#>
     - _resData: <#_resData description#>
     */
    func Res_Tcp_Point(tcpStatus _status:tcpStatus,ResData _resData:[String:String])
    {
        var productNum = PaySdk.instance.mTid.replacingOccurrences(of: " ", with: "") +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_resData["TrdDate"] ?? "") +
        (_resData["AuNo"] ?? "")
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) { [self] in
            switch _resData["TrdType"] {
            case Command.CMD_POINT_EARN_RES:
                //포인트적립거래
                if _status == .sucess {
                    if KocesSdk.instance.mEotCheck != 0 {
                        PaySdk.instance.mICCancelInfo = "I" + String(_resData["TrdDate"]?.prefix(6) ?? "") + _resData["AuNo"]!
                        
                        //2021-08-19 kim.jy
                        let TotalMoney:Int = PaySdk.instance.mMoney + Int(PaySdk.instance.mTax)! + Int(PaySdk.instance.mServiceCharge)!
                        PaySdk.instance.mMoney = TotalMoney
                        PaySdk.instance.mTax = "0"
                        PaySdk.instance.mServiceCharge = "0"
                        PaySdk.instance.mTaxfree = "0"
                        
                        PaySdk.instance.m2TradeCancel = true    //망취소발생
                        
                        PaySdk.instance.mPointTrdType = Command.CMD_POINT_EARN_CANCEL_REQ
                        Req_tcp_Point(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mICCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: PaySdk.instance.mCashTrack2data, ptCardCode: PaySdk.instance.mCompCode, PayType: "02", businessData: PaySdk.instance.mBusinessData)
                        return
                    }
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                        var _cardKind = _resData["CardKind"] ?? ""
                        if _cardKind == "3" || _cardKind == "4"  {

                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Reward,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"] ?? "",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"] ?? "", 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Reward,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"] ?? "", 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
              

                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
               
                break
            case Command.CMD_POINT_EARN_CANCEL_RES:
                if PaySdk.instance.m2TradeCancel == true { //망취소발생
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = (_resData["Message"] ?? "")
                    resDataDic["TrdType"] = Command.CMD_POINT_EARN_CANCEL_RES
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                    Clear()
                    return
                }
                
                //신용취소거래
                if _status == .sucess {
                    
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                        var _cardKind = _resData["CardKind"] ?? ""
                        if _cardKind == "3" || _cardKind == "4" {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Reward,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"] ?? "",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"] ?? "",
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Reward,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"] ?? "",
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
                   
                
                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            case Command.CMD_POINT_USE_RES:
                //포인트사용거래
                if _status == .sucess {
                    if KocesSdk.instance.mEotCheck != 0 {
                        PaySdk.instance.mICCancelInfo = "I" + String(_resData["TrdDate"]?.prefix(6) ?? "") + _resData["AuNo"]!
                        
                        //2021-08-19 kim.jy
                        let TotalMoney:Int = PaySdk.instance.mMoney + Int(PaySdk.instance.mTax)! + Int(PaySdk.instance.mServiceCharge)!
                        PaySdk.instance.mMoney = TotalMoney
                        PaySdk.instance.mTax = "0"
                        PaySdk.instance.mServiceCharge = "0"
                        PaySdk.instance.mTaxfree = "0"
                        
                        PaySdk.instance.m2TradeCancel = true    //망취소발생
                        
                        PaySdk.instance.mPointTrdType = Command.CMD_POINT_USE_CANCEL_REQ
                        Req_tcp_Point(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mICCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: PaySdk.instance.mCashTrack2data, ptCardCode: PaySdk.instance.mCompCode, PayType: "02", businessData: PaySdk.instance.mBusinessData)
                        return
                    }
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                        var _cardKind = _resData["CardKind"] ?? ""
                        if _cardKind == "3" || _cardKind == "4"  {

                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Redeem,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"] ?? "",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"] ?? "", 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Redeem,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"] ?? "", 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
              

                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            case Command.CMD_POINT_USE_CANCEL_RES:
                if PaySdk.instance.m2TradeCancel == true { //망취소발생
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = (_resData["Message"] ?? "")
                    resDataDic["TrdType"] = Command.CMD_POINT_USE_CANCEL_RES
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                    Clear()
                    return
                }
                
                //신용취소거래
                if _status == .sucess {
                    
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                        var _cardKind = _resData["CardKind"] ?? ""
                        if _cardKind == "3" || _cardKind == "4" {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Redeem,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"] ?? "",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"] ?? "",
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.Point_Redeem,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"] ?? "",
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
                   
                
                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            case Command.CMD_POINT_SEARCH_RES:
                if _status == .sucess {
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
                    
                } else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            case Command.CMD_MEMBER_USE_RES:
                break
            case Command.CMD_MEMBER_CANCEL_RES:
                break
            case Command.CMD_MEMBER_SEARCH_RES:
                break
            default:
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                break
            }
            
            //끝났으니 값들을 모두 정리한다
            Clear()
        }
    }
    
    func Res_Tcp_Member(tcpStatus _status:tcpStatus,ResData _resData:[String:String])
    {
        var productNum = PaySdk.instance.mTid.replacingOccurrences(of: " ", with: "") +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_resData["TrdDate"] ?? "") +
        (_resData["AuNo"] ?? "")
        DispatchQueue.main.asyncAfter(deadline: .now() + mDeley) { [self] in
            switch _resData["TrdType"] {
        
            case Command.CMD_MEMBER_USE_RES:
                if _status == .sucess {
                    if KocesSdk.instance.mEotCheck != 0 {
                        PaySdk.instance.mICCancelInfo = "I" + String(_resData["TrdDate"]?.prefix(6) ?? "") + _resData["AuNo"]!
                        
                        //2021-08-19 kim.jy
                        let TotalMoney:Int = PaySdk.instance.mMoney + Int(PaySdk.instance.mTax)! + Int(PaySdk.instance.mServiceCharge)!
                        PaySdk.instance.mMoney = TotalMoney
                        PaySdk.instance.mTax = "0"
                        PaySdk.instance.mServiceCharge = "0"
                        PaySdk.instance.mTaxfree = "0"
                        
                        PaySdk.instance.m2TradeCancel = true    //망취소발생
                        
                        PaySdk.instance.mPointTrdType = Command.CMD_POINT_EARN_CANCEL_REQ
                        Req_tcp_Point(TrdType: PaySdk.instance.mPointTrdType, Tid: PaySdk.instance.mTid, CancelInfo: PaySdk.instance.mICCancelInfo, InputMethod: PaySdk.instance.mInputMethod, PointCardNumber: PaySdk.instance.mCashTrack, idEncrpyt: PaySdk.instance.mCashTrack2data, ptCardCode: PaySdk.instance.mCompCode, PayType: "02", businessData: PaySdk.instance.mBusinessData)
                        return
                    }
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                        var _cardKind = _resData["CardKind"] ?? ""
                        if _cardKind == "3" || _cardKind == "4"  {

                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.MemberShip,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"] ?? "",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"] ?? "", 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.MemberShip,
                                                        취소여부: define.TradeMethod.NoCancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: _resData["OriDate"] ?? "",
                                                        승인번호: _resData["AuNo"] ?? "", 원승인번호: "",
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
              

                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            case Command.CMD_MEMBER_CANCEL_RES:
                if PaySdk.instance.m2TradeCancel == true { //망취소발생
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = (_resData["Message"] ?? "")
                    resDataDic["TrdType"] = Command.CMD_POINT_EARN_CANCEL_RES
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
                    Clear()
                    return
                }
                
                //신용취소거래
                if _status == .sucess {
                    
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        //여기서 sqlite에 거래 내역 저장 한다. 신용/현금인경우 리스너를 제거하고 영수증으로 보냄
                        var _cardKind = _resData["CardKind"] ?? ""
                        if _cardKind == "3" || _cardKind == "4" {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.MemberShip,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["Message"] ?? "",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"] ?? "",
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        } else {
                            sqlite.instance.InsertTrade(Tid: PaySdk.instance.mTid,
                                                        StoreName: PaySdk.instance.mStoreName,
                                                        StoreAddr: PaySdk.instance.mStoreAddr,
                                                        StoreNumber: PaySdk.instance.mStoreNumber,
                                                        StorePhone: PaySdk.instance.mStorePhone,
                                                        StoreOwner: PaySdk.instance.mStoreOwner,
                                                        신용현금: define.TradeMethod.MemberShip,
                                                        취소여부: define.TradeMethod.Cancel,
                                                        금액: self.mMoney,
                                                        선불카드잔액: _resData["GiftAmt"] ?? "0",
                                                        세금: Int(self.mTax) ?? 0,
                                                        봉사료: Int(self.mServiceCharge) ?? 0,
                                                        비과세: Int(self.mTaxfree) ?? 0,
                                                        할부: self.mInstallment,
                                                        현금영수증타겟: define.TradeMethod.NULL, 현금영수증발급형태: define.TradeMethod.NULL,현금발급번호: "",
                                                        카드번호: MarkingCardNumber(카드번호앞자리: _resData["CardNo"]!),
                                                        카드종류: _resData["CardKind"] ?? "",
                                                        카드매입사: _resData["InpNm"] ?? "",
                                                        카드발급사: _resData["OrdNm"] ?? "",
                                                        가맹점번호: _resData["MchNo"] ?? "",
                                                        승인날짜: _resData["TrdDate"] ?? "",
                                                        원거래일자: PaySdk.instance.mOriAudate,
                                                        승인번호: _resData["AuNo"] ?? "",
                                                        원승인번호: PaySdk.instance.mOriAuNum,
                                                        코세스고유거래키: _resData["TradeNo"] ?? "", 응답메시지: _resData["Message"] ?? "", KakaoMessage: "", PayType: "", KakaoAuMoney: "", KakaoSaleMoney: "", KakaoMemberCd: "", KakaoMemberNo: "", Otc: "", Pem: "", Trid: "", CardBin: "", SearchNo: "", PrintBarcd: "", PrintUse: "", PrintNm: "", MchFee: "", MchRefund: "",
                                                        PcKind: _resData["PcKind"] ?? "", PcCoupon: _resData["PcCoupon"] ?? "", PcPoint: _resData["PcPoint"] ?? "", PcCard: _resData["PcCard"] ?? "",
                                                        ProductNum: productNum,_ddc: _resData["DDCYn"] ?? "",_edc: _resData["EDCYn"] ?? "",
                                                        _icInputType: PaySdk.instance.mICInputMethod,_emvTradeType: PaySdk.instance.mEMVTradeType,_pointCode: _resData["PtResCode"] ?? "",_serviceName: _resData["PtResService"] ?? "",_earnPoint: _resData["PtResEarnPoint"] ?? "",_usePoint: _resData["PtResUsePoint"] ?? "",_totalPoint: _resData["PtResTotalPoint"] ?? "",_percent:  _resData["PtResPercentPoint"] ?? "",_userName: _resData["PtResUserName"] ?? "",_pointStoreNumber: _resData["PtResStoreNumber"] ?? "",_MemberCardTypeText: _resData["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _resData["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _resData["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _resData["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _resData["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _resData["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _resData["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _resData["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _resData["MemberStoreNoText"] ?? "")
                        }

                        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
                            let controller = Utils.topMostViewController() as! CardAnimationViewController
                            controller.GoToReceiptSwiftUI()
                            
                        }
                        
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
                   
                
                }
                else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            case Command.CMD_MEMBER_SEARCH_RES:
                if _status == .sucess {
                    //앱투앱이 아닌 경우에만 DB에 저장
                    if !self.mDBAppToApp {
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    } else {
                        //앱투앱인경우 리스너로 날려보냄
                        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .OK, payResult: _resData) //여기서 paylistener 가 널임
                    }
                    
                } else {
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                }
                break
            default:
                    PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: _resData)
                break
            }
            
            //끝났으니 값들을 모두 정리한다
            Clear()
        }
    }
 
    func MarkingCardNumber(카드번호앞자리 _cardNum:String) -> String {
        
        if(_cardNum.count > 6) {
            return _cardNum
        }
        let arr:[Character] = Array(_cardNum)
        var cardNo:String = String( arr[0...3])
        cardNo += "-"
        cardNo += String(arr[4...5])
        cardNo += "**-****-****"
        return cardNo
    }
    
    func getCashTarget(대상입력 _Target:Int) -> define.TradeMethod {
        var tar:define.TradeMethod = define.TradeMethod.NULL
        switch _Target {
        case 1:
            tar = define.TradeMethod.CashPrivate
            break
        case 2:
            tar = define.TradeMethod.CashBusiness
            break
        case 3:
            tar = define.TradeMethod.CashSelf
            break
        default:
            tar = define.TradeMethod.NULL
            break
        }
        
        return tar
    }
}
