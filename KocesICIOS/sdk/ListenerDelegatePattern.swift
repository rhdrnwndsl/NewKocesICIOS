//
//  ListenerDelegatePattern.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/15.
//

import Foundation

enum tcpStatus{
    case sucess
    case fail
    case timeout
    case etc
}

enum payStatus{
    case OK
    case ERROR

}

enum printStatus{
    case OK
    case FAIL
}

enum verityStatus{
    case SUCCESS
    case FAIL
}

enum updateStatus{
    case SUCCESS
    case FAIL
}

protocol TcpResultDelegate{
    //일반적인결과물
    func onResult(tcpStatus _status:tcpStatus,Result _result:Dictionary<String,String>)
    //만일 앱투앱/웹투앱 에서 거래요청까지 함께 받는 작업이라면 해당거래로 리턴시킨다.(본앱에서는 사용하지 않는다.)
    func onDirectResult(tcpStatus _status:tcpStatus,Result _result:Dictionary<String,String>, DirectData _directData:Dictionary<String, String>)
    /** 만일 결과물을 UInt8 로 받아야 할 상황이라면 */
    func onKeyResult(tcpStatus _status:tcpStatus,Result _result:[UInt8],DicResult _dicresult:Dictionary<String,String>)
}

// 신용/현금 결과처리
protocol PayResultDelegate{
    func onPaymentResult(payTitle _status:payStatus ,payResult _message:Dictionary<String,String>)
}

//프린트가 성공했는지 실패했는지 결과처리
protocol PrintResultDelegate{
    func onPrintResult(printStatus _status:printStatus, printResult _result:Dictionary<String,String>)
}

//캣거래 결과처리
protocol CatResultDelegate {
    func onResult(CatState _state:payStatus,Result _message:Dictionary<String,String>)
}

//앱아테스트의 애플서버와의 키값 비교 결과처리
protocol AppAttestResultDelegate {
    func onAppAttestResult(AppAttest _status:verityStatus, Result _result:Dictionary<String,String>)
}

//앱이 최신버전인지 체크하는 결과처리
protocol AppVersionUpdateDelegate {
    func onAppUpdateResult(UpdateState _state:updateStatus, Result _result:Dictionary<String,String>)
}

class payResult{
    var delegate: PayResultDelegate?
}

class TcpResult{
    var delegate: TcpResultDelegate?
}

class PrintResult{
    var delegate: PrintResultDelegate?
}

class CatResult{
    var delegate: CatResultDelegate?
}

class AppAttestResult{
    var delegate: AppAttestResultDelegate?
}

class AppUpdateResult {
    var delegate: AppVersionUpdateDelegate?
}

