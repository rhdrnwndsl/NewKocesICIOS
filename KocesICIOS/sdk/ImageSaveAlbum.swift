//
//  SignatureView.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/09.
//

import UIKit


class ImageSaveAlbum: UIView {
    
    //이미지를 포토앨범에 저장한다
    public func saveImageAlbum(Image _image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(_image, self, #selector(imageSaved(_:didFinishSavingWithError:contextType:)), nil)
    }
    
    
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextType: UnsafeRawPointer) {
        let controller = Utils.topMostViewController()
        let _title = "이미지저장"
        var _message = ""

        if error != nil {
            _message = "이미지저장에 실패하였습니다"
        } else {
            _message = "이미지저장에 성공하였습니다"
        }
        
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(btnOk)
        controller?.present(alert, animated: true, completion: nil)
    }

}
