//
//  ReceiptEasyPaySwiftUI.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/05/03.
//

import SwiftUI
import UIKit

struct ReceiptEasyPaySwiftUI: View, PayResultDelegate, PrintResultDelegate, CatResultDelegate  {
    //swiftui 뷰가 네비게이션으로 이동되어왔기에 아래의 모드를 받아서 dismiss 해주면 이전뷰로 이동하게된다
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    let mKocesSdk:KocesSdk = KocesSdk.instance
    let mKakaoSdk:KaKaoPaySdk = KaKaoPaySdk.instance
    var paylistener: payResult = payResult()
    var mCatSdk:CatSdk = CatSdk.instance
    var catlistener: CatResult = CatResult()
    var printlistener: PrintResult = PrintResult()
    var mTradeResult:DBTradeResult = DBTradeResult()
    var mMessage:String = "" //응답메세지
    var KakaoMessage:String = ""    //알림메세지
    var AuNo:String = ""    //승인번호
    var PayType:String = "" //결제수단
    var KakaoAuMoney:String = ""    //승인금액(카카오머니 승인 응답 시(승인금액 = 거래금액 - 카카오할인금액))
    var KakaoSaleMoney:String = ""  //카카오페이할인금액
    var KakaoMemberCd:String = ""   //카카오 멤버십바코드
    var KakaoMemberNo:String = ""   //카카오 멤버십 번호
    var Otc:String = "" //카드번호정보(OTC) - 결제수단 카드 시
    var Pem:String = "" //PEM - 결제수단 카드 시
    var Trid:String = ""    //trid - 결제수단 카드 시
    var CardBin:String = ""    //카드Bin - 결제수단 카드 시
    var SearchNo:String = ""    //조회고유번호
    var PrintBarcd:String = ""    //출력용 바코드 번호(전표 출력시 사용될 바코드 번호)
    var CardMethod:String = ""    //카드종류
//    var OrdCd:String = ""    //발급사코드
    var OrdNm:String = ""    //발급사명
//    var InpCd:String = ""    //매입사코드
    var InpNm:String = ""    //매입사명
//    var DDCYn:String = ""    //DDC 여부
//    var EDCYn:String = ""    //EDC 여부
    var PrintUse:String = ""    //전표출력여부
    var PrintNm:String = ""    //전표구분명
    var MchNo:String = ""    //가맹점번호
//    var WorkinKey:String = ""    //Workingkey(데이터에 null(0x00) 또는 스페이스(0x20) 있을 경우 업데이트 하지 말 것
//    var MchData:String = ""    //가맹점데이터
    var Money:String = ""    //거래금액
    var Tax:String = ""    //세금
    var ServiceCharge:String = ""    //봉사료
    var TaxFree:String = ""    //비과세
    var Inst:String = ""    //할부
    
    var 전표번호:String = ""
    var 원거래일자:String = ""
    var 뷰컨트롤러:String = ""
    
    var tradeType:String = ""   //신용/현금/간편... 나누는 구분자
    var CancelInfo:String = ""  //취소인지 아닌지를 체크 "1 = 취소" 그외는 승인
    var AuDate:String = ""    //승인날짜
    
    //제로페이 추가데이터
    var 가맹점수수료:String = ""
    var 가맹점환불금액:String = ""
    
    //페이코데이터
    var PcKind:String = ""
    var PcCoupon:String = ""
    var PcPoint:String = ""
    var PcCard:String = ""
    
    var TID:String = "" //취소시 사용하는 DB 에 저장된 TID
    var BSN:String = ""     //사업자번호
    var StoreAddr:String = "" //가맹점주소
    var StoreName:String = "" //가맹점명
    var StoreOwner:String = "" //대표자명
    var StorePhone:String = "" //연락처
    
    @State var mPrintCount:Int = 0  //프린트는 1회만 가능하다. 재출력 불가
    
    @State var printMsg:String = ""    //영수증에서 프린트 시 출력할 내용
    
    @State var mTotalMoney:Int = 0    //결제 취소시에는 총금액으로 취소를 한다.
    
    @State var mGiftView:String = ""    //선불카드잔액을 표시할지 말지를 체크한다.
    
    @State var scanTimeout:Timer?       //프린트시 타임아웃
    
    mutating func setData(영수증데이터 _receipt:DBTradeResult, 상품영수증데이터 _productList:[DBProductTradeResult] = [], 뷰컨트롤러 _controller:String, 전표번호 _dbNumber:String)
    {
        mTradeResult = _receipt
        tradeType = _receipt.getTrade()
        CancelInfo = _receipt.getCancel()
        if CancelInfo == "1" {
            Money = "-" + _receipt.getMoney()
            Tax =   "-" +  _receipt.getTax()
            ServiceCharge = "-" + _receipt.getSvc()
            TaxFree = "-" + _receipt.getTxf()
            원거래일자 = _receipt.getOriAuDate()
        } else {
            Money = _receipt.getMoney()
            Tax = _receipt.getTax()
            ServiceCharge = _receipt.getSvc()
            TaxFree = _receipt.getTxf()
        }
        
        mMessage = _receipt.getMessage()
        KakaoMessage = _receipt.getKakaoMessage()
        PayType = _receipt.getPayType()
        KakaoAuMoney = _receipt.getKakaoAuMoney()
        KakaoSaleMoney = _receipt.getKakaoSaleMoney()
        KakaoMemberCd = _receipt.getKakaoMemberCd()
        KakaoMemberNo = _receipt.getKakaoMemberNo()
        Otc = _receipt.getOtc()
        Pem = _receipt.getPem()
        Trid = _receipt.getTrid()
        CardBin = _receipt.getCardBin()
        SearchNo = _receipt.getSearchNo()
        PrintUse = _receipt.getPrintUse()
        PrintNm = _receipt.getPrintNm()
//        코세스고유거래키 = _receipt.getTradeNo()
//        선불카드잔액 = _receipt.getGiftAmt()
        Inst = _receipt.getInst()
        
        AuDate = _receipt.getAuDate()
        AuNo = _receipt.getAuNum()

        if _receipt.getPrintBarcd().isEmpty {
            PrintBarcd = barcodeParser(바코드: _receipt.getCardNum())
        } else {
            PrintBarcd = barcodeParser(바코드: _receipt.getPrintBarcd())
        }
        
        //제로페이추가정보
        가맹점수수료 = _receipt.getMchFee()
        가맹점환불금액 = _receipt.getMchRefund()
        //제로페이추가정보
        
        //페이코
        PcKind = _receipt.getPcKind()
        PcCoupon = _receipt.getPcCoupon()
        PcPoint = _receipt.getPcPoint()
        PcCard = _receipt.getPcCard()
        
        CardMethod = _receipt.getCardType()
        InpNm = _receipt.getCardInpNm()
        OrdNm = _receipt.getCardIssuer()
        MchNo = _receipt.getMchNo()
        뷰컨트롤러 = _controller
        
        if _dbNumber != "0" {
            전표번호 = _dbNumber
        }
        
        TID = _receipt.getTid().isEmpty ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_receipt.getTid()
        
        TID = _receipt.getTid().isEmpty ? "":_receipt.getTid()
        BSN = _receipt.getStoreNumber().isEmpty ? "":_receipt.getStoreNumber()
        StoreName = _receipt.getStoreName().isEmpty ? "":_receipt.getStoreName()
        StoreOwner = _receipt.getStoreOwner().isEmpty ? "":_receipt.getStoreOwner()
        StorePhone = _receipt.getStorePhone().isEmpty ? "":_receipt.getStorePhone()
        StoreAddr = _receipt.getStoreAddr().isEmpty ? "":_receipt.getStoreAddr()

        self.paylistener.delegate = self
        self.catlistener.delegate = self
        
        mKakaoSdk.Clear()
        mCatSdk.Clear()
    }
    
    func onPaymentResult(payTitle _status: payStatus, payResult _message: Dictionary<String, String>)
    {
        var _totalString:String = ""
        var _title:String = "거래[불가]"
        var keyCount:Int = 0
        switch _message["TrdType"] {
        case Command.CMD_KAKAOPAY_CANCEL_RES:
            _title = "카카오간편결제[취소]"
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            //거래상세내역에서 거래내역뷰로 돌아간다
            if _status == .OK {
                Utils.customAlertBoxInit(Title: _title, Message: "정상적으로 취소처리 되었습니다", LoadingBar: false, GetButton: "확인")
            } else {
                Utils.customAlertBoxInit(Title: _title, Message: _message["Message"] ?? _message["ERROR"] ?? "거래실패", LoadingBar: false, GetButton: "확인")
            }
        }
        
        mKakaoSdk.Clear()
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
        mKakaoSdk.Clear()
        mCatSdk.Clear()
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
                                PrintReceiptInit()

                            }, label: {
                                Text("출력")
                            }).buttonStyle(SwiftUIButton())
                        }
                    }
                    else if 뷰컨트롤러 == "거래내역" {
                        Spacer()
                        Button(action: {
                            PrintReceiptInit()

                        }, label: {
                            Text("출력")
                        }).buttonStyle(SwiftUIButton())
                    }
                }
                Spacer()
                Button("저장") {
                    let image = receiptKakaoView.SnapSave()

                    let imageAlbum = ImageSaveAlbum()
                    imageAlbum.saveImageAlbum(Image: image)
                }.buttonStyle(SwiftUIButton())
                Spacer()
                if 뷰컨트롤러 == "거래내역"{
                    if CancelInfo == define.TradeMethod.NoCancel.rawValue {
                        
                        Button(action: {
                            KakaoCancelPayment()
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
                        if Inst != "0" {
                            mPrintCount += 1
                            PrintReceiptInit()
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
                    receiptKakaoView
                }
                if UIDevice.current.userInterfaceIdiom != .phone {
                    VStack(spacing: nil, content: {
                        Spacer()
                    }).padding(25)
                }
            }
        }
    }

    var receiptKakaoView: some View {
        Group {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 30, content: {
                if CancelInfo == "1" {
                    Text("간편취소").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
                } else {
                    Text("간편승인").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 30))
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
                }   //Group
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
                }   //Group
                Group{
                    if !InpNm.isEmpty {
                        //매입사명
                        HStack{
                            Text("매입사명")
                            Spacer()
                            Text(InpNm.replacingOccurrences(of: " ", with: ""))
                        }.padding(.horizontal,20)
                        
                    }
                    if !OrdNm.isEmpty {
                        //카드종류
                        HStack{
                            Text("발급사명")
                            Spacer()
                            Text(OrdNm.replacingOccurrences(of: " ", with: ""))
                        }.padding(.horizontal,20)
                    }
                    //바코드,QR번호
                    if !PrintBarcd.isEmpty {
                        HStack{
                            Text("간편결제번호")
                            Spacer()
                            Text(PrintBarcd.replacingOccurrences(of: " ", with: ""))
                        }.padding(.horizontal,20)
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
                        Text(AuNo.replacingOccurrences(of: " ", with: ""))
                    }.padding(.horizontal,20)
                    //가맹점번호
                    if !MchNo.isEmpty{
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
                }   //Group
                Group{
                    //공급가액
                    HStack{
                        Text("공급가액")
                        Spacer()
                        var correctMoney = Int(Money)! - Int(TaxFree)!
                        Text(Utils.PrintMoney(Money: String(correctMoney) == "-0" ? "0":String(correctMoney)) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                    }.padding(.horizontal,20)
                    //부가세
                    HStack{
                        Text("부가세")
                        Spacer()
                        Text(Utils.PrintMoney(Money: Tax == "-0" ? "0":Tax) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                    }.padding(.horizontal,20)
                    //봉사료
                    if !ServiceCharge.isEmpty && ServiceCharge != "0" && ServiceCharge != "-0" {
                        HStack{
                            Text("봉사료")
                            Spacer()
                            Text(Utils.PrintMoney(Money: ServiceCharge) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                        }.padding(.horizontal,20)
                    }
                    //비과세
                    if !TaxFree.isEmpty && TaxFree != "0" && TaxFree != "-0" {
                        HStack{
                            Text("비과세")
                            Spacer()
                            Text(Utils.PrintMoney(Money: TaxFree) + " 원").foregroundColor(CancelInfo == "1" ? .red : .black)
                        }.padding(.horizontal,20)
                    }
                    if tradeType == define.TradeMethod.Kakao.rawValue && !KakaoAuMoney.isEmpty  && KakaoAuMoney != "0" {
                        HStack{
                            Text("카카오승인금액")
                            Spacer()
                            Text(Utils.PrintMoney(Money: KakaoAuMoney.filter{$0.isNumber}) + " 원")
                        }.padding(.horizontal,20)
                    }
                    if tradeType == define.TradeMethod.Kakao.rawValue && !KakaoSaleMoney.isEmpty  && KakaoSaleMoney != "0" {
                        HStack{
                            Text("카카오할인금액")
                            Spacer()
                            Text(Utils.PrintMoney(Money: KakaoSaleMoney.filter{$0.isNumber}) + " 원")
                        }.padding(.horizontal,20)
                    }
                    if tradeType == define.TradeMethod.Zero.rawValue && !가맹점수수료.isEmpty && 가맹점수수료 != "0" {
                        HStack{
                            Text("가맹점수수료")
                            Spacer()
                            Text(Utils.PrintMoney(Money: (가맹점수수료.isEmpty ? "0":가맹점수수료).filter{$0.isNumber}) + " 원")
                        }.padding(.horizontal,20)
                    }
                    if tradeType == define.TradeMethod.Zero.rawValue && !가맹점환불금액.isEmpty && 가맹점환불금액 != "0" {
                        HStack{
                            Text("가맹점환불금액")
                            Spacer()
                            Text(Utils.PrintMoney(Money: 가맹점환불금액.filter{$0.isNumber}) + " 원")
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
                        if tradeType == define.TradeMethod.Kakao.rawValue {
                            Text(Utils.PrintMoney(Money: "\(getTotalMoney(_money: Int(KakaoSaleMoney == "" ? Money:Money)!, _tax: Int(Tax)!, _Svc: Int(ServiceCharge)!, _Txf:Int(TaxFree)!))") + " 원").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 20)).foregroundColor(CancelInfo == "1" ? .red : .black)
                        } else if tradeType == define.TradeMethod.Zero.rawValue {
                            Text(Utils.PrintMoney(Money: "\(getTotalMoney(_money: Int(Money)!, _tax: Int(Tax)!, _Svc: Int(ServiceCharge)!, _Txf:Int(TaxFree)!))") + " 원").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 20)).foregroundColor(CancelInfo == "1" ? .red : .black)
                        } else {
                            Text(Utils.PrintMoney(Money: "\(getTotalMoney(_money: Int(Money)!, _tax: Int(Tax)!, _Svc: Int(ServiceCharge)!, _Txf:Int(TaxFree)!))") + " 원").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 20)).foregroundColor(CancelInfo == "1" ? .red : .black)
                        }
                    }.padding(.horizontal,20)
                   
                }   //Group
                Group{
                    //-------------
                    VStack{
                        Spacer()
                        Divider()
                        Spacer()
                    }
                    //응답메시지
                    HStack{
                        Text("메세지  " + mMessage)
                        Spacer()
                    }.padding(.horizontal,20)
                    
                    if tradeType == define.TradeMethod.Kakao.rawValue && !KakaoMessage.isEmpty {
                        HStack{
                            Text(KakaoMessage)
                            Spacer()
                        }.padding(.horizontal,20)
                        //-------------
                    }
                    
                    //실제앱에 저장되어있는 추가메시지
                    if !Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
                        HStack{
                            Text(Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL))
                            Spacer()
                        }.padding(.horizontal,20)
                    }
                }   //Group
                
                Group{

                    //-------------
                    VStack{
                        Spacer()
                        Spacer()
                        Spacer()
                    }

                }   //Group
            }
        }
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
    
    //출력용 바코드 번호 4자리 마다 "-" 를 넣는다. 단, 캐쉬는 제외
    func barcodeParser(바코드 _printBarcd:String) -> String {
        var _barcd:String = ""
        //만일 90일이 지난 거래라면 여기서 다시 한번 재마스킹처리한다
        _barcd = Utils.EasyParser(바코드qr번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: AuDate))
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
        
        _tid = "***" + String(tidchars[3...])
        
        return _tid
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
    
    //합계금액을 계산한다
    func getTotalMoney(_money:Int,_tax:Int,_Svc:Int,_Txf:Int) -> Int {
        //let TotalMoney:Int = _money + _tax + _Svc - _Txf
        var TotalMoney:Int = _money + _tax + _Svc
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            TotalMoney = _money + _tax + _Svc + _Txf
        }
        return TotalMoney
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
    }
    
    //메인화면으로 이동한다
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
        
        mainTabBarController?.selectedIndex = 0
        controller?.present(mainTabBarController!, animated: true, completion: nil)

    }
    
    //카카오페이 결제를 취소를 시작한다
    func KakaoCancelPayment() {
        self.paylistener.delegate = self
        let controller = Utils.topMostViewController()
        var 타이틀 = ""
        let 메세지 = "취소결제를 진행하시겠습니까?"
        if tradeType == define.TradeMethod.Kakao.rawValue {
            타이틀 = "카카오취소"
        } else if tradeType == define.TradeMethod.Zero.rawValue{
            // CashTarget = 1:개인 2:사업자 3:자진발급
            타이틀 = "제로페이취소"
        } else if tradeType == define.TradeMethod.Wechat.rawValue{
            // CashTarget = 1:개인 2:사업자 3:자진발급
            타이틀 = "위쳇/알리취소"
        } else if tradeType == define.TradeMethod.Ali.rawValue{
            // CashTarget = 1:개인 2:사업자 3:자진발급
            타이틀 = "위쳇/알리취소"
        } else {
            타이틀 = "간편취소"
        }
        let alert = UIAlertController(title: 타이틀, message: 메세지, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {(ACTION) in
            var mMoney:Int = Int(Money)! + Int(Tax)! + Int(ServiceCharge)! //2021.08.19 kim.jy
            //결제의 경우 전체 금액을 합산하여 서버로 전송, 부가세, 봉사료, 비과세는 0원을 전달한다.
            if tradeType == define.TradeMethod.Kakao.rawValue {
                //카카오
                mKakaoSdk.EasyPay(Command: Command.CMD_KAKAOPAY_CANCEL_REQ, Tid: TID, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: AuDate, AuNo: AuNo, InputType: "B", BarCode: "", OTCCardCode: [UInt8](), Money: String(mMoney), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: Inst, PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: SearchNo, WorkingKeyIndex: "", SignUse: "B", SignPadSerial: "", SignData: [UInt8](), StoreData: "", StoreInfo: "", KocesUniNum: "", payLinstener: paylistener.delegate! ,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, QrKind: "KP", Products: [])
                return
            }  else if tradeType == define.TradeMethod.Zero.rawValue {
                //기타 다른 간편결제
                mKakaoSdk.EasyPay(Command: Command.CMD_ZEROPAY_CANCEL_REQ, Tid: TID, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: AuDate, AuNo: AuNo, InputType: "B", BarCode: "", OTCCardCode: [UInt8](), Money: String(mMoney), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: Inst, PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: SearchNo, WorkingKeyIndex: "", SignUse: "B", SignPadSerial: "", SignData: [UInt8](), StoreData: "", StoreInfo: "", KocesUniNum: "", payLinstener: paylistener.delegate! ,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, QrKind: "ZP", Products: [])
                return
            }  else if tradeType == define.TradeMethod.Wechat.rawValue {
                //기타 다른 간편결제
                mKakaoSdk.EasyPay(Command: Command.CMD_WECHAT_ALIPAY_CANCEL_REQ, Tid: TID, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: AuDate, AuNo: AuNo, InputType: "B", BarCode: "", OTCCardCode: [UInt8](), Money: String(mMoney), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: Inst, PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: SearchNo, WorkingKeyIndex: "", SignUse: "B", SignPadSerial: "", SignData: [UInt8](), StoreData: "", StoreInfo: "", KocesUniNum: "", payLinstener: paylistener.delegate! ,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, QrKind: "WC", Products: [])
                return
            }  else if tradeType == define.TradeMethod.Ali.rawValue {
                //기타 다른 간편결제
                mKakaoSdk.EasyPay(Command: Command.CMD_WECHAT_ALIPAY_CANCEL_REQ, Tid: TID, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: AuDate, AuNo: AuNo, InputType: "B", BarCode: "", OTCCardCode: [UInt8](), Money: String(mMoney), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: Inst, PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: SearchNo, WorkingKeyIndex: "", SignUse: "B", SignPadSerial: "", SignData: [UInt8](), StoreData: "", StoreInfo: "", KocesUniNum: "", payLinstener: paylistener.delegate! ,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, QrKind: "AL", Products: [])
                return
            } else {
                //기타 다른 간편결제
                mKakaoSdk.EasyPay(Command: Command.CMD_KAKAOPAY_CANCEL_REQ, Tid: TID, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: AuDate, AuNo: AuNo, InputType: "B", BarCode: "", OTCCardCode: [UInt8](), Money: String(mMoney), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: Inst, PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: SearchNo, WorkingKeyIndex: "", SignUse: "B", SignPadSerial: "", SignData: [UInt8](), StoreData: "", StoreInfo: "", KocesUniNum: "", payLinstener: paylistener.delegate! ,StoreName: StoreName,StoreAddr: StoreAddr,StoreNumber: BSN,StorePhone: StorePhone,StoreOwner: StoreOwner, QrKind: "AP", Products: [])
                return
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(ok)

        controller?.present(alert, animated: false, completion: nil)
    }
    
    //개개 메세지 한줄씩 파싱
    func printParser(프린트메세지 _msg:String) {
        self.printMsg += _msg
    }
    
    //프린트 할 문장 전체 파싱
    func PrintReceiptInit() {
        //ble장치가 연결 되어 있는지 없는지 확인 한다.
        if mKocesSdk.blePrintState  == define.PrintDeviceState.BLENOPRINT {
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
        
        if CancelInfo == "1" {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "간편취소")) + define.PENTER)
        } else {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "간편승인")) + define.PENTER)
        }

        //전표번호(로컬DB에 저장되어 있는 거래내역리스트의 번호) + 전표출력일시
        printParser(프린트메세지: Utils.PrintPad(leftString: "No." + Utils.leftPad(str: 전표번호, fillChar: "0", length: 6), rightString: titleDateParser()) + define.PENTER)

        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        //가맹점명 단말기TID
        printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점명", rightString: StoreName.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        //대표자명 사업자번호 연락처
        printParser(프린트메세지: Utils.PrintPad(leftString: "대표자명", rightString: StoreOwner.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        printParser(프린트메세지: Utils.PrintPad(leftString: "사업자번호", rightString: bsnParser()) + define.PENTER)
        printParser(프린트메세지: Utils.PrintPad(leftString: "연락처", rightString: phoneParser()) + define.PENTER)
        //단말기TID
        printParser(프린트메세지: Utils.PrintPad(leftString: "단말기ID", rightString: tidParser()) + define.PENTER)
        
        //주소
        printParser(프린트메세지: Utils.PrintPad(leftString: "주소  ", rightString: StoreAddr) + define.PENTER)

        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        if !InpNm.isEmpty {
            //매입사명
            printParser(프린트메세지: Utils.PrintPad(leftString: "매입사명", rightString: InpNm.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }
        if !OrdNm.isEmpty {
            //카드종류
            printParser(프린트메세지: Utils.PrintPad(leftString: "발급사명", rightString: OrdNm.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }
        //바코드카드번호
        if !PrintBarcd.isEmpty {
            printParser(프린트메세지: Utils.PrintPad(leftString: "고객번호", rightString: PrintBarcd) + define.PENTER)
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
        printParser(프린트메세지: Utils.PrintPad(leftString: "승인번호", rightString: AuNo.replacingOccurrences(of: " ", with: "")) + define.PENTER)
    
        if !MchNo.isEmpty {
            //가맹점번호
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점번호", rightString: MchNo.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }

        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        //공급가액
        var correctMoney = Int(Money)! - Int(TaxFree)!  //2021-08-23 kim.jy 결제금액과 전체 합계가 맞게 하기 위해 공급가액에서 비과세를 제외 한다.
        printParser(프린트메세지: Utils.PrintPad(leftString: "공급가액", rightString: Utils.PrintMoney(Money: String(correctMoney) == "-0" ? "0":String(correctMoney)) + "원") + define.PENTER)
        //부가세
        printParser(프린트메세지: Utils.PrintPad(leftString: "부가세", rightString: Utils.PrintMoney(Money: Tax == "-0" ? "0":Tax) + "원") + define.PENTER)
        //봉사료
        if !ServiceCharge.isEmpty && ServiceCharge != "0" && ServiceCharge != "-0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "봉사료", rightString: Utils.PrintMoney(Money: ServiceCharge) + "원") + define.PENTER)
        }
        //비과세
        if !TaxFree.isEmpty && TaxFree != "0" && TaxFree != "-0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "비과세", rightString: Utils.PrintMoney(Money: TaxFree) + "원") + define.PENTER)
        }
        //카카오승인금액 카카오할인금액
        if tradeType == define.TradeMethod.Kakao.rawValue && !KakaoAuMoney.isEmpty && KakaoAuMoney != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "카카오승인금액", rightString: Utils.PrintMoney(Money: KakaoAuMoney) + "원") + define.PENTER)
        }
        if tradeType == define.TradeMethod.Kakao.rawValue && !KakaoSaleMoney.isEmpty && KakaoSaleMoney != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "카카오할인금액", rightString: Utils.PrintMoney(Money: KakaoSaleMoney) + "원") + define.PENTER)
        }
        //제로페이 가맹점수수료 가맹점환불금액
        if tradeType == define.TradeMethod.Zero.rawValue && !가맹점수수료.isEmpty  && 가맹점수수료 != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점수수료", rightString: Utils.PrintMoney(Money: 가맹점수수료.isEmpty ? "0":가맹점수수료) + "원") + define.PENTER)
        }
        if tradeType == define.TradeMethod.Zero.rawValue && !가맹점환불금액.isEmpty  && 가맹점환불금액 != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점환불금액", rightString: Utils.PrintMoney(Money: 가맹점환불금액) + "원") + define.PENTER)
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
        var _totalMoney:String = ""
        if tradeType == define.TradeMethod.Kakao.rawValue {
            _totalMoney = "\(getTotalMoney(_money: Int(KakaoSaleMoney == "" ? Money:Money)!, _tax: Int(Tax)!, _Svc: Int(ServiceCharge)!, _Txf:Int(TaxFree)!))"
        } else if tradeType == define.TradeMethod.Zero.rawValue {
            _totalMoney = "\(getTotalMoney(_money: Int(Money)!, _tax: Int(Tax)!, _Svc: Int(ServiceCharge)!, _Txf:Int(TaxFree)!))"
        } else {
            _totalMoney = "\(getTotalMoney(_money: Int(Money)!, _tax: Int(Tax)!, _Svc: Int(ServiceCharge)!, _Txf:Int(TaxFree)!))"
        }
        printParser(프린트메세지: Utils.PrintPad(leftString: Utils.PrintBold(_bold: "결제금액") , rightString: Utils.PrintBold(_bold: Utils.PrintMoney(Money: _totalMoney) + "원")) + define.PENTER)
        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        printParser(프린트메세지: "메세지 " + mMessage + define.PENTER)
        //-------------
        if tradeType == define.TradeMethod.Kakao.rawValue && !KakaoMessage.isEmpty {
            printParser(프린트메세지: KakaoMessage + define.PENTER)
            //-------------
           
        }
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        PrintReceipt(프린트메세지: printMsg)
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
                KocesSdk.instance.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                self.printlistener.delegate = self
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
}

struct ReceiptEasyPaySwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptEasyPaySwiftUI()
    }
}

struct signatureController: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<signatureController>) -> UIViewController {
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
 
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<signatureController>) {}
}

extension View {
    func SnapSave() -> UIImage {
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

