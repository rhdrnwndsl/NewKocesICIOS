//
//  LogFile.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/06/05.
//

import Foundation

/**
  - //앱투앱or웹투앱or본앱 내용인지를 첫줄에 명시
  - //앱투앱or웹투앱 일 경우 처음에 받은데이터를 명시 본앱일 경우 없음
  - //앱 -> 단말기 데이터 명시
  - //단말기 -> 앱 데이터 명시
  - //앱 -> 서버 데이터 명시
  - //서버 -> 앱 데이터 명시
  - 마지막 화면에 표시되는 데이터를 명시(본앱), 웹투앱or앱투앱은 다시 보내는 데이터를 명시
 */
class LogFile {
    static let instance:LogFile = LogFile()
    
    public func InsertLog(_ message: String, Tid _tid:String, TimeStamp _timeStamp:Bool = false) {
        let documentsDirectory = getDocumentsDirectory()
        let formatt = DateFormatter()
        formatt.locale = Locale(identifier: "en_US_POSIX")
        formatt.dateFormat = "yyyyMMdd"
        let dateString = formatt.string(from: Date())
        let fileName = "\(dateString)" + "_" + _tid + ".log"
        let logm = documentsDirectory.appendingPathComponent(fileName)

        let formatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        
        
        guard let data = _timeStamp == true ? ("[" + timestamp + "] " + message + "\n").data(using: String.Encoding.utf8):(message + "\n").data(using: String.Encoding.utf8) else { return }

        if FileManager.default.fileExists(atPath: logm.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logm) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: logm, options: .atomicWrite)
        }
    }
    
    public func LoadFileData(Title _title:String) -> Data {
        let fileName = _title
        let path = getDocumentsDirectory().appendingPathComponent(fileName)
        if let fileData = try? Data(contentsOf: path) {
            return fileData
        } else {
            return Data()
        }
        
    }
    
    func meetsRequirement(date: Int, minimumDate:Int) -> Bool { return date < minimumDate }
    
    public func DeleteLog() {
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first! as NSURL
        let documentsPath = documentsUrl.path
        let maximumDays = 30.0
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let minimumString = formatter.string(from: Date().addingTimeInterval(-maximumDays*24*60*60))
        
        let minimumDate:Int = Int(minimumString)!
       
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    let filePathName = "\(documentPath)/\(fileName)"
                    let dateString = formatter.string(from: ((try? FileManager.default.attributesOfItem(atPath: filePathName))?[.creationDate] as? Date)!)
                    let date:Int = Int(dateString)!
                    if meetsRequirement(date: date, minimumDate: minimumDate) && fileName.contains("txt") {
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }

            }

        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    /** 사용안함 */
    public func LoadLog() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let fileName = "LOG_\(dateString).log"
        let path = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let todos = try String(contentsOf: path)
            return todos
        } catch {
            print(error.localizedDescription)
            return error.localizedDescription
        }
    }
}
