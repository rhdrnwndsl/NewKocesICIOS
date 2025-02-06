//
//  CalendarViewController.swift
//  osxapp
//
//  Created by 신진우 on 2021/02/23.
//

import Foundation
import UIKit
//import FSCalendar

class CalendarViewController: UIViewController {
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var listener: TcpResult?
    
    @IBOutlet weak var mSegCalendarDay: UISegmentedControl! //기간선택
    
    
    let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
    @IBOutlet weak var mFirstDate: UIDatePicker!
    @IBOutlet weak var mLastDate: UIDatePicker!
    
    
    @IBOutlet weak var mTxtSumMoney: UILabel!   //총합계금액
    @IBOutlet weak var mTxtSumCount: UILabel!   //총합계건수
    @IBOutlet weak var mTxtSumAvrMoney: UILabel!    //총합계평균
    @IBOutlet weak var mTxtTotalMoney: UILabel! //총결제금액
    @IBOutlet weak var mTxtTotalCount: UILabel! //총결제건수
    @IBOutlet weak var mTxtTotalAvrMoney: UILabel!  //평균결제금액
    @IBOutlet weak var mTxtCancelMoney: UILabel!    //총환불금액
    @IBOutlet weak var mTxtCancelCount: UILabel!    //총환불건수
    @IBOutlet weak var mTxtCancelAvrMoney: UILabel! //환불평균금액
    
    @IBOutlet weak var mTxtCreditMoney: UILabel!    //신용결제금액
    @IBOutlet weak var mTxtCheckMoney: UILabel!     //신용체크금액
    @IBOutlet weak var mTxtGiftMoney: UILabel!      //신용기프트금액
    @IBOutlet weak var mTxtOtherMoney: UILabel!     //신용기타금액
    
    
    
    @IBOutlet weak var mTxtCashPrMoney: UILabel!    //현금개인결제금액
    @IBOutlet weak var mTxtCashBsMoney: UILabel!    //현금사업자결제금액
    @IBOutlet weak var mTxtCashVoMoney: UILabel!    //현금자진결제금액
    @IBOutlet weak var mTxtEasyKakaoMoney: UILabel! //카카오결제금액
    @IBOutlet weak var mTxtEasyZeroMoney: UILabel!  //제로결제금액
    @IBOutlet weak var mTxtEasyAppMoney: UILabel!   //앱카드결제금액
    @IBOutlet weak var mTxtEasyEmvQRMoney: UILabel! //EMV_QR결제금액
    @IBOutlet weak var mTxtEasyPaycoMoney: UILabel! //페이코 결제금액 -> 추가
    
    @IBOutlet weak var mTxtCashICMoney: UILabel!    //현금IC결제금액
    
    var creditMoney = 0    //신용승인
    var creditCancelMoney = 0  //신용취소
    var checkMoney = 0    //신용체크승인
    var checkCancelMoney = 0  //신용체크취소
    var giftMoney = 0    //신용선물승인
    var giftCancelMoney = 0  //신용선물취소
    var otherMoney = 0    //신용기타승인
    var otherCancelMoney = 0  //신용기타취소
    
    var cashBusinessMoney = 0  //현금사업자승인
    var cashBusinessCancelMoney = 0    //현금사업자취소
    var cashPersonalMoney = 0  //현금소득증빙승인
    var cashPersonalCancelMoney = 0    //현금소득증빙취소
    var cashVoluntaryMoney = 0     //현금자진발급승인
    var cashVoluntaryCancelMoney = 0   //현금자진발급취소
    var kakaoMoney = 0 //카카오승인
    var kakaoCancelMoney = 0   //카카오취소
    var aliMoney = 0   //알리승인
    var aliCancelMoney = 0 //알리취소
    var wechatMoney = 0    //위쳇승인
    var wechatCancelMoney = 0  //위쳇취소
    var appcardMoney = 0   //앱카드승인
    var appcardCancelMoney = 0 //앱카드취소
    var emvMoney = 0   //emvQr승인
    var emvCancelMoney = 0 //emvQr취소
    var zeroMoney = 0  //제로승인
    var zeroCancelMoney = 0    //제로취소
    
    var catcreditMoney = 0    //cat신용승인
    var catcreditCancelMoney = 0  //cat신용취소
    var catcheckMoney = 0    //cat신용체크승인
    var catcheckCancelMoney = 0  //cat신용체크취소
    var catgiftMoney = 0    //cat신용선물승인
    var catgiftCancelMoney = 0  //cat신용선물취소
    var catotherMoney = 0    //cat신용기타승인
    var catotherCancelMoney = 0  //cat신용기타취소

    var catcashBusinessMoney = 0  //cat현금사업자승인
    var catcashBusinessCancelMoney = 0    //cat현금사업자취소
    var catcashPersonalMoney = 0  //cat현금소득증빙승인
    var catcashPersonalCancelMoney = 0    //cat현금소득증빙취소
    var catcashVoluntaryMoney = 0     //cat현금자진발급승인
    var catcashVoluntaryCancelMoney = 0   //cat현금자진발급취소
    var catappcardMoney = 0   //cat앱카드승인
    var catappcardCancelMoney = 0 //cat앱카드취소
    
    var catzeroMoney = 0   //cat제로승인
    var catzeroCancelMoney = 0 //cat제로취소
    var catweMoney = 0   //cat위쳇승인
    var catweCancelMoney = 0 //cat위쳇취소
    var cataliMoney = 0   //cat알리승인
    var cataliCancelMoney = 0 //cat알리취소
    var catkakaoMoney = 0   //cat카카오승인
    var catkakaoCancelMoney = 0 //cat카카오취소
    var catpaycoMoney = 0   //cat페이코승인      -> 추가
    var catpaycoCancelMoney = 0 //cat페이코취소  -> 추가
    
    var catcashICMoney = 0  //cat cashIC승인
    var catcashICCancelMoney = 0  //cat cashIC취소
    
    var sumMoney = 0    //총합계금액
    var sumCount = 0    //총합계건수
    var sumAvrMoney = 0 //총합계평균금액
    var totalMoney = 0 //총결제금액
    var totalCancelMoney = 0   //총취소금액
    var totalCount = 0 //총결제건수
    var totalCancelCount = 0   //총취소건수
    var averageMoney = 0   //건당평균결제금액
    var averageCancelMoney = 0 //건당평균취소금액
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UISetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func Clear() {
        creditMoney = 0    //신용승인
        creditCancelMoney = 0  //신용취소
        checkMoney = 0    //신용체크승인
        checkCancelMoney = 0  //신용체크취소
        giftMoney = 0    //신용선물승인
        giftCancelMoney = 0  //신용선물취소
        otherMoney = 0    //신용기타승인
        otherCancelMoney = 0  //신용기타취소
        
        cashBusinessMoney = 0  //현금사업자승인
        cashBusinessCancelMoney = 0    //현금사업자취소
        cashPersonalMoney = 0  //현금소득증빙승인
        cashPersonalCancelMoney = 0    //현금소득증빙취소
        cashVoluntaryMoney = 0     //현금자진발급승인
        cashVoluntaryCancelMoney = 0   //현금자진발급취소
        kakaoMoney = 0 //카카오승인
        kakaoCancelMoney = 0   //카카오취소
        aliMoney = 0   //알리승인
        aliCancelMoney = 0 //알리취소
        wechatMoney = 0    //위쳇승인
        wechatCancelMoney = 0  //위쳇취소
        appcardMoney = 0   //앱카드승인
        appcardCancelMoney = 0 //앱카드취소
        emvMoney = 0   //emvQr승인
        emvCancelMoney = 0 //emvQr취소
        zeroMoney = 0  //제로승인
        zeroCancelMoney = 0    //제로취소
        
        catcreditMoney = 0    //cat신용승인
        catcreditCancelMoney = 0  //cat신용취소
        catcheckMoney = 0    //cat신용체크승인
        catcheckCancelMoney = 0  //cat신용체크취소
        catgiftMoney = 0    //cat신용선물승인
        catgiftCancelMoney = 0  //cat신용선물취소
        catotherMoney = 0    //cat신용기타승인
        catotherCancelMoney = 0  //cat신용기타취소

        catcashBusinessMoney = 0  //cat현금사업자승인
        catcashBusinessCancelMoney = 0    //cat현금사업자취소
        catcashPersonalMoney = 0  //cat현금소득증빙승인
        catcashPersonalCancelMoney = 0    //cat현금소득증빙취소
        catcashVoluntaryMoney = 0     //cat현금자진발급승인
        catcashVoluntaryCancelMoney = 0   //cat현금자진발급취소
        catappcardMoney = 0   //cat앱카드승인
        catappcardCancelMoney = 0 //cat앱카드취소
        catzeroMoney = 0   //cat제로승인
        catzeroCancelMoney = 0 //cat제로취소
        catweMoney = 0   //cat위쳇승인
        catweCancelMoney = 0 //cat위쳇취소
        cataliMoney = 0   //cat알리승인
        cataliCancelMoney = 0 //cat알리취소
        catkakaoMoney = 0   //cat카카오승인
        catkakaoCancelMoney = 0 //cat카카오취소
        catpaycoMoney = 0   //cat페이코승인      -> 추가
        catpaycoCancelMoney = 0 //cat페이코취소  -> 추가
        
        catcashICMoney = 0  //cat cashIC승인
        catcashICCancelMoney = 0  //cat cashIC취소
        
        totalMoney = 0 //총결제금액
        totalCancelMoney = 0   //총취소금액
        totalCount = 0 //총결제건수
        totalCancelCount = 0   //총취소건수
        averageMoney = 0   //건당평균결제금액
        averageCancelMoney = 0 //건당평균취소금액
        sumMoney = 0    //총합계금액
        sumCount = 0    //총합계건수
        sumAvrMoney = 0 //총합계평균금액
        
        mTxtTotalMoney.text = "0원" //총결제금액
        mTxtTotalCount.text = "0건" //총결제건수
        mTxtTotalAvrMoney.text = "0원" //평균결제금액
        mTxtCancelMoney.text = "0원"    //총환불금액
        mTxtCancelCount.text = "0건"   //총환불건수
        mTxtCancelAvrMoney.text = "0원" //환불평균금액
        mTxtSumMoney.text = "0원"   //총합계금액
        mTxtSumCount.text = "0건"   //총합계건수
        mTxtSumAvrMoney.text = "0원"    //총합계평균
       
        mTxtCreditMoney.text = "0원"    //신용결제금액
        mTxtCheckMoney.text = "0원"     //신용체크금액
        mTxtGiftMoney.text = "0원"     //신용기프트금액
        mTxtOtherMoney.text = "0원"     //신용기타금액

        mTxtCashPrMoney.text = "0원"    //현금개인결제금액
        mTxtCashBsMoney.text = "0원"    //현금사업자결제금액
        mTxtCashVoMoney.text = "0원"    //현금자진결제금액
        mTxtEasyKakaoMoney.text = "0원" //카카오결제금액
        mTxtEasyZeroMoney.text = "0원"  //제로결제금액
        mTxtEasyAppMoney.text = "0원"   //앱카드결제금액
        mTxtEasyEmvQRMoney.text = "0원" //EMV_QR결제금액
        mTxtEasyPaycoMoney.text = "0원" //페이코 결제금액 -> 추가
         
        mTxtCashICMoney.text = "0원"   //현금IC결제금액
    }
    
    func UISetting() {
        self.tabBarController?.delegate = self
        dateFormat.dateFormat = "yyMMdd"
        mSegCalendarDay.selectedSegmentIndex = 1
        mSegCalendarDay.translatesAutoresizingMaskIntoConstraints = false
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            // It's an iPhone
            mSegCalendarDay.frame.size.height = 40
            break
        case .pad:
            // It's an iPad (or macOS Catalyst)
            mSegCalendarDay.frame.size.height = 50
            break
        @unknown default:
            break
        }
        
        Clear()
    }
    
    
    @IBAction func select_calendar_day(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //전체
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyMMddHHmmss"
            //거래 내역 가져오기
            var mDBTradeTableResult:[DBTradeResult] = sqlite.instance.getTradeList(tid: Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" ? "":Utils.getIsCAT() ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
            if mDBTradeTableResult.count > 0 {
                mFirstDate.date = dateFormatter.date(from: mDBTradeTableResult[mDBTradeTableResult.count - 1].getAuDate())!
            } else {
                mFirstDate.date = Date()
            }
            mLastDate.date = Date()
            break
        case 1: //당일
            mFirstDate.date = Date()
            mLastDate.date = Date()
            break
        case 2: //당월
            mFirstDate.date = startOfMonth(날짜: Date())
            mLastDate.date = endOfMonth(날짜: Date())
            break
        default:
            break
        }
    }
    
    @IBAction func click_All_Day(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyMMddHHmmss"
        //거래 내역 가져오기
        var mDBTradeTableResult:[DBTradeResult] = sqlite.instance.getTradeList(tid: Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" ? "":Utils.getIsCAT() ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
        
        if mDBTradeTableResult.count > 0 {
            mFirstDate.date = dateFormatter.date(from: mDBTradeTableResult[mDBTradeTableResult.count - 1].getAuDate())!
        } else {
            mFirstDate.date = Date()
        }
        mLastDate.date = Date()
    }
    @IBAction func click_D_Day(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        mFirstDate.date = Date()
        mLastDate.date = Date()
    }
    
    @IBAction func click_D_Month(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        mFirstDate.date = startOfMonth(날짜: Date())
        mLastDate.date = endOfMonth(날짜: Date())
    }
    
    @IBAction func click_Result_Date(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        if Int(dateFormat.string(from: mFirstDate.date))! > Int(dateFormat.string(from: mLastDate.date))! {
            AlertBox(title: "조회오류", message: "조회시작일이 조회종료일보다 작아야 합니다", text: "확인")
            return
        }
        
        if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            TidAlertBox(title: "조회 할 TID 를 선택해 주세요") { [self](BSN,TID) in
                if TID == "" {
                    AlertBox(title: "조회를 종료합니다.", message: "", text: "확인")
                    return
                }
                AlertLoadingBox(title: "잠시만 기다려 주세요")
                if TID == "전체" {
//                    SetTradeData(Tid: "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[self] in
            //            CalendarResult()
                        getTradeListPeriod(Tid: "", From: dateFormat.string(from: mFirstDate.date), To: dateFormat.string(from: mLastDate.date))
                    }
                } else {
//                    SetTradeData(Tid: TID)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[self] in
            //            CalendarResult()
                        getTradeListPeriod(Tid: TID, From: dateFormat.string(from: mFirstDate.date), To: dateFormat.string(from: mLastDate.date))
                    }
                }
                
            }
            return
        }
        
        AlertLoadingBox(title: "잠시만 기다려 주세요")

//        dateFormat.dateFormat = "yyMMdd"
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[self] in
//            CalendarResult()
            getTradeListPeriod(Tid: Utils.getIsCAT() ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID), From: dateFormat.string(from: mFirstDate.date), To: dateFormat.string(from: mLastDate.date))
        }

    }
    
    func getTradeListPeriod(Tid _tid:String = "", From _from:String, To _to:String){
        let queryresult:[DBTradeResult] = sqlite.instance.getTradeListPeriod(Tid: _tid, from: _from, to: _to)
        var _okCount = 0
        var _cancelCount = 0
        var _tmpMoney = 0   //환불하여 추가로 총금액에 더해야 할 금액
        var _tmpCount = 0   //환불하여 추가로 총금액에 더해야 할 건수
        Clear()
        if queryresult.count == 0 {
            alertLoading.dismiss(animated: true) {[self] in
                AlertBox(title: "조회오류", message: "거래내역이 없습니다", text: "확인")
            }
            return
        }
        for i in 0 ..< queryresult.count {
            var _total:Int = (Int(queryresult[i].getMoney()) ?? 0) + (Int(queryresult[i].getTax()) ?? 0) + (Int(queryresult[i].getSvc()) ?? 0)
            if queryresult[i].getTrade().contains("(C)") { //CAT 거래인 경우
                _total = (Int(queryresult[i].getMoney()) ?? 0) + (Int(queryresult[i].getTax()) ?? 0) + (Int(queryresult[i].getSvc()) ?? 0)
                _total = _total + (Int(queryresult[i].getTxf() ?? "0") ?? 0)
            }
            switch queryresult[i].getTrade() {
            case define.TradeMethod.AppCard.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    appcardMoney += _total; _okCount += 1;
                } else {
                    appcardCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.EmvQr.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    emvMoney += _total; _okCount += 1;
                } else {
                    emvCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.Wechat.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    wechatMoney += _total; _okCount += 1;
                } else {
                    wechatCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.Ali.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    aliMoney += _total; _okCount += 1;
                } else {
                    aliCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.Zero.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    zeroMoney += _total; _okCount += 1;
                } else {
                    zeroCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.Kakao.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    kakaoMoney += _total; _okCount += 1;
                } else {
                    kakaoCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.Credit.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCardType() == "1" || queryresult[i].getCardType() == " " { //신용카드
                    if queryresult[i].getCancel() == "0" {
                        creditMoney += _total; _okCount += 1;
                    } else {
                        creditCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else if queryresult[i].getCardType() == "2" { //체크카드
                    if queryresult[i].getCancel() == "0" {
                        checkMoney += _total; _okCount += 1;
                    } else {
                        checkCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else if queryresult[i].getCardType() == "3" { //기프트카드
                    if queryresult[i].getCancel() == "0" {
                        giftMoney += _total; _okCount += 1;
                    } else {
                        giftCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else if queryresult[i].getCardType() == "4" { //기타카드
                    if queryresult[i].getCancel() == "0" {
                        otherMoney += _total; _okCount += 1;
                    } else {
                        otherCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else {
                    print("else")
                }

                break
            case define.TradeMethod.Cash.rawValue:
                if Utils.getIsCAT() {
                    continue
                }
                if queryresult[i].getCashTarget() == define.TradeMethod.CashPrivate.rawValue {  //개인
                    if queryresult[i].getCancel() == "0" {
                        cashPersonalMoney += _total; _okCount += 1;
                    } else {
                        cashPersonalCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }

                } else if queryresult[i].getCashTarget() == define.TradeMethod.CashBusiness.rawValue {  //사업자
                    if queryresult[i].getCancel() == "0" {
                        cashBusinessMoney += _total; _okCount += 1;
                    } else {
                        cashBusinessCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }

                } else if queryresult[i].getCashTarget() == define.TradeMethod.CashSelf.rawValue {  //자진발급
                    if queryresult[i].getCancel() == "0" {
                        cashVoluntaryMoney += _total; _okCount += 1;
                    } else {
                        cashVoluntaryCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }

                } else {
                    print("else")
                }

                break
            case define.TradeMethod.CAT_App.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    catappcardMoney += _total; _okCount += 1;
                } else {
                    catappcardCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.CAT_We.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    catweMoney += _total; _okCount += 1;
                } else {
                    catweCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.CAT_Ali.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    cataliMoney += _total; _okCount += 1;
                } else {
                    cataliCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.CAT_Zero.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    catzeroMoney += _total; _okCount += 1;
                } else {
                    catzeroCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.CAT_Kakao.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    catkakaoMoney += _total; _okCount += 1;
                } else {
                    catkakaoCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.CAT_Payco.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    catpaycoMoney += _total; _okCount += 1;
                } else {
                    catpaycoCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            case define.TradeMethod.CAT_Cash.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCashTarget() == define.TradeMethod.CashPrivate.rawValue {  //개인
                    if queryresult[i].getCancel() == "0" {
                        catcashPersonalMoney += _total; _okCount += 1;
                    } else {
                        catcashPersonalCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }

                } else if queryresult[i].getCashTarget() == define.TradeMethod.CashBusiness.rawValue {  //사업자
                    if queryresult[i].getCancel() == "0" {
                        catcashBusinessMoney += _total; _okCount += 1;
                    } else {
                        catcashBusinessCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }

                } else if queryresult[i].getCashTarget() == define.TradeMethod.CashSelf.rawValue {  //자진발급
                    if queryresult[i].getCancel() == "0" {
                        catcashVoluntaryMoney += _total; _okCount += 1;
                    } else {
                        catcashVoluntaryCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }

                } else {
                    print("else")
                }
                break
            case define.TradeMethod.CAT_Credit.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCardType() == "1" || queryresult[i].getCardType() == " " { //신용카드
                    if queryresult[i].getCancel() == "0" {
                        catcreditMoney += _total; _okCount += 1;
                    } else {
                        catcreditCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else if queryresult[i].getCardType() == "2" { //체크카드
                    if queryresult[i].getCancel() == "0" {
                        catcheckMoney += _total; _okCount += 1;
                    } else {
                        catcheckCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else if queryresult[i].getCardType() == "3" { //기프트카드
                    if queryresult[i].getCancel() == "0" {
                        catgiftMoney += _total; _okCount += 1;
                    } else {
                        catgiftCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else if queryresult[i].getCardType() == "4" { //기타카드
                    if queryresult[i].getCancel() == "0" {
                        catotherMoney += _total; _okCount += 1;
                    } else {
                        catotherCancelMoney += _total; _cancelCount += 1;
                        if (queryresult[i].getMineTrade() == "1") {
                            _tmpMoney += _total; _tmpCount += 1;
                        }
                    }
                } else {
                    print("else")
                }
                
                break
            case define.TradeMethod.CAT_CashIC.rawValue:
                if Utils.getIsBT() {
                    continue
                }
                if queryresult[i].getCancel() == "0" {
                    catcashICMoney += _total; _okCount += 1;
                } else {
                    catcashICCancelMoney += _total; _cancelCount += 1;
                    if (queryresult[i].getMineTrade() == "1") {
                        _tmpMoney += _total; _tmpCount += 1;
                    }
                }
                break
            default:
                print("default")
                break
            }
        }
        sumMoney = cashVoluntaryMoney + cashBusinessMoney + cashPersonalMoney + creditMoney + checkMoney + giftMoney + otherMoney + kakaoMoney + zeroMoney + aliMoney + wechatMoney + emvMoney + appcardMoney + catcreditMoney + catcheckMoney + catgiftMoney + catotherMoney + catappcardMoney + catweMoney + cataliMoney + catzeroMoney + catkakaoMoney + catcashBusinessMoney + catcashPersonalMoney + catcashVoluntaryMoney + catcashICMoney + catpaycoMoney
        totalMoney = sumMoney + _tmpMoney
        totalCancelMoney = cashVoluntaryCancelMoney + cashBusinessCancelMoney + cashPersonalCancelMoney + creditCancelMoney + checkCancelMoney + giftCancelMoney + otherCancelMoney + kakaoCancelMoney + zeroCancelMoney + aliCancelMoney + wechatCancelMoney + emvCancelMoney + appcardCancelMoney + catcreditCancelMoney + catcheckCancelMoney + catgiftCancelMoney + catotherCancelMoney + catappcardCancelMoney + catweCancelMoney + cataliCancelMoney + catzeroCancelMoney + catkakaoCancelMoney + catcashBusinessCancelMoney + catcashPersonalCancelMoney + catcashVoluntaryCancelMoney + catcashICCancelMoney + catpaycoCancelMoney
        
        sumCount = _okCount
        totalCount = sumCount + _tmpCount
        totalCancelCount = _cancelCount
        
        sumCount == 0 ? (sumAvrMoney = 0):(sumAvrMoney = sumMoney / sumCount)
        totalCount == 0 ?  (averageMoney = 0):(averageMoney = totalMoney / totalCount)
        totalCancelCount == 0 ? (averageCancelMoney = 0):(averageCancelMoney = totalCancelMoney / totalCancelCount)
        
        //매출정보(합계)
        mTxtSumMoney.text = Utils.PrintMoney(Money: String(sumMoney)) + "원"
        mTxtSumCount.text = Utils.PrintMoney(Money: String(sumCount)) + "건"
        mTxtSumAvrMoney.text = Utils.PrintMoney(Money: String(sumAvrMoney)) + "원"
        
        //매출정보(결제)
        mTxtTotalMoney.text = Utils.PrintMoney(Money: String(totalMoney)) + "원"
        mTxtTotalCount.text = Utils.PrintMoney(Money: String(totalCount)) + "건"
        mTxtTotalAvrMoney.text = Utils.PrintMoney(Money: String(averageMoney)) + "원"
        
        //매출정보(환불)
        mTxtCancelMoney.text = "-" + Utils.PrintMoney(Money: String(totalCancelMoney)) + "원"
        mTxtCancelCount.text = Utils.PrintMoney(Money: String(totalCancelCount)) + "건"
        mTxtCancelAvrMoney.text = "-" + Utils.PrintMoney(Money: String(averageCancelMoney)) + "원"
        
        //결제수단정보
        //신용 신용카드/체크카드/기프트카드/기타
        mTxtCreditMoney.text = Utils.PrintMoney(Money: String(creditMoney + catcreditMoney)) + "원"
        mTxtCheckMoney.text = Utils.PrintMoney(Money: String(checkMoney + catcheckMoney)) + "원"
        mTxtGiftMoney.text = Utils.PrintMoney(Money: String(giftMoney + catgiftMoney)) + "원"
        mTxtOtherMoney.text = Utils.PrintMoney(Money: String(otherMoney + catotherMoney)) + "원"
        //현금 개인/사업자/자진발급
        mTxtCashPrMoney.text = Utils.PrintMoney(Money: String(cashPersonalMoney + catcashPersonalMoney)) + "원"
        mTxtCashBsMoney.text = Utils.PrintMoney(Money: String(cashBusinessMoney + catcashBusinessMoney)) + "원"
        mTxtCashVoMoney.text = Utils.PrintMoney(Money: String(cashVoluntaryMoney + catcashVoluntaryMoney)) + "원"
        //간편결제 카카오/제로/App카드/페이코
        mTxtEasyKakaoMoney.text = Utils.PrintMoney(Money: String(kakaoMoney + catkakaoMoney)) + "원"
        mTxtEasyZeroMoney.text = Utils.PrintMoney(Money: String(zeroMoney + catzeroMoney)) + "원"
        mTxtEasyAppMoney.text = Utils.PrintMoney(Money: String(appcardMoney + catappcardMoney)) + "원"
        mTxtEasyEmvQRMoney.text = Utils.PrintMoney(Money: String(emvMoney)) + "원"
        mTxtEasyPaycoMoney.text = Utils.PrintMoney(Money: String(catpaycoMoney)) + "원"
        //현금IC
        mTxtCashICMoney.text = Utils.PrintMoney(Money: String(catcashICMoney)) + "원"
        
        let Count = queryresult.count
        
        print(Count)
//        var _msg =
//            "신용결제금액 : " + Utils.PrintMoney(Money: String(creditMoney)) + "원" + "\n" +
//            "신용취소금액 : " + "-" + Utils.PrintMoney(Money: String(creditCancelMoney)) + "원" + "\n" +
//            "현금소득증빙결제금액 : " + Utils.PrintMoney(Money: String(cashPersonalMoney)) + "원" + "\n" +
//            "현금소득증빙취소금액 : " + "-" + Utils.PrintMoney(Money: String(cashPersonalCancelMoney)) + "원" + "\n" +
//            "현금사업자결제금액 : " + Utils.PrintMoney(Money: String(cashBusinessMoney)) + "원" + "\n" +
//            "현금사업자취소금액 : " + "-" + Utils.PrintMoney(Money: String(cashBusinessCancelMoney)) + "원" + "\n" +
//            "현금자진발급결제금액 : " + Utils.PrintMoney(Money: String(cashVoluntaryMoney)) + "원" + "\n" +
//            "현금자진발급취소금액 : " + "-" + Utils.PrintMoney(Money: String(cashVoluntaryCancelMoney)) + "원" + "\n" +
//            "카카오간편결제금액 : " + Utils.PrintMoney(Money: String(kakaoMoney)) + "원" + "\n" +
//            "카카오간편취소금액 : " + "-" + Utils.PrintMoney(Money: String(kakaoCancelMoney)) + "원" + "\n" +
//            "제로간편결제금액 : " + Utils.PrintMoney(Money: String(zeroMoney)) + "원" + "\n" +
//            "제로간편취소금액 : " + "-" + Utils.PrintMoney(Money: String(zeroCancelMoney)) + "원" + "\n" +
//            "위쳇간편결제금액 : " + Utils.PrintMoney(Money: String(wechatMoney)) + "원" + "\n" +
//            "위쳇간편취소금액 : " + "-" + Utils.PrintMoney(Money: String(wechatCancelMoney)) + "원" + "\n" +
//            "알리간편결제금액 : " + Utils.PrintMoney(Money: String(aliMoney)) + "원" + "\n" +
//            "알리간편취소금액 : " + "-" + Utils.PrintMoney(Money: String(aliCancelMoney)) + "원" + "\n" +
//            "앱카드간편결제금액 : " + Utils.PrintMoney(Money: String(appcardMoney)) + "원" + "\n" +
//            "앱카드간편취소금액 : " + "-" + Utils.PrintMoney(Money: String(appcardCancelMoney)) + "원" + "\n" +
//            "EMVQR결제금액 : " + Utils.PrintMoney(Money: String(emvMoney)) + "원" + "\n" +
//            "EMVQR취소금액 : " + "-" + Utils.PrintMoney(Money: String(emvCancelMoney)) + "원" + "\n" +
//            "총결제건수 : " + String(totalCount) + "건" + "\n" +
//            "총환불건수 : " + String(totalCancelCount) + "건" + "\n" +
//            "총결제금액 : " + Utils.PrintMoney(Money: String(totalMoney)) + "원" + "\n" +
//            "총환불금액 : " + "-" + Utils.PrintMoney(Money: String(totalCancelMoney)) + "원" + "\n" +
//            "평균결제금액 : " + Utils.PrintMoney(Money: String(averageMoney)) + "원" + "\n" +
//            "평균환불금액 : " + "-" + Utils.PrintMoney(Money: String(averageCancelMoney)) + "원"
//        let alert = UIAlertController(title: "정상조회", message: "정상적으로 조회를 완료하였습니다", preferredStyle: .alert)
//        let button = UIAlertAction(title: "확인", style: .default, handler: nil)
//        alert.addAction(button)
//        alertLoading.dismiss(animated: true) {[self] in
//            present(alert, animated: true, completion: nil)
//        }
        alertLoading.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func changed_First_Date(_ sender: UIDatePicker) {
        mFirstDate.date = sender.date
    }
    
    
    @IBAction func changed_Last_Date(_ sender: UIDatePicker) {
        mLastDate.date = sender.date
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
    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
        }
    
    func startOfMonth(날짜 _date:Date) -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: _date)))!
    }
    
    func endOfMonth(날짜 _date:Date) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(날짜: _date))!
    }
    
    func TidAlertBox(title _title:String, callback: @escaping (_ BSN:String, _ TID:String)->Void) {

        let alertController = UIAlertController(title: _title, message: nil, preferredStyle: .alert)
        
        let widthConstraints = alertController.view.constraints.filter({ return $0.firstAttribute == .width })
        alertController.view.removeConstraints(widthConstraints)
        // Here you can enter any width that you want
        let newWidth = UIScreen.main.bounds.width * 0.90
        // Adding constraint for alert base view
        let widthConstraint = NSLayoutConstraint(item: alertController.view,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: newWidth)
        alertController.view.addConstraint(widthConstraint)
        let firstContainer = alertController.view.subviews[0]
        // Finding first child width constraint
        let constraint = firstContainer.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        firstContainer.removeConstraints(constraint)
        // And replacing with new constraint equal to alert.view width constraint that we setup earlier
        alertController.view.addConstraint(NSLayoutConstraint(item: firstContainer,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .width,
                                                        multiplier: 1.0,
                                                        constant: 0))
        // Same for the second child with width constraint with 998 priority
        let innerBackground = firstContainer.subviews[0]
        let innerConstraints = innerBackground.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        innerBackground.removeConstraints(innerConstraints)
        firstContainer.addConstraint(NSLayoutConstraint(item: innerBackground,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: firstContainer,
                                                        attribute: .width,
                                                        multiplier: 1.0,
                                                        constant: 0))
        var _tid0:String = ""
        var _store0:String = ""
        var _tid1:String = ""
        var _store1:String = ""
        var _tid2:String = ""
        var _store2:String = ""
        var _tid3:String = ""
        var _store3:String = ""
        var _tid4:String = ""
        var _store4:String = ""
        var _tid5:String = ""
        var _store5:String = ""
        var _tid6:String = ""
        var _store6:String = ""
        var _tid7:String = ""
        var _store7:String = ""
        var _tid8:String = ""
        var _store8:String = ""
        var _tid9:String = ""
        var _store9:String = ""
        var _tid10:String = ""
        var _store10:String = ""
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(define.STORE_TID) {
                if Utils.getIsCAT() {
                    if key == define.CAT_STORE_TID {
                        if (value as! String) != "" {
                            _tid0 = value as! String
                            _store0 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) != "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0").replacingOccurrences(of: " ", with: "")
                            
                        }
                    } else if key == define.CAT_STORE_TID + "1" {
                        if (value as! String) != "" {
                            _tid1 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store1 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "1").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "2" {
                        if (value as! String) != "" {
                            _tid2 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store2 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "2").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "3" {
                        if (value as! String) != "" {
                            _tid3 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store3 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "3").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "4" {
                        if (value as! String) != "" {
                            _tid4 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store4 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "4").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "5" {
                        if (value as! String) != "" {
                            _tid5 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store5 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "5").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "6" {
                        if (value as! String) != "" {
                            _tid6 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store6 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "6").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "7" {
                        if (value as! String) != "" {
                            _tid7 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store7 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "7").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "8" {
                        if (value as! String) != "" {
                            _tid8 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store8 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "8").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "9" {
                        if (value as! String) != "" {
                            _tid9 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store9 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "9").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.CAT_STORE_TID + "10" {
                        if (value as! String) != "" {
                            _tid10 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store10 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "10").replacingOccurrences(of: " ", with: "")
                        }
                    }
                } else {
                    if key == define.STORE_TID {
                        if (value as! String) != "" {
                            _tid0 = value as! String
                            _store0 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME) != "" ? Setting.shared.getDefaultUserData(_key: define.STORE_NAME).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0").replacingOccurrences(of: " ", with: "")
                            
                        }
                    } else if key == define.STORE_TID + "1" {
                        if (value as! String) != "" {
                            _tid1 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store1 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "1").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "2" {
                        if (value as! String) != "" {
                            _tid2 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store2 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "2").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "3" {
                        if (value as! String) != "" {
                            _tid3 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store3 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "3").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "4" {
                        if (value as! String) != "" {
                            _tid4 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store4 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "4").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "5" {
                        if (value as! String) != "" {
                            _tid5 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store5 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "5").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "6" {
                        if (value as! String) != "" {
                            _tid6 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store6 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "6").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "7" {
                        if (value as! String) != "" {
                            _tid7 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store7 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "7").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "8" {
                        if (value as! String) != "" {
                            _tid8 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store8 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "8").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "9" {
                        if (value as! String) != "" {
                            _tid9 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store9 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "9").replacingOccurrences(of: " ", with: "")
                        }
                    } else if key == define.STORE_TID + "10" {
                        if (value as! String) != "" {
                            _tid10 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store10 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "10").replacingOccurrences(of: " ", with: "")
                        }
                    }
                }
                
            }
        }

        if _tid0 != "" {
            let ok0 = UIAlertAction(title:  "1. " + _store0 + ", " + _tid0, style: .default, handler: { (Action) in
                callback(_store0,_tid0)
            })
            ok0.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok0)
        }
        
        if _tid1 != "" {
            let ok1 = UIAlertAction(title: "2. " + _store1 + ", " + _tid1 , style: .default, handler: { (Action) in
                callback(_store1,_tid1)
            })
            ok1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok1)
        }
        
        if _tid2 != "" {
            let ok2 = UIAlertAction(title: "3. " + _store2 + ", " + _tid2 , style: .default, handler: { (Action) in
                callback(_store2,_tid2)
            })
            ok2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok2)
        }
        
        if _tid3 != "" {
            let ok3 = UIAlertAction(title: "4. " + _store3 + ", " + _tid3 , style: .default, handler: { (Action) in
                callback(_store3,_tid3)
            })
            ok3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok3)
        }
        
        if _tid4 != "" {
            let ok4 = UIAlertAction(title: "5. " + _store4 + ", " + _tid4 , style: .default, handler: { (Action) in
                callback(_store4,_tid4)
            })
            ok4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok4)
        }
        
        if _tid5 != "" {
            let ok5 = UIAlertAction(title: "6. " + _store5 + ", " + _tid5 , style: .default, handler: { (Action) in
                callback(_store5,_tid5)
            })
            ok5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok5)
        }
        
        if _tid6 != "" {
            let ok6 = UIAlertAction(title: "7. " + _store6 + ", " + _tid6 , style: .default, handler: { (Action) in
                callback(_store6,_tid6)
            })
            ok6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok6)
        }
        
        if _tid7 != "" {
            let ok7 = UIAlertAction(title: "8. " + _store7 + ", " + _tid7 , style: .default, handler: { (Action) in
                callback(_store7,_tid7)
            })
            ok7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok7)
        }
        
        if _tid8 != "" {
            let ok8 = UIAlertAction(title: "9. " + _store8 + ", " + _tid8 , style: .default, handler: { (Action) in
                callback(_store8,_tid8)
            })
            ok8.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok8)
        }
        
        if _tid9 != "" {
            let ok9 = UIAlertAction(title: "10. " + _store9 + ", " + _tid9 , style: .default, handler: { (Action) in
                callback(_store9,_tid9)
            })
            ok9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok9)
        }
        
        if _tid10 != "" {
            let ok10 = UIAlertAction(title: "11. " + _store10 + ", " + _tid10 , style: .default, handler: { (Action) in
                callback(_store10,_tid10)
            })
            ok10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok10)
        }
        
        let all = UIAlertAction(title: "전체", style: UIAlertAction.Style.default, handler: { (Action) in
            callback("","전체")
        })
        alertController.addAction(all)
        
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: { (Action) in
            callback("","")
        })
//        cancel.setValue(messageAttrString, forKey: "attributedMessage")
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }

}

extension CalendarViewController:TcpResultDelegate, UITabBarControllerDelegate {
    func onDirectResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>, DirectData _directData: Dictionary<String, String>) {
        debugPrint("앱투앱/웹투앱에서만 사용")
    }
    
    //탭바로 다른 탭 이동시 네비게이션은 초기로 이동한다
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {
        if _status != .sucess {
            alertLoading.dismiss(animated: true) {[self] in
                AlertBox(title: "정산실패", message: _result["Message"] ?? "거래 데이터를 읽어오지 못했습니다", text: "확인")
            }
            return
        }
        var _totalString:String = ""    //메세지
        var _title:String = "정산[불가]"          //타이틀
        var keyCount:Int = 0
        for (key,value) in _result {
            if _result.count - 1 == keyCount {
                _totalString += key + "=" + value
            }
            else{
                _totalString += key + "=" + value + "\n"
            }
            keyCount += 1
        }
        
        debugPrint(_result)
        alertLoading.dismiss(animated: true) {[self] in
            AlertBox(title: "정산성공", message: _totalString, text: "확인")
        }

    }
    
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
    }
    
    func CalendarResult() {
        listener = TcpResult()
        listener?.delegate = self
        mKocesSdk.CalendarResult(Command: Command.CMD_CACULATE_AGGREGATION_REQ, Tid: Utils.getIsCAT() ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", StartDay: dateFormat.string(from: mFirstDate.date) + "000000", EndDay: dateFormat.string(from: mLastDate.date) + "235959", MchData: "", CallbackListener: listener?.delegate as! TcpResultDelegate)
    }
    
}

//extension Date {
//    func startOfMonth() -> Date {
//        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month],
//from: Calendar.current.startOfDay(for: self)))!
//    }
//
//    func endOfMonth() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1),
//to: self.startOfMonth())!
//    }
//
//}
