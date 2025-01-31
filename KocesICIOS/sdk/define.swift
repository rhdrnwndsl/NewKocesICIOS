//
//  define.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/13.
//

import Foundation
import UIKit
class define{
    /** 서버 아이피 key*/  public static let HOST_SERVER_IP:String = "HOST_SERVER_IP"
    /** 서버 포트 key*/   public static let HOST_SERVER_PORT:String = "HOST_SERVER_PORT"
    
    /** CAT 아이피 key*/  public static let CAT_SERVER_IP:String = "CAT_SERVER_IP"
    /** CAT 포트 key*/   public static let CAT_SERVER_PORT:String = "CAT_SERVER_PORT"
    
    /** CAT 아이피 key*/  public static let CAT_PRINT_SERVER_IP:String = "CAT_PRINT_SERVER_IP"
    /** CAT 포트 key*/   public static let CAT_PRINT_SERVER_PORT:String = "CAT_PRINT_SERVER_PORT"
    
    /** 테스트 TID */      public static let TEST_TID:String                = "0710000900"
    /** 테스트 사업자번호 */  public static let TEST_BUSINESS_NUMBER:String    = "2148631917"
    /** 테스트 시리얼번호 */  public static let TEST_SERIALNUMBER:String       = "MJ85050010"
    /** 소프트웨어 버전 */ public static let TEST_SOREWAREVERSION:String = "KI013"   //2021-01-18 kim.jy 수정
//    /** 현금IC 난수 32자리 */ public static let CASHIC_RANDOM_NUMBER:String = "qwerasdfzxcvqwerasdfzxcvqwerasdf"   //현금IC 난수 길이 32자리
    /** 현금IC 난수 32자리 */ public static let CASHIC_RANDOM_NUMBER:String = "                                ";   //현금IC 난수 길이 32자리 - 임의값이 아닌 스페이스패딩으로 변경 보안인증이슈 jiw230223
    public static let  WORKING_KEY_INDEX:String = "01";    //비밀번호 또는 전자서명(KOCES 사인패드) 사용 시 설정 데이터에 null(0x30) 스페이스(0x20) 이 있으면 업데이트하지 말것
    public static let  WORKING_KEY:String = "B77F25FB72762DD3";    //암호화 및 해쉬코드 생성시 이용하는 Working Key
    
    /// 펌웨어 서버 아이피 패스워드
    public static let FIRMWARESERVER_IP:String = "211.53.209.74"
    public static let FIRMWARESERVER_PORT:Int = 8892
    
    public static let APPTOAPP_ADDR:String = "apptoapp://"
    
    public static let PRIVACY_URL:String = "https://koces.co.kr/sub/privacy.php"
    
    /**
     가맹점 등록 정보 TID
     */
    public static let STORE_TID:String = "STORE_TID"
    /** 가맹점 등록 정보 사업자번호 */
    public static let STORE_BSN:String  = "STORE_BSN"
    /** 가맹점 등록 정보 시리얼 */
    public static let STORE_SERIAL:String = "STORE_SERIAL"
    
    public static let STORE_NAME:String = "STORE_NAME"
    public static let STORE_PHONE:String = "STORE_PHONE"
    public static let STORE_ADDR:String = "STORE_ADDR"
    public static let STORE_OWNER:String = "STORE_OWNER"
    
    /**
     CAT 가맹점 등록 정보
     */
    public static let CAT_STORE_TID:String = "CAT_STORE_TID"
    /** 가맹점 등록 정보 사업자번호 */
    public static let CAT_STORE_BSN:String  = "CAT_STORE_BSN"
    /** 가맹점 등록 정보 시리얼 */
    public static let CAT_STORE_SERIAL:String = "CAT_STORE_SERIAL"
    
    public static let CAT_STORE_NAME:String = "CAT_STORE_NAME"
    public static let CAT_STORE_PHONE:String = "CAT_STORE_PHONE"
    public static let CAT_STORE_ADDR:String = "CAT_STORE_ADDR"
    public static let CAT_STORE_OWNER:String = "CAT_STORE_OWNER"
    
    /**
     앱투앱/웹투앱으로 가맹점 등록시 보낸 정보 TID
     */
    public static let APPTOAPP_TID:String = "APPTOAPP_TID"
    /** 가맹점 등록 정보 사업자번호 */
    public static let APPTOAPP_BSN:String  = "APPTOAPP_BSN"
    /** 가맹점 등록 정보 시리얼 */
    public static let APPTOAPP_SERIAL:String = "APPTOAPP_SERIAL"
    public static let APPTOAPP_NAME:String = "APPTOAPP_NAME"
    
    
    /** workingkey */
    public static let WORKINGKEY_INDEX:String = "WORKINGKEY_INDEX"
    public static let WORKINGKEY:String = "WORKINGKEY"
    /** AppID(신용,현금 결제 시 사용) */
    public static let APP_ID:String = "APP_ID"
    
    /** 코세스식별번호 */
//    public static let KOCES_APP_ID:String = "##KOCESICAPP1004"
    public static let KOCES_ID:String = "##KOCESICIOS1013"
    public static let KOCES_APP_VERINFO:String = "v1.0.1.3(2024.07.11)"
    /** 앱식별번호 */
    public static let KOCES_APP_ID:String = "KOCESICIOS"
    
    /** TCP 전문  */
    public static let POS_TYPE = "P" // 0x50
    
    /** UniqueNumber*/
    public static let UNIQUE_NUMBER = "UNIQUE_NUMBER"
    
    /** TCP 응답 전문 */
//    public static let TCPRES_ERROR = "TcpResError"
//    public static let TCPRES_LENGTH = "TcpResLength"    //전문길이
//    public static let TCPRES_VERSION = "TcpResProtocolVer"  //전문 버전
    
    /** 이전에 연결했던 ble  */
    static let LAST_CONNECT_DEVICE = "LAST_CONNECT_DEVICE"
    
    /** C1 기존 연결장비 */
    public static let bleName: String = "KRE-C"
    public static let bleService: String = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"
    public static let bleRxSerial: String = "49535343-1E4D-4BD9-BA61-23C647249616"
    public static let bleTxSerial: String = "49535343-1E4D-4BD9-BA61-23C647249616"

    /** C1 신형장비 */
    public static let bleNameNew: String = "KREC"
    public static let bleServiceNew: String = "49324541-5211-FA30-4301-48AFD205E400"
    public static let bleRxSerialNew: String = "49324541-5211-FA30-4301-48AFD205E401"
    public static let bleTxSerialNew: String = "49324541-5211-FA30-4301-48AFD205E402"
    
    /** Zoa 장비 */
    public static let bleNameZoa: String = "KRE-Z"
    public static let bleServiceZoa: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    public static let bleRxSerialZoa: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    public static let bleTxSerialZoa: String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    /** 광우 장비 */
    public static let bleNameKwang: String = "KMR-K"
    public static let bleServiceKwang: String = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"
    public static let bleRxSerialKwang: String = "49535343-8841-43F4-A8D4-ECBE34729BB3"
    public static let bleTxSerialKwang: String = "49535343-1E4D-4BD9-BA61-23C647249616"
    
    /** C1 신형KMP장비 */
    public static let bleNameKMPC: String = "KMP-C"
    public static let bleServiceKMPC: String = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"
    public static let bleRxSerialKMPC: String = "49535343-1E4D-4BD9-BA61-23C647249616"
    public static let bleTxSerialKMPC: String = "49535343-1E4D-4BD9-BA61-23C647249616"

    /** ble 상태에 관한 이름 */
    public static let ScanSuccess: String = "ScanSuccess"
    public static let ConnectStart: String = "ConnectStart"
    public static let ConnectSuccess: String = "ConnectSuccess"
    public static let ConnectFail: String = "ConnectFail"
    public static let ConnectTimeOut: String = "ConnectTimeOut"
    public static let Disconnect: String = "Disconnect"
    public static let Receive: String = "Receive"
    public static let IsPaired: String = "IsPaired"
    public static let IsConnected: String = "IsConnected"
    public static let ScanFail: String = "ScanFail"
    public static let Send: String = "Send"
    public static let PowerOff: String = "PowerOff"
    public static let UpdateDevices: String = "UpdateDevices"
    public static let SendComplete: String = "SendComplete"
    public static let PairingKeyFail:String = "PairingKeyFail"
    
    /** 세금관련 이름 */
    public static let VAT_USE:String = "USE_VAT"
    public static let VAT_INCLUDE:String = "VAT_INCLUDE"
    public static let VAT_VALUE:String = "VAT_VALUE"
    public static let SVC_USE:String = "SVC_USE"
    public static let SVC_INCLUDE:String = "SVC_INCLUDE"
    public static let SVC_VALUE:String = "SVC_VALUE"
    public static let TXF_USE:String = "TXF_USE"    //비과세사용
    public static let TXF_AUTOMANUAL:String = "TXF_AUTOMANUAL"    //비과세 수동 자동 모드
    public static let TXF_INCLUDE:String = "TXF_INCLUDE"    //비과세율
    public static let INSTALLMENT_MINVALUE:String = "INSTALLMENT_MINVALUE"  //할부최소금액
    public static let UNSIGNED_SETMONEY:String = "UNSIGNED_SETMONEY"  //무서명금액
    
    /* 세금 관련 이름 재 할당 */
    /* 2021년 7월 14일 kim.jy : CAT과 BLE 세금 연동 부분과 관련 계산식 정리로 인하여 기존 설정값은 참고 할 수 없어 재할당함 */
    public static let TAX_VAT_USE:String            =   "TAX_USE_VAT"           //부가세 사용여부
    public static let TAX_VAT_METHOD:String         =   "TAX_VAT_METHOD"        //부가세 방식 ,AUTO,MANUAL,INTERGRATED
    public static let TAX_VAT_INCLUDE:String        =   "TAX_VAT_INCLUDE"       //부가세, INCLUDED, NOTINLUCDED
    public static let TAX_VAT_VALUE:String          =   "TAX_VAT_VALUE"         //부가세 비율
    public static let TAX_TXF_METHOD:String         =   "TAX_TXF_METHOD"        //비과세 방식 자동,수동
    public static let TAX_TXF_INCLUDE:String        =   "TAX_TXF_INCLUDE"       //비과세 포함, 미포함
    public static let TAX_SVC_USE:String            =   "TAX_USE_SVC"           //봉사료 사용여부
    public static let TAX_SVC_METHOD:String         =   "TAX_SVC_METHOD"        //봉사료 입력 방식 Auto,manual
    public static let TAX_SVC_INCLUDE:String        =   "TAX_SVC"               //봉사료 포함, 미포함
    public static let TAX_SVC_VALUE:String          =   "TAX_SVC_VALUE"         //봉사료 비율
    
    /** 약관동의 이름 */
    public static let TERMS_AGREE:String = "TERMS_AGREE"    //약관 동의. 이값이 셋팅되면 다시 약관동의 하지 않고 가맹점설정으로 넘어간다
    
    /** 전원유지5분,10분,상시유지관리 */
    public static let POWER_MANAGER:String = "POWER_MANAGER"    //단말기가 페어링되지 않았을 때 해당 단말기 전원유지 설정
    
    /** 장비 UUID 저장하는 키체인이름 */
    public static let APP_KEYCHAIN:String = "APP_KEYCHAIN"  //해당 값이 셋팅되면 장비 UUID 는 고정된 값을 갖는다. 단, 공장초기화를 한다면 이값도 사라진다.
 
    /** 서버에서 보내준 고유의 하드웨어 UUID 저장하는 키체인이름 위의 APP_KEYCHAIN 을 서버로 보내 내려받은 값.
     이것을 Base64 인코딩하여 저장한 후 신용 승인/취소 거래 시 디코딩하여 서버로 보낸다 */
    public static let SERVER_KEYCHAIN:String = "SERVER_KEYCHAIN"  //해당 값이 셋팅되면 장비 UUID 는 고정된 값을 갖는다. 단, 공장초기화를 한다면 이값도 사라진다.
    
    /** 복수가맹점 사용 유무 */
    public static let MULTI_STORE:String = "MULTI_STORE"
    
    /** Qr을 카메라=0 로 할지 CAT =1 에서 할지  */
    public static let QR_CAT_CAMERA:String = "QR_CAT_CAMERA"
    
    /** DB 테이블 이름 */
    public static let DB_Verity: String = "Verity"
    public static let DB_TradeOLD: String = "Trade"
    public static let DB_Trade: String = "Trade2"

    public static let DB_AppToApp: String = "Apptoapp"
    public static let DB_Store: String = "StoreRecord"
    
    public static let DB_ProductTable: String = "ProductTable"        //상품등록 테이블
    public static let DB_ProductTradeDetailTable: String = "ProductTradeDetailTable"        //상품거래 시 부분결제 때문에 디테일 테이블을 만든다
    
    /** 이용약관 페이지  */
    public static let APP_TERMS_CHECK: String = "APP_TERMS_CHECK"
    
    /** 권한설정 페이지  */
    public static let APP_PERMISSION_CHECK: String = "APP_PERMISSION_CHECK"
    
    public enum TradeMethod: String{
        case Credit = "신용"
        case EasyPay = "간편결제"       //모든간편결제 데이터들을 DB에서 조회하기위해 사용
        case Cash = "현금"
        case Kakao = "카카오"
        case Zero = "제로"
        case Wechat = "위쳇"
        case Ali = "알리"
        case AppCard = "앱카드"
        case EmvQr = "BC QR"
        case NoCancel = "0"
        case Cancel = "1"
        case CashPrivate = "개인"
        case CashBusiness = "사업"
        case CashSelf = "자체"
        case CashDirect = "직접입력"
        case CashMs = "Msr"
        case NULL = ""
        case CAT_Credit = "신용(C)"
        case CAT_App = "앱카드(C)"
        case CAT_Zero = "간편제로(C)";
        case CAT_Kakao = "간편카카오(C)";
        case CAT_Ali = "간편알리(C)";
        case CAT_We = "간편위쳇(C)";
        case CAT_Payco = "간편페이코(C)"
        case CAT_Cash = "현금(C)"
        case CAT_CashIC = "현금IC(C)"
        case Point_Redeem = "포인트사용";
        case Point_Reward = "포인트적립";
        case Point = "포인트";
        case MemberShip = "멤버십";
        
    }
    
    /** 각각의 간편결제 구분 */
    public enum EasyPayMethod: String{
        case EMV = "EMV"
        case Kakao = "KAKAO"
        case Zero_Bar = "ZERO_BAR"
        case Zero_Qr = "ZERO_QR"
        case Wechat = "WECHAT"
        case Ali = "ALI"
        case App_Card = "APP_CARD"
        case Payco = "PAYCO"
    }
    
    /** BLE프린터 관련 */
    public static let PCENTER:String = "__JYCE__"
    public static let PLEFT:String = "__JYLE__"
    public static let PRIGHT:String = "__JYRI__"
    public static let PBOLDSTART:String = "__JYBS__"
    public static let PBOLDEND:String = "__JYBE__"
    public static let PENTER:String = "___LF___"
    
    /** CAT프린터 관련 */
    public static let Init:[UInt8] = [0x1B, 0x40]; public static let PInit:String = "Init";   //초기화
    public static let Font_HT:[UInt8] = [0x09]; public static let PFont_HT:String = "Font_HT";  //수평 탭(HT)
    public static let Font_LF:[UInt8] = [0x0A]; public static let PFont_LF:String = "Font_LF"  //인쇄 및 한줄 내림(LF)
    public static let Font_CR:[UInt8] = [0x0D]; public static let PFont_CR:String = "Font_CR";  //인쇄 및 프린터 헤드를 라인의 시작위치로 이동
    public static let Logo_Print:[UInt8] = [0x1C, 0x70 ,0x01, 0x30]; public static let PLogo_Print:String = "Logo_Print"; //저장된 LOGO(prn 이미지)
    public static let Cut_print:[UInt8] = [0x1B ,0x69]; public static let PCut_print:String = "Cut_print";  //용지 커팅
    public static let Money_Tong:[UInt8] = [0x1B, 0x70 ,0x31, 0x01, 0x05]; public static let PMoney_Tong:String = "Money_Tong";   //금전함 열기
    public static let Money:[UInt8] = [0x1B, 0x70, 0x31, 0x01, 0x05]; public static let PMoney:String = "Money";   //금전함열기
    public static let Paper_up:[UInt8] = [0x1B, 0x64]; public static let PPaper_up:String = "Paper_up";    //출력 시에 원하는 만큼 라인 공백 추가, n
    public static let Font_Sort_L:[UInt8] = [0x1B, 0x61, 0x30]; public static let PFont_Sort_L:String = "Font_Sort_L";  //폰트 좌측 정렬
    public static let Font_Sort_C:[UInt8] = [0x1B, 0x61, 0x31]; public static let PFont_Sort_C:String = "Font_Sort_C";  //폰트 중앙 정렬
    public static let Font_Sort_R:[UInt8] = [0x1B, 0x61, 0x32]; public static let PFont_Sort_R:String = "Font_Sort_R";  //폰트 우측 정렬
    public static let Font_Default:[UInt8] = [0x1D, 0x21, 0x00]; public static let PFont_Default:String = "Font_Default_0"; //기본 폰트 크기
    public static let Font_Size_H:[UInt8] = [0x1D, 0x21, 0x01]; public static let PFont_Size_H:String = "Font_Size_H";  //폰트 크기 세로 두배
    public static let Font_Size_W:[UInt8] = [0x1D ,0x21, 0x10]; public static let PFont_Size_W:String = "Font_Size_W";  //폰트 크기 가로 두배
    public static let Font_Size_B:[UInt8] = [0x1D, 0x21, 0x11]; public static let PFont_Size_B:String = "Font_Size_B";  //폰트 크기 전체 두배
    public static let Font_Bold_0:[UInt8] = [0x1B, 0x45, 0x00]; public static let PFont_Bold_0:String = "Font_Bold_0";  //폰트 굵기 기본
    public static let Font_Bold_1:[UInt8] = [0x1B, 0x45, 0x01]; public static let PFont_Bold_1:String = "Font_Bold_1";   //폰트 굵기 굵게
    public static let Font_DS_0:[UInt8] = [0x1B, 0x47, 0x00]; public static let PFont_DS_0:String = "Font_DS_0";    //더블-스트라이크 모드 해제
    public static let Font_DS_1:[UInt8] = [0x1B, 0x47, 0x01]; public static let PFont_DS_1:String = "Font_DS_1";    //더블-스트라이크 모드 설정
    public static let Font_Udline_0:[UInt8] = [0x1B, 0x2D, 0x00]; public static let PFont_Udline_0:String = "Font_Udline_0";     //밑줄 모드 해제
    public static let Font_Udline_1:[UInt8] = [0x1B, 0x2D, 0x01]; public static let PFont_Udline_1:String = "Font_Udline_1";     //밑줄 모드 설정
    public static let Bar_Print_1:[UInt8] = [0x1D, 0x6B, 0x45]; public static let PBar_Print_1:String = "Bar_Print_1";   //바코드 출력(CODE39), n : 바코드 데이터 입력 값 길이 계산 하여 입력 필요
    public static let Bar_Print_2:[UInt8] = [0x1D, 0x6B, 0x48]; public static let PBar_Print_2:String = "Bar_Print_2";  //바코드 출력(CODE93), n : 바코드 데이터 입력 값 길이 계산 하여 입력 필요
    public static let Bar_Print_3:[UInt8] = [0x1D, 0x6B, 0x49]; public static let PBar_Print_3:String = "Bar_Print_3";   //바코드 출력(CODE128), n : 바코드 데이터 입력 값 길이 계산 하여 입력 필요
    public static let BarH_Size:[UInt8] = [0x1D, 0x68]; public static let PBarH_Size:String = "BarH_Size";     //바코드의 높이 지정, n
    public static let BarW_Size:[UInt8] = [0x1D, 0x77]; public static let PBarW_Size:String = "BarW_Size";    //바코드의 넓이 지정, n
    public static let Bar_Position_1:[UInt8] = [0x1D, 0x48, 0x01]; public static let PBar_Position_1:String = "Bar_Position_1";   //바코드숫자 위치 위
    public static let Bar_Position_2:[UInt8] = [0x1D, 0x48, 0x02]; public static let PBar_Position_2:String = "Bar_Position_2";   //바코드숫자 위치 아래
    public static let Bar_Position_3:[UInt8] = [0x1D, 0x48, 0x03]; public static let PBar_Position_3:String = "Bar_Position_3";   //바코드숫자 위치 위아래
    
    
    /** 프린트 설정 */
    public static let PRINT_CUSTOMER:String = "PRINT_CUSTOMER"  //고객용 프린트 출력설정
    public static let PRINT_STORE:String = "PRINT_STORE"    //가맹점용 프린트 출력설정
    public static let PRINT_CARD:String = "PRINT_CARD"      //카드사용 프린트 출력설정
    public static let PRINT_LOWLAVEL:String = "PRINT_LOWLAVEL"  //프린트 시 하단 문구 설정
    public static let PRINT_AD_AUTO:String = "PRINT_AD_AUTO"    //프린트 하단 문구출력을 서버에서 가져올(자동) 인지 수동으로 설정한건지 설정
    
    /** 무결성검사 성공/실패/미실행 */
    public enum VerityMethod:String {
        case Success = "성공"
        case Fail = "실패"
        case Default = "미실행"
    }
    
    
    /** 결제 장비 대상 */
    public static let TARGETDEVICE:String = "TARGETDEVICE"  //결제 장비 대상
    public static let TAGETBLE:String = "Target_ble" //결제 대상이 ble
    public static let TAGETCAT:String = "Target_cat"    //결제 대상이 cat
    public enum TargetDeviceState:Int{
        case BLENOCONNECT = 0
        case BLECONNECTED = 1
        case CATCONNECTED = 2
    }
    
    /** 프린트 장비 대상 */
    public static let PRINTDEVICE:String = "PRINTDEVICE"  //프린트 장비 대상
    public static let PRINTBLE:String = "Print_ble" //프린트 대상이 ble
    public static let PRINTCAT:String = "Print_cat"    //프린트 대상이 cat
    public enum PrintDeviceState:Int{
        case BLENOPRINT = 0
        case BLEUSEPRINT = 1
        case CATUSEPRINT = 2
    }
    
    /** 현금IC 업무 구분 */
    public enum CashICBusinessClassification:String {
        case Buy = "C10" //현금 IC 구매 요청
        case Cancel = "C20" //C20" : 현금 IC 구매 취소(환불) 요청
        case Search = "C30"   //현금 IC 잔액 조회 요청
        case BuySearch = "C40"    // 현금 IC 구매결과 조회 요청
        case CancelSearch = "C50"     //현금 IC 환불결과 조회 요청
        
    }
    
    /** CAT 서버 접속시 에러메세지(내가 만들어야 할 경우)  */
    public enum CatConnectError:String {
        case IpPortError = "IpPortError"
        case ConnectError = "ConnectError"
        case SendDataError = "SendDataError"
        case SendAckError = "SendAckError"
        case SendCompliteError = "SendCompliteError"
        case ReceiveError = "ReceiveError"
        case ReceiveAckError = "ReceiveAckError"
        case ReceiveA110Error = "ReceiveA110Error"
        case EOTError = "EOTError"
        case ParsingError = "ParsingError"
        case ScanError = "ScanError"
        case NotSupportNumber = "NotSupportNumber"
    }
    
    /** BLE 전원 유지 시간 설정 */
    public enum BlePowerManager:UInt8 {
        case AllWays = 0x00
        case FiveMinute = 0x01
        case TenMinute = 0x02
        case FifteenMinute = 0x03
        case Twenty = 0x04
    }
    
    
    
    /** 상품등록 테블릿 번호  */
    public static let LOGIN_POS_NO: String = "LOGIN_POS_NO"

 
    //#0089CF
    public static let message_blue = UIColor(red: 0/255, green: 137/255, blue: 207/255, alpha: 1.0)
    //#0089CF
    public static let message_btn_green = UIColor(red: 0/255, green: 137/255, blue: 207/255, alpha: 1.0)
    //#0089CF
    public static let txt_title_blue = UIColor(red: 0/255, green: 137/255, blue: 207/255, alpha: 1.0)
    //#0089CF
    public static let layout_round_blue = UIColor(red: 0/255, green: 137/255, blue: 207/255, alpha: 1.0)
    //#EEF7E9
    public static let layout_round_green = UIColor(red: 238/255, green: 247/255, blue: 233/255, alpha: 1.0)
    //#EEF7E9
    public static let layout_bg_green = UIColor(red: 238/255, green: 247/255, blue: 233/255, alpha: 1.0)
    //#E95117
    public static let txt_title_orange = UIColor(red: 233/255, green: 81/255, blue: 23/255, alpha: 1.0)
    //#E1F0FF
    public static let layout_round_lite_blue = UIColor(red: 225/255, green: 240/255, blue: 255/255, alpha: 1.0)
    
    //#C8FF64
    public static let trackcolor = UIColor(red: 200/255, green: 255/255, blue: 100/255, alpha: 1.0)
    //#70AD47
    public static let thumbcolor = UIColor(red: 112/255, green: 173/255, blue: 71/255, alpha: 1.0)
    //#f2f2f2
    public static let lightgrey = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    //#f2f2f2
    public static let trackgrey = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    //#bfbfbf
    public static let grey = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1.0)
    //#526684
    public static let bottom_background = UIColor(red: 82/255, green: 102/255, blue: 132/255, alpha: 1.0)
    //#C35732
    public static let bottom_select = UIColor(red: 195/255, green: 87/255, blue: 50/255, alpha: 1.0)
    
    //#6D828F
    public static let nk_color_ok_strike = UIColor(red: 109/255, green: 130/255, blue: 143/255, alpha: 1.0)
    //#70AD47
    public static let nk_color_ok = UIColor(red: 112/255, green: 173/255, blue: 71/255, alpha: 1.0)
    //#B40000
    public static let nk_color_deleted = UIColor(red: 180/255, green: 0/255, blue: 0/255, alpha: 1.0)
    //#B46400
    public static let nk_color_cleared = UIColor(red: 180/255, green: 100/255, blue: 0/255, alpha: 1.0)
    //#C54C4C
    public static let nk_color_clear_strike = UIColor(red: 197/255, green: 76/255, blue: 76/255, alpha: 1.0)
    //#4cc552
    public static let nk_color_pressed = UIColor(red: 76/255, green: 197/255, blue: 82/255, alpha: 1.0)
    //#2E7D32
    public static let nk_color_strike = UIColor(red: 46/255, green: 125/255, blue: 50/255, alpha: 1.0)

}
