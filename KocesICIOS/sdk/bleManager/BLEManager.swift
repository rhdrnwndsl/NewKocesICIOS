//
//  bleManager.swift
//  bleManager
//
//  Created by leehun on 2020/4/14.
//  Copyright © 2020 ycfy. All rights reserved.
//
import UIKit
import CoreBluetooth

public protocol BLEManagerDelegate : class {
    func bleManagerNotification(info:String)
    func bleManagerUpdateDevices(devices:[Dictionary<String,Any>])
    func bleManagerConnectStart()
    func bleManagerConnectSuccess(name:String, uuid:String)
    func bleManagerConnectFail()
    func bleManagerScanFail()
    func bleManagerDisconnect()
    func bleManagerScanSuccess()
    func bleManagerReceive(data:[UInt8])
    func bleManagerIsPaired(uuid:UUID, device:[Dictionary<String,Any>])
    func bleManagerIsConnected()
    func bleManagerSend(_data:[UInt8])
    func bleManagerPowerOff()
    func bleManagerWriteComplete(data:Data?)
    func bleManagerPairingFail()
    func bleManagerConnectTimeOut()
}

public class DeviceInfo:NSObject{
    var name:String?
    var service:String?
    var rxserial:String?
    var txserial:String?
    
    public override init() {
        
    }
    
    public init(name:String, service:String, rxserial:String, txserial:String) {
        super.init()
        self.name = name
        self.service = service
        self.rxserial = rxserial
        self.txserial = txserial
    }
}

public class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {
//    let bleSendMaxSize:Int = 100        //한번에 보낼 수 있는 데이터 사이즈

    static var Devices:[DeviceInfo] = [
//        DeviceInfo(name: "PW-01", service: "AB00", serial: "AB02"),
//        DeviceInfo(name: "PW-02", service: "DFB0", serial: "DFB1"),
//        DeviceInfo(name: "PW-03", service: "FFE0", serial: "FFE1")
//        DeviceInfo(name: "KRE-C101", service: "FE7D", serial: "1E4D")
    ]
    
    public static func setDetectDevices(devices:[DeviceInfo])
    {
        self.Devices = devices
    }
    
    /** 해당내용 Setting.swift 로 이동했다 */
//    static let LAST_CONNECT_DEVICE = "LAST_CONNECT_DEVICE"
    
    public weak var delegate:BLEManagerDelegate?
    var manager:CBCentralManager!
    
    var peripheral:CBPeripheral?
//    var atCtrl:CBCharacteristic?
    var deviceInfo:DeviceInfo?
    
    var devices:Dictionary = [UUID:Dictionary<String,Any>]()
    var isConnected:Bool = false
    var isRequestDisconnect:Bool = false
    var connectionTimeout:Timer?
    var scanTimeout:Timer?

    var pairingCheck: Bool = false
    
    var pairingCount: Int = 0   //페어링 실패를 카운트 해서 카운트가 올라가면 연속적으로 스캔이 들어오는 것을 막는다
    
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    private var connectServiceUUID: String = ""
    
    public override init() {
        super.init()
        // 210124_by_jiw
        // 앱이 실행되고 blemanager 를 따로 불러들이지 않아도 init 되기 때문에 아래를이곳에서 두면 이걸 앱의 실행순서와 관계없이 블루투스를 계속 먼저 찾고 있다. 실행순서를 통제하기 위해서 다른 곳에서 불러온다
//        manager = CBCentralManager(delegate: self, queue: nil, options:[CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    @discardableResult
    public func managerInit() -> CBCentralManager {
        manager = CBCentralManager(delegate: self, queue: nil, options:[CBCentralManagerOptionShowPowerAlertKey: true])
        return manager
    }
    
    //ble의 연결상태를 전달
    public func getIsConnected() -> Bool {
        return isConnected
    }
    
    //반드시 아래를 동작해줘야 한다. 아래가 실행되고 자동으로 scan() 함수가 들어가서 스캔후에 manager.scanForPeripherals(withServices: nil, options: nil) 를 통해서
    //centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    //에서 기존에 등록되어 있던 DeviceInfo(name: "KRE-C101", service: "FE7D", serial: "1E4D") 와 비교하여 일치하면 자동으로 연결한다 210124_by_jiw
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        scan()
    }
    
    public func scan()
    {
        if manager.state == CBManagerState.poweredOn
        {
            if isConnected {
                self.manager.stopScan()
                delegate?.bleManagerIsConnected()
                return
            }
            
            self.scanTimeout?.invalidate()
            self.scanTimeout = nil
            self.devices = [UUID:Dictionary<String,Any>]()
            manager.scanForPeripherals(withServices: nil, options: nil)
            self.scanTimeout = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
                self.manager.stopScan()
                
                if self.devices.count != 0 {
                    self.delegate?.bleManagerScanSuccess()
                } else {
                    self.delegate?.bleManagerScanFail()
                    self.disconnectClear()
                }

                self.scanTimeout?.invalidate()
                self.scanTimeout = nil
            })
            return
        }
        else {
            delegate?.bleManagerNotification(info: "Bluetooth not avaliable.")
            delegate?.bleManagerPowerOff()
            self.disconnectClear()
            return
        }

        
    }
    
    public static func isPaired() -> Bool {
        return UserDefaults.standard.string(forKey: define.LAST_CONNECT_DEVICE) != nil
    }
    
    public func isPaired(uuid:UUID) -> Bool
    {
        guard let deviceUUID = UserDefaults.standard.string(forKey: define.LAST_CONNECT_DEVICE) else {return false}
        return deviceUUID == uuid.uuidString
    }
    
    public func findDeviceInfo(device:NSString) -> DeviceInfo?
    {
        for item in BLEManager.Devices{
            /**
             등록되어있는 것만 스캔하려면 내가 모든걸 알고 있어야 한다 일단 주석처리 210124_by_jiw
             */
            if device.contains(item.name!) {
                return item
            }
        }
        return nil
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString else {
            return
        }
        guard let deviceInfo = findDeviceInfo(device: device) else {
            return
        }
        if nil != self.devices[peripheral.identifier] {
            return
        }
        
        debugPrint("Device_advertisementData_Name : ", device)
        debugPrint("Device_peripheral_Name : ", peripheral.name!)
        debugPrint("Device_uuid_Name : ", peripheral.identifier.uuidString)
        
        let elements = peripheral.identifier.uuidString.split(separator: "-")
        self.devices[peripheral.identifier] = ["uuid":peripheral.identifier, "peripheral":peripheral,"device":"\(device):\(String(elements.last!))", "rssi":RSSI, "info": deviceInfo]
        
        //자동으로 커넥트 하고 리턴시킨다 일단 주석처리 210124_by_jiw
        if isPaired(uuid: peripheral.identifier){
//            self.connect(uuid: peripheral.identifier)
            self.manager.stopScan()
            self.scanTimeout?.invalidate()
            self.scanTimeout = nil
            delegate?.bleManagerIsPaired(uuid: peripheral.identifier, device: Array(self.devices.values))
            return
        }
        
        var sorted = Array(self.devices.values)
        
        if sorted.count > 1 {

            sorted = sorted.sorted{
                
                let left = $0["rssi"] as! NSNumber
                let right = $1["rssi"] as! NSNumber
                
                return left.intValue > right.intValue
            }
        }

        delegate?.bleManagerUpdateDevices(devices: sorted)


    }
    
    public func connect(uuid: UUID)
    {
        debugPrint("connect start : ", uuid)
        if(self.isConnected)
        {
            debugPrint("isConnected : ", uuid)
            self.manager.stopScan()
            delegate?.bleManagerIsConnected()
            return
        }
        
        self.isConnected = false
        self.manager.stopScan()
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        
        guard let item = self.devices[uuid] else {
            debugPrint("item = self.devices[uuid] fail : ", uuid)
            delegate?.bleManagerConnectFail()
            self.disconnectClear()
            self.managerInit()
            return
        }
        
        self.peripheral = item["peripheral"] as? CBPeripheral
        self.peripheral?.delegate = self
        self.deviceInfo = item["info"] as? DeviceInfo

        guard let conn = self.peripheral else
        {
            debugPrint("conn = self.peripheral fail : ", deviceInfo)
            delegate?.bleManagerConnectFail()
            self.disconnectClear()
            self.managerInit()
            return
        }
        connectServiceUUID = (deviceInfo?.service)!
        
        self.manager.connect(conn, options: nil)

        delegate?.bleManagerConnectStart()
        
        self.connectionTimeout = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
            debugPrint("connectionTimeout timeout")
            self.delegate?.bleManagerConnectTimeOut()
            self.disconnectClear()
            // 타임아웃이니까 커넥트실패로 처리한다. 디스커넥트처리하면 연결해제라는 메세지를 보내기 때문에 상황이 안맞아 보인다
            self.connectionTimeout?.invalidate()
            self.connectionTimeout = nil
            self.managerInit()
        })
    }
    
    func disconnectClear() {
        
        peripheral = nil
//        atCtrl = nil
        deviceInfo = nil
        txCharacteristic = nil
        rxCharacteristic = nil
        connectServiceUUID = ""
        
        devices = [UUID:Dictionary<String,Any>]()
        isConnected = false
        isRequestDisconnect = false

        pairingCheck = false
        
        delegate = nil
        
        sendQue = [Chunk]()
        isSending = false
        sendLock = NSLock()
        
        /** 이걸 한번 없애본다 */
//        manager = nil
    }
    
    public func disconnect()
    {
        guard let peripheral = self.peripheral else {
            return
        }
        isRequestDisconnect = true

        if isConnected {
            self.manager.cancelPeripheralConnection(peripheral)
        } else {
            delegate?.bleManagerDisconnect()
            disconnectClear()
        }
    }
    
    struct Chunk {
        var data:Data?
        var chunks:[Data]
    }
    
    var sendQue = [Chunk]()
    var isSending = false
    var sendLock = NSLock()
    
    func writeChunk(data:Data, name:String) -> [Data] {
        
        var chunks = [Data]()
        
        //맥스사이즈는 2으로 처리해본다
        var maxSize = 20
        if name.contains(define.bleNameZoa) {
            maxSize = 20
        } else if name.contains(define.bleNameKwang) {
            maxSize = 150
        } else if name.contains(define.bleNameKMPC) {
            maxSize = 80
        }
        var len = 0
        while len < data.count {
            let remain = data.count - len
            let chunkSize = remain < maxSize ? remain : maxSize
            let send = data.subdata(in: len..<len+chunkSize)
            len += chunkSize
            chunks.append(send)
        }

        return chunks
    }
    
    func write() -> Bool {
        sendLock.lock()
        defer {
            sendLock.unlock()
        }

        guard let peripheral = self.peripheral else {
            return false
        }
        
        if sendQue.isEmpty {
            isSending = false
            return false
        }
        
        if sendQue[0].chunks.isEmpty {
            let send = sendQue.removeFirst()
//            DispatchQueue.main.async {
//                self.delegate?.bleManagerWriteComplete(data: send.data)
//            }
        }
        
        if sendQue.isEmpty {
            isSending = false
            return false
        }

        let send = sendQue[0].chunks.removeFirst()
//        debugPrint(Utils.UInt8ArrayToHexCode(_value: Array(send),_option: true))

        peripheral.writeValue(send, for: self.rxCharacteristic!, type:.withResponse)
        return true
    }
    
    //이 변수를 만든 이유는 ble가 어떻게 된 이유인지 데이터를 한번에 수신 하지 못해서 끊어 보내기 위해서 아래 변수를 설정한다.
//    var SendData:Data?  //보낼 데이터 전체
//    public func write(data:Data) -> Bool
//    {
//        SendData = data
//        guard let peripheral = self.peripheral else {
//            return false
//        }
//        if SendData!.count < bleSendMaxSize
//        {
//            delegate?.bleManagerSend(_data: Array(SendData!))
//            peripheral.writeValue(SendData!, for: self.atCtrl!, type:.withResponse)
//            SendData = nil
//        }
//        else
//        {
//            let Arr = SendData?.prefix(bleSendMaxSize)
//            delegate?.bleManagerSend(_data: Array(Arr!))
//            peripheral.writeValue(Arr!, for: self.atCtrl!, type:.withResponse)
//            SendData?.removeSubrange(0..<bleSendMaxSize)
//
//        }
//
//        return true
//    }
    
    public func write(data:Data, name:String) -> Bool
    {
        if(!self.isConnected)
        {
            self.manager.stopScan()
            isConnected = false
            delegate?.bleManagerNotification(info: "disconnect device")
            delegate?.bleManagerDisconnect()
            disconnectClear()
            return false
        }
        
        var chunks = writeChunk(data: data, name: name)

        sendLock.lock()
        sendQue.append(Chunk(data: data, chunks: chunks))
        
        if isSending {
            return true
        }
        
        sendLock.unlock()
        
        sendLock.lock()
        defer {
            sendLock.unlock()
        }

        guard let peripheral = self.peripheral else {
            return false
        }
        
        for i in 0 ..< chunks.count {

            if chunks.isEmpty {
                let send = chunks.removeFirst()
    //            DispatchQueue.main.async {
    //                self.delegate?.bleManagerWriteComplete(data: send.data)
    //            }
            }

            let send = chunks.removeFirst()
            debugPrint(Utils.UInt8ArrayToHexCode(_value: Array(send),_option: true))

            peripheral.writeValue(send, for: self.rxCharacteristic!, type:.withoutResponse)
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        return true
//        return write()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
//        peripheral.discoverServices(nil)
        peripheral.discoverServices([CBUUID(string: connectServiceUUID)])
        
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
        
        self.connectionTimeout = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
            debugPrint("connectionTimeout timeout")
            self.delegate?.bleManagerConnectTimeOut()
            self.disconnectClear()
            // 타임아웃이니까 커넥트실패로 처리한다. 디스커넥트처리하면 연결해제라는 메세지를 보내기 때문에 상황이 안맞아 보인다
            self.connectionTimeout?.invalidate()
            self.connectionTimeout = nil
            self.managerInit()
        })
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let serviceName = self.deviceInfo?.service else {return}
        guard let services = peripheral.services else {
                    return
                }
        
        for _service in services {
            
//            let service = _service as CBService
            /**
             등록한 서비스아이디로 체크하기에는 우리가 다 알고 있어야 해서 서비스아이디의 길이만 체크해서 맞는 것을 등록한다 210124_by_jiw
             */
            if false == _service.uuid.uuidString.contains(serviceName) {
                continue
            }

            delegate?.bleManagerNotification(info: "connect service:" + _service.uuid.uuidString)
            peripheral.discoverCharacteristics(nil, for: _service)
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        guard let rxSerialName = self.deviceInfo?.rxserial else {return}
        guard let txSerialName = self.deviceInfo?.txserial else {return}
        
        for _characteristic in service.characteristics!{
            
            let characteristic = _characteristic as CBCharacteristic
            /**
             등록한 시리얼 번호로 체크하는 부분. 우리가 시리얼번호를 알고 등록을 해줘야 해서 이부분 지우고 가장 먼저 찾은 것만 일단 해본다 210124_by_jiw
             */
            if !characteristic.uuid.uuidString.contains(txSerialName) && !characteristic.uuid.uuidString.contains(rxSerialName) {
                continue
            }
            
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                if characteristic.uuid.uuidString.contains(rxSerialName) {
                    rxCharacteristic = characteristic
//                    peripheral.setNotifyValue(true, for: characteristic)
                    delegate?.bleManagerNotification(info: "connect Rx complete:" + characteristic.uuid.uuidString)
                    
                }
            }

            if characteristic.uuid.uuidString.contains(txSerialName) {
                txCharacteristic = characteristic
                delegate?.bleManagerNotification(info: "connect Tx complete:" + characteristic.uuid.uuidString)
              
            }
            
            peripheral.setNotifyValue(true, for: characteristic)

        }
        if let device = self.peripheral{
            UserDefaults.standard.set(device.identifier.uuidString, forKey: define.LAST_CONNECT_DEVICE)
            self.pairingCount = 1
//                pairingCheck = true
//                self.isConnected = true
//                self.pairingCount = 0
//                delegate?.bleManagerConnectSuccess(name: peripheral.name ?? "", uuid: peripheral.identifier.uuidString)
            /** 페어링이 되었는지를 확인하기 위해 여기서 아무값이나 읽어본다 정상적으로 읽어지면 ok 아니면 실패 */
            peripheral.readValue(for: txCharacteristic)
        }
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil

    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if SendData != nil {    //보낼 데이터가 nil 아니면 다시 한번 write를 호출 한다.
//            let _:Bool = write(data: SendData!)
//        }
//        return
        
        if peripheral.canSendWriteWithoutResponse {
//            _ = write()
        } else {
            disconnect()
        }
        
       
    }
    
    
    var mReceivedData:[UInt8] = Array() //ble 수신 전체 데이터 담는 배열
    var mReceiveDataSize:Int = 0    //ble 수신 데이터 전체 길이
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if characteristic != txCharacteristic { return }
        /** 페어링체크를 하여서 페어링이 되었다는 게 완료되면 커넥트를 한다 아니면 커넥트 하지 않는다 */
        if !pairingCheck {
            pairingCheck = true
            self.isConnected = true
            self.pairingCount = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                //종종 페어링체크가 안되어있는데 정상적으로 읽히는 경우가 있다. 물론, 그럴경우 디스커넥트가 난다. 만일 그러하다면 다시한번 체크해서 페어링성공을 날린다
                if pairingCheck {
                    delegate?.bleManagerConnectSuccess(name: peripheral.name ?? "", uuid: peripheral.identifier.uuidString)
                }

            }

            /** 여기서의 리턴은 처음에 페어링이 되었다고 하면 커넥트를 완료하고 아래에서 데이터를 한번 읽게 되는데
             이렇게하면 후에 페어링되어있는 데이터는 초기접속시 데이터를 2번 읽어들이게 된다. 이를 방지하기 위해 여기서 리턴시킨다 */
            return
        }

        
        guard let value = characteristic.value else{
            return
        }
        
//        mReceivedData += [UInt8](value)
//        var data = [UInt8](value)
//        if data.count > 2 {
//            if data == [0x10,0x10,0x10] {
//                mReceiveDataSize = 0
//                mReceivedData = []
//                delegate?.bleManagerReceive(data: mReceivedData)
//                return
//            }
//        }
//
//        if data.count > 2 {
//            if data[0...2] == [0x06,0x06,0x06] {
//                mReceiveDataSize = 0
//                mReceivedData = []
//                delegate?.bleManagerReceive(data: mReceivedData)
//                return
//            }
//        }
//
//        let MinHeadSize = 4
//        if mReceiveDataSize == 0 && mReceivedData[0] == Command.STX && mReceivedData.count > MinHeadSize  {
//            mReceiveDataSize = Utils.UInt8ArrayToInt(_value: Array(data[1...2])) + MinHeadSize
//        }
//        //펌웨어 업데이트의 특이한 프로토콜 때문에 이 부분을 추가 한다.
//        //2020-06-23 kim.jy
//        if mReceivedData.count > 5 && mReceivedData[0] == Command.STX && mReceivedData[5] == Command.FS {
//            mReceiveDataSize =  getRecvFirmwareDataSize(Size: [UInt8](mReceivedData[1...4])) + 7
//        }
//
//        if mReceivedData.count == mReceiveDataSize && mReceiveDataSize > 0 {
//            delegate?.bleManagerReceive(data: mReceivedData)
//            mReceiveDataSize = 0
//            mReceivedData = []
//        }

        delegate?.bleManagerReceive(data: [UInt8](value))
    }
    
    
    func getRecvFirmwareDataSize(Size size:[UInt8]) -> Int {
        guard let str = String(bytes: size, encoding: .utf8) else {
            return 0
        }
        let total:Int = Int(str) ?? 0
        
        return total
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint(error)
        
        if error != nil {
            var _msg:String = "\(error)"
            if _msg.contains("CBErrorDomain Code=7") {
                delegate?.bleManagerNotification(info: "disconnect device")
                delegate?.bleManagerPairingFail()
                disconnectClear()
                return
            } 
        }
        isConnected = false
        delegate?.bleManagerNotification(info: "disconnect device")
 //       central.scanForPeripherals(withServices: nil, options: nil)
        delegate?.bleManagerDisconnect()
        disconnectClear()
//        if isRequestDisconnect {
//            isRequestDisconnect = false
//            return
//        }
     
    }
    
}
