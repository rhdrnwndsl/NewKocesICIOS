//
//  TradelistController.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/07.
//

import UIKit
import SwiftUI
class TradelistController:UIViewController{
    
    var mDBTradeTableResult:[DBTradeResult]?
    //거래내역 테이블
    @IBOutlet weak var mTradeTable: UITableView!
    
    let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
    @IBOutlet weak var mFirstDate: UIDatePicker!
    @IBOutlet weak var mLastDate: UIDatePicker!
    
    @IBOutlet weak var mSegTradeDaySelect: UISegmentedControl!
//    @IBOutlet weak var mBtnTradeAllDay: JButton!
//    @IBOutlet weak var mBtnTradeDDay: JButton!
//    @IBOutlet weak var mBtnTradeDMonth: JButton!
    
    @IBOutlet weak var mSegTradePaySelect: UISegmentedControl!
//    @IBOutlet weak var mBtnTradeAllPay: JButton!
//    @IBOutlet weak var mBtnTradeCardPay: JButton!
//    @IBOutlet weak var mBtnTradeCashPay: JButton!
//    @IBOutlet weak var mBtnTradeEasyPay: JButton!
//    @IBOutlet weak var mBtnTradeCashIC: JButton!
    
    @IBOutlet weak var mBtnTradeSearch: JButton!
    
    
    
    enum PeriodDevine:String {
        case DDay = "당일"
        case DMonth = "당월"
        case All = "전체"
        case Custom = "수동"
    }
    
    enum TradeDevine:String {
        case All = "전체"
        case Credit = "신용"
        case Cash = "현금"
        case EasyPay = "간편"
        case CashIC = "현금IC"
    }
    
    var mTradeDevine:TradeDevine = .All
    var mPeriodDevine:PeriodDevine = .All
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSetting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initSetting() {
        self.tabBarController?.delegate = self
        mTradeTable.dataSource = self
        mTradeTable.delegate = self
        //거래 내역 가져오기
        mDBTradeTableResult = sqlite.instance.getTradeList(tid: Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" ? "":Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
        mTradeTable.reloadData()
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())
        
//        UISetting.setGradientBackground(_bar: navigationController?.navigationBar ?? UINavigationBar(), colors: [
//            UIColor.systemBlue.cgColor,
//            UIColor.white.cgColor
//        ])
        
        dateFormat.dateFormat = "yyMMdd"
        
        mTradeDevine = .All
//        mBtnTradeAllDay.setTitleColor(UIColor(displayP3Red: 233/255, green:81/255, blue: 23/255, alpha: 100.0), for: .normal)
       
        mTradeDevine = .All
//        mBtnTradeAllPay.setTitleColor(UIColor(displayP3Red: 233/255, green:81/255, blue: 23/255, alpha: 100.0), for: .normal)
        
//        mBtnTradeDDay.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
//        mBtnTradeDMonth.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
        
//        mBtnTradeCardPay.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
//        mBtnTradeCashPay.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
//        mBtnTradeEasyPay.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
//        mBtnTradeCashIC.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyMMddHHmmss"
        mLastDate.date = Date()
        if mDBTradeTableResult?.count ?? 0 > 0 {
            mFirstDate.date = dateFormatter.date(from: mDBTradeTableResult![mDBTradeTableResult!.count - 1].getAuDate())!
        } else {
            mFirstDate.date = Date()
        }
        
        //당일내역 가져오기
        mSegTradeDaySelect.selectedSegmentIndex = 1 //당일
        mSegTradePaySelect.selectedSegmentIndex = 0 //전체
        mSegTradeDaySelect.translatesAutoresizingMaskIntoConstraints = false
        mSegTradePaySelect.translatesAutoresizingMaskIntoConstraints = false
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            // It's an iPhone
            mSegTradeDaySelect.frame.size.height = 40
            mSegTradePaySelect.frame.size.height = 40
            break
        case .pad:
            // It's an iPad (or macOS Catalyst)
            mSegTradeDaySelect.frame.size.height = 50
            mSegTradePaySelect.frame.size.height = 50
            break
        @unknown default:
            break
        }
        mPeriodDevine = .DDay
//        mBtnTradeAllDay.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
//        mBtnTradeDDay.setTitleColor(UIColor(displayP3Red: 233/255, green:81/255, blue: 23/255, alpha: 100.0), for: .normal)
//        mBtnTradeDMonth.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
        mFirstDate.date = Date()
        mLastDate.date = Date()
        mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" ? "":Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID), 결제구분: .NULL, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
        mTradeTable.reloadData()
        mTradeTable.translatesAutoresizingMaskIntoConstraints = false
        var _height:Float = Float((mDBTradeTableResult?.count ?? 20) * 100)
        mTradeTable.heightAnchor.constraint(equalToConstant: CGFloat(_height < 2000 ? 2000:_height)).isActive = true
    }

    //전체, 당일, 당월 기간 선택
    @IBAction func select_trade_day(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //전체
            //전체내역 가져오기
            mPeriodDevine = .All
            mLastDate.date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyMMddHHmmss"
            mDBTradeTableResult = sqlite.instance.getTradeList(tid: Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" ? "":Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
            if mDBTradeTableResult?.count ?? 0 > 0 {
                mFirstDate.date = dateFormatter.date(from: mDBTradeTableResult![mDBTradeTableResult!.count - 1].getAuDate())!
            } else {
                mFirstDate.date = Date()
            }
            break
        case 1: //당일
            //당일내역 가져오기
            mPeriodDevine = .DDay
            mFirstDate.date = Date()
            mLastDate.date = Date()
            break
        case 2: //당월
            //당월내역 가져오기
            mPeriodDevine = .DMonth
            mFirstDate.date = startOfMonth(날짜: Date())
            mLastDate.date = endOfMonth(날짜: Date())
            break
        default:
            break
        }
    }
    
    //전체, 카드, 현금, 간편, 현금IC 선택
    @IBAction func select_trade_pay(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //전체
            //전체내역 가져오기
            mTradeDevine = .All
            break
        case 1: //카드
            //신용내역 가져오기
            mTradeDevine = .Credit
            break
        case 2: //현금
            //현금내역 가져오기
            mTradeDevine = .Cash
            break
        case 3: //간편
            //간편결제내역 가져오기
            mTradeDevine = .EasyPay
            break
        case 4: //현금IC
            //현금IC결제내역 가져오기
            mTradeDevine = .CashIC
            break
        default:
            break
        }
    }
    
    @IBAction func changed_First_Date(_ sender: UIDatePicker) {
        mFirstDate.date = sender.date
    }
    
    
    @IBAction func changed_Last_Date(_ sender: UIDatePicker) {
        mLastDate.date = sender.date
    }
   
    //조회버튼클릭
    @IBAction func click_Btn_Search(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        if Int(dateFormat.string(from: mFirstDate.date))! > Int(dateFormat.string(from: mLastDate.date))! {
            AlertBox(title: "조회불가", message: "조회시작일이 마지막날보다 큽니다", text: "확인")
            return
        }
        
        if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            TidAlertBox(title: "조회 할 TID 를 선택해 주세요") { [self](BSN,TID) in
                if TID == "" {
                    AlertBox(title: "조회를 종료합니다.", message: "", text: "확인")
                    return
                }
                if TID == "전체" {
                    SetTradeData(Tid: "")
                } else {
                    SetTradeData(Tid: TID)
                }
                
            }
            return
        }
        SetTradeData(Tid: Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT ?  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
    }
    
    func SetTradeData(Tid _tid:String) {
        mDBTradeTableResult = nil

        switch mPeriodDevine {
        case .All:
            switch mTradeDevine {
            case .All:
                mDBTradeTableResult = sqlite.instance.getTradeList(tid: _tid)
                break
            case .Credit:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Credit, from: "", to: "")
                break
            case .Cash:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Cash, from: "", to: "")
                break
            case .EasyPay:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .EasyPay, from: "", to: "")
                break
            case .CashIC:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .CAT_CashIC, from: "", to: "")
                break
            }
            break
        case .DDay:
            switch mTradeDevine {
            case .All:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .NULL, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .Credit:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Credit, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .Cash:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Cash, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .EasyPay:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .EasyPay, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .CashIC:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .CAT_CashIC, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            }
            break
        case .DMonth:
            switch mTradeDevine {
            case .All:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .NULL, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .Credit:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Credit, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .Cash:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Cash, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .EasyPay:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .EasyPay, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .CashIC:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .CAT_CashIC, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            }
            break
        case .Custom:
            switch mTradeDevine {
            case .All:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .NULL, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .Credit:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Credit, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .Cash:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .Cash, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .EasyPay:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .EasyPay, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            case .CashIC:
                mDBTradeTableResult = sqlite.instance.getTradeListParsingData(Tid: _tid, 결제구분: .CAT_CashIC, from: dateFormat.string(from: mFirstDate.date), to: dateFormat.string(from: mLastDate.date))
                break
            }
            break

        }
   
        mTradeTable.translatesAutoresizingMaskIntoConstraints = false
        var _height:Float = Float((mDBTradeTableResult?.count ?? 20) * 100)
        mTradeTable.heightAnchor.constraint(equalToConstant: CGFloat(_height < 2000 ? 2000:_height)).isActive = true
        mTradeTable.reloadData()
    }
    
    func startOfMonth(날짜 _date:Date) -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: _date)))!
    }
    
    func endOfMonth(날짜 _date:Date) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(날짜: _date))!
    }
    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
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
                if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
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

extension TradelistController: UITableViewDelegate,UITableViewDataSource, UITabBarControllerDelegate {
    //탭바로 다른 탭 이동시 네비게이션은 초기로 이동한다
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let Count = mDBTradeTableResult?.count else {
            return 0
        }
        return Count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradeListTableCell", for: indexPath) as! TradeListTableCell
        
        let chars:[Character] = Array( (self.mDBTradeTableResult?[indexPath.row].getAuDate())!)
        let txtAuDate:String = String(chars[0...1]) + "/" + String(chars[2...3]) + "/" + String(chars[4...5]) + " " +
            String(chars[6...7]) + ":" + String(chars[8...9]) + ":" + String(chars[10...11])
        cell.lbl_date.text = txtAuDate
        
//        let TotalMoney:Int = Int((self.mDBTradeTableResult?[indexPath.row].getMoney())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getTax())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getSvc())!)! - Int((self.mDBTradeTableResult?[indexPath.row].getTxf())!)!
        
        var TotalMoney:Int = Int((self.mDBTradeTableResult?[indexPath.row].getMoney())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getTax())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getSvc())!)!
        var TradeType:String = self.mDBTradeTableResult?[indexPath.row].getTrade() ?? ""
        if TradeType.contains("(C)") { //CAT 거래인 경우
            TotalMoney = Int((self.mDBTradeTableResult?[indexPath.row].getMoney())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getTax())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getSvc())!)! + Int((self.mDBTradeTableResult?[indexPath.row].getTxf())!)!
        }
        cell.lbl_money.text = "\(TotalMoney)"
        //전에는 EMVQR 을 어떻게 표기할지 몰라서 EMVQR 일경우 앱카드로 표기했는데 이제 그렇게 표기하지 않는다
        cell.lbl_type.text = self.mDBTradeTableResult?[indexPath.row].getTrade()
//        cell.lbl_type.text = self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.EmvQr.rawValue ? define.TradeMethod.AppCard.rawValue:self.mDBTradeTableResult?[indexPath.row].getTrade()
        let cclTemp = self.mDBTradeTableResult?[indexPath.row].getCancel()
        if cclTemp! == "0" {
            cell.lbl_cancel.text = "승인"
            cell.lbl_money.text = "  " + Utils.PrintMoney(Money: cell.lbl_money.text!)
            cell.lbl_money.textColor = UIColor.black
        }
        else
        {
            cell.lbl_cancel.text = "환불"
            cell.lbl_money.text = "-" + Utils.PrintMoney(Money: cell.lbl_money.text!)
            cell.lbl_money.textColor = UIColor.red
        }

        
        return cell
    }
    ///처리 하지 않음
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let reciptView = storyboard.instantiateViewController(withIdentifier: "ReciptViewController") as? ReciptViewController else {return}
//        reciptView.view.backgroundColor = .white
//        reciptView.modalPresentationStyle = .fullScreen
//        present(reciptView, animated: true, completion: nil)
        
        guard self.mDBTradeTableResult?[indexPath.row] != nil else
        {
            return
        }
        
        
        if self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.Kakao.rawValue ||
            self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.Ali.rawValue ||
            self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.AppCard.rawValue ||
            self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.Zero.rawValue ||
            self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.EmvQr.rawValue ||
            self.mDBTradeTableResult?[indexPath.row].getTrade() == define.TradeMethod.Wechat.rawValue {
            let controller = UIHostingController(rootView: ReceiptEasyPaySwiftUI())
            controller.rootView.setData(영수증데이터: self.mDBTradeTableResult![indexPath.row], 뷰컨트롤러: "거래내역", 전표번호: String(mDBTradeTableResult![indexPath.row].getid()))
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = UIHostingController(rootView: ReceiptSwiftUI())
            controller.rootView.setData(영수증데이터: self.mDBTradeTableResult![indexPath.row], 뷰컨트롤러: "거래내역", 전표번호: String(mDBTradeTableResult![indexPath.row].getid()))
            navigationController?.pushViewController(controller, animated: true)
        }
        
        
    }
            
}
