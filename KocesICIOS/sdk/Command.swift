//
//  Command.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/10.
//

import Foundation

class Command{
    
//    public static let HEAD_DATA_SIZE = 4
    public static let HEAD_DATA_SIZE = 2
    public static let STX:UInt8 = 0x02
    public static let ETX:UInt8 = 0x03
    public static let FS :UInt8 = 0x1c //28
    public static let EOT:UInt8 = 0x04    //Xmodem 사용
    public static let ENQ:UInt8 = 0x05   //Xmodem 사용
    public static let ACK:UInt8 = 0x06 // 06
    public static let NAK:UInt8 = 0x15 // 15
    public static let ESC:UInt8 = 0x1B
    
    public static let TIMEOUT:[UInt8] = [0x54, 0x49, 0x4D, 0x45, 0x4F, 0x55, 0x54]    // 서버에서 요청전문에 대한 응답을 받지 못해 타임아웃이 난경우


    
    /** 초기화  */
    public static let CMD_INIT:UInt8 = 0xA0 //초기화 요청
    public static let  CMD_SIGN_REQ:UInt8 = 0xA1 //서명 입력 요청
    public static let  CMD_SIGN_RES:UInt8 = 0xB1 //서명 입력(실시간) 응답
    public static let  CMD_SIGN_REQ1:UInt8 = 0xA7 //서명 입력 요청
    public static let  CMD_SIGN_RES2:UInt8 = 0xB7 //서명 입력(실시간) 응답
    public static let  CMD_SIGN_SEND_REQ:UInt8 = 0xA2 //서명 전송 요청
    public static let  CMD_SIGN_SEND_RES:UInt8 = 0xB2 //서명 전송 응답
    public static let  CMD_SIGN_CANCEL_REQ:UInt8 = 0xAC //서명 취소(종료) 요청
    public static let  CMD_SIGN_CANCEL_RES:UInt8 = 0xBC //서명 취소(종료) 응답
    public static let  CMD_NO_ENCYPT_NUMBER_REQ:UInt8 = 0xA3 //암호화하지 않은 번호요청
    public static let  CMD_NO_ENCYPT_NUMBER_RES:UInt8 = 0xB3 //암호화하지 않은 번호 응답
    public static let  CMD_ENCYPT_NUMBER_REQ:UInt8 = 0xA4 //암호화된 비밀번호 요청
    public static let  CMD_ENCYPT_NUMBER_RES:UInt8 = 0xB4 //암호화된 비밀번호 응답
    public static let  CMD_SEND_MSG_REQ:UInt8 = 0xA5 //메시지 전송 요청
    public static let  CMD_SEND_MSG_RES:UInt8 = 0xB5 //메시지 전송 응답
    public static let  CMD_PRINT_REQ:UInt8 = 0xC6 //출력 요청
    public static let  CMD_PRINT_RES:UInt8 = 0xC6 //출력 응답
    public static let  CMD_RF_INIT:UInt8 = 0xC0 // RF초기화 요청
    public static let  CMD_RF_TRADE_REQ:UInt8 = 0xC1 //RF거래 요청
    public static let  CMD_RF_TRADE_RES:UInt8 = 0xD1 //RF거래 응답
    public static let  CMD_QR_SEND_REQ:UInt8 = 0xC2 //QR전송 요청
    public static let  CMD_RF_SEND_RES:UInt8 = 0xD2 //QR전송 응답
    public static let  CMD_BACCOUNT_REQ:UInt8 = 0xC3 //계좌번호 표시 요청
    public static let  CMD_BACCOUNT_RES:UInt8 = 0xD3 //계좌번호 표시 응답
    public static let  CMD_CDC_SELECT_REQ:UInt8 = 0xC4 //자국환(DCC) 선택 요청
    public static let  CMD_CDC_SELECT_RES:UInt8 = 0xD4 //자국환(DCC) 선택 응답
    public static let  CMD_IC_REQ:UInt8  = 0x10 //IC 거래 요청
    public static let  CMD_IC_RES:UInt8  = 0x11 //IC 응답
    public static let  CMD_UNIONPAY_IC_CARD_SELECT_REQ:UInt8  = 0x12 //은련IC카드선택결과
    public static let  CMD_UNION_IC_:UInt8  = 0x13 //은련IC카드선택
    public static let  CMD_IC_RESULT_REQ:UInt8  = 0x20 //IC 거래결과 요청
    public static let  CMD_IC_RESULT_RES:UInt8 = 0x21 //IC 거래결과 응답
    public static let  CMD_KEYUPDATE_READY_REQ:UInt8 = 0x30 //보안키갱신생성요청
    public static let  CMD_CASHIC_RES:UInt8  = 0x31 //IC 응답 – 현금 IC
    public static let  CMD_CASHIC_MULTIPLE_ACCOUNT_REQ:UInt8  = 0x32 //현금 IC 선택된 계좌
    public static let  CMD_MULTIPAD_STATUS_RES:UInt8  = 0x34 //멀티패드 처리상태 알림
    public static let  CMD_KEYUPDATE_REQ:UInt8  = 0x40 //보안키갱신요청
    public static let  CMD_KEYUPDATE_READY_RES:UInt8  = 0x41 //보안키갱신생성응답
    public static let  CMD_VERITY_REQ:UInt8  = 0x50 //자체보호요청
    public static let  CMD_VERITY_RES:UInt8  = 0x51 //자체보호응답
    public static let  CMD_MUTUAL_AUTHENTICATION_REQ:UInt8 = 0x52 //상호인증 요청
    public static let  CMD_MUTUAL_AUTHENTICATION_RES:UInt8 = 0x53 //상호인증 응답
    public static let  CMD_MUTUAL_AUTHENTICATION_RESULT_REQ:UInt8  = 0x54 //상호 인증정보 결과 요청
    public static let  CMD_MUTUAL_AUTHENTICATION_RESULT_RES:UInt8  = 0x55 //상호 인증정보 결과 응답
    public static let  CMD_SEND_UPDATE_DATA_REQ:UInt8  = 0x56 //업데이트 파일전송
    public static let  CMD_SEND_UPDATE_DATA_RES:UInt8  = 0x57 //업데이트 결과
    public static let  CMD_POSINFO_REQ:UInt8 = 0x58 //단말기 정보요청
    public static let  CMD_POSINFO_RES:UInt8  = 0x59 //단말기 정보응답
    public static let  CMD_TWO_CARD_REQ:UInt8  = 0x14 //TwoCard 요청
    public static let  CMD_UNIONPAY_PARASSWORD_RES:UInt8  = 0x16 //은련 비밀번호 필요(요청)
    public static let  CMD_UNIONPAY_PARASSWORD_REQ:UInt8  = 0x17 //은련 비밀번호필요 (응답)
    public static let  CMD_CASHIC_PASSWARD_REQ:UInt8  = 0x18 //현금 IC 비밀번호(요청)
    public static let  CMD_IC_STATE_RES:UInt8  = 0x19 //카드 상태 응답
    public static let  CMD_IC_INSERT_REQ:UInt8  = 0x22 //카드 넣기 요청
    public static let  CMD_IC_REMOVE_REQ:UInt8  = 0x24 //카드 빼기 요청
    public static let  CMD_IC_STATE_REQ:UInt8  = 0x26 //카드 상태 요청
    public static let  CMD_FIRMWARE_READY_REQ:UInt8 = 0x4A  //펌웨어 업데이트 준비 요청
    public static let  CMD_FIRMWARE_UPDATE_REQ:UInt8 = 0x4B  //펌웨어 업데이트
    public static let  CMD_HASH_ENCYPT_REQ:UInt8  = 0x60 //hash암호화요청/응답
    public static let  CMD_CHECK_HASH_DATA_REQ:UInt8  = 0x61 //hash검증요청/응답
    public static let  CMD_RESET_FACTORY_REQ:UInt8 = 0x62 //단말기 공장초기화 요청
    public static let  CMD_RESET_FACTORY_RES:UInt8  = 0x63 //단말기 공장초기화 응답
    public static let  CMD_KEYIN_ENCYPT_REQ:UInt8  = 0x28 //KeyIn 정보 암호화 요청
    public static let  CMD_RFCARD_INFO_REQ:UInt8  = 0x64 //RF카드정보요청
    public static let  CMD_RFCARD_INFO_RES:UInt8  = 0x65 //RF카드정보응답
    public static let  CMD_BARCODE_REQ:UInt8  = 0x66 //바코드 리딩 요청
    public static let  CMD_BARCODE_RES:UInt8  = 0x66 //바코드 리딩 응답
    public static let  CMD_RFCARD_INFO_ENCYPT_REQ:UInt8  = 0x67 //RF카드정보요청(암호화데이터 추가)
    public static let  CMD_RFCARD_INFO_ENCYPT_RES:UInt8 = 0x67 //RF카드정보응답(암호화데이터 추가)
    public static let  CMD_BLE_POWER_MANAGER_REQ:UInt8 = 0x4F //BLE 전원연결유지시간 요청
    public static let  CMD_BLE_POWER_MANAGER_RES:UInt8 = 0x4F //BLE 전원연결유지시간 응답
    public static let  CMD_BLE_POWER_OFF_REQ:UInt8 = 0x48 //BLE 전원종료(앱과 연결을 종료하고 바로 장비도 종료시키기 위한 전문)
    
    /** TCP*/
    public static let TCP_HEAD_DATA_SIZE = 11
    public static let TCP_DATA_LEN_EXCLUDE_NOT_DATA = 5
//    public static let TCP_PROTOCOL_VERSION: [UInt8] = [ 0x31,0x30,0x31,0x34]    //1014
    public static let TCP_PROTOCOL_VERSION: [UInt8] = [ 0x31,0x30,0x31,0x38]    //1018
    
    public static let PRINT_BMP_IMAGE_SAMPLE: [UInt8] = [0x1c, 0x70, 0x01, 0x30, 0x0d, 0x0a, 0x1b, 0x40, 0x01, 0x1d, 0x21, 0x11, 0xbf, 0xb5, 0xbc, 0xf6, 0xc1, 0xf5, 0x20, 0x28, 0xb0, 0xed, 0xb0, 0xb4, 0xbf, 0xeb, 0x29, 0x0d, 0x0a, 0x1b, 0x40, 0x00, 0xb4, 0xeb, 0x20, 0x20, 0xc7, 0xa5, 0x20, 0x20, 0xc0, 0xda, 0x20, 0x3a, 0x20, 0xc7, 0xd1, 0xb1, 0xb9, 0xbd, 0xc5, 0xbf, 0xeb, 0xc4, 0xab, 0xb5, 0xe5, 0xb0, 0xe1, 0xc1, 0xa6, 0x28, 0xc1, 0xd6, 0x29, 0x0d, 0x0a, 0xbb, 0xe7, 0xbe, 0xf7, 0xc0, 0xda, 0xb9, 0xf8, 0xc8, 0xa3, 0x20, 0x3a, 0x20, 0x32, 0x31, 0x38, 0x2d, 0x34, 0x36, 0x2d, 0x33, 0x31, 0x39, 0x31, 0x37, 0x0d, 0x0a, 0xc0, 0xfc, 0xc8, 0xad, 0x20, 0x20, 0xb9, 0xf8, 0xc8, 0xa3, 0x20, 0x3a, 0x20, 0x31, 0x35, 0x37, 0x37, 0x2d, 0x30, 0x30, 0x31, 0x36, 0x0d, 0x0a, 0xc1, 0xd6, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0xbc, 0xd2, 0x20, 0x3a, 0x20, 0xbc, 0xad, 0xbf, 0xef, 0xc6, 0xaf, 0xba, 0xb0, 0xbd, 0xc3, 0x20, 0xb0, 0xad, 0xb3, 0xb2, 0xb1, 0xb8, 0x20, 0xbb, 0xef, 0xbc, 0xba, 0x31, 0xb5, 0xbf, 0x20, 0xb9, 0xab, 0xbf, 0xaa, 0xbc, 0xbe, 0xc5, 0xcd, 0xc6, 0xae, 0xb7, 0xb9, 0xc0, 0xcc, 0xb5, 0xe5, 0xc5, 0xb8, 0xbf, 0xf6, 0x20, 0x39, 0xc3, 0xfe, 0x20, 0x39, 0x30, 0x31, 0xc8, 0xa3, 0x0d, 0x0a, 0xc8, 0xa8, 0x20, 0xc6, 0xe4, 0x20, 0xc0, 0xcc, 0x20, 0xc1, 0xf6, 0x3a, 0x20, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x6b, 0x6f, 0x63, 0x65, 0x73, 0x2e, 0x63, 0x6f, 0x6d, 0x0d, 0x0a, 0xc3, 0xb3, 0x20, 0x20, 0xb8, 0xae, 0x20, 0x20, 0xc0, 0xda, 0x20, 0x3a, 0x20, 0xbb, 0xe7, 0x20, 0xbf, 0xf8, 0x0d, 0x0a, 0xb0, 0xc5, 0xb7, 0xa1, 0x20, 0x20, 0xc0, 0xcf, 0xc0, 0xda, 0x20, 0x3a, 0x20, 0x30, 0x30, 0x30, 0x30, 0xb3, 0xe2, 0x30, 0x30, 0xbf, 0xf9, 0x30, 0x30, 0xc0, 0xcf, 0x20, 0x30, 0x30, 0x3a, 0x30, 0x30, 0x3a, 0x30, 0x30, 0x0d, 0x0a, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x0d, 0x0a, 0x1d, 0x21, 0x20, 0xc3, 0xd1, 0x20, 0x20, 0xb0, 0xe8, 0x0d, 0x0a, 0x1b, 0x21, 0x00, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x0d, 0x0a, 0xb1, 0xdd, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0xbe, 0xd7, 0x20, 0x3a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x31, 0x2c, 0x30, 0x30, 0x34, 0x0d, 0x0a, 0xba, 0xce, 0x20, 0x20, 0xb0, 0xa1, 0x20, 0x20, 0xbc, 0xbc, 0x20, 0x3a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x30, 0x0d, 0x0a, 0xc7, 0xd5, 0xb0, 0xe8, 0x20, 0x20, 0xb1, 0xdd, 0xbe, 0xd7, 0x20, 0x3a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x31, 0x2c, 0x30, 0x30, 0x34, 0x0d, 0x0a, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x0d, 0x0a, 0x1b, 0x61, 0x31, 0x1d, 0x68, 0x32, 0x1d, 0x77, 0x02, 0x1d, 0x48, 0x02, 0x1d, 0x6b, 0x48, 0x14, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x1b, 0x61, 0x32, 0x5b, 0x42, 0x4d, 0x50, 0x5d, 0x0d, 0x0a, 0xbc, 0xad, 0x20, 0xb8, 0xed, 0x20, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x0d, 0x0a, 0x1b, 0x64, 0x03, 0x1b, 0x69, 0x1b, 0x64, 0x03]
    /**
     * TCP 전문용 설정값
     */
//    public static let PROTOCOL_VERSION:String = "1014";
    public static let PROTOCOL_VERSION:String = "1018";
    public static let POS_TYPE:String = "P";
    public static let TCPSEVER_DISCONNECTED = -1;
    public static let TCP_PROCEDURE_NONE = 0;
    public static let TCP_PROCEDURE_INIT = 1;
    public static let TCP_PROCEDURE_SEND = 2;
    public static let TCP_PROCEDURE_RESEND = 3;
    public static let TCP_PROCEDURE_DATA = 4;
    public static let TCP_PROCEDURE_SEND_ACK = 5;
    public static let TCP_PROCEDURE_SEND_NAK = 6;
    public static let TCP_PROCEDURE_EOT = 7;
    public static let TCP_PROCEDURE_RE_REQUEST = 10;
    public static let TCP_PROCEDURE_ERROR_PACKER_REQUEST = 11;

    public static let CMD_ICTRADE_REQ = "A10";
    public static let CMD_ICTRADE_CANCEL_REQ = "A20";
    public static let CMD_REGISTERED_SHOP_DOWNLOAD_REQ = "D10"; //가맹점 다운로드
    public static let CMD_REGISTERED_SHOPS_DOWNLOAD_REQ = "D11"; //복수 가맹점 다운로드 5개
    public static let CMD_REGISTERED_SHOPS_DOWNLOAD_NEW_REQ = "D12"; //복수 가맹점 다운로드 10개
    public static let CMD_KEY_UPDATE_REQ = "D20"; // 키업데이트
    public static let CMD_AD_DOWNLOAD_REQ = "D30"; // 광고 메세지 다운로드 요청
    public static let CMD_AD_DOWNLOAD_RES = "D35"; // 광고 메세지 다운로드 응답
    public static let CMD_SHOP_DOWNLOAD_RES = "D15";
    public static let CMD_SHOPS_DOWNLOAD_RES = "D16";
    public static let CMD_SHOPS_DOWNLOAD_NEW_RES = "D17";
    public static let CMD_KEY_UPDATE_RES = "D25";
    public static let CMD_IC_OK_RES = "A15";
    public static let CMD_IC_CANCEL_RES = "A25";
    
    public static let CMD_EASY_APPTOAPP_REQ = "E10";        //앱투앱으로 간편결제 요청
    public static let CMD_EASY_APPTOAPP_RES = "E15";        //앱투앱으로 간편결제 요청
    public static let CMD_EASY_APPTOAPP_CANCEL_REQ = "E20"; //앱투앱으로 간편결제 취소요청
    public static let CMD_EASY_APPTOAPP_CANCEL_RES = "E25"; //앱투앱으로 간편결제 취소요청

    public static let CMD_CASH_RECEIPT_REQ = "B10";  //현금영수증 전문 요청
    public static let CMD_CASH_RECEIPT_CANCEL_REQ = "B20";  //현금영수증 전문 취소 요청
    public static let CMD_CASH_RECEIPT_RES = "B15"; //현금영수증 전문 응답
    public static let CMD_CASH_RECEIPT_CANCEL_RES = "B25"; //현금영수증 전문 취소 응답

    public static let CMD_CASHIC_BUY_RES = "C15"; //현금 IC 구매 응답
    public static let CMD_CASHIC_BUY_CANCEL_RES = "C25"; //현금 IC 구매 취소(환불) 응답
    public static let CMD_CASHIC_CHECK_ACCOUNT_RES = "C35";// 현금 IC 잔액 조회 응답
    
    public static let CMD_WECHAT_ALIPAY_REQ = "W10";  //위쳇/알리페이 전문 요청
    public static let CMD_WECHAT_ALIPAY_CANCEL_REQ = "W20";  //위쳇/알리페이 전문 취소 요청
    public static let CMD_WECHAT_ALIPAY_SEARCH_REQ = "W30";  //위쳇/알리페이 전문 조회 요청
    public static let CMD_WECHAT_ALIPAY_SEARCH_CANCEL_REQ = "W40";  //위쳇 전문 조회취소 요청(알리는 조회취소가 없다)
    public static let CMD_WECHAT_ALIPAY_RES = "W15"; //위쳇/알리페이 전문 응답
    public static let CMD_WECHAT_ALIPAY_CANCEL_RES = "W25"; //위쳇/알리페이 전문 취소 응답
    public static let CMD_WECHAT_ALIPAY_SEARCH_RES = "W35"; //위쳇/알리페이 전문 조회 응답
    public static let CMD_WECHAT_ALIPAY_SEARCH_CANCEL_RES = "W45"; //위쳇 전문 조회취소 응답(알리는 조회취소가 없다)
    
    public static let CMD_ZEROPAY_REQ = "Z10";  //제로페이 전문 요청
    public static let CMD_ZEROPAY_CANCEL_REQ = "Z20";  //제로페이 전문 취소 요청
    public static let CMD_ZEROPAY_SEARCH_REQ = "Z30";  //제로페이 전문 취소조회 요청(취소 거래 이며 응답 코드 "0100" 수신 시 응답 메세지"처리결과 확인 필요" 문구 포스 디스플레이 후 가맹점 사용자 확인 후 취소 조회 업무 진행하여 정상 취소 처 리 여부 확인 필요)
    public static let CMD_ZEROPAY_RES = "Z15"; //제로페이 전문 응답
    public static let CMD_ZEROPAY_CANCEL_RES = "Z25"; //제로페이 전문 취소 응답
    public static let CMD_ZEROPAY_SEARCH_RES = "Z35"; //제로페이 전문 취소조회 응답(취소 거래 이며 응답 코드 "0100" 수신 시 응답 메세지"처리결과 확인 필요" 문구 포스 디스플레이 후 가맹점 사용자 확인 후 취소 조회 업무 진행하여 정상 취소 처 리 여부 확인 필요)

    public static let CMD_KAKAOPAY_REQ = "K21";  //카카오페이 전문 요청
    public static let CMD_KAKAOPAY_CANCEL_REQ = "K22";  //카카오페이 전문 취소 요청
    public static let CMD_KAKAOPAY_SEARCH_REQ = "K23";  //카카오페이 전문 승인조회 요청(카카오페이는 반드시 취소 전에 조회를 요청하고 결과를 받은 뒤에 해야 정상처리가 된다)
    public static let CMD_KAKAOPAY_RES = "K26"; //카카오페이 전문 응답
    public static let CMD_KAKAOPAY_CANCEL_RES = "K27"; //카카오페이 전문 취소 응답
    public static let CMD_KAKAOPAY_SEARCH_RES = "K28"; //카카오페이 전문 승인조회 응답(카카오페이는 반드시 취소 전에 조회를 요청하고 결과를 받은 뒤에 해야 정상처리가 된다)
    
    public static let CMD_CACULATE_AGGREGATION_REQ = "T20"  //온라인 정산집계 요청
    public static let CMD_CACULATE_AGGREGATION_RES = "T25"  //온라인 정산집계 응답
    
    public static let CMD_RECOMMAND_REQ = "F10"; //앱투앱/웹투앱으로 전표번호거래 재전송 요청
    public static let CMD_RECOMMAND_RES = "F15"; //앱투앱/웹투앱으로 전표번호거래 재전송 응답
    
    //포인트   ("P10" 의 경우 앱투앱을 통한 프린트 요청 명령어와 동일하다. 사용에 주의한다)
    public static let CMD_POINT_EARN_REQ = "P10";          //포인트 적립 승인 요청
    public static let CMD_POINT_EARN_CANCEL_REQ = "P20";   //포인트 적립 취소 요청
    public static let CMD_POINT_USE_REQ = "P30";           //포인트 사용 승인 요청
    public static let CMD_POINT_USE_CANCEL_REQ = "P40";    //포인트 사용 취소 요청
    public static let CMD_POINT_SEARCH_REQ = "P50";        //포인트 조회 요청
    public static let CMD_POINT_EARN_RES = "P15";          //포인트 적립 승인 응답
    public static let CMD_POINT_EARN_CANCEL_RES = "P25";   //포인트 적립 취소 응답
    public static let CMD_POINT_USE_RES = "P35";           //포인트 사용 승인 응답
    public static let CMD_POINT_USE_CANCEL_RES = "P45";    //포인트 사용 취소 응답
    public static let CMD_POINT_SEARCH_RES = "P55";        //포인트 조회 응답

    //멤버십
    public static let CMD_MEMBER_USE_REQ = "M10";          //멤버십 사용 요청
    public static let CMD_MEMBER_CANCEL_REQ = "M20";   //멤버십 사용 취소 요청
    public static let CMD_MEMBER_SEARCH_REQ = "M30";           //멤버십 조회 요청
    public static let CMD_MEMBER_USE_RES = "M15";          //멤버십 사용 응답
    public static let CMD_MEMBER_CANCEL_RES = "M25";   //멤버십 사용 취소 응답
    public static let CMD_MEMBER_SEARCH_RES = "M35";           //멤버십 조회 응답
    //포인트는 앱투앱에서 올 시 P가 아닌 다른것을 쓴다. P10을 이미 쓰고 있기 때문에
    public static let CMD_ONLY_APPTOAPP_POINT_EARN_REQ = "PO10";          //포인트 적립 승인 요청
    public static let CMD_ONLY_APPTOAPP_POINT_EARN_CANCEL_REQ = "PO20";   //포인트 적립 취소 요청
    public static let CMD_ONLY_APPTOAPP_POINT_USE_REQ = "PO30";           //포인트 사용 승인 요청
    public static let CMD_ONLY_APPTOAPP_POINT_USE_CANCEL_REQ = "PO40";    //포인트 사용 취소 요청
    public static let CMD_ONLY_APPTOAPP_POINT_SEARCH_REQ = "PO50";        //포인트 조회 요청
    public static let CMD_ONLY_APPTOAPP_POINT_EARN_RES = "PO15";          //포인트 적립 승인 응답
    public static let CMD_ONLY_APPTOAPP_POINT_EARN_CANCEL_RES = "PO25";   //포인트 적립 취소 응답
    public static let CMD_ONLY_APPTOAPP_POINT_USE_RES = "PO35";           //포인트 사용 승인 응답
    public static let CMD_ONLY_APPTOAPP_POINT_USE_CANCEL_RES = "PO45";    //포인트 사용 취소 응답
    public static let CMD_ONLY_APPTOAPP_POINT_SEARCH_RES = "PO55";        //포인트 조회 응답
    
    /**
            CAT 통신 커멘드
     */
    
    public static let CMD_CAT_AUTH:UInt8 = 0x47     //(Auth CMD “G”)
    public static let CMD_CAT_EASY_AUTH:UInt8 = 0x54;     //(Auth CMD “T”)
    /// 신용승인&*취소 DCC
    public static let CMD_CAT_CREDIT_REQ:[UInt8] = [0x47,0x31,0x32,0x30]    //"G120"
    /// 현금승인&취소
    public static let CMD_CAT_CASH_REQ:[UInt8] = [0x47,0x31,0x33,0x30]  // "G130"
    /// 은련승인&취소
    public static let CMD_CAT_UNIPAY_REQ:[UInt8] = [0x47,0x31,0x34,0x30]  // "G140"
    /// 앱카드
    public static let CMD_CAT_APPPAY_REQ:[UInt8] = [0x54,0x31,0x38,0x30]  // "G150"
    /// DCC 응답
    public static let CMD_CAT_DCC_REQ:[UInt8] = [0x47,0x31,0x36,0x30]  // "G160"
    /// 현금 IC
    public static let CMD_CAT_CASHIC_REQ:[UInt8] = [0x47,0x31,0x37,0x30]  // "G170"

    ///통신 전문 거래응답 신용승인 & 취소
    public static let CMD_CAT_CREDIT_RES = "G125"
    ///통신 전문 거래응답 현금승인&취소
    public static let CMD_CAT_CASH_RES = "G135"
    ///통신 전문 거래응답 은련승인&취소
    public static let CMD_CAT_UNIPAY_RES = "G145"
    ///통신 전문 거래응답 앱카드
    public static let CMD_CAT_APPPAY_RES = "G155"
    ///통신 전문 거래응답 DCC 응답
    public static let CMD_CAT_DCC_RES = "G165"
    ///통신 전문 거래응답 현금 IC
    public static let CMD_CAT_CASHIC_RES = "G175"
    
    /// 통신확인 TR COMMAND
    public static let CMD_CAT_TRCHECK_REQ:[UInt8] = [0x41,0x31,0x31,0x30]  //  "A110"  //거래 내역 있을 때
    public static let CMD_CAT_TRCHECK_REQ2:[UInt8] = [0x41,0x31,0x31,0x35] // "A115" //거래 내역 없을 때
    ///미전송거래 요청 전문
    public static let CMD_CAT_NOTRANS_TRADE_REQ:[UInt8] = [0x4D,0x31,0x31,0x30] // "M110" //미수신 거래)
    
    /* 현금IC업무 구분 */
    /// 현금 IC 구매 요청
    public static let CMD_CAT_CIC_BUY_REQ = "C10"
    /// 현금 IC 구매 응답
    public static let CAT_CASHIC_BUY_RES = "C15"
    public static let CAT_CASHIC_CANCEL_REQ = "C20"
    /// 현금 IC 구매 취소(환불) 응답
    public static let CAT_CASHIC_CANCEL_RES = "C25"
    public static let CAT_CASHIC_BALANCE_REQ = "C30"
    /// 현금 IC 잔액 조회 응답
    public static let CAT_CASHIC_BALANCE_RES = "C35"
    public static let CAT_CASHIC_RESULT_REQ = "C40"
    /// 현금 IC 구매결과 조회 응답
    public static let CAT_CASHIC_RESULT_RES = "C45"
    public static let CAT_CASHIC_CANCEL_RESULT_REQ = "C50"
    /// 현금 IC 환불결과 조회 응답
    public static let CAT_CASHIC_CANCEL_RESULT_RES = "C55"
    
    /// 프린트시 한라인의 바이트수
    public static let lineCount:Int = 48;
    
    // ================================= BLE 전문===============================================
 
    ///장치에 ACK, NAK, EOT, ESC 를 날린다
    static func SendCommand(Command _command:UInt8)-> [UInt8]
    {
        let Data: [UInt8] = Array()
        return Utils.MakePacket(_Command: _command,_Data: Data)
    }

     ///장치 초기화
     ///- parameter VanCode: 일반 서명패드, 멀티패드-99 기존 통합동글용-13 COSTCO 서명패드-88
     ///- returns: 완성된 패킷 데이터 UInt8 Array
    static func DeviceInit(VanCode _vanCode:String)-> [UInt8]
    {
        let VanCode: [UInt8] = Array( _vanCode.utf8)
        return Utils.MakePacket(_Command: Command.CMD_INIT,_Data: VanCode)
    }
    
    /**
     단말기 정보 요청 장비정보
     - parameter _Date: 현재 시간  yyyyMMddhhmmss (14자)
     - Returns: 완성된 패킷 데이터 UInt8 Array
     */
    static func GetSystemInfo(Date _Date:String)-> [UInt8]
    {
        let Date: [UInt8] = Array( _Date.utf8)
        return Utils.MakePacket(_Command: Command.CMD_POSINFO_REQ,_Data: Date)
    }
    
    /// 장치 무결성 검사
    /// - Returns: 완성된 패킷 데이터 UInt8 Array
    static func GetVerity()-> [UInt8]
    {
        let Data: [UInt8] = Array()
        return Utils.MakePacket(_Command: Command.CMD_VERITY_REQ,_Data: Data)
    }
    
    /// 장치에 보안키 관련 업데이트 준비 요청
    /// - Returns: 완성된 패킷 데이터 UInt8 Array
    static func KeyDownload_Ready()-> [UInt8]
    {
        let Data: [UInt8] = Array()
        return Utils.MakePacket(_Command: Command.CMD_KEYUPDATE_READY_REQ,_Data: Data)
    }
    
    /// 장치에 보안키 업데이트
    /// - Parameters:
    ///   - _time: 서버로 부터 받은 시각 또는 IOS 현재 시각
    ///   - _data: 보안키 데이터
    /// - Returns: 완성된 패킷 데이터 UInt8 Array
    static func KeyDownload_Update(Time _time:String ,Data _data:[UInt8] )-> [UInt8]
    {
        var Data: [UInt8] = Array()
        Data += Array( _time.utf8)
        Data += _data
        return Utils.MakePacket(_Command: CMD_KEYUPDATE_REQ, _Data: Data)
    }
    
    /**
         *  업데이트 파일전송 (PC -> 멀티패드)
         * @param _type 요청데이타구분 4 Char 0001:최신펌웨어, 0003:EMV Key
         * @param _dataLength 데이터 총 크기
         * @param _sendDataSize 전송중인 데이터 크기
         * @param _defaultSize 기본사이즈 크기, 아래의 데이터가 이것보다 작으면 데이터의 뒤에 0x00을 붙인다
         * @param _data 데이터
         * @return
         */
    static func updatefile_transfer_req( _type:String, _dataLength:String, _sendDataSize:String, _defaultSize:Int,  _data:[UInt8]) -> [UInt8]
        {
            var bArray: [UInt8] = Array()
            bArray += Array( _type.utf8)

            var _l : Int = 10 - _dataLength.count;
            bArray += Array( _dataLength.utf8)
            
            for i in 0 ..< _l {
                bArray.append(0x00)
            }

            if(_sendDataSize == "") {
                bArray += Array( _sendDataSize.utf8)
            } else {
                var _j : Int = 10 - _sendDataSize.count;
                bArray += Array( _sendDataSize.utf8)
                for i in 0 ..< _j {
                    bArray.append(0x00)
                }
            }

            if (_data.count < _defaultSize) {
                bArray += _data
                for i in _data.count ..< _defaultSize {
                    bArray.append(0x00)
                }

            } else {
                bArray += _data
            }

            return Utils.MakePacket(_Command: CMD_SEND_UPDATE_DATA_REQ,_Data: bArray);
        }
    
    /**
     * 상호인증 요청 (PC -> USB멀티패드)
     * @param _type : 0001:최신펌웨어, 0003:EMV Key
     * @return
     */
    static func mutual_authenticatoin_req(_type:String) -> [UInt8]
    {
        var Data: [UInt8] = Array()
        Data += Array( _type.utf8)
        return Utils.MakePacket(_Command: CMD_MUTUAL_AUTHENTICATION_REQ, _Data: Data);
    }
    
    /**
         *  상호 인증정보 결과 요청 (PC  -> 멀티패드)
         * @param _date 시간 14 Char YYYYMMDDHHMMSS
         * @param _multipadAuth 멀티패드인증번호 32 Char 인증업체로부터 발급받은 단말 인증 번호
         * @param _multipadSerial 멀티패드시리얼번호 10 Char 멀티패드 시리얼 번호
         * @param _code 응답코드 4 * Char 정상응답 : ‚0000‛(그외 실패) 실패 수신 시 ‚0x55‛응답도 실패(01)처리
         * @param _resMsg 응답메세지
         * @param _key 접속보안키 48 Bin Srandom(16)+KEY2_ENC(IPEK+Crandom, 32)
         * @param _dataCount 데이터 개수 4 Char 주4) 데이터의 개수
         * @param _protocol 전송 프로토콜 5 Char "SFTP"
         * @param _Addr 다운로드서버주소
         * @param _port 포트
         * @param _id 계정
         * @param _passwd 비밀번호
         * @param _ver 버전 및 데이터 구분
         * @param _verDesc 버전 설명
         * @param _fn 파일명
         * @param _fnSize 파일크기
         * @param _fnCheckType 파일체크방식
         * @param _fnChecksum 파일체크섬
         * @param _dscrKey 파일복호화키
         * @return
         */
    static func authenticatoin_result_req( _date:[UInt8],_multipadAuth:[UInt8], _multipadSerial:[UInt8], _code:[UInt8], _resMsg:[UInt8], _key:[UInt8], _dataCount:[UInt8], _protocol:[UInt8], _Addr:[UInt8], _port:[UInt8], _id:[UInt8], _passwd:[UInt8], _ver:[UInt8], _verDesc:[UInt8], _fn:[UInt8], _fnSize:[UInt8], _fnCheckType:[UInt8], _fnChecksum:[UInt8], _dscrKey:[UInt8]) -> [UInt8]
        {
            var bArray: [UInt8] = Array()

            if (_date.count < 14) {
                bArray += _date;
                for i in _date.count ..< 14 {
                    bArray.append(0x20)
                }

            } else {
                bArray += _date;
            }

            if (_multipadAuth.count < 32) {
                bArray += _multipadAuth
                for i in _multipadAuth.count ..< 32 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _multipadAuth
            }

            if (_multipadSerial.count < 10) {
                bArray += _multipadSerial
                for i in _multipadSerial.count ..< 10 {
                    bArray.append(0x20)
                }

            } else {
                bArray += _multipadSerial
            }

            if (_code.count < 4) {
                bArray += _code
                for i in _code.count ..< 4 {
                    bArray.append(0x20)
                }

            } else {
                bArray += _code
            }

            if (_resMsg.count < 80) {
                bArray += _resMsg
                for i in _resMsg.count ..< 80 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _resMsg
            }

            if (_key.count < 48) {
                bArray += _key
                for i in _key.count ..< 48 {
                    bArray.append(0x20)
                }

            } else {
                bArray += _key
            }

            if (_dataCount.count < 4) {
                bArray += _dataCount
                for i in _dataCount.count ..< 4 {
                    bArray.append(0x20)
                }

            } else {
                bArray += _dataCount
            }

            if (_protocol.count < 5) {
                bArray += _protocol
                for i in _protocol.count ..< 5 {
                    bArray.append(0x20)
                }

            } else {
                bArray += _protocol
            }

            if (_Addr.count < 80) {
                bArray += _Addr
                for i in _Addr.count ..< 80 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _Addr
            }

            if (_port.count < 5) {
                bArray += _port
                for i in _port.count ..< 5 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _port
            }

            if (_id.count < 16) {
                bArray += _id
                for i in _id.count ..< 16 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _id
            }

            if (_passwd.count < 16) {
                bArray += _passwd
                for i in _passwd.count ..< 16 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _passwd
            }

            if (_ver.count < 5) {
                bArray += _ver
                for i in _ver.count ..< 5 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _ver
            }

            if (_verDesc.count < 80) {
                bArray += _verDesc
                for i in _verDesc.count ..< 80 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _verDesc
            }

            if (_fn.count < 256) {
                bArray += _fn
                for i in _fn.count ..< 256 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _fn
            }

            if (_fnSize.count < 10) {
                bArray += _fnSize
                for i in _fnSize.count ..< 10 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _fnSize
            }

            if (_fnCheckType.count < 5) {
                bArray += _fnCheckType
                for i in _fnCheckType.count ..< 5 {
                    bArray.append(0x20)
                }
            } else {
                bArray += _fnCheckType
            }

            if (_fnChecksum.count < 64) {
                bArray += _fnChecksum
                for i in _fnChecksum.count ..< 64 {
                    bArray.append(0x00)
                }
            } else {
                bArray += _fnChecksum
            }

            if (_dscrKey.count < 32) {
                bArray += _dscrKey
                for i in _dscrKey.count ..< 32 {
                    bArray.append(0x00)
                }
            } else {
                bArray += _dscrKey
            }

            return Utils.MakePacket(_Command: CMD_MUTUAL_AUTHENTICATION_RESULT_REQ, _Data: bArray)
        }
    
    /**
         * TMS 단말기 데이타 다운로드 정보 요청
         * @param _Command
         * @param _Tid
         * @param _swVer
         * @param _serialNum
         * @param _dataType
         * @param _secKey
         * @return
         */
    static func TCP_TMSDownInfo( _Command:String, _Tid:String, _swVer:String, _serialNum:[UInt8], _dataType:String, _secKey:[UInt8]) -> [UInt8]
        {

            var b: [UInt8] = Array()
            b += Array( "1".utf8) //유무선구분 1:유선 2:무선 1만쓴다
            if (_Tid == "")
            {
                for _ in 0 ..< 10 {
                    b.append(0x20)
                }
            }
            else {
                b += Array(_Tid.utf8);
            }

            b += Array(_swVer.utf8);
            b += _serialNum;
            b.append(Command.FS);
            b += Array(_dataType.utf8);
            b.append(Command.FS);
            b.append(Command.FS);
            b.append(Command.FS);
            b.append(Command.FS);
            b.append(Command.FS);
            
            var ConvertsignData : String = _secKey.map{ String(format:"%02X", $0) }.joined(separator: "")
            b += Array(ConvertsignData.utf8);
    //        b.Add(_secKey);
            b.append(Command.FS);
            return Utils.MakeTMSClientPacket(PacketData: b, _cmd: _Command);
        }
    
    /**
     IC 요청 전문 (PC -> 멀티패드)
     
     01:신용IC(RF포함) 참고2),
     
     02: 은련IC
     
     03: 현금IC
    
     04: 포인트/맴버쉽
     
     05: Two Card(신용+포인트)
     
     06: 현금영수증
     
     07: FallBack MSR
     
     08:RF
     
     09:현금영수증(자진발급)
     
     10:은련 FallBack MSR
     
     11:현금IC 카드조회 참고3)
     
     12:가맹점 자체 MS전용 회원카드 참고4)

     * - Parameters:
     *   - _type: _type 거래구분
     *   - _money: 금액 최대 10자리
     *   - _date: YYYYMMDDHHmmss
     *   - _usePad: 서명패드입력여부 (멀티패드만 해당)
     *   - _cashIC: 현금IC간소화 1 Char 0:미사용, 1:사용
     *   - _printCount: 전표출력카운터 4 Char 단말기에서는 전표출력 순번 사용
     *   - _signType: 서명데이터 치환방식 1 Char ‘0’(0x30) : 치환하지 않음
     *   - _minPasswd: 입력 최소 길이 2 Char 비밀번호 경우 : ‚00‛ /  현금영수증 경우 ‚01‛
     *   - _MaxPasswd: 입력 최대 길이 2 Char 비밀번호 경우 : ‚06‛ /  현금영수증 경우 ‚40‛
     *   - _workingKeyIndex: Working Key Index 2 Char Working Key Index   2 bytev
     *   - _workingkey: Working Key 16 Char Working Key         16 bytev
     *   - _cashICRnd: 현금IC 난수 32 Char
     * - Returns: 완성된 패킷 데이터 UInt8 Array
     */
    static func Credit(Type _type:String,Money _money:String,Date _date:String,UsePad _usePad:String,CashIC _cashIC:String,PrintCount _printCount:String,
                      SignType _signType:String,MinPasswd _minPasswd:String,MaxPasswd _MaxPasswd:String,WorkingKeyIndex _workingKeyIndex:String,WorkingKey _workingkey:String,CashICRnd _cashICRnd:String)-> [UInt8]
    {
        var Data:[UInt8] = Array()

        Data += StrToArr(_type); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_type)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_money); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_money)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_date); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_date)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_usePad); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_usePad)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_cashIC); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_cashIC)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_printCount); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_printCount)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_signType); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_signType)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_minPasswd); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_minPasswd)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_MaxPasswd); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_MaxPasswd)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_workingKeyIndex); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_workingKeyIndex)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_workingkey); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_workingkey)), Tid: PaySdk.instance.mTid);
        Data += StrToArr(_cashICRnd); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_cashICRnd)), Tid: PaySdk.instance.mTid);

        return Utils.MakePacket(_Command:Command.CMD_IC_REQ, _Data: Data )
    }
    
    static func Cash()-> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0)
        return Data
    }
    
    
    /// 프린트 초기화
    /// - Returns: 완성된 패킷 데이터 UInt8 Array
    static func PrintInit() -> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data.insert(Command.ESC, at: 0)
        Data.append(0x40)
        
        return Utils.MakePacket(_Command: Command.CMD_PRINT_REQ, _Data: Data )
    }
    
    
    /// 프린트
    /// - Parameter _Contents: <#_Contents description#>
    /// - Returns: <#description#>
    static func Print(_Contents:[UInt8]) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data += _Contents
        
        return Utils.MakePacket(_Command: Command.CMD_PRINT_REQ, _Data: Data )
    }
    
    ///전원유지시간설정
    static func PowerManager(_Content:[UInt8]) -> [UInt8]
    {
        var Data:[UInt8] = []
        Data += _Content
        return Utils.MakePacket(_Command: Command.CMD_BLE_POWER_MANAGER_REQ, _Data: Data)
    }
    
    ///전원종료
    static func PowerOff() -> [UInt8]
    {
        var Data:[UInt8] = []
        return Utils.MakePacket(_Command: Command.CMD_BLE_POWER_OFF_REQ, _Data: Data)
    }
    
    /**
     * 펌웨어 다운로드 준비
     */
    static func FirmwareUpgradeReady() -> [UInt8] {
        var Data: [UInt8] = Array()
        return Utils.MakePacket(_Command: CMD_FIRMWARE_READY_REQ, _Data: Data)
    }
    
    static func FirmwareUpgradeStart() -> [UInt8] {
        var Data:[UInt8] = Array()
        Data += Array("CONNECT SERVER".utf8)
        return Data
    }
    
    static func FirmwareUpgradeStart2() -> [UInt8] {
        let Data:[UInt8] = [0x05,0x05,0x05]
        return Data
    }
    
    ///펌웨어 사이즈 전달
    static func FirmwareFileSize(filesize fs:Int) -> [UInt8] {
        var d:[UInt8] = Array()
        d.insert(Command.STX, at: 0)
        
        var content:[UInt8]=Array()
        content.insert(Command.FS, at: 0)
        content += Array("FileSize".utf8)
        content.append(Command.FS)
        content += Utils.Int4ToUInt8ArrayStringType(_value: Array(String(fs).utf8).count)
        content += Array(String(fs).utf8)
        
        d += Utils.Int4ToUInt8ArrayStringType(_value: content.count)
        d += content
        
        d.append(Command.ETX)
        d.append(Utils.makeLRC(_data: d))   //펌웨어만 LRC구조가 다름
        return d
    }
    ///펌웨어 데이터 전달
    static func FirmwareData(data _data:[UInt8]) -> [UInt8] {
        var d:[UInt8] = Array()
        d.insert(Command.STX, at: 0)
        
        var content:[UInt8]=Array()
        content.insert(Command.FS, at: 0)
        content += Array("HTMS".utf8)
        content.append(Command.FS)
        content += Utils.Int4ToUInt8ArrayStringType(_value: _data.count)
        content += _data
        
        d += Utils.Int4ToUInt8ArrayStringType(_value: content.count)
        d += content
        d.append(Command.ETX)
        d.append(Utils.makeLRC(_data: d))
        return d
    }
    //펌웨어 완료 전달
    static func FirmwareComplete() -> [UInt8] {
        var d:[UInt8] = Array()
        d.insert(Command.STX, at: 0)
        
        var content:[UInt8]=Array()
        content.insert(Command.FS, at: 0)
        content += Array("Complete".utf8)
        content.append(Command.FS)
        content += [0x30,0x30,0x31,0x36,0xC6,0xC4,0xC0,0xCF,0xC0,0xFC,0xBC,0xDB,0xBF,0xCF,0xB7,0xE1,0x20,0x20,0x20,0x20]
        
        d += Utils.Int4ToUInt8ArrayStringType(_value: content.count)
        d += content
        d.append(Command.ETX)
        d.append(Utils.makeLRC(_data: d)) 

        return d
    }
    // ================================================ TCP 전문 ========================================================
    
    /**
     TCP 가맹점등록 다운로드 전문 제작 함수
     - parameter _Command: "D10" : 가맹점다운로드  "D11","D12" : 복수가맹점다운로드  "D20" : 키업데이트 6
     - parameter _Tid: 단말기 ID
     - parameter _Date: 거래일시 14 N YYMMDDhhmmss
     - parameter _posVer: 전문일련번호
     - parameter _etc: 미정
     - parameter _length: 길이 4byte 128byte => 0128
     - parameter _posCheckdata: 단말 검증 요청 데이터 길이(3byte, ex.087)+TrsmID(7)+Crandom(16)+KEY1_ENC(25바이 트Timpstamp+가변SvrInfo+7바이트TID+16바이트CRandom) MDO : 가맹점 정보 다운로드 ONLY(Key 다운로드 안함) 15
     - parameter _Bsn: 가맹점 사업자 번호
     - parameter _Serial: 장비 제조일련번호
     - parameter _posData: 가맹점데이터
     -  parameter _macAddr: 맥어드레스 또는 UUID
     - returns: [UInt8] 서버 요청 전문
     */
    static func StoreDownloadReq(Command _Command:String,Tid _Tid:String,Date _Date:String,PosVer _posVer:String,Etc _etc:String,Length _length:String,
                                    PosCheckData _posCheckdata:String ,BSN _Bsn:String,Serial _Serial:String,PosData _posData:String,MacAddr _macAddr:String) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid);
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(_Date); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Date)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(_posVer); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid);
        if _etc != "" {
            Data += StrToArr(_etc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_length); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_length)), Tid: _Tid);
        
        if _posCheckdata == "" {     //단말 검증 요청 데이터는 Binary 타입
            for _ in 0 ..< Int(_length)! {
                Data.append(0x00)
            }
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x00, count: Int(_length)!)), Tid: _Tid);
        } else {
            Data += StrToArr(_posCheckdata); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posCheckdata)), Tid: _Tid);
        }
        
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _Command != "D20" { // D20의 경우에는 사업자 번호를 넣지 않는다.
            Data += StrToArr(_Bsn); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Bsn)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_Serial); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Serial)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        if _posData == ""{
            for _ in 0 ..< 64{
                Data.append(0x20)
            }
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 64)), Tid: _Tid);
        } else {
            Data += StrToArr(_posData); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posData)), Tid: _Tid);
        }
        
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _Command != "D20" { // D20의 경우에는 UUID 주소를 넣지않는다
            Data += StrToArr(_macAddr); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_macAddr)), Tid: _Tid);
        }
      
        return Utils.MakeClientPacket(PacketData: Data);
    }
    
    /**
     TCP 가맹점등록 다운로드 전문 제작 함수
     - parameter _Command: "D10" : 가맹점다운로드  "D11" ,"D12": 복수가맹점다운로드  "D20" : 키업데이트 6
     - parameter _Tid: 단말기 ID
     - parameter _Date: 거래일시 14 N YYMMDDhhmmss
     - parameter _posVer: 전문일련번호
     - parameter _etc: 미정
     - parameter _length: 길이 4byte 128byte => 0128
     - parameter _posCheckdata: 단말 검증 요청 데이터 길이(3byte, ex.087)+TrsmID(7)+Crandom(16)+KEY1_ENC(25바이 트Timpstamp+가변SvrInfo+7바이트TID+16바이트CRandom) MDO : 가맹점 정보 다운로드 ONLY(Key 다운로드 안함) 15
     - parameter _Bsn: 가맹점 사업자 번호
     - parameter _Serial: 장비 제조일련번호
     - parameter _posData: 가맹점데이터
     - parameter _macAddr: 맥어드레스 또는 UUID
     - returns: [UInt8] 서버 요청 전문
     */
    static func KeyReq(Command _Command:String,Tid _Tid:String,Date _Date:String,PosVer _posVer:String,Etc _etc:String,Length _length:String,
                                    PosCheckData _posCheckdata:[UInt8] ,BSN _Bsn:String,Serial _Serial:String,PosData _posData:String,MacAddr _macAddr:String) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid);
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid)
        Data += StrToArr(_Date);    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Date)), Tid: _Tid)
        Data += StrToArr(Utils.getUniqueProtocolNumbering());   LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid)
        Data += StrToArr(define.POS_TYPE);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid)
        Data += StrToArr(_posVer);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid)
        if _etc != "" {
            Data += StrToArr(_etc);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid)
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_length);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_length)), Tid: _Tid)
        
        Data += _posCheckdata;  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _posCheckdata), Tid: _Tid)
        
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _Command != "D20" { // D20의 경우에는 사업자 번호를 넣지 않는다.
            Data += StrToArr(_Bsn);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Bsn)), Tid: _Tid)
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_Serial);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Serial)), Tid: _Tid)
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        if _posData == ""{
            for _ in 0 ..< 64{
                Data.append(0x20)
            }
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 64)), Tid: _Tid)
            
        } else {
            Data += StrToArr(_posData);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posData)), Tid: _Tid)
        }
        
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _Command != "D20" { // D20의 경우에는 UUID 주소를 넣지않는다
            Data += StrToArr(_macAddr);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_macAddr)), Tid: _Tid)
        }

        return Utils.MakeClientPacket(PacketData: Data);
    }
    
    /**
     TCP 광고메세지 다운로드(D30)
     - parameter _Command: "D30" : 광고메세지다운로드
     - parameter _Tid: 단말기 ID
     - parameter _Date: 거래일시 14 N YYMMDDhhmmss
     - parameter _posVer: 전문일련번호
     - parameter  광고출력구분: 0:문자광고, 1:화면이미지, 2:2인치전표이미지, 3:3인치전표이미지
     - parameter _문자출력코드 0:완성형, 1:조합형
     - parameter _문자출력가능길이 3바이트
     - parameter _문자출력가능라아니 2바이트
     - parameter _이미지출력포맷 BMP, JPG, PNG 현재 BMP 만 지원, 스페이스패등은 이미지출력불가단말기 3바이트
     - parameter _이미지출력가능 가로사이즈 4바이트
     - parameter _이미지출력가능 세로사이즈 4바이트
     - parameter _PosData 가맹점데이터
     - returns: [UInt8] 서버 요청 전문
     */
    static func AdDownload(Command _Command:String,Tid _Tid:String,Date _Date:String,PosVer _posVer:String,Etc _etc:String,
                           광고출력구분 _광고출력구분:String, 문자출력구분 _문자출력구분:String, 문자출력길이 _문자출력길이:String, 문자출력라인 _문자출력라인:String,
                           이미지출력포맷 _이미지출력포맷:String, 이미지출력가로사이즈 _이미지출력가로사이즈:String, 이미지출력세로사이즈 _이미지출력세로사이즈:String,
                           PosData _posData:String) ->[UInt8]{
        
        var Data:[UInt8] = Array()
        
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid);
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid)
        Data += StrToArr(_Date);    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Date)), Tid: _Tid)
        Data += StrToArr(Utils.getUniqueProtocolNumbering());   LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid)
        Data += StrToArr(define.POS_TYPE);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid)
        Data += StrToArr(_posVer);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid)
        if _etc != "" {
            Data += StrToArr(_etc);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid)
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        Data += StrToArr(_광고출력구분); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_광고출력구분)), Tid: _Tid);
        Data += StrToArr(_문자출력구분); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_문자출력구분)), Tid: _Tid);
        Data += StrToArr(_문자출력길이); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_문자출력길이)), Tid: _Tid);
        Data += StrToArr(_문자출력라인); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_문자출력라인)), Tid: _Tid);
        Data += StrToArr(_이미지출력포맷); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_이미지출력포맷)), Tid: _Tid);
        Data += StrToArr(_이미지출력가로사이즈); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_이미지출력가로사이즈)), Tid: _Tid);
        Data += StrToArr(_이미지출력세로사이즈); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_이미지출력세로사이즈)), Tid: _Tid);

        
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        if _posData == ""{
            for _ in 0 ..< 64{
                Data.append(0x20)
            }
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 64)), Tid: _Tid)
            
        } else {
            Data += StrToArr(_posData);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posData)), Tid: _Tid)
        }
        
        return Utils.MakeClientPacket(PacketData: Data);
    }
    
    /**
     신용 결제
     - parameter   _Command:
     - parameter _Tid: <#_Tid description#>
     - parameter _date: <#_date description#>
     - parameter _posVer: <#_posVer description#>
     - parameter _etc: <#_etc description#>
     - parameter _ResonCancel: <#_ResonCancel description#>
     - parameter _inputType: <#_inputType description#>
     - parameter _CardNum: <#_CardNum description#>
     - parameter _encryptInfo: <#_encryptInfo description#>
     - parameter _money: <#_money description#>
     - parameter _tax: <#_tax description#>
     - parameter _svc: <#_svc description#>
     - parameter _txf: <#_txf description#>
     - parameter _currency: <#_currency description#>
     - parameter _Installment: <#_Installment description#>
     - parameter _PoscertifiNum: <#_PoscertifiNum description#>
     - parameter _tradeType: <#_tradeType description#>
     - parameter _emvData: <#_emvData description#>
     - parameter _fallback: <#_fallback description#>
     - parameter _ICreqData: <#_ICreqData description#>
     - parameter _keyIndex: <#_keyIndex description#>
     - parameter _passwd: <#_passwd description#>
     - parameter _oil: <#_oil description#>
     - parameter _txfOil: <#_txfOil description#>
     - parameter _Dccflag: <#_Dccflag description#>
     - parameter _DccreqInfo: <#_DccreqInfo description#>
     - parameter _ptCode: <#_ptCode description#>
     - parameter _ptNum: <#_ptNum description#>
     - parameter _ptCardEncprytInfo: <#_ptCardEncprytInfo description#>
     - parameter _SignInfo: <#_SignInfo description#>
     - parameter _signPadSerial: <#_signPadSerial description#>
     - parameter _SignData: <#_SignData description#>
     - parameter _Cert: <#_Cert description#>
     - parameter _posData: <#_posData description#>
     - parameter _kocesUid: <#_kocesUid description#>
     - parameter _uniqueCode:
     - parameter _macAddr:
     - parameter _hardwareKey:
     - Returns: <#description#>
     */
    static func TCPICReq(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,
                         CardNumber _CardNum:String,EncryptInfo _encryptInfo:[UInt8],Money _money:String,Tax _tax:String,ServiceCharge _svc:String,TaxFree _txf:String,Currency _currency:String,
                         InstallMent _Installment:String,PosCertificationNumber _PoscertifiNum:String,TradeType _tradeType:String,EmvData _emvData:String,ResonFallBack _fallback:String,
                         ICreqData _ICreqData:[UInt8],WorkingKeyIndex _keyIndex:String,Password _passwd:String,OilSurpport _oil:String,OilTaxFree _txfOil:String,DccFlag _Dccflag:String,
                         DccReqInfo _DccreqInfo:String,PointCardCode _ptCode:String,PointCardNumber  _ptNum:String,PointCardEncprytInfo _ptCardEncprytInfo:[UInt8],SignInfo _SignInfo:String,
                         SignPadSerial _signPadSerial:String,SignData _SignData:[UInt8],Certification _Cert:String,PosData _posData:String,KocesUid _kocesUid:String,UniqueCode _uniqueCode:String,MacAddr _macAddr:String, HardwareKey _hardwareKey:String) -> [UInt8]
    {

        var Data:[UInt8] = Array()
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid); //전문커맨드
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(_date); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_date)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(_posVer); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid);


        //단말추가정보 미설정 시:String, 데이터 미설정(20.05.20)
        if _etc != "" {
            Data += StrToArr(_etc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ResonCancel != "" {
            Data += StrToArr(_ResonCancel); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ResonCancel)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_inputType); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_inputType)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_CardNum); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_CardNum)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _encryptInfo.count > 0 {
            Data += StrToArr(String(format: "%04d", _encryptInfo.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _encryptInfo.count))), Tid: _Tid);
            Data += _encryptInfo; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _encryptInfo), Tid: _Tid);
        }else{
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_money); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_money)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _tax != "" || _tax != "0"{ // 세금이 0이 아니라면
            Data += StrToArr(_tax); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_tax)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _svc != "" || _svc != "0" { //봉사료가  0이 아니면
            Data += StrToArr(_svc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_svc)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _txf != "" || _txf != "0" { //면세  0이 아니면
            Data += StrToArr(_txf); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_txf)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _currency != "" || _currency != "410" { //통화코드가 410이 아니면
            Data += StrToArr(_currency); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_currency)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _Installment == "" || _Installment == "0" || _Installment == "1" || _Installment == "00" || _Installment == "01" { }
        else{
            Data += StrToArr(_Installment.count == 1 ? "0" + _Installment:_Installment ); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Installment.count == 1 ? "0" + _Installment:_Installment)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_PoscertifiNum); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_PoscertifiNum)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _tradeType != "" {
            Data += StrToArr(_tradeType); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_tradeType)), Tid: _Tid);
        } //전화승인or 은련핫키입력일경우
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_emvData); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_emvData)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        //fallback거래 아닐경우 폴백 사유 미설정, 스페이스패딩 하지 말 것(20.05.23)
        if _fallback != "" {
            Data += StrToArr(_fallback); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_fallback)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        //
        if(_ICreqData.count > 0 ) {
            Data += StrToArr(String(format: "%04d", _ICreqData.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _ICreqData.count))), Tid: _Tid);
            Data += _ICreqData; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _ICreqData), Tid: _Tid);
        }
        else {
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_keyIndex); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_keyIndex)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_passwd); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_passwd)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _oil != "" {
            Data += StrToArr(_oil); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_oil)), Tid: _Tid);
        }//유류지원정보없을경우
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _txfOil != "" {
            Data += StrToArr(_txfOil); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_txfOil)), Tid: _Tid);
        }//면세유정보없을경우
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _Dccflag != "" {
            Data += StrToArr(_Dccflag); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Dccflag)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _DccreqInfo != "" {
            Data += StrToArr(_DccreqInfo); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_DccreqInfo)), Tid: _Tid);
            
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ptCode != "" {
            Data += StrToArr(_ptCode); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ptCode)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ptNum != "" {
            Data += StrToArr(_ptNum); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ptNum)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _ptCardEncprytInfo.count > 0 {
            Data += StrToArr(String(format: "%04d", _ptCardEncprytInfo.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _ptCardEncprytInfo.count))), Tid: _Tid);
            Data += _ptCardEncprytInfo; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _ptCardEncprytInfo), Tid: _Tid);
        }else {
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_SignInfo); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_SignInfo)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _signPadSerial != "" {
            Data += StrToArr(_signPadSerial); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_signPadSerial)), Tid: _Tid);
            
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _SignData.count > 0 {
            if _SignInfo == "B" {
                //kim.jy 20200628   //사인데이터가 BM 데이터 인 경우에는 byte를 hex로 변환 하여 데이터를 전송 한다.
                // 2021-01-23
//                let  ConvertsignData:String = Utils.UInt8ArrayToHexCode(_value: _SignData, _option: false)
//                Data += StrToArr(String(format: "%04d", ConvertsignData.count))
//                Data += StrToArr(ConvertsignData)
                Data += StrToArr(String(format: "%04d", _SignData.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _SignData.count))), Tid: _Tid);
                Data += _SignData; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _SignData), Tid: _Tid);
            } else {
                Data += StrToArr(String(format: "%04d", _SignData.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _SignData.count))), Tid: _Tid);
                Data += _SignData; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _SignData), Tid: _Tid);
            }
        }else{
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _Cert != "" {
            Data += StrToArr(_Cert); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Cert)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _posData != "" {
            Data += StrToArr(_posData); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posData)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _ResonCancel != "" {
            Data += StrToArr(_kocesUid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_kocesUid)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        //접속업체코드 미설정시 데이터 미설정
        if _uniqueCode == ""  {
         //   byte[] bunique = new byte[3];
         //   for(int i=0;i<3;i++){bunique[i]=(byte)0x20;}
         //   Data += StrToArr((bunique));
        } else {
            Data += StrToArr(_uniqueCode); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_uniqueCode)), Tid: _Tid);
        }
        
        //MacAddress or UUID
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_macAddr); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_macAddr)), Tid: _Tid);
        
        //서버에서 받은 맥어드레스 응답키
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_hardwareKey); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_hardwareKey)), Tid: _Tid);
        
        return Utils.MakeClientPacket(PacketData: Data)
    }

    
    ///  현금 영수증 (서버 요청 함수)
    /// - Parameters:
    ///   - _Command: <#_Command description#>
    ///   - _Tid: <#_Tid description#>
    ///   - _date: <#_date description#>
    ///   - _posVer: <#_posVer description#>
    ///   - _etc: <#_etc description#>
    ///   - _cancelInfo: <#_cancelInfo description#>
    ///   - _ipt: <#_ipt description#>
    ///   - _id: <#_id description#>
    ///   - idEnc: <#idEnc description#>
    ///   - _money: <#_money description#>
    ///   - _tax: <#_tax description#>
    ///   - _svc: <#_svc description#>
    ///   - _txf: <#_txf description#>
    ///   - _tgt: <#_tgt description#>
    ///   - _resoncancel: <#_resoncancel description#>
    ///   - _ptCardCode: <#_ptCardCode description#>
    ///   - _ptAcceptNum: <#_ptAcceptNum description#>
    ///   - _bsnData: <#_bsnData description#>
    ///   - _halfYear: <#_halfYear description#>
    ///   - _kocesNumber: <#_kocesNumber description#>
    /// - Returns: <#description#>
    static func TcpCash(Command _Command:String,Tid _Tid:String,Date _date: String,PosVer _posVer:String,Etc _etc:String,CancelInfo _cancelInfo:String,Method _ipt:String,Id _id:[UInt8],IdEncrptying idEnc:[UInt8],Money _money:String,Tax _tax:String,ServiceCharge _svc:String,TaxFree _txf:String,Target _tgt:String,ResonCancel _resoncancel:String,PointCardCode _ptCardCode:String,PointAcceptNumber _ptAcceptNum:String,BusinessData _bsnData:String,halfYear _halfYear:String,KocesNumber _kocesNumber:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid);
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(_date); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_date)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(_posVer); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid);

        //단말추가정보 미설정시 데이터 미설정(20.05.23)
        if _etc != "" {
            Data += StrToArr(_etc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _Command == "B20" {  //현금 영수증 등록 취소
            Data += StrToArr(_cancelInfo); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_cancelInfo)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_ipt); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ipt)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if(_id.count > 0){
            Data += _id; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _id), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        if idEnc.count > 0 {
            Data += StrToArr(String(format: "%04d", idEnc.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", idEnc.count))), Tid: _Tid);
            Data += idEnc; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: idEnc), Tid: _Tid);
        }
        else
        {
            //해당 값을 0000 으로 보내면 kns 오류가 난다 0224.jiw
            //Data += StrToArr("0000")
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_money); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_money)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _tax != "" { Data += StrToArr(_tax); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_tax)), Tid: _Tid);  } //세금이 0이 아니면
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _svc != "" { Data += StrToArr(_svc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_svc)), Tid: _Tid); } //봉사료가  0이 아니면
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _txf != "" { Data += StrToArr(_txf); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_txf)), Tid: _Tid); } //비과세가 0이 아니면
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_tgt); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_tgt)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_resoncancel); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_resoncancel)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ptCardCode != "" { Data += StrToArr(_ptCardCode); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ptCardCode)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ptAcceptNum != "" { Data += StrToArr(_ptAcceptNum); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ptAcceptNum)), Tid: _Tid);  }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _bsnData != "" { Data += StrToArr(_bsnData); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_bsnData)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _halfYear != "" { Data += StrToArr(_halfYear); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_halfYear)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _kocesNumber != "" {Data += StrToArr(_kocesNumber); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_kocesNumber)), Tid: _Tid); }
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    ///위쳇/알리페이 서버요청함수 사용안함
    static func TcpWeChat_AliPay(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String,CancelInfo 취소정보:String,OriDate 원거래일자:String,OriAuNumber 원승인번호:String, OriSubAuNumber 원서브승인번호:String, InputType 입력방법:String, BarCode 바코드번호:String, PayType 지불수단구분:String,Money 거래금액:String,Tax 세금:String,ServiceCharge 봉사료:String,TaxFree 비과세:String,Currency 통화코드:String, SearchUniqueNum 조회거래고유번호:String, HostStoreData 호스트가맹점데이터:String, TmicNo 단말인증번호:String, StoreData 가맹점데이터:String, KocesUniqueNum KOCES거래고유번호:String) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data += StrToArr(전문번호);
        Data += StrToArr(_Tid);
        Data += StrToArr(거래일시);
        Data += StrToArr(Utils.getUniqueProtocolNumbering());
        Data += StrToArr(define.POS_TYPE);
        Data += StrToArr(단말버전);

        //단말추가정보 미설정시 데이터 미설정(20.05.23)
        if 단말추가정보 != "" {
            Data += StrToArr(단말추가정보)
        }
        Data.append(Command.FS)

        if 전문번호 == "W20"{  //위쳇/알리 취소요청 또는 위쳇 조회취소요청 사용
            Data += StrToArr(취소정보);
        } else if 전문번호 == "W40" {
            if 지불수단구분 == "W" {
                Data += StrToArr(취소정보);
            }
        }
        Data.append(Command.FS)
        
        if 전문번호 == "W20" || 전문번호 == "W40" {
            Data += StrToArr(원거래일자)
        }
        Data.append(Command.FS)
        if 전문번호 == "W20" || 전문번호 == "W40" {
            Data += StrToArr(원승인번호)
        }
        Data.append(Command.FS)
        if 전문번호 == "W20" || 전문번호 == "W40" {
            Data += StrToArr(원서브승인번호)
        }
        Data.append(Command.FS)
        Data += StrToArr(입력방법)
        Data.append(Command.FS)
        if 전문번호 == "W10" || 전문번호 == "W30" {
            Data += StrToArr(바코드번호)
        }
        Data.append(Command.FS)
//        Data += StrToArr(신용암호화정보길이)   미사용
//        Data += StrToArr(신용암호화정보)     미사용
        Data.append(Command.FS)
        Data += StrToArr(거래금액)
        Data.append(Command.FS)
        if 세금 != "" && 세금 != "0" { Data += StrToArr(세금) }
        Data.append(Command.FS)
        if 봉사료 != "" && 봉사료 != "0" { Data += StrToArr(봉사료) }
        Data.append(Command.FS)
        if 비과세 != "" && 비과세 != "0" { Data += StrToArr(비과세) }
        Data.append(Command.FS)
        if 통화코드 == "" || 통화코드 == "410" || 통화코드 == "KRW" { Data += StrToArr("KRW") }
        else { Data += StrToArr(통화코드) }
        Data.append(Command.FS)
        if 조회거래고유번호 != "" { Data += StrToArr(조회거래고유번호) }
        Data.append(Command.FS)
        if 호스트가맹점데이터 != "" { Data += StrToArr(호스트가맹점데이터) }
        Data.append(Command.FS)
        Data += StrToArr(단말인증번호)
        Data.append(Command.FS)
        if 가맹점데이터 != "" { Data += StrToArr(가맹점데이터) }
        Data.append(Command.FS)
        if KOCES거래고유번호 != "" { Data += StrToArr(KOCES거래고유번호) }
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    
    ///제로페이 서버요청함수
    static func TcpZeroPay(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String,CancelInfo 취소정보:String,InputType 입력방법:String, OriDate 원거래일자:String,OriAuNumber 원승인번호:String, BarCode 바코드번호:String,Money 거래금액:String,Tax 세금:String,ServiceCharge 봉사료:String,TaxFree 비과세:String,Currency 통화코드:String, Installment 할부개월:String,StoreInfo 가맹점추가정보:String, StoreData 가맹점데이터:String, KocesUniqueNum KOCES거래고유번호:String) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data += StrToArr(전문번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(전문번호)), Tid: _Tid);
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(거래일시); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(거래일시)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(단말버전); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(단말버전)), Tid: _Tid);

        //단말추가정보 미설정시 데이터 미설정(20.05.23)
        if 단말추가정보 != "" {
            Data += StrToArr(단말추가정보); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(단말추가정보)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if 전문번호 == "Z20"{  //제로페이 취소요청
            Data += StrToArr(취소정보); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(취소정보)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "Z10" { Data += StrToArr(입력방법); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(입력방법)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        if 전문번호 == "Z20" || 전문번호 == "Z30" {
            Data += StrToArr(원거래일자); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(원거래일자)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "Z20" || 전문번호 == "Z30" {
            Data += StrToArr(원승인번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(원승인번호)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "Z10" { Data += StrToArr(바코드번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(바코드번호)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(거래금액); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(거래금액)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 세금 != "" && 세금 != "0" { Data += StrToArr(세금); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(세금)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 봉사료 != "" && 봉사료 != "0" { Data += StrToArr(봉사료); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(봉사료)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 비과세 != "" && 비과세 != "0" { Data += StrToArr(비과세); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(비과세)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 통화코드 == "" || 통화코드 == "410" { }
        else { Data += StrToArr(통화코드); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(통화코드)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 할부개월 == "" || 할부개월 == "0" || 할부개월 == "1" || 할부개월 == "00" || 할부개월 == "01" { }
        else{
            Data += StrToArr(할부개월.count == 1 ? "0" + 할부개월:할부개월 ); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(할부개월.count == 1 ? "0" + 할부개월:할부개월)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 가맹점추가정보 != "" { Data += StrToArr(가맹점추가정보); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(가맹점추가정보)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 가맹점데이터 != "" { Data += StrToArr(가맹점데이터); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(가맹점데이터)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if KOCES거래고유번호 != "" { Data += StrToArr(KOCES거래고유번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(KOCES거래고유번호)), Tid: _Tid); }
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    ///카카오페이 서버요청함수
    static func TcpKakaoPay(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String,CancelInfo 취소정보:String,InputType 입력방법:String, BarCode 바코드번호:String, OTCCardCode OTC카드번호:[UInt8], Money 거래금액:String,Tax 세금:String,ServiceCharge 봉사료:String,TaxFree 비과세:String,Currency 통화코드:String, Installment 할부개월:String, PayType 결제수단:String, CancelMethod 취소종류:String, CancelType 취소타입:String, StoreCode 점포코드:String, PEM _PEM:String, trid _trid:String, CardBIN 카드BIN:String, SearchNumber 조회고유번호:String, WorkingKeyIndex _WorkingKeyIndex:String, SignUse 전자서명사용여부:String, SignPadSerial 사인패드시리얼번호:String, SignData 전자서명데이터:[UInt8], StoreData 가맹점데이터:String) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data += StrToArr(전문번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(전문번호)), Tid: _Tid);
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(거래일시); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(거래일시)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(단말버전); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(단말버전)), Tid: _Tid);

        //단말추가정보 미설정시 데이터 미설정(20.05.23)
        if 단말추가정보 != "" {
            Data += StrToArr(단말추가정보); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(단말추가정보)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if 전문번호 == "K22"{  //카카오페이 취소요청
            Data += StrToArr(취소정보); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(취소정보)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(입력방법); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(입력방법)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(바코드번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(바코드번호)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" && OTC카드번호.count > 0 {  Data += OTC카드번호; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: OTC카드번호), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(거래금액); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(거래금액)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 세금 != "" && 세금 != "0" { Data += StrToArr(세금); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(세금)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 봉사료 != "" && 봉사료 != "0" { Data += StrToArr(봉사료); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(봉사료)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 비과세 != "" && 비과세 != "0" { Data += StrToArr(비과세); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(비과세)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 통화코드 == "" || 통화코드 == "410" { }
        else { Data += StrToArr(통화코드); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(통화코드)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 할부개월 == "" || 할부개월 == "0" || 할부개월 == "1" || 할부개월 == "00" || 할부개월 == "01" { }
        else{
            Data += StrToArr(할부개월.count == 1 ? "0" + 할부개월:할부개월 ); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(할부개월.count == 1 ? "0" + 할부개월:할부개월)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" { Data += StrToArr(결제수단); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(결제수단)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K22" && 취소종류 != "" {  Data += StrToArr(취소종류); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(취소종류)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K22" && 취소타입 != "" {  Data += StrToArr(취소타입); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(취소타입)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 점포코드 != "" {  Data += StrToArr(점포코드); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(점포코드)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" && _PEM != "" { Data += StrToArr(_PEM); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_PEM)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" && _trid != "" { Data += StrToArr(_trid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_trid)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" && 카드BIN != "" { Data += StrToArr(카드BIN); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(카드BIN)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" || 전문번호 == "K22" && 조회고유번호 != "" { Data += StrToArr(조회고유번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(조회고유번호)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" || 전문번호 == "K22" && _WorkingKeyIndex != "" { Data += StrToArr(_WorkingKeyIndex); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_WorkingKeyIndex)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" || 전문번호 == "K22" && 전자서명사용여부 != "" { Data += StrToArr(전자서명사용여부); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(전자서명사용여부)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전문번호 == "K21" || 전문번호 == "K22" && 사인패드시리얼번호 != "" { Data += StrToArr(사인패드시리얼번호); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(사인패드시리얼번호)), Tid: _Tid); }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 전자서명데이터.count > 0 {
            Data += StrToArr(String(format: "%04d", 전자서명데이터.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", 전자서명데이터.count))), Tid: _Tid);
            Data += 전자서명데이터; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: 전자서명데이터), Tid: _Tid);
        }else{
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if 가맹점데이터 != "" { Data += StrToArr(가맹점데이터); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(가맹점데이터)), Tid: _Tid); }
        
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    /**
     포인트 결제
     - Returns: <#description#>
     */
    static func TCPPointPay(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,CardNumber _CardNum:[UInt8],EncryptInfo _encryptInfo:[UInt8],Money _money:String,PointCode _pointCode:String,PayType _payType:String,WorkingKeyIndex _keyIndex:String,Password _passwd:String,PosData _posData:String) -> [UInt8]
    {

        var Data:[UInt8] = Array()
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid); //전문커맨드
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(_date); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_date)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(_posVer); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid);


        //단말추가정보 미설정 시:String, 데이터 미설정(20.05.20)
        if _etc != "" {
            Data += StrToArr(_etc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ResonCancel != "" {
            Data += StrToArr(_ResonCancel); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ResonCancel)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_inputType); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_inputType)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += _CardNum; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _CardNum), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _encryptInfo.count > 0 {
            Data += StrToArr(String(format: "%04d", _encryptInfo.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _encryptInfo.count))), Tid: _Tid);
            Data += _encryptInfo; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _encryptInfo), Tid: _Tid);
        }else{
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_money); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_money)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        Data += StrToArr(_pointCode); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_pointCode)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_payType); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_payType)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        Data += StrToArr(_keyIndex); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_keyIndex)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_passwd); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_passwd)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
       

        if _posData != "" {
            Data += StrToArr(_posData); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posData)), Tid: _Tid);
        }
//        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

      
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    /**
     멤버십 결제
     - Returns: <#description#>
     */
    static func TCPMemberPay(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,CardNumber _CardNum:[UInt8],EncryptInfo _encryptInfo:[UInt8],Money _money:String,memberProductCode _memberProductCode:String,dongul _dongul:String,PosData _posData:String) -> [UInt8]
    {

        var Data:[UInt8] = Array()
        Data += StrToArr(_Command); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Command)), Tid: _Tid); //전문커맨드
        Data += StrToArr(_Tid); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_Tid)), Tid: _Tid);
        Data += StrToArr(_date); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_date)), Tid: _Tid);
        Data += StrToArr(Utils.getUniqueProtocolNumbering()); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(Utils.getUniqueProtocolNumbering())), Tid: _Tid);
        Data += StrToArr(define.POS_TYPE); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(define.POS_TYPE)), Tid: _Tid);
        Data += StrToArr(_posVer); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posVer)), Tid: _Tid);


        //단말추가정보 미설정 시:String, 데이터 미설정(20.05.20)
        if _etc != "" {
            Data += StrToArr(_etc); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_etc)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _ResonCancel != "" {
            Data += StrToArr(_ResonCancel); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_ResonCancel)), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_inputType); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_inputType)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += _CardNum; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _CardNum), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        if _encryptInfo.count > 0 {
            Data += StrToArr(String(format: "%04d", _encryptInfo.count)); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(String(format: "%04d", _encryptInfo.count))), Tid: _Tid);
            Data += _encryptInfo; LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: _encryptInfo), Tid: _Tid);
        }else{
            Data += StrToArr("0000"); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr("0000")), Tid: _Tid);
        }
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_money); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_money)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        
        Data += StrToArr(_memberProductCode); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_memberProductCode)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)
        Data += StrToArr(_dongul); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_dongul)), Tid: _Tid);
        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

        if _posData != "" {
            Data += StrToArr(_posData); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: StrToArr(_posData)), Tid: _Tid);
        }
//        Data.append(Command.FS);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.FS]), Tid: _Tid)

      
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    /** 정산요청 */
    static func TcpCalendarResult(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String, StartDay 조회시작일자:String, EndDay 조회종료일자:String, MchData 가맹점데이터:String) -> [UInt8]
    {
        var Data:[UInt8] = Array()
        Data += StrToArr(전문번호);
        Data += StrToArr(_Tid);
        Data += StrToArr(거래일시);
        Data += StrToArr(Utils.getUniqueProtocolNumbering());
        Data += StrToArr(define.POS_TYPE);
        Data += StrToArr(단말버전);

        //단말추가정보 미설정시 데이터 미설정(20.05.23)
        if 단말추가정보 != "" {
            Data += StrToArr(단말추가정보)
        }
        Data.append(Command.FS)
        Data += StrToArr(조회시작일자)
        Data.append(Command.FS)
        Data += StrToArr(조회종료일자)
        Data.append(Command.FS)
        if 가맹점데이터 != "" { Data += StrToArr(가맹점데이터) }
        return Utils.MakeClientPacket(PacketData: Data)
    }
    
    static func NetworkState(_data: [UInt8]) -> [UInt8]
    {
        return Utils.MakeClientPacket(PacketData: _data)
    }
    
    
    /// 펌웨어 다운로드 리스트 요청
    /// 목록정보 요청시에 Chunk Size 는명시하지 않아도 상관 없다. 단 4 바이트는 무조건 채워놔야 한다. Chunk Size 관련해서는 뒤에 나오는 "6. 파일다운로드" 항목 참조. 또한 파일명 정보는 이 단계에선 생략해도 된다.
    /// - Parameters:
    ///   - _Command: "Config"
    ///   - _Van: van 이름 16 byte
    ///   - _model: 모델명 16 byte
    ///   - _ver: 버전 16 byte
    ///   - _ProductNum: 제품 번혼 16 byte
    ///   - _chunkSize: 4byte
    ///   - _FnName: 파일이름 n byte
    /// - Returns: UInt8 Array
    static func TcpFirmWarelistDownload(Command _Command:String,Van _Van:String,ModelName _model:String,Version _ver:String,ProductNumber _ProductNum:String,ChunkSize _chunkSize:Int,FileName _FnName:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.FS, at: 0)
        Data += Array(_Command.utf8)
        Data.append(Command.FS)
        Data += Array(_Van.utf8)
        Data.append(Command.FS)
        Data += Array(_model.utf8)
        Data.append(Command.FS)
        Data += Array(_ver.utf8)
        Data.append(Command.FS)
        Data += Array(_ProductNum.utf8)
        Data.append(Command.FS)
        Data += withUnsafeBytes(of: _chunkSize.bigEndian, Array.init)
        Data.append(Command.FS)
        Data += Array(_FnName.utf8)
        Data.append(Command.ETX)
        
        //STX(1) + Length(4) + FS(1) + "Config"(6) + FS(1) + VAN(16) + 모델명(16) + 버젼(16) + 제품번호(16) + Chunk Size(4) +파일명(n) + ETX(1) + LRC(1)
        let length:Int = Data.count
        
        
        var retData:[UInt8] = Array()
        retData.insert(Command.STX, at: 0)
        retData += Array(Utils.leftPad(str: String(length), fillChar: "0", length: 4).utf8)
        retData += Data
        retData.append(Utils.makeLRC(_data: retData))
        
        return retData
    }
    
    
    /// 펌웨어 서버 수신 데이터 퍼서
    /// - Parameter _data: 수신 데이터
    /// - Returns: UInt8 Array
    static func TcpFirmWareParser(ResData _data:[UInt8]) -> [UInt8] {
        var ParsingData:[UInt8] = Array()
    
        return ParsingData
    }
    
    
    /**
     TCP 서버 응답 파싱 데이터 구조체
     */
    public struct TcpResParsingData {
        var length:Int = 0
        var version = ""
        var TrdType = ""
        var result = ""
        var error = ""
        var TermID = ""
        var TrdDate = ""
        var UniqueNum = ""
        var PosType = ""
        var PosVer = ""
        var AnsCode = ""
        var Data:[ArraySlice<UInt8>] = Array()
        init() {
        }
    }
    
    static func TcpResDataParser(ResData _data:[UInt8]) -> TcpResParsingData
    {
        typealias byte = Array
        let spliteData = FSspliter(Data: _data)
        var ParsingData:TcpResParsingData = TcpResParsingData()
        
        //최소한 데이터 그룹은 3개 이상은 되어야 한다.
        guard spliteData.count > 3 else {
            ParsingData.error = "fail"
            return ParsingData
        }
        //STX 포함 헤더는 9 바이트가 되야 한다.
        guard spliteData[0].count > 8 else {
            ParsingData.error = "fail"
            return ParsingData
        }
        ParsingData.length = Utils.UInt8Array4ToInt(_value: byte(spliteData[0][1...4]))
        ParsingData.version = Utils.utf8toHangul(str: byte(spliteData[0][5...8]))
        
        let Head1:[UInt8] = byte(spliteData[1])
        //기본 헤더의 길이가 37 바이트 보다 작으면 에러 처리 한다.
        guard Head1.count >= 37 else {
            ParsingData.error = "fail"
            return ParsingData
        }
        ParsingData.TrdType = Utils.utf8toHangul(str: byte(Head1[0...2]))
        ParsingData.TermID = Utils.utf8toHangul(str: byte(Head1[3...12]))
        ParsingData.TrdDate = Utils.utf8toHangul(str: byte(Head1[13...24]))
        ParsingData.UniqueNum    = Utils.utf8toHangul(str: byte(Head1[25...30]))
        ParsingData.PosType = Utils.UInt8ArrayToStr(UInt8: Head1[31] )
        ParsingData.PosVer = Utils.UInt8ArrayToStr(UInt8: Head1[36] )
        ParsingData.Data = spliteData

        return ParsingData
        
    }
    
    /*=========================================================================== CAT 통신용 전문 ==================================================================================== */
    
    
    
    
    /// 종료 전문 (PC->단말기)
    /// - Returns: byte 배열
    static func Cat_finish() -> [UInt8]{
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0)
        Data.append(0x45)   // Cancel 'E'
        Data += Array(repeating: 0x20, count: 10)
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))
        
        return Data
    }
    
    /// 단말기 현금 결제
    /// - Parameters:
    ///   - _tid: tid
    ///   - _money: 거래금액
    ///   - _tax: 세금
    ///   - _svc: 봉사료
    ///   - _txf: 비과세
    ///   - _AuDate: 원거래일자
    ///   - _AuNo: 원승인번호
    ///   - _KocesUniqueNumber: 코세스거래고유번호
    ///   - _Installment: 할부
    ///   - _cancel: 취소
    ///   - _mchData: 가맹점데이터
    ///   - _extrafield: 여유필드
    /// - Returns: UInt8 Array
    static func Cat_Credit(TID _tid:String,거래금액 _money:String,세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String,원승인번호 _AuNo:String,코세스거래고유번호 _KocesUniqueNumber:String,할부 _Installment:String,취소 _cancel:Bool,가맹점데이터 _mchData:String,여유필드 _extrafield:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.STX]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)     // 1byte
        Data.append(Command.CMD_CAT_AUTH);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.CMD_CAT_AUTH]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   // 1byte
        Data += Command.CMD_CAT_CREDIT_REQ;  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Command.CMD_CAT_CREDIT_REQ), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)  // 4byte
        Data += Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)     // TID 10 byte
//        Data += Array(repeating: 0x20, count: 10)    // TID 10 byte
        Data += Array(Utils.leftPad(str: _money, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _money, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //거래금액
        Data += Array(Utils.leftPad(str: _tax, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _tax, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //세금
        Data += Array(Utils.leftPad(str: _svc, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _svc, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //봉사료
        Data += Array(Utils.leftPad(str: _txf, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _txf, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //비과세
        if !_cancel {
            Data += Array(repeating: 0x20, count: 8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //원거래일자
            Data += Array(repeating: 0x20, count: 12);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 12)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //원승인번호
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //코세스거래고유번호
        }
        else{
            Data += Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 8).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 8).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            Data += Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            if _KocesUniqueNumber.count == 0 {     //코세스고유번호취소가 아닌 경우
                Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            }
            else
            {
                Data += Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //코세스고유번호취소의 경우
            }
        }

        Data += Array(Utils.leftPad(str: _Installment, fillChar: "0", length: 2).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _Installment, fillChar: "0", length: 2).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)  //할부
        
        Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //고객번호 20 byte (신용에서는 안씀)
        Data += Array(repeating: 0x20, count: 1);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 1)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //개인 법인구분 1byte (신용에서는 안씀)
        Data += Array(repeating: 0x20, count: 1);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 1)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //취소사유 1byte    (신용에서는 안씀)
        if _mchData.count != 0 {
            Data += Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //가맹점 데이터
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        }
        
        if _extrafield.count != 0 {
            Data += Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //여유필드
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        }
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))

        return Data
    }
    
    /** 사용안함 */
    static func Cat_CreditUnion(TID _tid:String,거래금액 _money:String,세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String,원승인번호 _AuNo:String,코세스거래고유번호 _KocesUniqueNumber:String,할부 _Installment:String,취소 _cancel:Bool,가맹점데이터 _mchData:String,여유필드 _extrafield:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0)
        Data.append(Command.CMD_CAT_AUTH)
        Data += Command.CMD_CAT_UNIPAY_REQ
        Data += Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8)     // TID 10 byte
//        Data += Array(repeating: 0x20, count: 10)    // TID 10 byte
        Data += Array(Utils.leftPad(str: _money, fillChar: "0", length: 9).utf8)    //거래금액
        Data += Array(Utils.leftPad(str: _tax, fillChar: "0", length: 9).utf8)      //세금
        Data += Array(Utils.leftPad(str: _svc, fillChar: "0", length: 9).utf8)      //봉사료
        Data += Array(Utils.leftPad(str: _txf, fillChar: "0", length: 9).utf8)      //비과세
        if !_cancel {
            Data += Array(repeating: 0x20, count: 8)    //원거래일자
            Data += Array(repeating: 0x20, count: 12)   //원승인번호
            Data += Array(repeating: 0x20, count: 20)   //코세스거래고유번호
        }
        else{
            Data += Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 8).utf8)
            Data += Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 12).utf8)
            if _KocesUniqueNumber.count == 0 {     //코세스고유번호취소가 아닌 경우
                Data += Array(repeating: 0x20, count: 20)
            }
            else
            {
                Data += Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8) //코세스고유번호취소의 경우
            }
        }
        Data += Array(Utils.leftPad(str: _Installment, fillChar: "0", length: 2).utf8)  //할부
        Data += Array(repeating: 0x20, count: 20)   //고객번호 20 byte (신용에서는 안씀)
        Data += Array(repeating: 0x20, count: 1)   //개인 법인구분 1byte (신용에서는 안씀)
        Data += Array(repeating: 0x20, count: 1)   //취소사유 1byte    (신용에서는 안씀)
        if _mchData.count != 0 {
            Data += Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 20).utf8)    //가맹점 데이터
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20)
        }
        
        if _extrafield.count != 0 {
            Data += Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8) //여유필드
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20)
        }
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))

        return Data
    }
    
    static func Cat_CashRecipt(TID _tid:String,거래금액 _money:String,세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String,원승인번호 _AuNo:String,코세스거래고유번호 _KocesUniqueNumber:String,할부 _Installment:String,고객번호 _customNum:String,개인법인구분 _pb:String,취소 _cancel:Bool,취소사유 _cancelReason:String,가맹점데이터 _mchData:String,여유필드 _extrafield:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.STX]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data.append(Command.CMD_CAT_AUTH);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.CMD_CAT_AUTH]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Command.CMD_CAT_CASH_REQ;  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Command.CMD_CAT_CASH_REQ), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)     // TID 10 byte
//        Data += Array(repeating: 0x20, count: 10)    // TID 10 byte
        Data += Array(Utils.leftPad(str: _money, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _money, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //거래금액
        Data += Array(Utils.leftPad(str: _tax, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _tax, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //세금
        Data += Array(Utils.leftPad(str: _svc, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _svc, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //봉사료
        Data += Array(Utils.leftPad(str: _txf, fillChar: "0", length: 9).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _txf, fillChar: "0", length: 9).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //비과세
        if !_cancel {
            Data += Array(repeating: 0x20, count: 8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //원거래일자
            Data += Array(repeating: 0x20, count: 12);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 12)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //원승인번호
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //코세스거래고유번호
        }
        else{
            Data += Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 8).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 8).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            Data += Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            if _KocesUniqueNumber.count == 0 {     //코세스고유번호취소가 아닌 경우
                Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            }
            else
            {
                Data += Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //코세스고유번호취소의 경우
            }
        }

        Data += Array(repeating: 0x20, count: 2);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 2)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //할부
        if _customNum.count == 0 {
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        } else {
            Data += Array(Utils.rightPad(str: _customNum, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _customNum, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //고객번호 20 byte
        }
        Data += Array(_pb.utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(_pb.utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //개인 법인구분 1byte
        if _cancelReason.isEmpty {
            Data += Array(repeating: 0x20, count: 1);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 1)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        } else {
            Data += Array(_cancelReason.utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(_cancelReason.utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //취소사유 1byte
        }
        if _mchData.count > 0 {
            Data += Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //가맹점 데이터
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        }
        
        if _extrafield.count > 0 {
            Data += Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //여유필드
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        }
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))

        return Data

    }
    
    static func Cat_CreditAppCard(TrdType _trdType:String,TID _tid:String,Qr _qr:String,거래금액 _money:String,세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,EasyKind _easyKind:String,원거래일자 _AuDate:String,원승인번호 _AuNo:String,서브승인번호 _subAuNo:String,할부 _Installment:String,가맹점데이터 _mchData:String,호스트가맹점데이터 _hostMchData:String,코세스거래고유번호 _KocesUniqueNumber:String) -> [UInt8] {
        var _length:Int = 0;
        var btmp:[UInt8] = Array()
        btmp = Array(_trdType.utf8)
        btmp += Array("S01=".utf8); btmp += Array(";".utf8);
        btmp += Array("S02=".utf8); btmp += Array(";".utf8);
        btmp += Array("S03=".utf8); btmp += Array(";".utf8);
        btmp += Array("S04=".utf8); btmp += Array(";".utf8);
        btmp += Array("S05=".utf8); btmp += Array(";".utf8);
        btmp += Array("S06=".utf8); btmp += Array(";".utf8);
        btmp += Array("S07=".utf8); btmp += Array(";".utf8);
        btmp += Array("S08=".utf8); btmp += Array(";".utf8);
        btmp += Array("S09=".utf8); btmp += Array(";".utf8);
        btmp += Array("S010=".utf8); btmp += Array(";".utf8);
        btmp += Array("S011=".utf8); btmp += Array(";".utf8);
        btmp += Array("S012=".utf8); btmp += Array(";".utf8);
        btmp += Array("S013=".utf8); btmp += Array(";".utf8);
        btmp += Array("S014=".utf8); btmp += Array(";".utf8);
        btmp += Array("S015=".utf8); btmp += Array(";".utf8);
        
        btmp += Array("S016=".utf8); btmp += Array(";".utf8);
        btmp += Array("S017=".utf8); btmp += Array(";".utf8);
        btmp += Array("S018=".utf8); btmp += Array(";".utf8);
        btmp += Array("S019=".utf8); btmp += Array(";".utf8);
        btmp += Array("S020=".utf8); btmp += Array(";".utf8);
        btmp += Array("S021=".utf8); btmp += Array(";".utf8);
        btmp += Array("S022=".utf8); btmp += Array(";".utf8);
        
        btmp += Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8);
        if (_trdType != "Z30")
        {
            btmp += Array(_qr.utf8);
        }
        btmp += Array(Utils.leftPad(str: _money, fillChar: "0", length: 12).utf8);
        btmp += Array(Utils.leftPad(str: _tax, fillChar: "0", length: 12).utf8);
        btmp += Array(Utils.leftPad(str: _svc, fillChar: "0", length: 12).utf8);
        btmp += Array(Utils.leftPad(str: _txf, fillChar: "0", length: 12).utf8);
        if (_trdType != "Z30")
        {
            btmp += Array(_easyKind.utf8);
        }
        
        if (_trdType == "A10") {
            
        } else {
            btmp += Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 6).utf8);
            btmp += Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 40).utf8);
            if (_trdType == "A20")
            {
                btmp += Array(Utils.rightPad(str: _subAuNo, fillChar: " ", length: 40).utf8);
            }

        }
        
        if (_trdType == "A10")
        {
            btmp += Array(Utils.leftPad(str: _Installment, fillChar: "0", length: 2).utf8);
        }
        
        if _mchData.count > 0 {
            btmp += Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 64).utf8);
        }
        
        if _trdType != "Z30" {
            if (_hostMchData.count > 0) {
                btmp += Array(Utils.rightPad(str: _hostMchData, fillChar: " ", length: 50).utf8);
            }
        }
        
        if (_trdType != "A10")
        {
            if (_KocesUniqueNumber == nil || _KocesUniqueNumber == "")
            {    //코세스고유번호취소가 아닌 경우

            }
            else
            {
                btmp += Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8);
            }
        }
        
        //s16 ~ s20 까지는 없음
        if (_trdType == "A10") {   //s21 컵보증금
            btmp += Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8);
        }
        //s22 한글코드구분자. 없음
        
        _length = btmp.count
        
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.STX]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data.append(Command.CMD_CAT_EASY_AUTH);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.CMD_CAT_AUTH]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Command.CMD_CAT_APPPAY_REQ;  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Command.CMD_CAT_APPPAY_REQ), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array(Utils.leftPad(str: String(_length), fillChar: "0", length: 4).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: String(_length), fillChar: "0", length: 4).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        //길이 들어감
        Data += Array("S01=".utf8); Data += Array(_trdType.utf8); Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(_trdType.utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array("S02=".utf8); Data += Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8); Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array("S03=".utf8);
        if (_trdType != "Z30")
        {
            Data += Array(_qr.utf8);
        }
        Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(_qr.utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array("S04=".utf8); Data += Array(Utils.leftPad(str: _money, fillChar: "0", length: 12).utf8); Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _money, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //거래금액
        Data += Array("S05=".utf8); Data += Array(Utils.leftPad(str: _tax, fillChar: "0", length: 12).utf8); Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _tax, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //세금
        Data += Array("S06=".utf8); Data += Array(Utils.leftPad(str: _svc, fillChar: "0", length: 12).utf8); Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _svc, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //봉사료
        Data += Array("S07=".utf8); Data += Array(Utils.leftPad(str: _txf, fillChar: "0", length: 12).utf8); Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _txf, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)      //비과세
        Data += Array("S08=".utf8);
        if (_trdType != "Z30")
        {
            Data += Array(_easyKind.utf8);
        }
        Data += Array(";".utf8);
        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(_easyKind.utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        if (_trdType == "A10") {
            Data += Array("S09=".utf8); Data += Array(";".utf8);
            Data += Array("S10=".utf8); Data += Array(";".utf8);
            Data += Array("S11=".utf8); Data += Array(";".utf8);
        } else {
            Data += Array("S09=".utf8);
            Data += Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 6).utf8);
            Data += Array(";".utf8);
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _AuDate, fillChar: " ", length: 6).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            Data += Array("S10=".utf8);
            Data += Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 40).utf8);
            Data += Array(";".utf8);
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _AuNo, fillChar: " ", length: 40).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            Data += Array("S11=".utf8);
            if (_trdType == "A20")
            {
                Data += Array(Utils.rightPad(str: _subAuNo, fillChar: " ", length: 40).utf8);
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _subAuNo, fillChar: " ", length: 40).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
            }
            Data += Array(";".utf8);
        }

        Data += Array("S12=".utf8);
        if (_trdType == "A10")
        {
            Data += Array(Utils.leftPad(str: _Installment, fillChar: "0", length: 2).utf8);
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _Installment, fillChar: "0", length: 2).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)  //할부
        }
        Data += Array(";".utf8);
        Data += Array("S13=".utf8);
        if _mchData.count > 0 {
            btmp += Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 64).utf8);
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 64).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //가맹점 데이터
        }
        Data += Array(";".utf8);
        Data += Array("S14=".utf8);
        if _trdType != "Z30" {
            if (_hostMchData.count > 0) {
                Data += Array(Utils.rightPad(str: _hostMchData, fillChar: " ", length: 50).utf8);
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _hostMchData, fillChar: " ", length: 50).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //호스트가맹점 데이터
            }
        }
        Data += Array(";".utf8);
        Data += Array("S15=".utf8);
        if (_trdType != "A10")
        {
            if (_KocesUniqueNumber == "")
            {    //코세스고유번호취소가 아닌 경우

            }
            else
            {
                Data += Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8);
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _KocesUniqueNumber, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //코세스고유번호취소의 경우
            }
        }
        Data += Array(";".utf8);
        
        Data += Array("S16=".utf8);
        Data += Array(";".utf8);
        Data += Array("S17=".utf8);
        Data += Array(";".utf8);
        Data += Array("S18=".utf8);
        Data += Array(";".utf8);
        Data += Array("S19=".utf8);
        Data += Array(";".utf8);
        Data += Array("S20=".utf8);
        Data += Array(";".utf8);
        Data += Array("S21=".utf8);
        if (_trdType == "A10") {
            Data += Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8);
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)  //컵보증금
        }
        Data += Array(";".utf8);
        Data += Array("S22=".utf8);
        Data += Array(";".utf8);
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))

        return Data
    }
    
    
    /// 무선단말기 현금IC 거래 요청
    /// - Parameters:
    ///   - _Class: <#_Class description#>
    ///   - _tid: <#_tid description#>
    ///   - _money: <#_money description#>
    ///   - _tax: <#_tax description#>
    ///   - _svc: <#_svc description#>
    ///   - _txf: <#_txf description#>
    ///   - _AuDate: <#_AuDate description#>
    ///   - _AuNo: <#_AuNo description#>
    ///   - _KocesUniqueNumber: <#_KocesUniqueNumber description#>
    ///   - _Installment: <#_Installment description#>
    ///   - _cancel: <#_cancel description#>
    ///   - _mchData: <#_mchData description#>
    ///   - _extrafield: <#_extrafield description#>
    /// - Returns: <#description#>
    static func Cat_CashIC(업무구분 _Class:define.CashICBusinessClassification, TID _tid:String,거래금액 _money:String,세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String,원승인번호 _AuNo:String,간소화거래여부 _directTrade:String,카드정보수록여부 _cardInfo:String,취소 _cancel:Bool,가맹점데이터 _mchData:String,여유필드 _extrafield:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.STX]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data.append(Command.CMD_CAT_AUTH);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: [Command.CMD_CAT_AUTH]), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Command.CMD_CAT_CASHIC_REQ;  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Command.CMD_CAT_CASHIC_REQ), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array( _Class.rawValue.utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array( _Class.rawValue.utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        Data += Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _tid, fillChar: " ", length: 10).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)     // TID 10 byte
//        Data += Array(repeating: 0x20, count: 10)    // TID 10 byte
        if _Class != define.CashICBusinessClassification.Search {
            Data += Array(Utils.leftPad(str: _money, fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _money, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //거래금액
        } else {
            Data += Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8); LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //거래금액
        }
        
        if _Class == define.CashICBusinessClassification.Buy ||
        _Class == define.CashICBusinessClassification.Cancel ||
            _Class == define.CashICBusinessClassification.Search {
            Data += Array(Utils.leftPad(str: _tax, fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _tax, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //세금
            Data += Array(Utils.leftPad(str: _svc, fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _svc, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //봉사료
            Data += Array(Utils.leftPad(str: _txf, fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _txf, fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //비과세
        } else {
            Data += Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //세금
            Data += Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //봉사료
            Data += Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: "0", fillChar: "0", length: 12).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //비과세
        }
        
        if _Class == define.CashICBusinessClassification.BuySearch ||
        _Class == define.CashICBusinessClassification.Cancel ||
            _Class == define.CashICBusinessClassification.CancelSearch {
            Data += Array(Utils.leftPad(str: _AuDate, fillChar: " ", length: 6).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _AuDate, fillChar: " ", length: 6).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //원거래일자
            Data += Array(Utils.leftPad(str: _AuNo, fillChar: " ", length: 13).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _AuNo, fillChar: " ", length: 13).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //원승인번호
        } else {
            Data += Array(repeating: 0x20, count: 6);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 6)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //원거래일자
            Data += Array(repeating: 0x20, count: 13);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 13)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)   //원승인번호
        }
        
        if _Class == define.CashICBusinessClassification.Buy ||
        _Class == define.CashICBusinessClassification.Cancel {
            Data += Array(Utils.leftPad(str: _directTrade, fillChar: " ", length: 1).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _directTrade, fillChar: " ", length: 1).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //간소화거래여부
        } else {
            Data += Array(repeating: 0x20, count: 1);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 1)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //간소화거래여부
        }
        Data += Array(Utils.leftPad(str: _cardInfo, fillChar: " ", length: 1).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.leftPad(str: _cardInfo, fillChar: " ", length: 1).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //카드정보수록여부
        if _mchData.count != 0 {
            Data += Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 64).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _mchData, fillChar: " ", length: 64).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)    //가맹점 데이터
        }
        else
        {
            Data += Array(repeating: 0x20, count: 64);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 64)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        }
        
        if _extrafield.count != 0 {
            Data += Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(Utils.rightPad(str: _extrafield, fillChar: " ", length: 20).utf8)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid) //여유필드
        }
        else
        {
            Data += Array(repeating: 0x20, count: 20);  LogFile.instance.InsertLog(Utils.UInt8ArrayToHex(_value: Array(repeating: 0x20, count: 20)), Tid: _tid == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID):_tid)
        }
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))
        
        return Data
    }
    
    
    /// 통합전문 거래응답 통신전문
    /// - Parameters:
    ///   - _com: 명령코드
    ///   G120(신용승인&취소, DCC, 앱카드),-> G125
    ///   G130(현금승인&취소)-> G135
    ///   G140(은련승인&취소)-> G145
    ///   G160(DCC)-> G165
    ///   G170(현금 IC)-> G175
    ///   - _code: 수신응답코드 0000(성공)/그외(실패)
    ///   - _msg: 응답메세지 0000 시 “정상수신” 그 외 실패코드에 따른 응답메시지
    /// - Returns: Byte Array
    static func Cat_ResponseTrade(Command _com:String,Code _code:[UInt8],Message _msg:String) -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0)
        Data += Array(_com.utf8)
        Data += _code
        // 이곳에 한글"정상수신"을 입력했을 때 한글을 utf8 로 바로 변환하니 오류가 났다. 한번 인코딩을 다시해서 보내본다.
//        let message = NSString(string: Utils.rightPad(str: _msg.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "\n!*'();:@&=+$,/?%#[]{} ").inverted)!, fillChar: " ", length: 40)) as String
        Data += Utils.hangultoUint8(str: _msg)
        var count:Int = (Utils.hangultoUint8(str: _msg)).count
        Data += Array(repeating: 0x20, count: 40 - count)
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))
        return Data
    }
    
    /// 미전송거래 요청 전문
    ///
    /// - Returns: byte array
    static func Cat_noTranTrade() -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0)
        Data += Command.CMD_CAT_NOTRANS_TRADE_REQ   //M110
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))
        return Data
    }
    
    /// Cancel CMD 요청 전문(E)
    static func Cat_CancelCMD_E() -> [UInt8] {
        var Data:[UInt8] = Array()
        Data.insert(Command.STX, at: 0)
        Data.insert(0x45, at: 1)  //E
        Data += Array(repeating: 0x20, count: 10)
        Data.append(Command.ETX)
        Data.append(Utils.makeLRC(_data: Data))
        return Data
    }
    
    /* ========================================CAT 전문 끝 ================================= */
    
    
    /**
     문자열 byteArray 로 변환 하는 함수
     */
    static func StrToArr(_ str:String) -> [UInt8] {
        return Array(str.utf8)
    }
    
    /**
     FS를 기준으로 분리하는 함수
     */
    static func FSspliter(Data _data:[UInt8]) -> [ArraySlice<UInt8>]{
        let garbage = _data[0...(_data.count - 3)]
        return Array(garbage).split(separator: Command.FS, omittingEmptySubsequences: false)
    }

    static func Check_IC_result_code(Res _res:String) -> String {
        if _res.contains("00") {
            return "00"
        } else if (_res.contains("M")) {
            return "M";
        } else if (_res.contains("R")) {
            return "R";
        } else if (_res.contains("E")) {
            return "E";
        } else if (_res.contains("F")) {
            return "F";
        } else if (_res.contains("K")) {
            return "K";
        } else if (_res.contains("99")) {
            return "99";
        } else if (_res.contains("01")) {
            return "Chip 전원을 넣었으나 응답이 없습니다.";
        } else if (_res.contains("02")) {
            return "지원하지 않는 어플리케이션 입니다.";
        } else if (_res.contains("03")) {
            return "칩데이터 읽기에 실패 하였습니다.";
        } else if (_res.contains("04")) {
            return "Mandatory 데이터 포함 되어 있지 않습니다.";
        } else if (_res.contains("05")) {
            return "CVM 커맨드 응답에 실패 하였습니다";
        } else if (_res.contains("06")) {
            return "EMV 커맨드 잘못설정 되었습니다.";
        } else if (_res.contains("07")) {
            return "터미널 오작동";
        } else if (_res.contains("08")) {
            return "IC카드 읽기에 실패 하였습니다.";
        } else if (_res.contains("09")) {
            return "IC우선 거래 입니다.";
        } else if (_res.contains("10")) {
            return "처리 불가 카드 입니다.";
        } else if (_res.contains("11")) {
            return "MS 읽기 실패 입니다.";
        } else if (_res.contains("12")) {
            return "해외은련카드(PIN필요카드) 지원 불가 입니다.";
        }
        return "지원 하지 않는 카드 입니다.";
    }
    
    static func Check_Print_Result_Code(Res _res:UInt8) -> String {
        var resStr:String = ""
        switch _res {
        case 0x31:
            resStr = "용지가 없거나 프린터 커버가 열려 있습니다."
            break
        default:
            break
        }
        
        return resStr
    }
}
