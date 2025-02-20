//
//  ReceiptSwiftUI.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/10.
//

import SwiftUI
import UIKit

struct ReceiptSwiftUI: View, PayResultDelegate, PrintResultDelegate, CatResultDelegate {
    
    
    //swiftui 뷰가 네비게이션으로 이동되어왔기에 아래의 모드를 받아서 dismiss 해주면 이전뷰로 이동하게된다
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    //아래의 값을 체크하여 해당 값이 변하면 버튼이 눌렸다고 판단한다
    @State var isShowingViewController:Bool = false
    var mpaySdk:PaySdk = PaySdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var paylistener: payResult = payResult()
    var catlistener: CatResult = CatResult()
    var printlistener: PrintResult = PrintResult()
    var mTradeResult:DBTradeResult = DBTradeResult()
    var tradeType:String = ""
    var CancelInfo:String = ""
    var money:String = ""
    var Tax:String = ""
    var Svc:String = ""
    var Txf:String = ""
    var Inst:String = ""
    var CashTarget:String = ""
    var CashMethod:String = ""
    var CashNum:String = ""
    var 카드번호:String = ""
    var 카드종류:String = ""
    var 카드매입사:String = ""
    var 카드발급사:String = ""
    var MchNo:String = ""   //가맹점번호
    var AuDate:String = ""
    var 승인번호:String = ""
    var 코세스고유거래키:String = ""
    var 뷰컨트롤러:String = ""
    var 원거래일자:String = ""
    var 선불카드잔액:String = ""
    var 응답메세지:String = ""
    
    var 전표번호:String = ""
    
    var TID:String = "" //취소시 사용하는 DB 에 저장된 TID
    var BSN:String = ""     //사업자번호
    var StoreAddr:String = "" //가맹점주소
    var StoreName:String = "" //가맹점명
    var StoreOwner:String = "" //대표자명
    var StorePhone:String = "" //연락처
    
    //페이코데이터
    var PcKind:String = ""
    var PcCoupon:String = ""
    var PcPoint:String = ""
    var PcCard:String = ""
    
    //포인트데이터
    //서비스명
    var PtServiceName:String = ""
    //적립포인트, 가용포인트, 누적포인트, 할인율
    var PtEarnPoint:String = ""
    var PtAvailablePoint:String = ""
    var PtTotalPoint:String = ""
    var PtPercent:String = ""
    
    //멤버십데이터
    //옵션코드
    var MemberOptionCode:String = ""
    //서비스명
    var MemberServiceName:String = ""
    //할인금액, 할인후금액, 잔여포인트
    var MemberSaleMoney:String = ""
    var MemberSaleAfterMoney:String = ""
    var MemberAfterPoint:String = ""
    
    
    @State var mPrintCount:Int = 0  //프린트는 1회만 가능하다. 재출력 불가
    
    @State var printMsg:String = ""    //영수증에서 프린트 시 출력할 내용
    
    @State var mTotalMoney:Int = 0    //결제 취소시에는 총금액으로 취소를 한다.
    
    @State var mGiftView:String = ""    //선불카드잔액을 표시할지 말지를 체크한다.
    
    @State var scanTimeout:Timer?       //프린트시 타임아웃
    
    @State var isCheckCardOrQr = false   //멤버십/포인트 에서 사용하는 카드/바코드 선택 false=card true=qr
    
    mutating func setData(영수증데이터 _receipt:DBTradeResult, 상품영수증데이터 _productList:[DBProductTradeResult] = [], 뷰컨트롤러 _controller:String, 전표번호 _dbNumber:String){
        mTradeResult = _receipt
        tradeType = _receipt.getTrade()
        CancelInfo = _receipt.getCancel()
        if CancelInfo == "1" {
            money = "-" + _receipt.getMoney()
            Tax =   "-" +  _receipt.getTax()
            Svc = "-" + _receipt.getSvc()
            Txf = "-" + _receipt.getTxf()
            원거래일자 = _receipt.getOriAuDate()
        } else {
            money = _receipt.getMoney()
            Tax = _receipt.getTax()
            Svc = _receipt.getSvc()
            Txf = _receipt.getTxf()
        }
        
        응답메세지 = _receipt.getMessage()
        Inst = _receipt.getInst()
        CashTarget = _receipt.getCashTarget()
        CashMethod = _receipt.getCashMethod()
        AuDate = _receipt.getAuDate()
        //이건 카드임
        CashNum = barcodeParser(바코드:_receipt.getCashNum().replacingOccurrences(of: " ", with: ""),신용OR현금: false)
       
        MchNo = _receipt.getMchNo().replacingOccurrences(of: " ", with: "")
        카드번호 = barcodeParser(바코드: _receipt.getCardNum().replacingOccurrences(of: " ", with: ""),신용OR현금: true)
        카드종류 = _receipt.getCardType()
        카드매입사 = _receipt.getCardInpNm()
        카드발급사 = _receipt.getCardIssuer()
        승인번호 = _receipt.getAuNum()
        코세스고유거래키 = _receipt.getTradeNo()
        선불카드잔액 = _receipt.getGiftAmt()
        
        //페이코
        PcKind = _receipt.getPcKind()
        PcCoupon = _receipt.getPcCoupon()
        PcPoint = _receipt.getPcPoint()
        PcCard = _receipt.getPcCard()
        
        뷰컨트롤러 = _controller
        
        if _dbNumber != "0" {
            전표번호 = _dbNumber
        }
        
        TID = _receipt.getTid().isEmpty ? "":_receipt.getTid()
        BSN = _receipt.getStoreNumber().isEmpty ? "":_receipt.getStoreNumber()
        StoreName = _receipt.getStoreName().isEmpty ? "":_receipt.getStoreName()
        StoreOwner = _receipt.getStoreOwner().isEmpty ? "":_receipt.getStoreOwner()
        StorePhone = _receipt.getStorePhone().isEmpty ? "":_receipt.getStorePhone()
        StoreAddr = _receipt.getStoreAddr().isEmpty ? "":_receipt.getStoreAddr()
        
        self.paylistener.delegate = self
        self.catlistener.delegate = self
        
        mpaySdk.Clear()
        mCatSdk.Clear()
    }
    //TradelistController 이곳에서 값을 가져와서 셋팅한다

    func CashReciptDirectInput(CancelReason _CancelReason:String,Tid _Tid:String, AuDate _AuDate:String, AuNo _AuNo:String, Num _num:String, Command _Command:String, MchData _MchData:String, TrdAmt _TrdAmt:String, TaxAmt _TaxAmt:String, SvcAmt _SvcAmt:String, TaxFreeAmt _TaxFreeAmt:String, InsYn _InsYn:String, kocesNumber _kocesNumber:String) {
        mpaySdk.CashReciptDirectInput(CancelReason: _CancelReason, Tid: _Tid, AuDate: _AuDate, AuNo: _AuNo, Num: _num, Command: _Command, MchData: _MchData, TrdAmt: _TrdAmt, TaxAmt: _TaxAmt, SvcAmt: _SvcAmt, TaxFreeAmt: _TaxFreeAmt, InsYn: _InsYn, kocesNumber: _kocesNumber, payLinstener: paylistener.delegate!,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, Products: [])

    }
    
    func startPayment(Tid _Tid:String,Money _money:String,Tax _tax:Int,ServiceCharge _serviceCharge:Int,TaxFree _txf:Int,InstallMent _installment:String,OriDate _oriDate:String,
                      CancenInfo _cancelInfo:String,mchData _mchData:String,KocesTreadeCode _kocesTradeCode:String,CompCode _compCode:String) {
        mpaySdk.CreditIC(Tid: _Tid, Money: _money, Tax: _tax, ServiceCharge: _serviceCharge, TaxFree: _txf, InstallMent: _installment, OriDate: _oriDate, CancenInfo: _cancelInfo, mchData: _mchData, KocesTreadeCode: _kocesTradeCode, CompCode: _compCode, SignDraw: "1", FallBackUse: "0",payLinstener: paylistener.delegate!,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, Products: [])
    }

    
    func onPaymentResult(payTitle _status: payStatus, payResult _message: Dictionary<String, String>) {
        var _totalString:String = ""
        var _title:String = "거래[불가]"  
        var keyCount:Int = 0
        switch _message["TrdType"] {
        case Command.CMD_CASH_RECEIPT_CANCEL_RES:
            _title = "현금[취소]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        case Command.CMD_IC_CANCEL_RES:
            _title = "신용[취소]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        case Command.CMD_POINT_USE_CANCEL_RES:
            _title = "포인트사용[취소]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        case Command.CMD_POINT_EARN_CANCEL_RES:
            _title = "포인트적립[취소]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        case Command.CMD_MEMBER_CANCEL_RES:
            _title = "멤버십[취소]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        default:
            break
        }

        // 카드애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CardAnimationViewControllerClear()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            //거래상세내역에서 거래내역뷰로 돌아간다
            if _status == .OK {
                Utils.customAlertBoxInit(Title: _title, Message: "정상적으로 취소처리 되었습니다", LoadingBar: false, GetButton: "확인")
            }
            else {
                Utils.customAlertBoxInit(Title: _title, Message: _message["Message"] ?? _message["ERROR"] ?? "거래실패", LoadingBar: false, GetButton: "확인")
            }
        }
        
        mpaySdk.Clear()
        mCatSdk.Clear()
    }
    
    
    
    func getTotalMoney(_money:Int,_tax:Int,_Svc:Int,_Txf:Int) -> Int {
        var TotalMoney:Int = _money + _tax + _Svc
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            TotalMoney = _money + _tax + _Svc + _Txf
        }
        return TotalMoney
    }
    
    var body: some View {
        Group{  //공통
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: nil, content: {
                if Utils.PrintDeviceCheck().isEmpty {
                    if Setting.shared.getDefaultUserData(_key: define.PRINT_CUSTOMER) == "PRINT_CUSTOMER" && 뷰컨트롤러 != "거래내역" {
                        if mPrintCount == 0 {   //프린트 버튼은 한번만 보이게 처리 한다.
                            Spacer()
                            Button(action: {
                                mPrintCount += 1
                                Utils.CatAnimationViewInitClear()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    PrintReceiptInit()
                                }

                            }, label: {
                                Text("출력")
                            }).buttonStyle(SwiftUIButton())
                        }
                    }
                    else if 뷰컨트롤러 == "거래내역" {
                        Spacer()
                        Button(action: {
                            Utils.CatAnimationViewInitClear()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                PrintReceiptInit()
                            }

                        }, label: {
                            Text("출력")
                        }).buttonStyle(SwiftUIButton())
                    }
                }
                Spacer()
                Button("저장") {
                    let image = receiptView.snapshot()
                    let imageAlbum = ImageSaveAlbum()
                    imageAlbum.saveImageAlbum(Image: image)
                }.buttonStyle(SwiftUIButton())
                Spacer()
                if 뷰컨트롤러 == "거래내역"{
                    if CancelInfo == define.TradeMethod.NoCancel.rawValue {
                        
                        Button(action: {
                            AlertBox()
                        }) {
                            Text("취소")
                        }.buttonStyle(SwiftUIButton())
                        Spacer()
                    }

                } else {
                    //신용/현금에서 온경우
                    Button(action: {
                        GoToMain()
                    }) {
                        Text("닫기")
                    }.buttonStyle(SwiftUIButton())
                    Spacer()
                }
              
            }).padding()
            .onAppear(perform: {
                if Utils.PrintDeviceCheck().isEmpty {
                    //거래내역에서 올라왔을 때는 자동출력하지 않는다
                    if 뷰컨트롤러 != "거래내역" {
                        //할부개월이 있을 경우 전표기능과 무관하게 자동출력한다
                        if tradeType == define.TradeMethod.Credit.rawValue || tradeType == define.TradeMethod.CAT_Credit.rawValue {
                            if Inst != "0" && !Inst.isEmpty {
                                mPrintCount += 1
                                Utils.CatAnimationViewInitClear()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    PrintReceiptInit()
                                }
                            }
                        }
                    }
                }
            })
            HStack{
                if UIDevice.current.userInterfaceIdiom != .phone {
                    VStack(spacing: nil, content: {
                        Spacer()
                    }).padding(25)
                }
                VStack{
                    receiptView
                }
                if UIDevice.current.userInterfaceIdiom != .phone {
                    VStack(spacing: nil, content: {
                        Spacer()
                    }).padding(25)
                }
            }
            if 뷰컨트롤러 == "거래내역"{
                if CancelInfo == define.TradeMethod.NoCancel.rawValue {
                    HStack{
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            VStack(spacing: nil, content: {
                               
                            }).padding(25)
                        }
                        VStack{
                            Toggle("카드/바코드 사용", isOn: $isCheckCardOrQr)
                        }
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            VStack(spacing: nil, content: {
                               
                            }).padding(25)
                        }
                    }
                }

            }
        }
    }
    
    var receiptView: some View {
        Group {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 30, content: {
                // 신용승인/신용취소/현금승인/현금취소 총4개로 구분지어서 파싱한다
                if tradeType == define.TradeMethod.Credit.rawValue || tradeType == define.TradeMethod.CAT_Credit.rawValue {
                    //신용매출
                    if CancelInfo == "1" {
                        Text("카드취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("카드승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                } else if tradeType == define.TradeMethod.CAT_App.rawValue ||
                            tradeType == define.TradeMethod.CAT_We.rawValue ||
                            tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                            tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                            tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                            tradeType == define.TradeMethod.CAT_Payco.rawValue {
                    //간편매출
                    if CancelInfo == "1" {
                        Text("간편취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("간편승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                } else if tradeType == define.TradeMethod.CAT_CashIC.rawValue  {
                    //현금IC
                    if CancelInfo == "1" {
                        Text("현금IC취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("현금IC승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                } else if tradeType == define.TradeMethod.Point_Redeem.rawValue  {
                    //포인트사용
                    if CancelInfo == "1" {
                        Text("포인트사용취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("포인트사용승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                } else if tradeType == define.TradeMethod.Point_Reward.rawValue  {
                    //포인트적립
                    if CancelInfo == "1" {
                        Text("포인트적립취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("포인트적립승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                } else if tradeType == define.TradeMethod.MemberShip.rawValue  {
                    //멤버십
                    if CancelInfo == "1" {
                        Text("멤버십취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("멤버십승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                } else {
                    //현금매출
                    if CancelInfo == "1" {
                        Text("현금취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    } else {
                        Text("현금승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                    }
                }
            }).padding()
            ScrollView{
                Group{
                    //전표번호(로컬DB에 저장되어 있는 거래내역리스트의 번호) + 전표출력일시
                    HStack{
                        Text("No." + Utils.leftPad(str: 전표번호, fillChar: "0", length: 6))
                        Spacer()
                        Text(titleDateParser())
                    }.padding(.horizontal,20)
                    //-------------
                    VStack{
                        Spacer()
                        Divider()
                        Spacer()
                    }
                }
                Group{
                    //가맹점명
                    HStack{
                        Text("가맹점명")
                        Spacer()
                        Text(StoreName.replacingOccurrences(of: " ", with: ""))
                    }.padding(.horizontal,20)
                    // 사업자번호
                    HStack{
                        Text("사업자번호")
                        Spacer()
                        Text(bsnParser())
                    }.padding(.horizontal,20)
                    //대표자명
                    HStack{
                        Text("대표자명")
                        Spacer()
                        Text(StoreOwner.replacingOccurrences(of: " ", with: ""))
                    }.padding(.horizontal,20)
                    //연락처
                    HStack{
                        Text("연락처")
                        Spacer()
                        Text(phoneParser())
                    }.padding(.horizontal,20)
                    //TID
                    HStack{
                        Text("단말기ID")
                        Spacer()
                        Text(tidParser())
                    }.padding(.horizontal,20)
                    //주소
                    HStack{
                        Text("주소")
                        Spacer()
                        Text(StoreAddr)
                    }.padding(.horizontal,20)
                    //-------------
                    VStack{
                        Spacer()
                        Divider()
                        Spacer()
                    }
                }
                Group{
                    if !카드매입사.isEmpty{
                        //매입사명
                        HStack{
                            Text("매입사명")
                            Spacer()
                            Text(카드매입사.replacingOccurrences(of: " ", with: ""))
                        }.padding(.horizontal,20)
                        
                    }
                    if !카드발급사.isEmpty {
                        //카드종류
                        HStack{
                            Text("발급사명")
                            Spacer()
                            Text(카드발급사.replacingOccurrences(of: " ", with: ""))
                        }.padding(.horizontal,20)
                        
                    }
                    //카드번호
                    if tradeType == define.TradeMethod.Credit.rawValue || tradeType == define.TradeMethod.CAT_Credit.rawValue {
                        if !카드번호.isEmpty {
                            HStack{
                                Text("카드번호")
                                Spacer()
                                Text(카드번호)
                            }.padding(.horizontal,20)
                        }
                   
                    } else if tradeType == define.TradeMethod.CAT_App.rawValue  ||
                                tradeType == define.TradeMethod.CAT_We.rawValue ||
                                tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                                tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                                tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                                tradeType == define.TradeMethod.CAT_Payco.rawValue {
                        if !카드번호.isEmpty {
                            HStack{
                                Text("고객번호")
                                Spacer()
                                Text(카드번호)
                            }.padding(.horizontal,20)
                        }
                
                    } else if tradeType == define.TradeMethod.Point_Redeem.rawValue  {
                        //포인트사용
                        if !카드번호.isEmpty {
                            HStack{
                                Text("카드번호")
                                Spacer()
                                Text(카드번호)
                            }.padding(.horizontal,20)
                        }
                    } else if tradeType == define.TradeMethod.Point_Reward.rawValue  {
                        //포인트적립
                        if !카드번호.isEmpty {
                            HStack{
                                Text("카드번호")
                                Spacer()
                                Text(카드번호)
                            }.padding(.horizontal,20)
                        }
                    } else if tradeType == define.TradeMethod.MemberShip.rawValue  {
                        //멤버십
                        if !카드번호.isEmpty {
                            HStack{
                                Text("카드번호")
                                Spacer()
                                Text(카드번호)
                            }.padding(.horizontal,20)
                        }
                    } else {
                        if !CashNum.isEmpty {
                            HStack{
                                Text("고객번호")
                                Spacer()
                                Text(CashNum.replacingOccurrences(of: " ", with: ""))
                            }.padding(.horizontal,20)
                        }
                  
                    }
                    //승인일시
                    HStack{
                        Text("승인일시")
                        Spacer()
                        Text(dateParser())
                    }.padding(.horizontal,20)
                    //만약 취소 시에는 여기에서 원거래일자를 삽입해야 한다. 결국 sqlLITE 에 원거래일자 항목을 하나 만들어서 취소시에는 원거래일자에 승인일자를 삽입해야 한다.
                    if CancelInfo == "1" {
                        HStack{
                            Text("원거래일")
                            Spacer()
                            Text(oriDateParser())
                        }.padding(.horizontal,20)
                    }
                    //승인번호 할부개월
                    if tradeType == define.TradeMethod.Credit.rawValue ||
                        tradeType == define.TradeMethod.CAT_Credit.rawValue ||
                        tradeType == define.TradeMethod.CAT_App.rawValue  ||
                        tradeType == define.TradeMethod.CAT_We.rawValue ||
                        tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                        tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                        tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                        tradeType == define.TradeMethod.CAT_Payco.rawValue {
                        HStack{
                            Text("할부개월")
                            Spacer()
                            Text(installmentParser())
                        }.padding(.horizontal,20)
                    }
                    HStack{
                        Text("승인번호")
                        Spacer()
                        Text(승인번호.replacingOccurrences(of: " ", with: ""))
                    }.padding(.horizontal,20)
                    //가맹점번호
                    if !MchNo.isEmpty {
                        HStack{
                            Text("가맹점번호")
                            Spacer()
                            Text(MchNo.replacingOccurrences(of: " ", with: ""))
                        }.padding(.horizontal,20)
                    }
                    //-------------
                    VStack{
                        Spacer()
                        Divider()
                        Spacer()
                    }
                }
                Group{
                    //공급가액
                    HStack{
                        Text("공급가액")
                        Spacer()
                        var correctMoney:Int = KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED ? Int(money)!:Int(money)! - Int(Txf)!

                        Text(Utils.PrintMoney(Money: String(correctMoney) == "-0" ? "0":String(correctMoney)) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                    }.padding(.horizontal,20)
                    //부가세
                    HStack{
                        Text("부가세")
                        Spacer()
                        Text(Utils.PrintMoney(Money: Tax == "-0" ? "0":Tax) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                    }.padding(.horizontal,20)
                    //봉사료
                    if !Svc.isEmpty && Svc != "0" && Svc != "-0" {
                        HStack{
                            Text("봉사료")
                            Spacer()
                            Text(Utils.PrintMoney(Money: Svc) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                        }.padding(.horizontal,20)
                    }
                    //비과세
                    if !Txf.isEmpty && Txf != "0" && Txf != "-0" {
                        HStack{
                            Text("비과세")
                            Spacer()
                            Text(Utils.PrintMoney(Money: Txf) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                        }.padding(.horizontal,20)
                    }
                    if tradeType == define.TradeMethod.CAT_Payco.rawValue {
                        if !PcCoupon.isEmpty && PcCoupon != "0" {
                            HStack{
                                Text("페이코쿠폰")
                                Spacer()
                                Text(Utils.PrintMoney(Money: (PcCoupon.isEmpty ? "0":PcCoupon).filter{$0.isNumber}) + " 원")
                            }.padding(.horizontal,20)
                        }
                        if !PcPoint.isEmpty && PcPoint != "0" {
                            HStack{
                                Text("페이코포인트")
                                Spacer()
                                Text(Utils.PrintMoney(Money: (PcPoint.isEmpty ? "0":PcPoint).filter{$0.isNumber}) + " 원")
                            }.padding(.horizontal,20)
                        }
                        if !PcCard.isEmpty && PcCard != "0" {
                            HStack{
                                Text("페이코카드")
                                Spacer()
                                Text(Utils.PrintMoney(Money: (PcCard.isEmpty ? "0":PcCard).filter{$0.isNumber}) + " 원")
                            }.padding(.horizontal,20)
                        }
                    }
                    //결제금액
                    HStack{
                        Text("결제금액").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 20))
                        Spacer()
                        Text(Utils.PrintMoney(Money: "\(getTotalMoney(_money: Int(money)!, _tax: Int(Tax)!, _Svc: Int(Svc)!, _Txf:Int(Txf)!))") + " 원").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 20)).foregroundColor(CancelInfo == "1" ? .red : .black)
                    }.padding(.horizontal,20)
                    //기프트카드 잔액
                    if 카드종류.contains("3") || 카드종류.contains("4") {
                        HStack{
                            Text("기프트카드잔액")
                            Spacer()
                            Text(Utils.PrintMoney(Money: 선불카드잔액.filter{$0.isNumber}) + " 원")
                        }.padding(.horizontal,20)
                    }

                }
                Group{
                    //-------------
                    VStack{
                        Spacer()
                        Divider()
                        Spacer()
                    }
                    //응답메시지
                    HStack{
                        Text("메세지 " + 응답메세지)
                        Spacer()
                    }.padding(.horizontal,20)
                    
                    //실제앱에 저장되어있는 추가메시지
                    if !Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
                        HStack{
                            Text(Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL))
                            Spacer()
                        }.padding(.horizontal,20)
                    }
                }
                
                Group{
                    //-------------
                    VStack{
                        Spacer()
                        Spacer()
                        Spacer()
                    }

                }

            }
        }
    }

    //할부를 0-> 일시불, 개월 로 수정
    func installmentParser() -> String{
        var InstString:String = ""
        if Inst == "" {
            return InstString
        }
        if Inst == "0" {
            InstString = "(일시불)"
        } else {
            InstString = Inst + " 개월"
        }
        return InstString
    }
    
    //거래일자를 프린트용으로 파싱
    func dateParser() -> String {
        let auchars:[Character] = Array(AuDate)
        var dateString:String = ""
        if AuDate.count > 10 {
            dateString = String(auchars[0...1]) + "/" + String(auchars[2...3]) + "/" + String(auchars[4...5]) + " " +
                String(auchars[6...7]) + ":" + String(auchars[8...9]) + ":" + String(auchars[10...])
        } else {
            dateString = AuDate
        }
        return dateString
    }
    
    //원거래일자를 프린트용으로 파싱
    func oriDateParser() -> String {
        let auchars:[Character] = Array(원거래일자)
        var dateString:String = ""
        if 원거래일자.count >= 6 {
            dateString = String(auchars[0...1]) + "/" + String(auchars[2...3]) + "/" + String(auchars[4...5])

        } else {
            dateString = 원거래일자
        }
        return dateString
    }
    
    //타이틀의 옆에 나오는 (현재시간)
    func titleDateParser() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yy/MM/dd HH:mm:ss"
     
        let currentDate:String = dateFormatter.string(from: Date())
        let dateString:String = currentDate
        return dateString
    }
    
    // _check = true 신용, false=현금
    func barcodeParser(바코드 _printBarcd:String,신용OR현금 _check:Bool) -> String {
        var _barcd:String = ""
        //만일 90일이 지난 거래라면 여기서 다시 한번 재마스킹처리한다
        if tradeType.contains("간편") {
            _barcd = Utils.EasyParser(바코드qr번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: AuDate))
        } else if tradeType.contains("현금IC") {
            _barcd = _printBarcd
        } else {
            if _check {
                _barcd = Utils.CardParser(카드번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: AuDate))
            } else {
                _barcd = Utils.CashParser(현금영수증번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: AuDate))
            }
        }

        return _barcd
    }
    
    //사업자번호의 중간에 - 를 넣는다
    func bsnParser() -> String {
        let bsnchars:[Character] = Array(BSN.replacingOccurrences(of: " ", with: ""))
        var _bsn:String = ""
        if bsnchars.count > 9 {
            _bsn = String(bsnchars[0...2]) + "-" + String(bsnchars[3...4]) + "-" + String(bsnchars[5...])
        } else {
            _bsn = BSN.replacingOccurrences(of: " ", with: "")
        }
        return _bsn
    }
    //전화번호 중간에 - 를 넣는다
    func phoneParser() -> String {
        let telchars:[Character] = Array(StorePhone.replacingOccurrences(of: " ", with: ""))
        var _tel:String = ""
        if telchars.count == 9 {
            _tel = String(telchars[0...1]) + "-" + String(telchars[2...4]) + "-" + String(telchars[5...8])
        } else if telchars.count == 10 {
            _tel = String(telchars[0...1]) + "-" + String(telchars[2...5]) + "-" + String(telchars[6...9])
        } else if telchars.count == 11 {
            _tel = String(telchars[0...2]) + "-" + String(telchars[3...6]) + "-" + String(telchars[7...10])
        } else {
            _tel = StorePhone.replacingOccurrences(of: " ", with: "")
        }
        return _tel
    }
    
    //프린트에 TID 앞에 *** 를 넣는다
    func tidParser() -> String {
        let tidchars:[Character] = Array(TID.replacingOccurrences(of: " ", with: ""))
        var _tid:String = ""
        if tidchars.count > 3 {
            _tid = "***" + String(tidchars[3...])
        }
 
        return _tid
    }
    
    //문장에 스페이스바패딩이 되어있다면 제거한다
    func spaceReplace(Message _msg:String) -> String {
        var _spaceReplace = ""
        _spaceReplace = _msg.replacingOccurrences(of: " ", with: "")
        return _spaceReplace
    }

    //프린트 할 문장 전체 파싱
    func PrintReceiptInit() {
        //ble장치가 연결 되어 있는지 없는지 확인 한다.
        if mKocesSdk.blePrintState == define.PrintDeviceState.BLENOPRINT {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"), preferredStyle: UIAlertController.Style.alert)
            let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
            return
        }
        
        //cat 연동일 경우
        if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
            if Utils.CheckPrintCatPortIP() != "" {
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: Utils.CheckPrintCatPortIP(), preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if !Utils.PrintDeviceCheck().isEmpty {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "에러", message: "출력 가능 장치 없음", preferredStyle: UIAlertController.Style.alert)
            let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
            return
        }
        
        Utils.printAlertBox(Title: "프린트 출력중입니다", LoadingBar: true, GetButton: "")

        // 신용승인/신용취소/현금승인/현금취소 총4개로 구분지어서 파싱한다
        if tradeType == define.TradeMethod.Credit.rawValue || tradeType == define.TradeMethod.CAT_Credit.rawValue {
            //신용매출
            if CancelInfo == "1" {
                printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "카드취소")) + define.PENTER)
            } else {
                printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "카드승인")) + define.PENTER)
            }
        } else if tradeType == define.TradeMethod.CAT_App.rawValue   ||
                    tradeType == define.TradeMethod.CAT_We.rawValue ||
                    tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                    tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                    tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                    tradeType == define.TradeMethod.CAT_Payco.rawValue  {
            //간편매출
            if CancelInfo == "1" {
                printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "간편취소")) + define.PENTER)
            } else {
                printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "간편승인")) + define.PENTER)
            }
        } else {
            //현금매출
            if CancelInfo == "1" {
                printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "현금취소")) + define.PENTER)
            } else {
                printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "현금승인")) + define.PENTER)
            }
        }
        
        //전표번호(로컬DB에 저장되어 있는 거래내역리스트의 번호) + 전표출력일시
        printParser(프린트메세지: Utils.PrintPad(leftString: "No." + Utils.leftPad(str: 전표번호, fillChar: "0", length: 6), rightString: titleDateParser()) + define.PENTER)
        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        //가맹점명
        printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점명", rightString: StoreName.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        //대표자명 사업자번호 연락처
        printParser(프린트메세지: Utils.PrintPad(leftString: "대표자명", rightString: StoreOwner.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        printParser(프린트메세지: Utils.PrintPad(leftString: "사업자번호", rightString: bsnParser()) + define.PENTER)
        printParser(프린트메세지: Utils.PrintPad(leftString: "연락처", rightString: phoneParser()) + define.PENTER)
        
        //단말기TID
        printParser(프린트메세지: Utils.PrintPad(leftString: "단말기ID", rightString:  tidParser()) + define.PENTER)
        //주소
        printParser(프린트메세지: Utils.PrintPad(leftString: "주소  ", rightString: StoreAddr) + define.PENTER)
        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)

        if !카드매입사.isEmpty {
            //매입사명
            printParser(프린트메세지: Utils.PrintPad(leftString: "매입사명", rightString: 카드매입사.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }
        if !카드발급사.isEmpty {
            //카드종류
            printParser(프린트메세지: Utils.PrintPad(leftString: "발급사명", rightString: 카드발급사.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }
        //카드번호
        if tradeType == define.TradeMethod.Credit.rawValue || tradeType == define.TradeMethod.CAT_Credit.rawValue {
            if !카드번호.isEmpty {
                printParser(프린트메세지: Utils.PrintPad(leftString: "카드번호", rightString: 카드번호) + define.PENTER)
            }
        
        } else if tradeType == define.TradeMethod.CAT_App.rawValue  ||
                    tradeType == define.TradeMethod.CAT_We.rawValue ||
                    tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                    tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                    tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                    tradeType == define.TradeMethod.CAT_Payco.rawValue  {
            if !카드번호.isEmpty {
                printParser(프린트메세지: Utils.PrintPad(leftString: "카드번호", rightString: 카드번호) + define.PENTER)
            }
      
        } else {
            if !CashNum.isEmpty {
                printParser(프린트메세지: Utils.PrintPad(leftString: "고객번호", rightString: CashNum.replacingOccurrences(of: " ", with: "")) + define.PENTER)
            }

        }
        //승인일시
        printParser(프린트메세지: Utils.PrintPad(leftString: "승인일시", rightString: dateParser())  + define.PENTER)
        //만약 취소 시에는 여기에서 원거래일자를 삽입해야 한다. 결국 sqlLITE 에 원거래일자 항목을 하나 만들어서 취소시에는 원거래일자에 승인일자를 삽입해야 한다.
        if CancelInfo == "1" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "원거래일", rightString: oriDateParser()) + define.PENTER)
        }
        
        if tradeType == define.TradeMethod.Credit.rawValue ||
            tradeType == define.TradeMethod.CAT_Credit.rawValue ||
            tradeType == define.TradeMethod.CAT_App.rawValue  ||
            tradeType == define.TradeMethod.CAT_We.rawValue ||
            tradeType == define.TradeMethod.CAT_Ali.rawValue ||
            tradeType == define.TradeMethod.CAT_Zero.rawValue ||
            tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
            tradeType == define.TradeMethod.CAT_Payco.rawValue
        {
            //승인번호 할부개월
            printParser(프린트메세지: Utils.PrintPad(leftString: "할부개월", rightString: installmentParser()) + define.PENTER)
        }
        //승인번호
        printParser(프린트메세지: Utils.PrintPad(leftString: "승인번호", rightString: 승인번호.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        if !MchNo.isEmpty {
            //가맹점번호
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점번호", rightString: MchNo.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }
        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        //공급가액
        var correctMoney:Int = 0
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED
        {
            correctMoney = Int(money)!
        }
        else
        {
            correctMoney = Int(money)! - Int(Txf)!
        }
        printParser(프린트메세지: Utils.PrintPad(leftString: "공급가액", rightString: Utils.PrintMoney(Money: String(correctMoney) == "-0" ? "0":String(correctMoney)) + "원") + define.PENTER)
        //부가세
        printParser(프린트메세지: Utils.PrintPad(leftString: "부가세", rightString: Utils.PrintMoney(Money: Tax == "-0" ? "0":Tax) + "원") + define.PENTER)
        //봉사료
        if !Svc.isEmpty && Svc != "0" && Svc != "-0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "봉사료", rightString: Utils.PrintMoney(Money: Svc) + "원") + define.PENTER)
        }
        //비과세
        if !Txf.isEmpty && Txf != "0" && Txf != "-0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "비과세", rightString: Utils.PrintMoney(Money: Txf) + "원") + define.PENTER)
        }
        
        if tradeType == define.TradeMethod.CAT_Payco.rawValue {
//            if !PcKind.isEmpty {
//                printParser(프린트메세지: Utils.PrintPad(leftString: "페이코종류", rightString: PcKind.replacingOccurrences(of: " ", with: "")) + define.PENTER)
//            }
            if !PcCoupon.isEmpty && PcCoupon != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "페이코쿠폰", rightString: Utils.PrintMoney(Money: PcCoupon.isEmpty ? "0":PcCoupon) + "원") + define.PENTER)
            }
            if !PcPoint.isEmpty && PcPoint != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "페이코포인트", rightString: Utils.PrintMoney(Money: PcPoint.isEmpty ? "0":PcPoint) + "원") + define.PENTER)
            }
            if !PcCard.isEmpty && PcCard != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "페이코카드", rightString: Utils.PrintMoney(Money: PcCard.isEmpty ? "0":PcCard) + "원") + define.PENTER)
            }
        }
        
        //결제금액
        let _totalMoney:String = "\(getTotalMoney(_money: Int(money)!, _tax: Int(Tax)!, _Svc: Int(Svc)!, _Txf:Int(Txf)!))"
 
        printParser(프린트메세지: Utils.PrintPad(leftString: Utils.PrintBold(_bold: "결제금액") , rightString: Utils.PrintBold(_bold: Utils.PrintMoney(Money: _totalMoney) + "원")) + define.PENTER)
//        printParser(프린트메세지: Utils.PrintPadBold(leftString: "결제금액" , rightString: Utils.PrintMoney(Money: _totalMoney) + "원") + define.PENTER)
        //기프트카드 잔액
        if 카드종류.contains("3") || 카드종류.contains("4") {
            printParser(프린트메세지: Utils.PrintPad(leftString: "기프트카드잔액", rightString: Utils.PrintMoney(Money: 선불카드잔액.filter{$0.isNumber}) + "원") + define.PENTER)
        }
        
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)

        printParser(프린트메세지: "메세지 " + 응답메세지 + define.PENTER)

        PrintReceipt(프린트메세지: printMsg)

    }
    
    //개개 메세지 한줄씩 파싱
    func printParser(프린트메세지 _msg:String) {
        self.printMsg += _msg
    }
    
    //영수증을 프린터로 출력한다
    func PrintReceipt(프린트메세지 _msg:String) {
 
        var _totalMsg:String = ""
        _totalMsg += _msg
        if !Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
            _totalMsg += (define.PLEFT + Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL) + define.PENTER)
        }

        let prtStr = KocesSdk.instance.PrintParser(파싱할프린트내용: _totalMsg)
        //프린트 타임아웃 체크
        printTimeOut()
        self.catlistener.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if mKocesSdk.blePrintState == define.PrintDeviceState.BLEUSEPRINT {
                self.printlistener.delegate = self
                KocesSdk.instance.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                
                KocesSdk.instance.BlePrinter(내용: prtStr, CallbackListener: self.printlistener.delegate!)
            } else if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                CatSdk.instance.Print(파싱할프린트내용: prtStr, CompletionCallback: self.catlistener.delegate!)
            }
          
            self.printMsg = ""
        }
        return
    }
    
    func printTimeOut() {
        self.scanTimeout = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { timer in
            var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
            resDataDic["Message"] = NSString("프린트를 실패(타임아웃)하였습니다") as String
            onPrintResult(printStatus: .OK, printResult: resDataDic)
            self.scanTimeout?.invalidate()
            self.scanTimeout = nil
        })
    }
    
    func onResult(CatState _state: payStatus, Result _message: Dictionary<String, String>) {
        Utils.CatAnimationViewInitClear()
        let _msg:String = _message["Message"] ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            //거래상세내역에서 거래내역뷰로 돌아간다
            if _msg.contains("프린트") {
                self.scanTimeout?.invalidate()
                self.scanTimeout = nil
                Utils.customAlertBoxClear()

                if _state == .OK {
//                    Utils.customAlertBoxInit(Title: "프린트", Message: "정상적으로 취소처리 되었습니다", LoadingBar: false, GetButton: "확인")

                } else {
                    Utils.customAlertBoxInit(Title: "프린트", Message:_message["Message"] ?? _message["ERROR"] ?? "프린트 실패", LoadingBar: false, GetButton: "확인")
                    mPrintCount = 0
                }
                return
            }
            // 0=성공, 1=실패
            if _state == .OK {
                Utils.customAlertBoxInit(Title: "CAT거래[취소]", Message: "정상적으로 취소처리 되었습니다", LoadingBar: false, GetButton: "확인")

            } else {
                Utils.customAlertBoxInit(Title: "CAT거래[취소]", Message:_message["Message"] ?? _message["ERROR"] ?? "거래실패", LoadingBar: false, GetButton: "확인")
                
            }

        }
        
        mpaySdk.Clear()
        mCatSdk.Clear()
    }
    
    func onPrintResult(printStatus _status: printStatus, printResult _result: Dictionary<String, String>) {
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        Utils.customAlertBoxClear()

        if (_result["Message"] ?? "").contains("완료") {
            
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "프린트결과", message: _result["Message"] ?? "프린트에 실패하였습니다", preferredStyle: .alert)
            let btnOk = UIAlertAction(title: "확인", style: .default) { _ in
//                mPrintCount = 0
            }
            mPrintCount = 0
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
        }
        
        mpaySdk.Clear()
        mCatSdk.Clear()
    }

    //신용/현금에서 왔을 경우 버튼으로 메인화면으로 나간다. 혹은 해당신용/현금으로 이동?
    func GoToMain() {
        let controller = Utils.topMostViewController()
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar") as? TabBarController
        mainTabBarController?.modalPresentationStyle = .fullScreen
        if 뷰컨트롤러 == "신용" {
            mainTabBarController?.selectedIndex = 0
            controller?.present(mainTabBarController!, animated: true, completion: nil)
        } else if 뷰컨트롤러 == "현금" {
            mainTabBarController?.selectedIndex = 0
            controller?.present(mainTabBarController!, animated: true, completion: nil)
        } else {
            mainTabBarController?.selectedIndex = 0
            controller?.present(mainTabBarController!, animated: true, completion: nil)
        }
    }
    
    //메세지박스만들기 tradeType = "신용" or "현금"
    func AlertBox() {
        self.paylistener.delegate = self
        self.catlistener.delegate = self
        //스위프트UI 에서 기존의 UIAlertController 를 사용하기 위해서 현재 최상위에 띄워진 뷰컨트롤러를 받아와야 한다
        let controller = Utils.topMostViewController()
        var 타이틀 = ""
        let 메세지 = "취소결제를 진행하시겠습니까?"
        if tradeType == define.TradeMethod.Credit.rawValue || tradeType == define.TradeMethod.CAT_Credit.rawValue {
            타이틀 = "신용취소"
        } else if tradeType == define.TradeMethod.CAT_App.rawValue  ||
                    tradeType == define.TradeMethod.CAT_We.rawValue ||
                    tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                    tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                    tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                    tradeType == define.TradeMethod.CAT_Payco.rawValue  {
            타이틀 = "간편취소"
        } else if tradeType == define.TradeMethod.Point_Redeem.rawValue  {
            //포인트사용
            타이틀 = "포인트사용취소"
        } else if tradeType == define.TradeMethod.Point_Reward.rawValue  {
            //포인트적립
            타이틀 = "포인트적립취소"
        } else if tradeType == define.TradeMethod.MemberShip.rawValue  {
            //멤버십
            타이틀 = "멤버십취소"
        } else {
            // CashTarget = 1:개인 2:사업자 3:자진발급
            타이틀 = "현금취소"
        }
        let alert = UIAlertController(title: 타이틀, message: 메세지, preferredStyle: UIAlertController.Style.alert)
        
        //현금인경우 msr 인지 체크한다
        switch CashMethod {
        case define.TradeMethod.CashMs.rawValue:
            if tradeType == define.TradeMethod.Cash.rawValue {
                CashCancel(cashNumber: "")
                return
            }
            break
        case define.TradeMethod.CashDirect.rawValue:
            //현금이면 번호를 입력받는 구간을 만든다. 그러나 자진발급인 경우 번호를 입력받지 않는다
            switch CashTarget {
            case define.TradeMethod.CashPrivate.rawValue://개인
                alert.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = "개인(전화번호)를 입력해주세요"
                    textField.keyboardType = .numberPad
                    textField.isSecureTextEntry = true
                })
                break
            case define.TradeMethod.CashBusiness.rawValue://사업자
                alert.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = "사업자번호를 입력해주세요"
                    textField.keyboardType = .numberPad
                    textField.isSecureTextEntry = true
                })
                break
            case define.TradeMethod.CashSelf.rawValue://자진발급
                CashCancel(cashNumber: "0100001234")
                return
            default://신용
                break
            }
            break
        default:
            break
        }
        
        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {(ACTION) in
            if tradeType == define.TradeMethod.Credit.rawValue {
                //신용
                CreditCancel()
                return
            } else if tradeType == define.TradeMethod.CAT_Credit.rawValue {
                //캣신용취소
                mCatSdk.PayCredit(TID: TID, 거래금액: money, 세금: Tax, 봉사료: Svc, 비과세: Txf, 원거래일자: String("20" + AuDate.replacingOccurrences(of: " ", with: "").prefix(6)), 원승인번호: 승인번호.replacingOccurrences(of: " ", with: ""), 코세스거래고유번호: "", 할부: Inst, 취소: true, 가맹점데이터: "", 여유필드: "", StoreName: StoreName, StoreAddr: StoreAddr, StoreNumber: BSN, StorePhone: StorePhone, StoreOwner: StoreOwner,CompletionCallback: catlistener.delegate!, Products: [])
                return
            } else if tradeType == define.TradeMethod.CAT_Cash.rawValue {
                //캣현금취소
                var _개인법인구분 = ""
                switch CashTarget {
                case define.TradeMethod.CashPrivate.rawValue://개인
                    _개인법인구분 = "1"

                    break
                case define.TradeMethod.CashBusiness.rawValue://사업자
                    _개인법인구분 = "2"

                    break
                case define.TradeMethod.CashSelf.rawValue://자진발급
                    _개인법인구분 = "3"

                    break
                default://신용
                    _개인법인구분 = ""
                    break
                }
                var _number = ""
                if CashMethod != define.TradeMethod.CashMs.rawValue {
                    _number = alert.textFields?[0].text ?? ""
                    if _number.isEmpty == true {
                        _number = ""
                    }
                }
               
                mCatSdk.CashRecipt(TID: TID, 거래금액: money, 세금: Tax, 봉사료: Svc, 비과세: Txf, 원거래일자: String("20" + AuDate.replacingOccurrences(of: " ", with: "").prefix(6)), 원승인번호: 승인번호.replacingOccurrences(of: " ", with: ""), 코세스거래고유번호: "", 할부: "", 고객번호: _number, 개인법인구분: _개인법인구분, 취소: true, 최소사유: "1", 가맹점데이터: "", 여유필드: "", StoreName: StoreName, StoreAddr: StoreAddr, StoreNumber: BSN, StorePhone: StorePhone, StoreOwner: StoreOwner,CompletionCallback: catlistener.delegate!, Products: [])
                return
            } else if tradeType == define.TradeMethod.CAT_CashIC.rawValue {
                //캣현금IC취소
                mCatSdk.CashIC(업무구분: define.CashICBusinessClassification.Cancel, TID: TID, 거래금액: money, 세금: Tax, 봉사료: Svc, 비과세: Txf, 원거래일자: String(AuDate.replacingOccurrences(of: " ", with: "").prefix(6)), 원승인번호: 승인번호, 간소화거래여부: "0", 카드정보수록여부: "0", 취소: true, 가맹점데이터: "", 여유필드: "", StoreName: StoreName, StoreAddr: StoreAddr, StoreNumber: BSN, StorePhone: StorePhone, StoreOwner: StoreOwner,CompletionCallback: catlistener.delegate!, Products: [])
                return
            } else if tradeType == define.TradeMethod.CAT_App.rawValue  ||
                        tradeType == define.TradeMethod.CAT_We.rawValue ||
                        tradeType == define.TradeMethod.CAT_Ali.rawValue ||
                        tradeType == define.TradeMethod.CAT_Zero.rawValue ||
                        tradeType == define.TradeMethod.CAT_Kakao.rawValue ||
                        tradeType == define.TradeMethod.CAT_Payco.rawValue {
                //캣앱카드취소
                var mEasyKind = ""
                switch tradeType {
                case define.TradeMethod.CAT_App.rawValue :
                    mEasyKind = "AP"
                    break
                case define.TradeMethod.CAT_Zero.rawValue :
                    mEasyKind = "ZP"
                    break
                case define.TradeMethod.CAT_Kakao.rawValue :
                    mEasyKind = "KP"
                    break
                case define.TradeMethod.CAT_Ali.rawValue :
                    mEasyKind = "AL"
                    break
                case define.TradeMethod.CAT_We.rawValue :
                    mEasyKind = "WC"
                    break
                case define.TradeMethod.Kakao.rawValue :
                    mEasyKind = "KP"
                    break
                case define.TradeMethod.Zero.rawValue :
                    mEasyKind = "ZP"
                    break
                case define.TradeMethod.Wechat.rawValue :
                    mEasyKind = "WC"
                    break
                case define.TradeMethod.Ali.rawValue :
                    mEasyKind = "AL"
                    break
                case define.TradeMethod.AppCard.rawValue :
                    mEasyKind = "AP"
                    break
                case define.TradeMethod.EmvQr.rawValue :
                    mEasyKind = "AP"
                    break
                case define.TradeMethod.CAT_Payco.rawValue :
                    mEasyKind = "PC"
                    break
                default:
                    mEasyKind = ""
                    break
                }

                mCatSdk.EasyRecipt(TrdType: "A20", TID: TID, Qr: "", 거래금액: money, 세금: Tax, 봉사료: Svc, 비과세: Txf, EasyKind: mEasyKind, 원거래일자: String(AuDate.replacingOccurrences(of: " ", with: "").prefix(6)), 원승인번호: 승인번호.replacingOccurrences(of: " ", with: ""), 서브승인번호: "", 할부: Inst, 가맹점데이터: "", 호스트가맹점데이터: "", 코세스거래고유번호: "", StoreName: StoreName, StoreAddr: StoreAddr, StoreNumber: BSN, StorePhone: StorePhone, StoreOwner: StoreOwner, CompletionCallback: catlistener.delegate!, Products: [])

                return
            } else if tradeType == define.TradeMethod.Point_Redeem.rawValue  {
                //포인트사용
                PointCancel()
            } else if tradeType == define.TradeMethod.Point_Reward.rawValue  {
                //포인트적립
                PointCancel()
            } else if tradeType == define.TradeMethod.MemberShip.rawValue  {
                //멤버십
                MemberCancel()
            } else {
                //현금
                var _number = ""
                _number = alert.textFields?[0].text ?? ""
                if _number.isEmpty == true {
                    _number = ""
                }
                CashCancel(cashNumber: _number)
                return
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(ok)

        controller?.present(alert, animated: false, completion: nil)
        
    }
    
    // 신용취소
    func CreditCancel() {
        //ble장치가 연결 되어 있는지 없는지 확인 한다.
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"), preferredStyle: UIAlertController.Style.alert)
            let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
            return
        }
        
        //cat 연동일 경우
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: Utils.CheckCatPortIP(), preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
            if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: "리더기 무결성 검증실패 제조사A/S요망.", preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
        }
                                            
        //거래고유키 없이 취소승인을 진행한다
        let mCanCelInfo = "0" + AuDate.prefix(6) + 승인번호
        var mMoney:Int = Int(self.money)! + Int(Tax)! + Int(Svc)!
        //ble 경우 Cat의 경우는 따로 처리 해야 할지 말지 정해야 한다.
        startPayment(Tid: TID, Money: String(mMoney), Tax: 0, ServiceCharge: 0, TaxFree: 0, InstallMent: Inst, OriDate: AuDate, CancenInfo: mCanCelInfo, mchData: "", KocesTreadeCode: "", CompCode: "")
    }
    
    // 현금취소
    func CashCancel(cashNumber _number:String) {
        //취소사유    '1' : 거래취소, '2' : 오류발급, '3' : 기타
        let _cancelReason = "1" //일반취소사유
        
        // _InsYn, CashTarget = 1:개인 2:사업자 3:자진발급. 자진발급인경우 신분확인번호를 "0100001234" 로 대입하여 취소한다
        var 신분확인번호 = ""
        var _InsYn = "1"
        switch CashTarget {
        //자진발급이 아닌경우 사용자번호(전화번호 or 사업자번호)를 입력받는다.
        case define.TradeMethod.CashPrivate.rawValue://개인
            신분확인번호 = _number
            _InsYn = "1"
            break
        case define.TradeMethod.CashBusiness.rawValue://사업자
            신분확인번호 = _number
            _InsYn = "2"
            break
        case define.TradeMethod.CashSelf.rawValue://자진발급
            신분확인번호 = "0100001234"
            _InsYn = "3"
            break
        default://신용
            break
        }
        
        var TotlaMonay:Int = Int(money)! + Int(Tax)! + Int(Svc)! //2021-08-20 kim.jy 취소는 총합으로
        // 신분확인번호가 없다면 자동적으로 msr 리딩을 진행하며 번호가 입력되어있는경우라면 다이렉트취소로 진행한다
        if !신분확인번호.isEmpty {
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    let controller = Utils.topMostViewController()
                    let alert = UIAlertController(title: "에러", message: Utils.CheckCatPortIP(), preferredStyle: UIAlertController.Style.alert)
                    let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(btnOk)
                    controller?.present(alert, animated: true, completion: nil)
                    return
                }
                
                mCatSdk.CashRecipt(TID: TID, 거래금액: money, 세금: Tax, 봉사료: Svc, 비과세: Txf, 원거래일자: String("20" + AuDate.replacingOccurrences(of: " ", with: "").prefix(6)), 원승인번호: 승인번호.replacingOccurrences(of: " ", with: ""), 코세스거래고유번호: "", 할부: "", 고객번호: 신분확인번호, 개인법인구분: _InsYn, 취소: true, 최소사유: "1", 가맹점데이터: "", 여유필드: "", StoreName: StoreName, StoreAddr: StoreAddr, StoreNumber: BSN, StorePhone: StorePhone, StoreOwner: StoreOwner,CompletionCallback: catlistener.delegate!, Products: [])
            }
            else
            {
                //다이렉트취소(번호입력)
                CashReciptDirectInput(CancelReason: _cancelReason, Tid: TID, AuDate: AuDate, AuNo: 승인번호, Num: 신분확인번호, Command: Command.CMD_CASH_RECEIPT_CANCEL_REQ, MchData: "", TrdAmt: String(TotlaMonay), TaxAmt: "0", SvcAmt: "0", TaxFreeAmt: "0", InsYn: _InsYn, kocesNumber: "")
            }
            
        } else {
            
            //ble장치가 연결 되어 있는지 없는지 확인 한다.
            if mKocesSdk.bleState  == define.TargetDeviceState.BLENOCONNECT {
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"), preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    let controller = Utils.topMostViewController()
                    let alert = UIAlertController(title: "에러", message: Utils.CheckCatPortIP(), preferredStyle: UIAlertController.Style.alert)
                    let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(btnOk)
                    controller?.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                    
                    let controller = Utils.topMostViewController()
                    let alert = UIAlertController(title: "에러", message: "리더기 무결성 검증실패 제조사A/S요망.", preferredStyle: UIAlertController.Style.alert)
                    let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(btnOk)
                    controller?.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
            //MSR 취소승인을 진행한다
            let mCanCelInfo = "0" + AuDate.prefix(6) + 승인번호
            mpaySdk.CashRecipt(Tid: TID, Money: String(TotlaMonay), Tax: 0, ServiceCharge: 0, TaxFree: 0, PrivateOrBusiness: Int(_InsYn)!, ReciptIndex: "0000", CancelInfo: mCanCelInfo, OriDate: AuDate, InputMethod: CashMethod, CancelReason: _cancelReason, ptCardCode: "", ptAcceptNum: "", BusinessData: "", Bangi: "", KocesTradeUnique: "", payLinstener: paylistener.delegate!,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, Products: [])
        }
        
    }
    
    func PointCancel() {
        
    }
    
    //멤버십취소
    func MemberCancel() {
        //ble장치가 연결 되어 있는지 없는지 확인 한다.
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"), preferredStyle: UIAlertController.Style.alert)
            let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
            return
        }
        
        //cat 연동일 경우
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "에러", message: "CAT 은 지원하지 않습니다", preferredStyle: UIAlertController.Style.alert)
            let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
            return
        }
        
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
            if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: "리더기 무결성 검증실패 제조사A/S요망.", preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
        }
                                            
        //거래고유키 없이 취소승인을 진행한다
        let mCanCelInfo = "0" + AuDate.prefix(6) + 승인번호
        var mMoney:Int = Int(self.money)!
        //ble 경우 Cat의 경우는 따로 처리 해야 할지 말지 정해야 한다.
  
        
        mpaySdk.MemberPay(TrdType: Command.CMD_MEMBER_CANCEL_REQ, Tid: TID, Money: self.money, OriDate: AuDate, CancenInfo: mCanCelInfo, mchData: "", payLinstener: paylistener.delegate!, StoreName: StoreName, StoreAddr: StoreAddr, StoreNumber: BSN, StorePhone: StorePhone, StoreOwner: StoreOwner, Qr: "", IsQr: isCheckCardOrQr.self)
    }
        
}


struct ReceiptSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptSwiftUI()
    }
}

struct presentAnimationViewController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<presentAnimationViewController>) -> UIViewController {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let controller = storyboard!.instantiateViewController(identifier: "SignatureController")
        
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
 
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<presentAnimationViewController>) {}
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
