//
//  TcpSocket.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/10.
//

import Foundation

public protocol TcpSocketDelegate:AnyObject {
    func socketConnectSuccess(Data _data:[UInt8])
    func socketConnectFail()
}

class TcpSocket: NSObject, StreamDelegate{
    
    var host:String?
    var port:Int?
    var inputStream:InputStream?
    var outputStream:OutputStream?
    var recData:[UInt8] = []
    public weak var delegate:TcpSocketDelegate?
    var SocketTimeOut:Timer?
    var IsCat = false  //만일 단말기가 CAT 이면 true
    
    func connect(host: String, port: Int, Data _recData:[UInt8] = [UInt8](), IsCat _isCat:Bool = false){
        
        self.host = host
        self.port = port
        self.recData = _recData
        self.IsCat = _isCat
        if recData.count > 0 {
            SocketTimeOut = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { [self] Timer in
                SocketTimeOut?.invalidate()
                SocketTimeOut = nil
                delegate?.socketConnectFail()
            })
        }
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)

        if inputStream != nil && outputStream != nil {
            //self delegate
            inputStream!.delegate = self
            outputStream!.delegate = self

            //schedule
            inputStream?.schedule(in: .current, forMode: RunLoop.Mode.common)
            outputStream?.schedule(in: .current, forMode: RunLoop.Mode.common)
            let socketWorkQueue = DispatchQueue(label: "socketWorkQueue", attributes: .concurrent)
            CFReadStreamSetDispatchQueue(inputStream, socketWorkQueue)
            CFWriteStreamSetDispatchQueue(outputStream, socketWorkQueue)

    //        CFReadStreamOpen(inputStream)
    //        CFWriteStreamOpen(outputStream)
            //open
            inputStream!.open()
            outputStream!.open()
        }
    }
    
    @discardableResult
    func send(data: Data) -> Int{
        if outputStream == nil {
            return 0
        }
        if outputStream?.streamStatus != .open {
            return 0
        }

        let bytesWritten = data.withUnsafeBytes {outputStream?.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)}

        return bytesWritten ?? 0
    }
    
//    func sendByte(data: [UInt8]){
//        return outputStream?.write(data, maxLength: data.count)
//    }
    
    func recv(buffersize: Int) -> Data {
        
        if inputStream == nil {
            return Data()
        }
        if inputStream?.streamStatus != .open {
            return Data()
        }

        
        var buffer = [UInt8](repeating: 0, count: buffersize)
        
        let bytesRead = inputStream?.read(&buffer, maxLength: buffersize)
        var dropCount = buffersize - (bytesRead ?? 0)
        if dropCount < 0 {
            dropCount = 0
        }
        let chunk = buffer.dropLast(dropCount)
  
        debugPrint("Server -> App :", Utils.UInt8ArrayToHexCode(_value: Array(chunk),_option: true))

        return Data(chunk)
    }
    
    func disconnect(){
        recData.removeAll()
        IsCat = false
        host = nil
        port = nil
        SocketTimeOut?.invalidate()
        SocketTimeOut = nil
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
        outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
        inputStream?.close()
        outputStream?.close()
        if inputStream != nil {
            CFReadStreamClose(inputStream)
        }
        if outputStream != nil {
            CFWriteStreamClose(outputStream)
        }
        inputStream = nil
        outputStream = nil

    }
    
    func stream(_ stream: Stream, handle eventCode: Stream.Event){
        
        print("event:\(eventCode)")
        if IsCat {
           TcpCatStream(stream, handle: eventCode)
        } else {
            TcpKocesStream(stream, handle: eventCode)
        }
        
    }
    
    func TcpCatStream(_ stream: Stream, handle eventCode: Stream.Event){
        switch stream {
        case inputStream:
            switch eventCode {
            case Stream.Event.errorOccurred:
                print("inputStream:ErrorOccurred")
                break
            case Stream.Event.openCompleted:
                print("inputStream:OpenCompleted")
                break
            case Stream.Event.hasBytesAvailable:
                print("inputStream:HasBytesAvailable")
//                disconnect()
                return
                //여기가 서버에서 정상적으로 파일을 받을 때
            case Stream.Event.endEncountered:
                print("inputStream:endEncountered")
                break
            case Stream.Event.hasSpaceAvailable:
                print("inputStream:hasSpaceAvailable")
            default:
                print("inputStream: \(eventCode)")
                break
            }
            break
        case outputStream:
            switch eventCode {
            case Stream.Event.errorOccurred:
                print("outputStream:ErrorOccurred")
                break
            case Stream.Event.openCompleted:
                print("outputStream:OpenCompleted")
                SocketTimeOut?.invalidate()
                SocketTimeOut = nil
                delegate?.socketConnectSuccess(Data: recData)
                break
            case Stream.Event.hasBytesAvailable:
                print("outputStream:HasBytesAvailable")
                //정상적으로 데이터를 보냈다
                break
            case Stream.Event.endEncountered:
                print("outputSteam:endEncountered")
                break
            case Stream.Event.hasSpaceAvailable:
                print("outputSteam:hasSpaceAvailable")
            default:
                print("outputSteam: \(eventCode)")
                break
            }
            break
        default:
            break
        }
    }
    
    func TcpKocesStream(_ stream: Stream, handle eventCode: Stream.Event){
        switch stream {
        case inputStream:
            switch eventCode {
            case Stream.Event.errorOccurred:
                print("inputStream:ErrorOccurred")
                break
            case Stream.Event.openCompleted:
                print("inputStream:OpenCompleted")
                SocketTimeOut?.invalidate()
                SocketTimeOut = nil
                delegate?.socketConnectSuccess(Data: recData)
                break
            case Stream.Event.hasBytesAvailable:
                print("inputStream:HasBytesAvailable")
//                disconnect()
                return
                //여기가 서버에서 정상적으로 파일을 받을 때
            case Stream.Event.endEncountered:
                print("inputStream:endEncountered")
                break
            case Stream.Event.hasSpaceAvailable:
                print("inputStream:hasSpaceAvailable")
            default:
                print("inputStream: \(eventCode)")
                break
            }
            break
        case outputStream:
            switch eventCode {
            case Stream.Event.errorOccurred:
                print("outputStream:ErrorOccurred")
                break
            case Stream.Event.openCompleted:
                print("outputStream:OpenCompleted")
                break
            case Stream.Event.hasBytesAvailable:
                print("outputStream:HasBytesAvailable")
                //정상적으로 데이터를 보냈다
                break
            case Stream.Event.endEncountered:
                print("outputSteam:endEncountered")
                break
            case Stream.Event.hasSpaceAvailable:
                print("outputSteam:hasSpaceAvailable")
            default:
                print("outputSteam: \(eventCode)")
                break
            }
            break
        default:
            break
        }
    }
    
}
