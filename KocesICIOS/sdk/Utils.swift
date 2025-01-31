//
//  Utils.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/12.
//

import Foundation
import SystemConfiguration
import UIKit
import Network

enum keyChainTarget:String{
    case AppToApp = "AppToApp"
    case KocesICIOSPay = "KocesICIOSPay"
}

/**
 전역으로 선언된 Util 함수
 */
class Utils{
    
    /**
     함수 콜백 리스너를 테스트하기 위해 임시로 만들었다
     sdk 폴더 안에 ListenerDelegatePattern 이란 폴더 안에 protocol 로 만들었다. 이게 interface 와 기능적으로 유사하다
     */
    
//    static var temp: NetworkStateDelegate?
//
//    static func testListener(_ del: NetworkStateDelegate)
//    {
//        temp = del
//    }
    /**
     인터넷 연결 상태를 확인 한다.
     - Returns: <#description#>
     */
    static func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress){
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1){
                zeroSockAddress in SCNetworkReachabilityCreateWithAddress(nil,zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }
    /**
     ble 전송용 패킷을 만드는 함수
     
     - parameter     _Command: 명령어
     - parameter     _Data: 전송 데이터
     - returns: Uint8 배열
     */
    static func MakePacket(_Command:UInt8,_Data:[UInt8]) -> [UInt8] {

        var cmdFrame:[UInt8] = Array()

        cmdFrame.insert(Command.STX, at: 0)
        cmdFrame += intToUInt8Array(_value: _Data.count + Command.HEAD_DATA_SIZE)
        cmdFrame.append(_Command)
        if _Data.count > 0 {
        cmdFrame += _Data
        }
        cmdFrame.append(Command.ETX)
        
        cmdFrame.append(makeLRC(_data: cmdFrame))
        //String sendBufferString = bytesToHex(sendBuffer);
        //Debug Print
//        debugPrint("App To Device -> " + Utils.UInt8ArrayToHexCode(_value: cmdFrame,_option: true))
        return cmdFrame
    }
    
    /**
     서버 전송용 패킷을 만드는 함수
     
     - parameter     _Command: 명령어
     - parameter     _Data: 전송 데이터
     - returns: Uint8 배열
     */
    static func MakeClientPacket(PacketData _Data:[UInt8]) -> [UInt8] {
        
        var cmdFrame:[UInt8] = Array()
        
        let dataSize:Int = _Data.count + Command.TCP_HEAD_DATA_SIZE - Command.TCP_DATA_LEN_EXCLUDE_NOT_DATA
        
        //let dataLength: [UInt8] = withUnsafeBytes(of: dataSize.bigEndian, Array.init)
        let dataLength:String = String(format: "%04d", dataSize)
        cmdFrame.insert(Command.STX, at: 0)
        cmdFrame += Array(dataLength.utf8) //데이터 사이즈
        cmdFrame += Command.TCP_PROTOCOL_VERSION //프로토콜 버전
        cmdFrame.append(Command.FS)
        cmdFrame += _Data
        cmdFrame.append(Command.ETX)
        cmdFrame.append(makeLRC(_data: cmdFrame))
        
        debugPrint("Device to TCP server -> " + Utils.UInt8ArrayToHexCode(_value: cmdFrame, _option: true))
        return cmdFrame
    }
    
    /**
     TMS서버 전송용 패킷을 만드는 함수
     
     - parameter     _Command: 명령어
     - parameter     _Data: 전송 데이터
     - returns: Uint8 배열
     */
    static func MakeTMSClientPacket(PacketData _Data:[UInt8], _cmd:String) -> [UInt8] {
        
        var cmdFrame:[UInt8] = Array()

        let dataSize:Int = _Data.count + Command.TCP_HEAD_DATA_SIZE + 4 + 1 - Command.TCP_DATA_LEN_EXCLUDE_NOT_DATA
        
        //let dataLength: [UInt8] = withUnsafeBytes(of: dataSize.bigEndian, Array.init)
        let dataLength:String = String(format: "%04d", dataSize)
        cmdFrame.insert(Command.STX, at: 0)
        cmdFrame += Array(dataLength.utf8) //데이터 사이즈
        cmdFrame += Array(_cmd.utf8) //프로토콜 버전
        cmdFrame.append(0x20)
        cmdFrame.append(0x20)
        cmdFrame.append(0x20)
        cmdFrame.append(0x20)
        cmdFrame.append(Command.FS)
        cmdFrame += _Data
        cmdFrame.append(Command.ETX)
        cmdFrame.append(makeLRC(_data: cmdFrame))
        
        debugPrint("Device to TCP server -> " + Utils.UInt8ArrayToHexCode(_value: cmdFrame, _option: true))
        return cmdFrame
    }

    /**
     LRC 구현함수
     - Parameter _data: UInt8 Array 타입
     - Returns: UInt8 Array 타입
     */
    static func makeLRC(_data:[UInt8]) -> UInt8 {
        var lrc:UInt8 = 0x00
        
        for i in 1..<_data.count{
            lrc ^= _data[i]
        }
        return lrc
    }
    
    static func CheckLRC(bytes:[UInt8]) -> Bool
    {
        var lrc:UInt8 = 0x00
        
        for i in 1..<bytes.count-1 {
            lrc ^= bytes[i]
        }
        
        if bytes[bytes.count-1] == lrc {
            return true
        }

        return false
    }
    
    /// Int를 2바이트  Uint8 Array로 변하는 함수
    /// - Parameter _value: Int  값
    /// - Returns: UInt8 Array 타입
    static func intToUInt8Array(_value:Int) -> [UInt8] {
        var result: [UInt8] = Array()
        result.insert((UInt8)(_value >> 8 & 255),at:0)
        result.append((UInt8)(_value & 255))
        return result
    }
    
    /// Int를 4바이트  Uint8 Array로 변하는 함수
    /// - Parameter _value: Int  값
    /// - Returns: UInt8 Array 타입
    static func int4ToUInt8Array(_value:Int) -> [UInt8] {
        var result: [UInt8] = Array()
        result.insert((UInt8)(_value >> 32 & 255),at:0)
        result.append((UInt8)(_value >> 16 & 255))
        result.append((UInt8)(_value >> 8 & 255))
        result.append((UInt8)(_value & 255))
        return result
    }
    
    
    /// 문자열을 숫자로 변환후 UInt8 배열로 변환하는 함수
    /// 예시 "100" -> 0x30 0x31 0x30 0x30
    /// - Parameters:
    ///   - val: 숫자
    ///   - len: 자릿수
    /// - Returns: UInt8 Array
    static func StrLengthToUIntArray(value val:String,Length len:Int) -> [UInt8] {
        var b:[UInt8] = Array(val.utf8)
        if b.count == len {
            return b
        }
        let term:Int = len - b.count
        if term < 0 {
            return b
        }
        for _ in 0..<term {
            b.insert(0x30, at: 0)
        }
        return b
    }
    /**
     UInt8 배열을 Hex String 형태로 컨버팅 함수
     - parameter    _value:Uint8 배열
     - parameter    _option: true의 경우는 0xXX 0xXX 타입으로 false의 경우에는 XXXXXX
     - Returns: hex 형태 문자열
     */
    static func UInt8ArrayToHexCode(_value:[UInt8],_option:Bool) -> String {
        var HexString:String = ""
        for i in 0 ..< _value.count
        {
            if(_option)
            {
                HexString += String(format:" 0x%02X", _value[i])
            }
            else
            {
                HexString += String(format:" %02X", _value[i])
            }
        }
        return HexString
    }
    
    static func UInt8ArrayToHex16Code(_value:[UInt8]) -> String {
        var HexString:String = ""
        for i in 0 ..< _value.count
        {
            if i % 16 == 0 && i != 0 {
                HexString += "\n"
            }
            HexString += String(format:"%02X", _value[i])
        }
        return HexString
    }
    
    static func UInt8ArrayToHex(_value:[UInt8]) -> String {
        var HexString:String = ""
        for i in 0 ..< _value.count
        {
            HexString += String(format:" %02X", _value[i])
        }
        return HexString
    }
    
    ///본앱에서 그린 사인데이터를 잘게 쪼개어서 1086 의 2배의 사이즈로 변환한다
    static func SignUin8ArrayToStringHexCode(_value:[UInt8]) -> [UInt8] {
        var StringHexCode:[UInt8] = []
        var HexString:String = ""
        for i in 0 ..< _value.count {
            HexString += String(format: "%02X", _value[i])
        }
        StringHexCode = [UInt8](HexString.utf8)
        return StringHexCode
    }
    
    /// <#Description#>
    /// - Parameter _value: <#_value description#>
    /// - Returns: <#description#>
    static func UInt8Array4ToInt(_value:[UInt8]) -> Int {
        let bytes = _value
        let result = bytes.reversed().reduce(0) { b, byte in
            return b << 8 | UInt32(byte)
        }
        return Int(result)
    }
    /// <#Description#>
    /// - Parameter _value: <#_value description#>
    /// - Returns: <#description#>
    static func UInt8Array2ToInt(_value:[UInt8]) -> Int {
        let bytes = _value
        let result = bytes.reversed().reduce(0) { b, byte in
            return b << 8 | UInt16(byte)
        }
        return Int(result)
    }
    
    static func UInt8ArrayToInt(_value: [UInt8]) -> Int {
      assert(_value.count <= 4)
      var result: UInt = 0
      for idx in 0..<(_value.count) {
        let shiftAmount = UInt((_value.count) - idx - 1) * 8
        result += UInt(_value[idx]) << shiftAmount
      }
      return Int(result)
    }
    
    /// UInt8 배열을 스트링으로 변환하는 함수
    /// - Parameter _value: UInt8 배열
    /// - Returns: 스트링
    static func UInt8ArrayToStr(UInt8Array _value:[UInt8]) -> String{
        let str:[UInt8] = _value
        let result = String.init(bytes: str, encoding: .utf8) ?? ""
        return result
    }
    
    
    /// UInt8 을 문자로 변환하는 함수
    /// - Parameter _value: UInt8
    /// - Returns: string
    static func UInt8ArrayToStr(UInt8 _value:UInt8) -> String{
        var str:[UInt8] = Array()
        str.insert(_value, at: 0)
        let result = String.init(bytes: str, encoding: .utf8) ?? ""
        return result
    }
    
    /// 펌웨어에서만 사용하는 길이표시 함수
    /// - Parameter _value: <#_value description#>
    /// - Returns: <#description#>
    static func Int4ToUInt8ArrayStringType(_value:Int) -> [UInt8] {
        let valStr:String = leftPad(str: String(_value), fillChar: "0", length: 4)
        return Array(valStr.utf8)
    }
    
    /**
     전문 고유번호 생성 함수
     - Returns: string
     */
    static func getUniqueProtocolNumbering()-> String{
        let UniqueNumber :String = Setting.shared.getDefaultUserData(_key: define.UNIQUE_NUMBER)
        var uniNumber :Int = 0
        if UniqueNumber == ""{
            uniNumber = 1
            
        }
        else
        {
            uniNumber = Int(UniqueNumber) ?? 1
            uniNumber += 1
        }
        
        Setting.shared.setDefaultUserData(_data: String(uniNumber), _key: define.UNIQUE_NUMBER)
        
        if uniNumber > 999999
        {
            uniNumber = 1
        }
        
        return String(format: "%06d", uniNumber)
    }
    
    /**
     포맷에 맞는 시간을 스트링으로 가져오기
     - Parameter _format: <#_format description#>
     - Returns: <#description#>
     */
    static func getDate(format _format:String) -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.dateFormat = _format
        return dateformat.string(from: Date())
    }
    
    /**
         오른쪽 패딩
         str: 기존문자열
         fillchar: 넣어야할 문자
         length: 기존문자열 + 넣어야할 문자를 포함하는 총 자릿수
         */
    /// <#Description#>
    /// - Parameters:
    ///   - str: <#str description#>
    ///   - fillChar: <#fillChar description#>
    ///   - length: <#length description#>
    /// - Returns: <#description#>
    static func rightPad(str:String, fillChar:String, length:Int) -> String {
        if str.count > length {
            return str
        }
        
        if fillChar.count > length {
            return str
        }
        
        var returnStr:String = str
        for _ in str.count ..< length {
            returnStr.insert(contentsOf: fillChar, at: returnStr.endIndex)
        }
        return returnStr
     }

    /**
     왼쪽패딩
     str: 기존문자열
     fillchar: 넣어야할 문자
     length: 기존문자열 + 넣어야할 문자를 포함하는 총 자릿수
     - Parameters:
     - str: <#str description#>
     - fillChar: <#fillChar description#>
     - length: <#length description#>
     - Returns: <#description#>
     */
        static func leftPad(str:String, fillChar:String, length:Int) -> String {
            if str.count > length {
                return str
            }
            
            if fillChar.count > length {
                return str
            }
            
            var returnStr:String = str
            for _ in str.count ..< length {
                returnStr.insert(contentsOf: fillChar, at: returnStr.startIndex)
            }
            return returnStr
        }
    
    static func titleDateParser() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss'Z'"
        dateFormatter.dateFormat = "yy/MM/dd HH:mm:ss"
        let currentDate:String = dateFormatter.string(from: Date())
        let dateString:String = currentDate
        return dateString
    }
    
    //원거래일자를 프린트용으로 파싱
    static func oriDateParser(oriDate 원거래일자:String) -> String {
        let auchars:[Character] = Array(원거래일자)
        var dateString:String = ""
        if 원거래일자.count >= 6 {
            dateString = String(auchars[0...1]) + "/" + String(auchars[2...3]) + "/" + String(auchars[4...5])
//            + " " +
//                String(auchars[6...7]) + ":" + String(auchars[8...9]) + ":" + String(auchars[10...])
        } else {
            dateString = 원거래일자
        }
        return dateString
    }
    
    /**
     프린트 할 때 좌우로 값이 있고 가운데 빈칸을 얼마나 채워야 하는지를 체크 한줄은 48byte
     */
    static func PrintPad(leftString _left:String, rightString _right:String) -> String {
        var returnStr:String = ""
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)
        var sizeLeft = _left.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        var sizeRight = _right.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        if sizeRight < _right.count {
            sizeRight = _right.count
        }
        
        if sizeLeft < _left.count {
            sizeLeft = _left.count
        }
//        var _right2 = _right.replacingOccurrences(of: " ", with: "")
        var _right2 = _right
        var buffer: [CChar] = []
        if _left.contains(define.PBOLDSTART) {
            buffer =  [CChar](repeating: 0, count: (sizeLeft/3)*2)
        } else {
            buffer =  [CChar](repeating: 0, count: sizeLeft)
        }
        
        if _right2.contains(define.PBOLDEND) {
            if sizeRight < 25 {
                buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-12)/3*2 + 8)
            } else {
                switch sizeRight {
                case 25:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-10)/3*2 + 8)
                    break
                case 26:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-8)/3*2 + 8)
                    break
                case 27:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-6)/3*2 + 8)
                    break
                case 28:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-4)/3*2 + 8)
                    break
                case 29:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-2)/3*2 + 8)
                    break
                case 30:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight)/3*2 + 8)
                    break
                default:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + sizeRight)
                    break
                }
            }
        } else {
            buffer =  [CChar](repeating: 0, count: buffer.count  + sizeRight)
        }

        if buffer.count >= Command.lineCount - 4 {
//            if _right2.count >= 60 {
//                returnStr = _left + _right2.prefix(15) + define.PENTER + _right2.substring(시작: 15, 끝: 30) + define.PENTER + _right2.substring(시작: 30, 끝: 45) + define.PENTER
//                + _right2.substring(시작: 45, 끝: 60) + define.PENTER + _right2.substring(시작: 60)
//            } else if _right2.count > 45 && _right2.count < 60 {
//                returnStr = _left + _right2.prefix(15) + define.PENTER + _right2.substring(시작: 15, 끝: 30) + define.PENTER + _right2.substring(시작: 30, 끝: 45) + define.PENTER + _right2.substring(시작: 45)
//            } else if _right2.count > 40 && _right2.count < 45 {
//                returnStr = _left + _right2.prefix(15) + define.PENTER + _right2.substring(시작: 15, 끝: 30) + define.PENTER + _right2.substring(시작: 30)
//            } else if _right2.count > 20 && _right2.count < 40 {
//                returnStr = _left + _right2.prefix(20) + define.PENTER + _right2.substring(시작: 20)
//            } else {
//                returnStr = _left + _right2 + define.PENTER
//            }
            returnStr = _left + _right2 + define.PENTER
            return returnStr
        }

        returnStr += _left

        for _ in buffer.count ..< Command.lineCount {
            returnStr += " "
        }

        returnStr += _right2
        
        return returnStr
    }
    
    /**
     프린트 할 때 좌우로 값이 있고 가운데 빈칸을 얼마나 채워야 하는지를 체크 한줄은 48byte 그리고 글자크기 키우기
     */
    static func PrintPadBold(leftString _left:String, rightString _right:String) -> String {
        var returnStr:String = ""
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)
        let _sizeL = define.PBOLDSTART + _left + define.PBOLDEND
        let _sizeR = define.PBOLDSTART + _right + define.PBOLDEND
        var sizeLeft =  _sizeL.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        var sizeRight = _sizeR.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        if sizeRight < _sizeR.count {
            sizeRight = _sizeR.count
        }
        
        if sizeLeft < _sizeL.count {
            sizeLeft = _sizeL.count
        }
        var _right2 = _sizeR.replacingOccurrences(of: " ", with: "")
        var buffer: [CChar] = []
        if _sizeL.contains(define.PBOLDSTART) {
            buffer =  [CChar](repeating: 0, count: (sizeLeft/3)*2)
        } else {
            buffer =  [CChar](repeating: 0, count: sizeLeft)
        }
        
        if _right2.contains(define.PBOLDEND) {
            if sizeRight < 25 {
                buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-12)/3*2 + 8)
            } else {
                switch sizeRight {
                case 25:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-10)/3*2 + 8)
                    break
                case 26:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-8)/3*2 + 8)
                    break
                case 27:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-6)/3*2 + 8)
                    break
                case 28:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-4)/3*2 + 8)
                    break
                case 29:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight-2)/3*2 + 8)
                    break
                case 30:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + (sizeRight)/3*2 + 8)
                    break
                default:
                    buffer =  [CChar](repeating: 0, count: buffer.count  + sizeRight)
                    break
                }
            }
        } else {
            buffer =  [CChar](repeating: 0, count: buffer.count  + sizeRight)
        }

        if buffer.count >= Command.lineCount - 4 {
//            var _c = _right.count
//            if _c > 20 {
//                returnStr = _left + _right2.prefix(20) + define.PENTER + _right2.substring(시작: 20)
//            } else {
//                returnStr = _left + _right2
//            }
            
            if _right2.count >= 60 {
                returnStr = _sizeL + _right2.prefix(15) + define.PENTER + _right2.substring(시작: 15, 끝: 30) + define.PENTER + _right2.substring(시작: 30, 끝: 45) + define.PENTER
                + _right2.substring(시작: 45, 끝: 60) + define.PENTER + _right2.substring(시작: 60)
            } else if _right2.count > 45 && _right2.count < 60 {
                returnStr = _sizeL + _right2.prefix(15) + define.PENTER + _right2.substring(시작: 15, 끝: 30) + define.PENTER + _right2.substring(시작: 30, 끝: 45) + define.PENTER + _right2.substring(시작: 45)
            } else if _right2.count > 40 && _right2.count < 45 {
                returnStr = _sizeL + _right2.prefix(15) + define.PENTER + _right2.substring(시작: 15, 끝: 30) + define.PENTER + _right2.substring(시작: 30)
            } else if _right2.count > 20 && _right2.count < 40 {
                returnStr = _sizeL + _right2.prefix(20) + define.PENTER + _right2.substring(시작: 20)
            } else {
                returnStr = _sizeL + _right2
            }
           
            return returnStr
        }

        returnStr += _sizeL

        for _ in buffer.count ..< Command.lineCount {
            returnStr += " "
        }

        returnStr += _right2
        
        return returnStr
    }
    
    /**
     결제금액 프린트
     */
    static func PrintPadMoney(leftString _left:String, rightString _right:String) -> String {
        var returnStr:String = ""
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)
        var sizeLeft = _left.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        var sizeRight = _right.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        if sizeRight < _right.count {
            sizeRight = _right.count
        }
        
        if sizeLeft < _left.count {
            sizeLeft = _left.count
        }
        var _right2 = _right
        var buffer: [CChar] = []
        buffer =  [CChar](repeating: 0, count: sizeLeft)
        buffer =  [CChar](repeating: 0, count: buffer.count  + sizeRight)
        
//        returnStr += define.PBOLDSTART
        
        returnStr += _left

//        for _ in buffer.count ..< (Command.lineCount - 4) {
//            returnStr += " "
//        }

//        returnStr += define.PBOLDSTART
        returnStr += _right2
        
//        returnStr += define.PBOLDEND
        
        return returnStr
    }
    
    /**
     응답메세지 등의 길이가 1라인을 넘기는 경우처리
     */
    static func printMessage(rightString _right:String) -> String {
        var returnStr:String = ""
        var right = _right.replacingOccurrences(of: " ", with: "")
        if right.count >= 60 {
            returnStr = right.prefix(20) + define.PENTER + right.substring(시작: 20, 끝: 40) + define.PENTER + right.substring(시작: 40, 끝: 60) + define.PENTER + right.substring(시작: 60)
//            + define.PENTER + right.substring(시작: 40, 끝: 50) + define.PENTER + right.substring(시작: 50, 끝: 60) + define.PENTER + right.substring(시작: 60)
        } else if right.count > 40 && right.count < 60 {
            returnStr = right.prefix(20) + define.PENTER + right.substring(시작: 20, 끝: 40) + define.PENTER + right.substring(시작: 40)
        } else if right.count > 20 && right.count < 40 {
            returnStr = right.prefix(20) + define.PENTER + right.substring(시작: 20)
        } else {
            returnStr = right
        }
//        returnStr = _right
        return returnStr
    }
    
    /**
     프린트 할 때 제목:값. 제목:값  형태로 4개를 입력받을 때
     */
    static func Print4Pad(FirTitle _firTitle:String, FirValue _firValue:String, SecTitle _secTitle:String, SecValue _secValue:String) -> String {
        var returnStr:String = ""
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)
        let sizeFirTitle = _firTitle.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        let sizeFirValue = _firValue.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        let sizeSecTitle = _secTitle.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        let sizeSecValue = _secValue.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))

        var bufferLeft: [CChar] = []
        if _firValue.contains(define.PBOLDSTART) {
            bufferLeft =  [CChar](repeating: 0, count: sizeFirTitle+sizeFirValue - 8)
        } else {
            bufferLeft =  [CChar](repeating: 0, count: sizeFirTitle+sizeFirValue)
        }
        
        var bufferRight: [CChar] = []
        if _secValue.contains(define.PBOLDEND) {
            bufferRight =  [CChar](repeating: 0, count: sizeSecTitle+sizeSecValue - 8)
        } else {
            bufferRight =  [CChar](repeating: 0, count: sizeSecTitle+sizeSecValue)
        }
        
        if bufferLeft.count + bufferRight.count >= Command.lineCount {
            returnStr = _firTitle + _firValue + _secTitle + _secValue
            return returnStr
        }
        
        returnStr += _firTitle
        for _ in bufferLeft.count ..< 22 {
            returnStr += " "
        }
        returnStr += _firValue
        
        for _ in 0 ..< 4 {
            returnStr += " "
        }
        
        returnStr += _secTitle
        for _ in bufferRight.count ..< 22 {
            returnStr += " "
        }
        returnStr += _secValue
        
        return returnStr
    }
    
    /**
     프린트 시 라인 ----- 을 그린다 48bytes
     */
    static func PrintLine(line _line:String) -> String {
        var returnStr:String = ""
        for i in 0 ..< Command.lineCount/_line.count {
            returnStr += _line
        }

        return returnStr
    }
    
    /**
     프린트 시 돈을 계산할 때 자릿수에 , 삽입한다
     */
    static func PrintMoney(Money _money:String) -> String {
        if _money.count < 4 {
            return _money
        }
        var returnStr:String = ""
        let number = NumberFormatter()
        number.numberStyle = .decimal
        returnStr = number.string(from: NSNumber(integerLiteral: Int(_money)!))!
        return returnStr
    }
    
    /**
     프린트 시 강조구문을 만든다
     */
    static func PrintBold(_bold:String) -> String {
        return define.PBOLDSTART + _bold + define.PBOLDEND
    }
    
    /**
     가운데정렬해서 표시
     */
    static func PrintCenter(Center _center:String) -> String {
        var returnStr:String = ""
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)
      
        let sizeCenter = _center.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR))
        var buffer: [CChar] = []
        if _center.contains(define.PBOLDEND) {
            buffer =  [CChar](repeating: 0, count: sizeCenter - 8)
        } else {
            buffer =  [CChar](repeating: 0, count: sizeCenter)
        }
        if buffer.count >= Command.lineCount {
            returnStr = _center
            return returnStr
        }

        for _ in 0 ..< (Command.lineCount-buffer.count)/2 {
            returnStr += " "
        }
        
        returnStr += _center

        for _ in 0 ..< (Command.lineCount-buffer.count)/2 {
            returnStr += " "
        }
        
        return returnStr
    }
    /**
     한글및 특수문자 포함된 데이터[UInt8] 를 문자열로 변환한다
     - Parameter str: <#str description#>
     - Returns: <#description#>
     */
    static func utf8toHangul(str:[UInt8]) -> String {
        let resNS = NSString(data: Data(str), encoding:
        CFStringConvertEncodingToNSStringEncoding( 0x0422 ) )
        
        let responseString = resNS ?? "" as String as NSString
        return responseString as String
    }
    
    /**
     문자를 한글로 변환하고 이를 다시 배열로 변환.(캣에 적용하기 위해 만들었지만 안됨. 캣은 조합형임
     */
    static func hangultoUint8(str:String) -> [UInt8] {
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)

        let size = str.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR)) + 1

        var buffer: [CChar] = [CChar](repeating: 0, count: size)

        /// UTF8 -> EUC-KR 로 변환
        let result = str.getCString(&buffer, maxLength: size, encoding: String.Encoding(rawValue: encodingEUCKR))

        print(buffer)
        print(buffer.count)
        // output : [-80, -95, -68, ... , -39, 46, 0]
        // output : 272 byte


        /// EUC-KR -> UTF8 로 변환
        let data = Data(bytes: buffer, count: size - 1)
        let strUTF8 = String(data: data, encoding: String.Encoding(rawValue: encodingEUCKR))
        
        return Array(data)
    }
    
    static func hangultoutf8toUint8(str:String) -> String {
        let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)

        let size = str.lengthOfBytes(using: String.Encoding(rawValue: encodingEUCKR)) + 1

        var buffer: [CChar] = [CChar](repeating: 0, count: size)

        /// UTF8 -> EUC-KR 로 변환
        let result = str.getCString(&buffer, maxLength: size, encoding: String.Encoding(rawValue: encodingEUCKR))

        print(buffer)
        print(buffer.count)
        // output : [-80, -95, -68, ... , -39, 46, 0]
        // output : 272 byte


        /// EUC-KR -> UTF8 로 변환
        let data = Data(bytes: buffer, count: size)
        guard let strUTF8 = String(data: data, encoding: String.Encoding(rawValue: encodingEUCKR)) else { return "" }
        
        return strUTF8
    }
    
    static func euckrEncoding(_ query: String) -> String { //EUC-KR 인코딩
        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        let encoding = String.Encoding(rawValue: rawEncoding)
        let eucKRStringData = query.data(using: encoding) ?? Data()
        let outputQuery = eucKRStringData.map { byte->String in
            if byte >= UInt8(ascii: "A") && byte <= UInt8(ascii: "Z") || byte >= UInt8(ascii: "a") && byte <= UInt8(ascii: "z") || byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9") || byte == UInt8(ascii: "_") || byte == UInt8(ascii: ".") || byte == UInt8(ascii: "-") {
                return String(Character(UnicodeScalar(UInt32(byte))!))
                
            } else if byte == UInt8(ascii: " ") {
                return "+"
                
            } else {
                return String(format: "%%%02X", byte)
                
            }
            
        }.joined();
        return outputQuery
        
    }
    
    
    /**
     현재 활성화되어 있는 뷰컨트롤러를 확인하는 코드 by.jiw 21-01-30
     사용법은 PaySdk 에 넣어두었다
     - Returns: 뷰컨트롤러를 반환한다. 해당 뷰컨트롤러를 스트링String(descrpion: topMostViewController ())으로 값을 받아서 이를 contains("Credit") 를 통해 클레스이름으로 검사할 수 있다
     */
    static func topMostViewController ()-> UIViewController? {
        return topViewControllerForRoot (rootViewController: UIApplication.shared.keyWindow?.rootViewController)
    }

    /**
     위의 topMostViewController () 와 연계 되는 함수 위를 통해 최상위 뷰컨트롤러 즉, 루트뷰를 확인 하고 아래를 통해 루트뷰에서 타고 들어가 현재 뷰를 체크한다
     */
    static func topViewControllerForRoot(rootViewController:UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        
        guard let presented = rootViewController.presentedViewController else {
            return rootViewController
        }

        switch presented {
        case is UINavigationController:
            let navigationController:UINavigationController = presented as! UINavigationController
            return topViewControllerForRoot(rootViewController: navigationController.viewControllers.last)

        case is UITabBarController:
            let tabBarController:UITabBarController = presented as! UITabBarController
            return topViewControllerForRoot(rootViewController: tabBarController.selectedViewController)

        default:
            return topViewControllerForRoot(rootViewController: presented)
        }
    }
    
    /**
     최상위 뷰가 어디인지 몰라도 메세지박스를 화면에 띄우기 위한 함수
     - Parameters:
     - _title: 메세지박스의 타이틀
     - _message: 메세지박스의 중단메세지
     - _loading: 로딩바를 표시할 것인지 체크
     - _btn: 버튼이 화면에 있는지 체크. 로딩바가 있을 시에는 버튼을 그리지 않는다
     */
    static func customAlertBoxInit(Title _title:String, Message _message:String, LoadingBar _loading:Bool, GetButton _btn:String) {
        
        /** 메세지박스를 띄우기 전에 기존의 메세지박스가 있다면 제거한다 */
        customAlertBoxClear()
        
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        
        if _loading {
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            
            alert.view.addSubview(activityIndicator)
            alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true
            
            activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
            activityIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20).isActive = true
        } else {
            let ok = UIAlertAction(title: _btn, style: .default, handler: nil)
            alert.addAction(ok)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            topMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    //프린트시 사용하는 박스
    static func printAlertBox(Title _title:String, LoadingBar _loading:Bool, GetButton _btn:String) {
        
        /** 메세지박스를 띄우기 전에 기존의 메세지박스가 있다면 제거한다 */
        customAlertBoxClear()
        
        let alert = UIAlertController(title: _title, message: "", preferredStyle: .alert)
//        let activityIndicator = UIActivityIndicatorView(style: .medium)
        
        if _loading {
//            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//            activityIndicator.isUserInteractionEnabled = false
//            activityIndicator.startAnimating()
//
//            alert.view.addSubview(activityIndicator)
//            alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true
//
//            activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
//            activityIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20).isActive = true
            var count = 30
            let margin:CGFloat = 8.0
//                let rect = CGRect(x: margin, y: 70, width: alert.view.frame.width - margin * 2.0 , height: 20)
//                let label = UILabel(frame: rect)
            let label = UILabel()
            label.text = String(count)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            alert.view.addSubview(label)
            alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
            label.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20).isActive = true
            var _:Timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                
                count-=1
                label.text = String(count)
                if count == 0 {
//                    connectionTimeout.invalidate()
                    alert.dismiss(animated: true){
//                        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
//                        let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
//                        alertController.addAction(okButton)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//                            topMostViewController()?.present(alertController, animated: true, completion: nil)
//                        }
                    }
                    return
                }
                
                
            })
        } else {
            let ok = UIAlertAction(title: _btn, style: .default, handler: nil)
            alert.addAction(ok)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            topMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     현재 화면의 모든 메세지 박스를 닫는다
     */
    static func customAlertBoxClear() {
        guard let isKindOf = topMostViewController()?.isKind(of: UIAlertController.classForCoder()), isKindOf else {
            return
        }
        DispatchQueue.main.async {
            topMostViewController()?.dismiss(animated: true, completion: nil)
        }
   
    }
    
    /** 결제 할 때 띄운 카드읽기 전용 뷰컨트롤러를 닫는다 */
    static func CardAnimationViewControllerClear() {
        if String(describing: topMostViewController()).contains("CardAnimationViewController") {
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            guard let cardAni = storyboard!.instantiateViewController(withIdentifier: "CardAnimationViewController") as? CardAnimationViewController else {return}
            cardAni.connectionTimeout?.invalidate()
            cardAni.connectionTimeout = nil
            cardAni.paylistener = nil
//            KocesSdk.instance.DeviceInit(VanCode: "99")
            DispatchQueue.main.async {
                topMostViewController()?.dismiss(animated: true, completion: nil)
            }
//            topMostViewController()?.dismiss(animated: true, completion: nil)
        }
    }
    
    /** 결제 할 때 새로운 뷰컨트롤러를 띄워서 카드읽기를 한다 */
    static func CardAnimationViewControllerInit(Message _message:String, isButton _isBtn:Bool, CountDown _countDown:String, TotalMoney _money:String, IsCancel _iscancel:Bool, Listener _listener:PayResultDelegate) {
        let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        /** 기존의 메세지박스가 있다면 제거한다 */
        if presented is UIAlertController
        {
            //블루투스 단말기를 읽고 나서 서버로 해당 내용을 보내는 상황이라면
            if (String(describing: topMostViewController()).contains("CardAnimationViewController") && _message.contains("서버")) {
                guard let cardAni = topMostViewController() as? CardAnimationViewController else {return}
                cardAni.view.backgroundColor = .white
                cardAni.modalPresentationStyle = .fullScreen
                cardAni.cardMsg = _message
                cardAni.totalMoney = _money
                cardAni.iscancel = _iscancel
                cardAni.paylistener = _listener
//                if _isBtn {
//                    cardAni.mCardBtn.isHidden = false
//                    cardAni.mCardBtn.alpha = 1.0
//                } else {
//                    cardAni.mCardBtn.isHidden = true
//                    cardAni.mCardBtn.alpha = 0.0
//                }
//                cardAni.mCardBtn.isHidden = true
//                cardAni.mCardBtn.alpha = 0.0
                cardAni.CardViewInit()
                return
            }
            DispatchQueue.main.async {
                topMostViewController()?.dismiss(animated: true)
                {
                    if String(describing: topMostViewController()).contains("CardAnimationViewController")
                    {
                        topMostViewController()?.dismiss(animated: true)
                        {
                            var storyboard:UIStoryboard?
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            } else {
                                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                            }
                            guard let cardAni = storyboard!.instantiateViewController(withIdentifier: "CardAnimationViewController") as? CardAnimationViewController else {return}
                            cardAni.view.backgroundColor = .white
                            cardAni.modalPresentationStyle = .fullScreen
                            cardAni.cardMsg = _message
                            cardAni.totalMoney = _money
                            cardAni.iscancel = _iscancel
                            cardAni.paylistener = _listener
          
                            Utils.topMostViewController()?.present(cardAni, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        var storyboard:UIStoryboard?
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        } else {
                            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                        }
                        guard let cardAni = storyboard!.instantiateViewController(withIdentifier: "CardAnimationViewController") as? CardAnimationViewController else {return}
                        cardAni.view.backgroundColor = .white
                        cardAni.modalPresentationStyle = .fullScreen
                        cardAni.cardMsg = _message
                        cardAni.totalMoney = _money
                        cardAni.iscancel = _iscancel
                        cardAni.paylistener = _listener
      
                        Utils.topMostViewController()?.present(cardAni, animated: true, completion: nil)
                    }
                }
            }
            
        }
        else
        {
            //블루투스 단말기를 읽고 나서 서버로 해당 내용을 보내는 상황이라면
            if (String(describing: topMostViewController()).contains("CardAnimationViewController") && _message.contains("서버")) {
                guard let cardAni = topMostViewController() as? CardAnimationViewController else {return}
                cardAni.view.backgroundColor = .white
                cardAni.modalPresentationStyle = .fullScreen
                cardAni.cardMsg = _message
                cardAni.totalMoney = _money
                cardAni.iscancel = _iscancel
                cardAni.paylistener = _listener

                cardAni.CardViewInit()
                return
            }
            if String(describing: topMostViewController()).contains("CardAnimationViewController")
            {
                DispatchQueue.main.async {
                    topMostViewController()?.dismiss(animated: true)
                    {
                        var storyboard:UIStoryboard?
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        } else {
                            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                        }
                        guard let cardAni = storyboard!.instantiateViewController(withIdentifier: "CardAnimationViewController") as? CardAnimationViewController else {return}
                        cardAni.view.backgroundColor = .white
                        cardAni.modalPresentationStyle = .fullScreen
                        cardAni.cardMsg = _message
                        cardAni.totalMoney = _money
                        cardAni.iscancel = _iscancel
                        cardAni.paylistener = _listener
                        
                        Utils.topMostViewController()?.present(cardAni, animated: true, completion: nil)
                    }
                }
            }
            else
            {
                var storyboard:UIStoryboard?
                if UIDevice.current.userInterfaceIdiom == .phone {
                    storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                } else {
                    storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                }
                guard let cardAni = storyboard!.instantiateViewController(withIdentifier: "CardAnimationViewController") as? CardAnimationViewController else {return}
                cardAni.view.backgroundColor = .white
                cardAni.modalPresentationStyle = .fullScreen
                cardAni.cardMsg = _message
                cardAni.totalMoney = _money
                cardAni.iscancel = _iscancel
                cardAni.paylistener = _listener
                DispatchQueue.main.async {
                    topMostViewController()?.present(cardAni, animated: true, completion: nil)
                }
            }
        }
    }
    
    /** cat결제 할 때 띄운 카드읽기 전용 뷰컨트롤러를 닫는다 */
    static func CatAnimationViewInitClear() {
        if String(describing: topMostViewController()).contains("CatAnimationViewController") {
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            guard let catAni = storyboard!.instantiateViewController(withIdentifier: "CatAnimationViewController") as? CatAnimationViewController else {return}
            catAni.connectionTimeout?.invalidate()
            catAni.connectionTimeout = nil
            catAni.catlistener = nil
//            KocesSdk.instance.DeviceInit(VanCode: "99")
            DispatchQueue.main.async {
                topMostViewController()?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //cat결제 시 화면
    static func CatAnimationViewInit(Message _message:String,TotalMoney _money:String,IsCancel _iscancel:Bool, Listener _listener:CatResultDelegate) {
        let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        /** 기존의 메세지박스가 있다면 제거한다 */
        if presented is UIAlertController {
            //블루투스 단말기를 읽고 나서 서버로 해당 내용을 보내는 상황이라면
            if (String(describing: topMostViewController()).contains("CatAnimationViewController") && _message.contains("서버")) {
                guard let catAni = topMostViewController() as? CatAnimationViewController else {return}
                catAni.view.backgroundColor = .white
                catAni.modalPresentationStyle = .fullScreen
                catAni.cardMsg = _message
                catAni.totalMoney = _money
                catAni.iscancel = _iscancel
                catAni.catlistener = _listener
                catAni.CardViewInit()
                return
            }
            DispatchQueue.main.async {
                topMostViewController()?.dismiss(animated: true)
                {
                    if String(describing: topMostViewController()).contains("CatAnimationViewController")
                    {
                        topMostViewController()?.dismiss(animated: true)
                        {
                            guard let catAni = storyboard!.instantiateViewController(withIdentifier: "CatAnimationViewController") as? CatAnimationViewController else {return}
                            catAni.view.backgroundColor = .white
                            catAni.modalPresentationStyle = .fullScreen
                            catAni.cardMsg = _message
                            catAni.totalMoney = _money
                            catAni.iscancel = _iscancel
                            catAni.catlistener = _listener
                            Utils.topMostViewController()?.present(catAni, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        
                        guard let catAni = storyboard!.instantiateViewController(withIdentifier: "CatAnimationViewController") as? CatAnimationViewController else {return}
                        catAni.view.backgroundColor = .white
                        catAni.modalPresentationStyle = .fullScreen
                        catAni.cardMsg = _message
                        catAni.totalMoney = _money
                        catAni.iscancel = _iscancel
                        catAni.catlistener = _listener
                        Utils.topMostViewController()?.present(catAni, animated: true, completion: nil)
                    }
                }
            }
        }
        else
        {
            //블루투스 단말기를 읽고 나서 서버로 해당 내용을 보내는 상황이라면
            if (String(describing: topMostViewController()).contains("CatAnimationViewController") && _message.contains("서버")) {
                guard let catAni = topMostViewController() as? CatAnimationViewController else {return}
                catAni.view.backgroundColor = .white
                catAni.modalPresentationStyle = .fullScreen
                catAni.cardMsg = _message
                catAni.totalMoney = _money
                catAni.iscancel = _iscancel
                catAni.catlistener = _listener
                catAni.CardViewInit()
                return
            }
            if String(describing: topMostViewController()).contains("CatAnimationViewController")
            {
                DispatchQueue.main.async {
                    topMostViewController()?.dismiss(animated: true)
                    {
                        guard let catAni = storyboard!.instantiateViewController(withIdentifier: "CatAnimationViewController") as? CatAnimationViewController else {return}
                        catAni.view.backgroundColor = .white
                        catAni.modalPresentationStyle = .fullScreen
                        catAni.cardMsg = _message
                        catAni.totalMoney = _money
                        catAni.iscancel = _iscancel
                        catAni.catlistener = _listener
                        Utils.topMostViewController()?.present(catAni, animated: true, completion: nil)
                    }
                }
            }
            else
            {
                guard let catAni = storyboard!.instantiateViewController(withIdentifier: "CatAnimationViewController") as? CatAnimationViewController else {return}
                catAni.view.backgroundColor = .white
                catAni.modalPresentationStyle = .fullScreen
                catAni.cardMsg = _message
                catAni.totalMoney = _money
                catAni.iscancel = _iscancel
                catAni.catlistener = _listener
                Utils.topMostViewController()?.present(catAni, animated: true, completion: nil)
            }
        }
        
    }
    
    ///간편결제 시 새로운 카메라스캐너를 하는 뷰컨트롤러를 띄워서 처리한다
    static func ScannerOpen(Sdk _sdk:String) {
        let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        /** 기존의 메세지박스가 있다면 제거한다 */
        if presented is UIAlertController
        {
            DispatchQueue.main.async {
                topMostViewController()?.dismiss(animated: true){
                    var storyboard:UIStoryboard?
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    } else {
                        storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
                    }
                    guard let scannerView = storyboard!.instantiateViewController(withIdentifier: "ScannerViewController") as? ScannerViewController else {return}
                    scannerView.initSetting(Sdk: _sdk)
                    Utils.topMostViewController()?.present(scannerView, animated: true, completion: nil)
                    
                }
            }
            
        }
        else
        {
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            guard let scannerView = storyboard!.instantiateViewController(withIdentifier: "ScannerViewController") as? ScannerViewController else {return}
            scannerView.initSetting(Sdk: _sdk)
            Utils.topMostViewController()?.present(scannerView, animated: true, completion: nil)

        }
    }
    
    /// string.plist 읽어 들이는 함수
    /// - Returns: NSDictionary
    static func getStringPlist() -> NSDictionary {
        
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "string", ofType: "plist") {
           nsDictionary = NSDictionary(contentsOfFile: path)
        }
        return nsDictionary!
    }
    
    
    static func getDeviceUUID() -> String {
        guard let uuid:String = UIDevice.current.identifierForVendor?.uuidString else {
            return ""
        }
        return uuid
    }
    
    /** UUID 키체인으로 등록하고 해당 UUID 를 반환한다 */
    static func getKeyChainUUID() -> String {
        var _macAddr:String = ""
        if KeychainWrapper.standard.string(forKey: define.APP_KEYCHAIN) != nil {
            _macAddr = KeychainWrapper.standard.string(forKey: define.APP_KEYCHAIN)!
        } else {
            let str:String = getDeviceUUID()
            KeychainWrapper.standard.set(str, forKey: define.APP_KEYCHAIN)
            _macAddr = KeychainWrapper.standard.string(forKey: define.APP_KEYCHAIN)!
        }
        let _key:String = String(_macAddr.split(separator: "-").last!)
        let _key15count = rightPad(str: _key, fillChar: "0", length: 15)
        return _key15count
    }
    
    /** 서버에서 내려온 포스의 하드웨어 고유키.
     이 키를 반드시 키체인으로 등록해둔다(base64인코딩하여저장)
     그리고 해당값은 신용 승인/취소 거래 시 사용한다(이때 디코딩하여 보낸다 */
    static func setPosKeyChainUUIDtoBase64(Target _target:keyChainTarget, Tid _tid:String, PosKeyChain _posKey:String) {
        // 여기서 base64로 인코딩한해서 아래에 값을 저장한다
//        if _posKey == "" {
//            KeychainWrapper.standard.set("", forKey: define.SERVER_KEYCHAIN)
//            return
//        }
//        let _base64Encode:String = toBase64Encoding(Res: leftPad(str: _posKey, fillChar: " ", length: 15))
//        KeychainWrapper.standard.set(_base64Encode, forKey: define.SERVER_KEYCHAIN)
        
        if _tid == "" {
            return
        }
        
        //서버에서 해당 값이 빈값으로 오는 경우도 발생 할 수 있다.
//        if _posKey == "" {
//            return
//        }

        var _key:String = ""
        
        if _target == .AppToApp {
            _key = keyChainTarget.AppToApp.rawValue + _tid
        } else if _target == .KocesICIOSPay {
            _key = keyChainTarget.KocesICIOSPay.rawValue + _tid
        }
        
        let _base64Encode:String = toBase64Encoding(Res: rightPad(str: _posKey, fillChar: " ", length: 15))
        KeychainWrapper.standard.set(_base64Encode, forKey: _key)
        
    }
    
    /** 서버에서 내려온 포스의 하드웨어 고유키.
     이 키를 반드시 키체인으로 등록해둔다(base64인코딩하여저장)
     그리고 해당값은 신용 승인/취소 거래 시 사용한다(이때 디코딩하여 보낸다 */
    static func getPosKeyChainUUIDtoBase64(Target _target:keyChainTarget, Tid _tid:String) -> String {
        // 여기서 base64로 인코딩한해서 아래에 값을 저장한다
        var _base64Decode:String = ""
        let _key:String = _target.rawValue + _tid
        if KeychainWrapper.standard.string(forKey: _key) != nil {
            if KeychainWrapper.standard.string(forKey: _key) == "" {
                _base64Decode = ""
                return _base64Decode
            }
            _base64Decode = fromBase64Decoding(Res: KeychainWrapper.standard.string(forKey: _key)!)
        }
        return _base64Decode
    }
    
    ///base64를 디코딩
    static func fromBase64Decoding(Res _res:String) -> String {
        guard let data = Data(base64Encoded: _res, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return ""
        }
        return String(data: data as Data, encoding: String.Encoding.utf8) ?? ""
    }

    ///base64로 인코딩
    static func toBase64Encoding(Res _res:String) -> String {
        guard let data = _res.data(using: String.Encoding.utf8) else {
            return ""
        }
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    ///한국 전화 번호 '-' 번호 넣기
    static func seperated_phonenum(전화번호 _phoneNumber:String) -> String
    {
        var number = ""
        ///번호가 9자 이내의 경우
        return number
    }
    
    ///출력이 가능한 장치인지 체크
    static func PrintDeviceCheck() -> String {
        var _check = ""
        if KocesSdk.instance.blePrintState == define.PrintDeviceState.BLENOPRINT {
            _check += " 출력 가능 장비 없음. "
            return _check
        }
        
        if KocesSdk.instance.blePrintState == define.PrintDeviceState.BLEUSEPRINT {
            let TempDeviceName:String = KocesSdk.instance.mModelNumber
            if TempDeviceName.contains("C100") {
                _check += " 출력 가능 장비 없음. "
            } else if TempDeviceName.contains(define.bleNameKwang) {
                _check += " 출력 가능 장비 없음. "
            }
            return _check
        } else {
            //cat print 장비 연동
            if CheckPrintCatPortIP() != "" {
                _check += CheckPrintCatPortIP()
                return _check
            }
        }
        
//        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
//            _check += " 출력 가능 장비 없음. "
//            return _check
//        }
//
//        if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
//            let TempDeviceName:String = KocesSdk.instance.mModelNumber
//            if TempDeviceName.contains("C100") {
//                _check += " 출력 가능 장비 없음. "
//            } else if TempDeviceName.contains(define.bleNameKwang) {
//                _check += " 출력 가능 장비 없음. "
//            }
//            return _check
//        } else {
//            //cat 장비 연동
//            if CheckCatPortIP() != "" {
//                _check += CheckCatPortIP()
//                return _check
//            }
//        }
       
        return _check
    }
    
    //cat 연동 시 포트,ip 설정이 되어 있는지 체크
    static func CheckCatPortIP() -> String {
        var _check = ""
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            if Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_IP) == "" {
                _check += " CAT IP 가 셋팅되지 않았습니다 "
                return _check
            }
            if Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT) == "" {
                _check += " CAT PORT 가 셋팅되지 않았습니다 "
                return _check
            }
        } else {
            _check += " Cat 연동 중이 아닙니다 "
            return _check
        }
        return _check
    }
    
    static func CheckPrintCatPortIP() -> String {
        var _check = ""
        if KocesSdk.instance.blePrintState == define.PrintDeviceState.CATUSEPRINT {
            if Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_IP) == "" {
                _check += " CAT PRINT IP 가 셋팅되지 않았습니다 "
                return _check
            }
            if Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_PORT) == "" {
                _check += " CAT PRINT PORT 가 셋팅되지 않았습니다 "
                return _check
            }
        } else {
            _check += " Cat PRINT 연동 중이 아닙니다 "
            return _check
        }
        return _check
    }
    
    /** 카드종류 1신용 2체크 3기프트 4기타 스페이스패딩은 신용 */
    static func CardKindCheck(CardKind card:String) -> String {
        var _card = card
        switch card {
        case " ":
            _card = "신용"
        case "1":
            _card = "신용"
        case "2":
            _card = "체크"
        case "3":
            _card = "기프트"
        case "4":
            _card = "기타"
        default:
            break
        }
        return _card
    }
    
    /** TmicNo 단말인증번호가 리더기를 사용하지 않는 거래를 서버로 전달할 때는
     ##KOCESICIOS1002################
     APP 의 식별번호 + # 패딩으로 처리
     */
    static func AppTmlcNo() -> String {
        let appid: String = "################" + define.KOCES_ID 

        return appid
    }
    
    static func dateComp(승인날짜 _auDate:String) -> Bool {
        var _result:Bool = false
        var au = _auDate
        if _auDate.isEmpty {
            return _result
        }
        if _auDate.count < 2 {
            return _result
        }
        if String(au.prefix(2)) == "20" {
            au.removeFirst()
            au.removeFirst()
        }
        let auchars:[Character] = Array(au)
        
        var _year:Int = Int("20" + String(auchars[0...1])) ?? 0
        var _month:Int = Int(String(auchars[2...3])) ?? 0
        var _day:Int = Int(String(auchars[4...5])) ?? 0
        
        let myDateComponents = DateComponents(year: _year, month: _month, day: _day)
        let startDate = Calendar.current.date(from: myDateComponents)!

        let offsetComps = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        if offsetComps >= 90 {
            _result = true
        }
        return _result
        
    }
    
    /** 카드번호만 처리 */
    static func CardParser(카드번호 _cardNum:String, 날짜90일경과 _overDate:Bool = false) -> String {
        var _num = ""
        if _cardNum.contains("=") {
            _num = String(_cardNum.split(separator: "=").first!)
            if _num.contains("-") {
                var _tmp = _num.split(separator: "-")
                var _tmpNum = ""
                for i in 0 ..< _tmp.count {
                    if i == 2 {
                        _tmpNum += "****" + "-"
                    } else {
                        if _overDate {
                            if i >= 3 {
                                for j in 0 ..< _tmp[i].count {
                                    _tmpNum += "*"
                                }
                                _tmpNum += "-"
                            } else {
                                _tmpNum += String(_tmp[i]) + "-"
                            }
                        } else {
                            _tmpNum += String(_tmp[i]) + "-"
                        }
                    }
                 
                }
                _tmpNum.removeLast()    //"-" 제거
                _tmpNum.removeLast()    //"마지막번호" 제거
                _tmpNum += "*"
                _num = _tmpNum
            } else {
                if _cardNum.count >= 15 {
                    if _overDate {
                        _num = String(_cardNum.prefix(8))
                        for _ in 0 ..< _cardNum.count-7 {
                            _num += "*"
                        }
                    } else {
                        _num = String(_cardNum.prefix(8)) + "****" + _cardNum.substring(시작: 12)
                        _num.removeLast()
                        _num += "*"
                    }
               
                }
            }
        } else {
            _num = _cardNum
            if _num.contains("-") {
                var _tmp = _num.split(separator: "-")
                var _tmpNum = ""
                for i in 0 ..< _tmp.count {
                    if i == 2 {
                        _tmpNum += "****" + "-"
                    } else {
                        if _overDate {
                            if i >= 3 {
                                for j in 0 ..< _tmp[i].count {
                                    _tmpNum += "*"
                                }
                                _tmpNum += "-"
                            } else {
                                _tmpNum += String(_tmp[i]) + "-"
                            }
                        } else {
                            _tmpNum += String(_tmp[i]) + "-"
                        }
                    }
                }
                _tmpNum.removeLast()    //"-" 제거
                _tmpNum.removeLast()    //"마지막번호" 제거
                _tmpNum += "*"
                _num = _tmpNum
            } else {
                if _cardNum.count >= 15 {
                    if _overDate {
                        _num = String(_cardNum.prefix(8))
                        for _ in 0 ..< _cardNum.count-7 {
                            _num += "*"
                        }
                    } else {
                        _num = String(_cardNum.prefix(8)) + "****" + _cardNum.substring(시작: 12)
                        _num.removeLast()
                        _num += "*"
                    }
               
                }
            }
        }
        
        
        return _num
    }
    /** 현금영수증만 처리 */
    static func CashParser(현금영수증번호 _cardNum:String, 날짜90일경과 _overDate:Bool = false) -> String {
        var _num = ""
        if _cardNum.contains("=") {
            _num = String(_cardNum.split(separator: "=").first!)
            if _num.count >= 16 {
                _num.removeLast()
                _num = String(_num.prefix(8)) + "****" + _num.substring(시작: 12) + "*"
            } else if _cardNum.count == 15 {
                _num = String(_num.prefix(8)) + "****" + "***"
            } else if _cardNum.count >= 13 && _cardNum.count < 15 {
                _num = String(_num.prefix(6)) + "****" + "***"
            } else if _cardNum.count >= 11 && _cardNum.count < 13 {
                _num = String(_num.prefix(3)) + "****" + _num.substring(시작: 7)
            } else if _cardNum.count == 10 {
                _num = String(_num.prefix(2)) + "****" + _num.substring(시작: 6)
            } else {
                //이건 그냥 사용
            }
 
        } else {
            _num = _cardNum
            if _num.count >= 16 {
                _num.removeLast()
                _num = String(_num.prefix(8)) + "****" + _num.substring(시작: 12) + "*"
            } else if _cardNum.count == 15 {
                _num = String(_num.prefix(8)) + "****" + "***"
            } else if _cardNum.count >= 13 && _cardNum.count < 15 {
                _num = String(_num.prefix(6)) + "****" + "***"
            } else if _cardNum.count >= 11 && _cardNum.count < 13 {
                _num = String(_num.prefix(3)) + "****" + _num.substring(시작: 7)
            } else if _cardNum.count == 10 {
                _num = String(_num.prefix(2)) + "****" + _num.substring(시작: 6)
            } else {
                //이건 그냥 사용
            }
        }
        
        
        return _num
    }
    /** 간편결제바코드qr번호처리 */
    static func EasyParser(바코드qr번호 _cardNum:String, 날짜90일경과 _overDate:Bool = false) -> String {
        var _num = ""
        if _cardNum.contains("=") {
            _num = String(_cardNum.split(separator: "=").first!)
            if _num.contains("-") {
                var _tmp = _num.split(separator: "-")
                var _tmpNum = ""
                for i in 0 ..< _tmp.count {
                    if i == 2 {
                        _tmpNum += "****" + "-"
                    } else {
                        if _overDate {
                            if i >= 3 {
                                for j in 0 ..< _tmp[i].count {
                                    _tmpNum += "*"
                                }
                                _tmpNum += "-"
                            } else {
                                _tmpNum += String(_tmp[i]) + "-"
                            }
                        } else {
                            _tmpNum += String(_tmp[i]) + "-"
                        }
                    }
                }
                _tmpNum.removeLast()    //"-" 제거
                _tmpNum.removeLast()    //"마지막번호" 제거
                _tmpNum += "*"
                _num = _tmpNum
            } else {
                if _cardNum.contains("***") {
                    if _cardNum.count >= 15 {
                        if _overDate {
                            _num = String(_cardNum.prefix(8))
                            for _ in 0 ..< _cardNum.count-7 {
                                _num += "*"
                            }
                        } else {
                            _num = String(_cardNum.prefix(8)) + "****" + _cardNum.substring(시작: 12)
                            _num.removeLast()
                            _num += "*"
                        }
                   
                    }
                }
            }
        } else {
            _num = _cardNum
            if _num.contains("-") {
                var _tmp = _num.split(separator: "-")
                var _tmpNum = ""
                for i in 0 ..< _tmp.count {
                    if i == 2 {
                        _tmpNum += "****" + "-"
                    } else {
                        if _overDate {
                            if i >= 3 {
                                for j in 0 ..< _tmp[i].count {
                                    _tmpNum += "*"
                                }
                                _tmpNum += "-"
                            } else {
                                _tmpNum += String(_tmp[i]) + "-"
                            }
                        } else {
                            _tmpNum += String(_tmp[i]) + "-"
                        }
                    }
                }
                _tmpNum.removeLast()    //"-" 제거
                _tmpNum.removeLast()    //"마지막번호" 제거
                _tmpNum += "*"
                _num = _tmpNum
            } else {
                if _cardNum.contains("***") {
                    if _cardNum.count >= 15 {
                        if _overDate {
                            _num = String(_cardNum.prefix(8))
                            for _ in 0 ..< _cardNum.count-7 {
                                _num += "*"
                            }
                        } else {
                            _num = String(_cardNum.prefix(8)) + "****" + _cardNum.substring(시작: 12)
                            _num.removeLast()
                            _num += "*"
                        }
                   
                    }
                }

            }
        }
        return _num
    }

    static func ParserPrint(내용 _msg:String) -> String {
        var _print = ""
        _print = _msg.replacingOccurrences(of: define.PInit, with: Utils.UInt8ArrayToStr(UInt8Array: define.Init))
        _print = _print.replacingOccurrences(of: define.PFont_HT, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_HT))
        _print = _print.replacingOccurrences(of: define.PFont_LF, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_LF))
        
        _print = _print.replacingOccurrences(of: define.PFont_CR, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_CR))
        _print = _print.replacingOccurrences(of: define.PLogo_Print, with: Utils.UInt8ArrayToStr(UInt8Array: define.Logo_Print))
        _print = _print.replacingOccurrences(of: define.PCut_print, with: Utils.UInt8ArrayToStr(UInt8Array: define.Cut_print))
        _print = _print.replacingOccurrences(of: define.PMoney_Tong, with: Utils.UInt8ArrayToStr(UInt8Array: define.Money_Tong))
        _print = _print.replacingOccurrences(of: define.PPaper_up, with: Utils.UInt8ArrayToStr(UInt8Array: define.Paper_up))
        _print = _print.replacingOccurrences(of: define.PFont_Sort_L, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Sort_L))
        _print = _print.replacingOccurrences(of: define.PFont_Sort_C, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Sort_C))
        _print = _print.replacingOccurrences(of: define.PFont_Sort_R, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Sort_R))
        _print = _print.replacingOccurrences(of: define.PFont_Default, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Default))
        _print = _print.replacingOccurrences(of: define.PFont_Size_H, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Size_H))
        _print = _print.replacingOccurrences(of: define.PFont_Size_W, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Size_W))
        _print = _print.replacingOccurrences(of: define.PFont_Size_B, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Size_B))
        _print = _print.replacingOccurrences(of: define.PFont_Bold_0, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Bold_0))
        _print = _print.replacingOccurrences(of: define.PFont_Bold_1, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Bold_1))
        _print = _print.replacingOccurrences(of: define.PFont_DS_0, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_DS_0))
        _print = _print.replacingOccurrences(of: define.PFont_DS_1, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_DS_1))
        _print = _print.replacingOccurrences(of: define.PFont_Udline_0, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Udline_0))
        _print = _print.replacingOccurrences(of: define.PFont_Udline_1, with: Utils.UInt8ArrayToStr(UInt8Array: define.Font_Udline_1))
        _print = _print.replacingOccurrences(of: define.PBar_Print_1, with: Utils.UInt8ArrayToStr(UInt8Array: define.Bar_Print_1))
        _print = _print.replacingOccurrences(of: define.PBar_Print_2, with: Utils.UInt8ArrayToStr(UInt8Array: define.Bar_Print_2))
        _print = _print.replacingOccurrences(of: define.PBar_Print_3, with: Utils.UInt8ArrayToStr(UInt8Array: define.Bar_Print_3))
        _print = _print.replacingOccurrences(of: define.PBarH_Size, with: Utils.UInt8ArrayToStr(UInt8Array: define.BarH_Size))
        _print = _print.replacingOccurrences(of: define.PBarW_Size, with: Utils.UInt8ArrayToStr(UInt8Array: define.BarW_Size))
        _print = _print.replacingOccurrences(of: define.PBar_Position_1, with: Utils.UInt8ArrayToStr(UInt8Array: define.Bar_Position_1))
        _print = _print.replacingOccurrences(of: define.PBar_Position_2, with: Utils.UInt8ArrayToStr(UInt8Array: define.Bar_Position_2))
        _print = _print.replacingOccurrences(of: define.PBar_Position_3, with: Utils.UInt8ArrayToStr(UInt8Array: define.Bar_Position_3))

        return _print
    }
    
    /**
     복수가맹점 TID 가 무엇인지 표시하기 위한 함수.
     */
    static func ParseMultiTid(Target _target:keyChainTarget) -> [String:String] {
        var resTidDic:[String:String] = [:]
        let _keyTID:String = (_target == .KocesICIOSPay ? define.STORE_TID:define.APPTOAPP_TID)
        let _keyBSN:String = (_target == .KocesICIOSPay ? define.STORE_BSN:define.APPTOAPP_BSN)
        let _keyStoreName:String = (_target == .KocesICIOSPay ? define.STORE_NAME:define.APPTOAPP_NAME)
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(_keyTID) {
                if key == _keyTID {
                    if (value as! String) != "" {
                        resTidDic[_keyTID] = value as? String
                        resTidDic[_keyBSN] = Setting.shared.getDefaultUserData(_key: _keyBSN)
                        resTidDic[_keyStoreName] = Setting.shared.getDefaultUserData(_key: _keyStoreName)
                    }
                } else if key == _keyTID + "0" {
                    if (value as! String) != "" {
                        resTidDic[_keyTID + "0"] = value as? String
                        resTidDic[_keyBSN + "0"] = Setting.shared.getDefaultUserData(_key: _keyBSN + "0")
                        resTidDic[_keyStoreName + "0"] = Setting.shared.getDefaultUserData(_key: _keyStoreName + "0")
                    }
                }  else if key == _keyTID + "1" {
                    if (value as! String) != "" {
                        resTidDic[_keyTID + "1"] = value as? String
                        resTidDic[_keyBSN + "1"] = Setting.shared.getDefaultUserData(_key: _keyBSN + "1")
                        resTidDic[_keyStoreName + "1"] = Setting.shared.getDefaultUserData(_key: _keyStoreName + "1")
                    }
                } else if key == _keyTID + "2" {
                    if (value as! String) != "" {
                        resTidDic[_keyTID + "2"] = value as? String
                        resTidDic[_keyBSN + "2"] = Setting.shared.getDefaultUserData(_key: _keyBSN + "2")
                        resTidDic[_keyStoreName + "2"] = Setting.shared.getDefaultUserData(_key: _keyStoreName + "2")
                    }
                } else if key == _keyTID + "3" {
                    if (value as! String) != "" {
                        resTidDic[_keyTID + "3"] = value as? String
                        resTidDic[_keyBSN + "3"] = Setting.shared.getDefaultUserData(_key: _keyBSN + "3")
                        resTidDic[_keyStoreName + "3"] = Setting.shared.getDefaultUserData(_key: _keyStoreName + "3")
                    }
                } else if key == _keyTID + "4" {
                    if (value as! String) != "" {
                        resTidDic[_keyTID + "4"] = value as? String
                        resTidDic[_keyBSN + "4"] = Setting.shared.getDefaultUserData(_key: _keyBSN + "4")
                        resTidDic[_keyStoreName + "4"] = Setting.shared.getDefaultUserData(_key: _keyStoreName + "4")
                    }
                } else if key == _keyTID + "5" {
                    if (value as! String) != "" {
                        resTidDic[_keyTID + "5"] = value as? String
                        resTidDic[_keyBSN + "5"] = Setting.shared.getDefaultUserData(_key: _keyBSN + "5")
                        resTidDic[_keyStoreName + "5"] = Setting.shared.getDefaultUserData(_key: _keyStoreName + "5")
                    }
                }
            }
        }
        return resTidDic
    }

    static func pixelValues(fromCGImage imageRef: UIImage) -> [UInt8]?
    {
        let bitmap:BMImage =     BMImage(cgImage: imageRef.cgImage!)
        let IamgeByteData = bitmap.getInvertPixelBytes()
        var bmpByteData:[UInt8] = [0x42,0x4D]   //'BM'
        bmpByteData += [0x3E, 0x04, 0x00, 0x00, 0x00, 0x00] //4바이트 파일크가 2바이트 bfReserved1
        bmpByteData += [0x00, 0x00, 0x3E, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00] //2바이트 bfReserved2 //4바이트  비트맵데이터시작위치 //4바이트 비트맵 헤더 정보 사이즈
        bmpByteData += [0x80, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00] //4바이트 이미지 가로크기 //4바이트 비트맵 세로 크기
        bmpByteData += [0x01, 0x00, 0x01, 0x00 ] //2바이트 사용하는 색상판수 항상 1 //2바이트 픽셀 하나를 표현하는 비트 수
        bmpByteData += [0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00] //4바이트 항상 0 //4바이트 픽셀데이터 크기
        bmpByteData += [0xC4, 0x0E, 0x00, 0x00, 0xC4, 0x0E, 0x00, 0x00] //4바이트 가로 해상도 //4바이트 세로 해상도
        bmpByteData += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] //4바이트 사용되는 색상수 //4바이트 색상 인덱스
        bmpByteData += [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        bmpByteData = IamgeByteData
        return bmpByteData
        /** 혹시 몰라서 만들어 놓음 */
 
    }
    
}

