//
//  Products.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/10/25.
//

import UIKit

struct Product: Codable {
    // 기본 상품 정보
    var id: Int = 0
    var tid: String = ""
    var productSeq: String = ""
    var tableNo: String = ""
    var barcode: String = ""
    var pDate: String = ""
    var code: String = ""
    var name: String = ""
    var category: String = ""
    var price: Int = 0
    var totalPrice: String = ""
    var isUse: Int = 1       // 1 = true, 0 = false
    var mCount: Int = 0      // 상품 갯수
    var mDesc: String = ""   // 상품 설명
    var imgUrl: String = ""  // 상품 이미지 URL (WebP 등으로 변환해서 사용할 수 있음)
    var mModify: Bool = false  // 상품 수정모드 여부 (보통 false)
    var imgString: String = "" // Base64 인코딩된 이미지 데이터
    
    // 부가세 관련
    var useVAT: Int = 0
    var autoVAT: Int = 0
    var includeVAT: Int = 0
    var vatRate: Int = 0
    var vatWon: String = ""
    
    // 봉사료 관련
    var useSVC: Int = 0
    var autoSVC: Int = 0
    var includeSVC: Int = 0
    var svcRate: Int = 0
    var svcWon: String = ""
    
    // 이미지 사용 여부
    var isImgUse: Int = 1   // 1 = true, 0 = false

    // 기본 initializer (모든 값에 기본값을 제공)
    init(
        id: Int = 0,
        tid: String = "",
        productSeq: String = "",
        tableNo: String = "",
        barcode: String = "",
        pDate: String = "",
        code: String = "",
        name: String = "",
        category: String = "",
        price: Int = 0,
        totalPrice: String = "",
        isUse: Int = 1,
        mCount: Int = 0,
        mDesc: String = "",
        imgUrl: String = "",
        imgString: String = "",
        useVAT: Int = 0,
        autoVAT: Int = 0,
        includeVAT: Int = 0,
        vatRate: Int = 0,
        vatWon: String = "",
        useSVC: Int = 0,
        autoSVC: Int = 0,
        includeSVC: Int = 0,
        svcRate: Int = 0,
        svcWon: String = "",
        isImgUse: Int = 1
    ) {
        self.id = id
        self.tid = tid
        self.productSeq = productSeq
        self.tableNo = tableNo
        self.barcode = barcode
        self.pDate = pDate
        self.code = code
        self.name = name
        self.category = category
        self.price = price
        self.totalPrice = totalPrice
        self.isUse = isUse
        self.mCount = mCount
        self.mDesc = mDesc
        self.imgUrl = imgUrl
        self.imgString = imgString
        self.useVAT = useVAT
        self.autoVAT = autoVAT
        self.includeVAT = includeVAT
        self.vatRate = vatRate
        self.vatWon = vatWon
        self.useSVC = useSVC
        self.autoSVC = autoSVC
        self.includeSVC = includeSVC
        self.svcRate = svcRate
        self.svcWon = svcWon
        self.isImgUse = isImgUse
    }
    
    // setAll 메서드: 모든 값들을 한 번에 설정 (Android의 setAll 메서드와 유사)
    mutating func setAll(
        id: Int,
        tid: String,
        productSeq: String,
        tableNo: String,
        code: String,
        name: String,
        category: String,
        price: Int,
        pDate: String,
        barcode: String,
        isUse: Int,
        imgUrl: String,
        desc: String,
        imgString: String,
        useVAT: Int,
        autoVAT: Int,
        includeVAT: Int,
        vatRate: Int,
        vatWon: String,
        useSVC: Int,
        autoSVC: Int,
        includeSVC: Int,
        svcRate: Int,
        svcWon: String,
        totalPrice: String,
        count: Int,
        isImgUse: Int
    ) {
        self.id = id
        self.tid = tid
        self.productSeq = productSeq
        self.tableNo = tableNo
        self.code = code
        self.name = name
        self.category = category
        self.price = price
        self.totalPrice = totalPrice
        self.pDate = pDate
        self.barcode = barcode
        self.isUse = isUse
        self.imgUrl = imgUrl
        self.mDesc = desc
        self.imgString = imgString
        self.useVAT = useVAT
        self.autoVAT = autoVAT
        self.includeVAT = includeVAT
        self.vatRate = vatRate
        self.vatWon = vatWon
        self.useSVC = useSVC
        self.autoSVC = autoSVC
        self.includeSVC = includeSVC
        self.svcRate = svcRate
        self.svcWon = svcWon
        self.mCount = count
        self.isImgUse = isImgUse
    }
    
    // computed property: imgUrl를 URL?로 반환
    var imageURL: URL? {
        return URL(string: imgUrl)
    }
    
    // computed property: Base64로 인코딩된 imgString을 UIImage로 변환하여 반환
    var image: UIImage? {
        guard !imgString.isEmpty, let data = Data(base64Encoded: imgString, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: data)
    }
}
