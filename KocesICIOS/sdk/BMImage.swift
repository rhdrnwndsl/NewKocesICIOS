//
//  BMImage.swift
//  osxapp
//
//  Created by 金載龍 on 2021/03/08.
//

import Foundation
import UIKit
class BMImage: UIImage {
    func getPixel(x _x:Int,y _y:Int) -> UIColor? {
        guard _x >= 0 && _x < Int(size.width) && _y >= 0 && _y < Int(size.height),
        let cgImage = cgImage,
        let provider = cgImage.dataProvider,
        let providerData = provider.data,
        let data = CFDataGetBytePtr(providerData) else {
        return nil
    }
        let numberOfComponents = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        let pixelData = ((Int(size.width) * _y) + _x) * numberOfComponents
        let r = CGFloat(data[pixelData]) / 255.0
        let g = CGFloat(data[pixelData + 1]) / 255.0
        let b = CGFloat(data[pixelData + 2]) / 255.0
        let a = CGFloat(data[pixelData + 3]) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
//    func getPixels() -> [UIColor] {
//        var uiColor:[UIColor] = Array()
//
//        for x1 in 0..<Int(size.width) {
//            for y1 in 0..<Int(size.height){
//                if uiColor.count == 0 {
//                    uiColor.insert(getPixel(x: x1, y: y1)!, at: 0)
//                }
//                else{
//                    uiColor.append(getPixel(x: x1, y: y1)!)
//                }
//            }
//        }
//        return uiColor
//    }
    func getPixels() -> [Int]? {
        var PixelData:[Int] = Array()
        guard let cgImage = cgImage,
        let provider = cgImage.dataProvider,
        let providerData = provider.data,
        let data = CFDataGetBytePtr(providerData) else {
        return nil
    }
        let numberOfComponents = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        
        for y1 in 0..<Int(size.height) {
            for x1 in 0..<Int(size.width){
                let pixelData = ((y1 * Int(size.width)) + x1) * numberOfComponents
                let r = CGFloat(data[pixelData]) / 255.0
                let g = CGFloat(data[pixelData + 1]) / 255.0
                let b = CGFloat(data[pixelData + 2]) / 255.0
                let a = CGFloat(data[pixelData + 3]) / 255.0
                
                if r > 0.75 && g > 0.75  && b > 0.75 {
                    //PixelData.append(0)
                    PixelData.append(1)
                }else{
                    //PixelData.append(1)
                    PixelData.append(0)
                }
                
            }
        }
        return PixelData
    }
    
    
    func getPixelBytes() -> [UInt8] {
        let pixelData:[Int] = getPixels()!
        var DataArray:[UInt8] = Array()
        let bits:Int = 8
        for i in 0 ..< (pixelData.count / bits) {
            let val:Int = pixelData[bits*i] * 128 + pixelData[bits*i+1] * 64 + pixelData[bits*i+2] * 32 + pixelData[bits*i+3] * 16 + pixelData[bits*i+4] * 8 + pixelData[bits*i+5] * 4  + pixelData[bits*i+6] * 2 + pixelData[bits*i+7]
            let temp:UInt8 = UInt8(val)
            DataArray.append(temp)
        }
        
        var Arr:[UInt8] = Array()

        while DataArray.count > 0 {
            Arr.insert(contentsOf: Array(DataArray[0..<16]), at: 0)
            DataArray.removeSubrange(0..<16)
        }
        
        return Arr
    }
    //실제 bitmap은 값이 반대로 들어가 있다. 이건 나중에 서버에서 확인해서 이 함수를 사용할지 말지 결정한다
    func getInvertPixelBytes() -> [UInt8] {
        let pixelData:[Int] = getPixels()!
        var DataArray:[UInt8] = Array()
        let bits:Int = 8
        for i in 0 ..< (pixelData.count / bits) {
            let val:Int = (128 - pixelData[bits*i] * 128) + (64 - pixelData[bits*i+1] * 64) + (32 - pixelData[bits*i+2] * 32) + (16 - pixelData[bits*i+3] * 16) + (8 - pixelData[bits*i+4] * 8 ) + (4 - pixelData[bits*i+5] * 4)  + (2 - pixelData[bits*i+6] * 2) + (1 - pixelData[bits*i+7])
            let temp:UInt8 = UInt8(val)
            DataArray.append(temp)
        }
        return DataArray
    }
    
}
