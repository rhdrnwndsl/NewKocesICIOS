//
//  sqlite.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/27.
//

import Foundation
import SQLite3
/// 예시 구조체 (Java의 DBProductInfoResult 대응)
struct DBProductInfoResult {
    let id: Int
    let tid: String
    let productSeq: String
    let tableNo: String
    let code: String
    let name: String
    let category: String
    let price: String
    let date: String
    let barcode: String
    let isUse: Int
    let imgUrl: String
    let imgString: String
    let vatUse: Int
    let vatMode: Int
    let vatInclude: Int
    let vatRate: Int
    let vatWon: String
    let svcUse: Int
    let svcMode: Int
    let svcInclude: Int
    let svcRate: Int
    let svcWon: String
    let totalPrice: String
    let isImgUse: Int
}
struct DBProductTradeResult {
    let id: Int
    let productNum: String
    let tid: String
    let storeName: String
    let storeAddr: String
    let storeNumber: String
    let storePhone: String
    let storeOwner: String
    let trade: String
    let code: String
    let name: String
    let category: String
    let price: String
    let count: String
    let isCombine: String
    let isCancel: String
    let auDate: String
    let oriAuDateTime: String
}
struct DBVerityResult {
    var date:String = ""
    var mode:String = ""
    var result:String = ""
    func getDate()-> String { return date }
    func getMode()-> String { return  mode }
    func getResult()-> String { return result }
}

struct DBTradeResult {
    var id:Int = 0
    //본앱에서도 가맹점등록다운로드를 다른 tid 로 하면서 결제를 요청하고 취소한다. 만일 취소한다고 하면 저장된 tid 로 취소를 요청한다
    var Tid:String = "" //거래 할 때의 TID
    var StoreName:String = ""
    var StoreAddr:String = ""
    var StoreNumber:String = ""
    var StorePhone:String = ""
    var StoreOwner:String = ""
    
    var Trade:String = ""
    var Cancel:String = ""
    var Money:String = ""   //거래금액
    var GiftAmt:String = ""     //기프트카드 잔액
    var Tax:String = "" //세금
    var Svc:String = "" //봉사료
    var Txf:String = ""  //비과세
    var Inst:String = ""    //할부
    var CashTarget:String = ""
    var CashInputMethod:String = ""
    var CashNum:String = ""     //현금영수증 발행 번호
    var CardNum:String = ""
    var CardType:String = ""    //카드종류
    var CardInpNm:String = ""    //매입사명
    var CardIssuer:String = ""  //발급사명
    var MchNo:String = ""   //가맹점번호
    var AuDate:String = ""  //승인날짜
    var OriAuDate:String = ""   //원승인날짜(취소전표에 출력내용에 표시)
    var AuNum:String = ""   //승인번호
    var OriAuNum:String = ""   //원승인번호(취소 시 거래내역 업데이트 에서 필요)
    var TradeNo:String = ""
    var Message:String = "" //거래 응답메시지
    
    /** 여기서부터 간편결제용 추가 내용 */
    //카카오페이추가내용
    var KakaoMessage:String = ""    //알림메세지
    var PayType:String = "" //결제수단
    var KakaoAuMoney:String = ""    //승인금액(카카오머니 승인 응답 시(승인금액 = 거래금액 - 카카오할인금액))
    var KakaoSaleMoney:String = ""  //카카오페이할인금액
    var KakaoMemberCd:String = ""   //카카오 멤버십바코드
    var KakaoMemberNo:String = ""   //카카오 멤버십 번호
    var Otc:String = "" //카드번호정보(OTC) - 결제수단 카드 시
    var Pem:String = "" //PEM - 결제수단 카드 시
    var Trid:String = ""    //trid - 결제수단 카드 시
    var CardBin:String = ""    //카드Bin - 결제수단 카드 시
    var SearchNo:String = ""    //조회고유번호
    var PrintBarcd:String = ""    //출력용 바코드 번호(전표 출력시 사용될 바코드 번호)
    var PrintUse:String = ""    //전표출력여부
    var PrintNm:String = ""    //전표구분명
    //제로페이추가내용
    var MchFee:String = ""  //제로페이 가맹점수수료
    var MchRefund:String = ""   //제로페이 가맹점 환불금액
    //페이코추가내용
    var PcKind:String = ""
    var PcCoupon:String = ""
    var PcPoint:String = ""
    var PcCard:String = ""
    
    //해당거래가 내가 승인했던 거래인지 아닌지를 체크(취소시 데이터를 제거하니까 이 취소거래가 기존에 내가 거래했던 내용인지를 체크한다 1:내가했던거래 2:기존에 없던 취소거래
    var MineTrade:String = ""
    
    //상품거래 포인트거래 멤버십거래 및 영수증에 사용할 데이터추가
    var ProductNum:String = ""
    var OriAuDateTime:String = ""
    var DDCYn:String = ""
    var EDCYn:String = ""
    var ICInputType:String = ""
    var EMVTradeType:String = ""
    var PtPointCode:String = ""
    var PtServiceName:String = ""
    var PtEarnPoint:String = ""
    var PtUsePoint:String = ""
    var PtTotalPoint:String = ""
    var PtPercent:String = ""
    var PtUserName:String = ""
    var PtPointStoreNumber:String = ""
    var MemberCardType:String = ""
    var MemberServiceType:String = ""
    var MemberServiceName:String = ""
    var MemberTradeMoney:String = ""
    var MemberSaleMoney:String = ""
    var MemberAfterTradeMoney:String = ""
    var MemberAfterMemberPoint:String = ""
    var MemberOptionCode:String = ""
    var MemberStoreNo:String = ""

    
    func getid() ->Int {return id }
    //본앱에서도 가맹점등록다운로드를 다른 tid 로 하면서 결제를 요청하고 취소한다. 만일 취소한다고 하면 저장된 tid 로 취소를 요청한다
    func getTid() -> String { return Tid } //거래 할 때의 TID
    func getStoreName() -> String { return StoreName }
    func getStoreAddr() -> String { return StoreAddr }
    func getStoreNumber() -> String { return StoreNumber }
    func getStoreOwner() -> String { return StoreOwner }
    func getStorePhone() -> String { return StorePhone }
    
    func getTrade() ->String { return Trade }
    func getCancel() ->String { return Cancel }
    func getMoney() ->String { return Money }
    func getGiftAmt() ->String { return GiftAmt }   //기프트카드 잔액
    func getTax() ->String { return Tax }
    func getSvc() ->String { return Svc }
    func getTxf() ->String { return Txf }
    func getInst() ->String { return Inst }
    func getCashTarget() -> String { return CashTarget }
    func getCashMethod() -> String { return CashInputMethod }
    func getCashNum() -> String { return CashNum }
    func getCardNum() ->String { return CardNum }
    func getCardType() ->String { return CardType }
    func getCardInpNm() -> String { return CardInpNm }
    func getCardIssuer() ->String { return CardIssuer }
    func getMchNo() ->String {return MchNo }
    func getAuDate() ->String { return AuDate }
    func getOriAuDate() -> String {return OriAuDate }
    func getAuNum() ->String { return AuNum }
    func getOriAuNum() -> String {return OriAuNum }
    func getTradeNo() ->String { return TradeNo }
    func getMessage() ->String {return Message }
    
    /** 여기서부터 간편결제용 추가 내용 */
    //카카오페이추가내용
    func getKakaoMessage() ->String { return KakaoMessage }
    func getPayType() ->String { return PayType }
    func getKakaoAuMoney() -> String { return KakaoAuMoney }
    func getKakaoSaleMoney() -> String { return KakaoSaleMoney }
    func getKakaoMemberCd() -> String { return KakaoMemberCd }
    func getKakaoMemberNo() ->String { return KakaoMemberNo }
    func getOtc() ->String { return Otc }
    func getPem() -> String { return Pem }
    func getTrid() ->String { return Trid }
    func getCardBin() ->String {return CardBin }
    func getSearchNo() ->String { return SearchNo }
    func getPrintBarcd() -> String {return PrintBarcd }
    func getPrintUse() ->String { return PrintUse }
    func getPrintNm() ->String { return PrintNm }
    //제로페이추가내용
    func getMchFee() ->String { return MchFee }
    func getMchRefund() ->String { return MchRefund }
    //페이코추가내용
    func getPcKind() ->String {return PcKind}
    func getPcCoupon() ->String {return PcCoupon}
    func getPcPoint() ->String {return PcPoint}
    func getPcCard() ->String {return PcCard}
    
    func getMineTrade() -> String {return MineTrade}
    
    //상품거래 포인트거래 멤버십거래 및 영수증에 사용할 데이터추가
    func getProductNum() -> String {return ProductNum}
    func getOriAuDateTime() -> String {return OriAuDateTime}
    func getDDCYn() -> String {return DDCYn}
    func getEDCYn() ->String {return EDCYn }
    func getICInputType() ->String {return ICInputType }
    func getEMVTradeType() ->String {return EMVTradeType }
    func getPtPointCode() ->String {return PtPointCode }
    func getPtServiceName() ->String {return PtServiceName }
    func getPtEarnPoint() ->String {return PtEarnPoint }
    func getPtUsePoint() ->String {return PtUsePoint }
    func getPtTotalPoint() ->String {return PtTotalPoint }
    func getPtPercent() ->String {return PtPercent }
    func getPtUserName() ->String {return PtUserName }
    func getPtPointStoreNumber() ->String {return PtPointStoreNumber }
    func getMemberCardType() ->String {return MemberCardType }
    func getMemberServiceType() ->String {return MemberServiceType }
    func getMemberServiceName() ->String {return MemberServiceName }
    func getMemberTradeMoney() ->String {return MemberTradeMoney }
    func getMemberSaleMoney() ->String {return MemberSaleMoney }
    func getMemberAfterTradeMoney() ->String {return MemberAfterTradeMoney }
    func getMemberAfterMemberPoint() ->String {return MemberAfterMemberPoint }
    func getMemberOptionCode() ->String {return MemberOptionCode }
    func getMemberStoreNo() ->String {return MemberStoreNo }

}

class sqlite {
    static let instance = sqlite()
    private var db_point: OpaquePointer? = nil
    /// DB 보전할 최대 개수 (무결성 검사 테이블 등)
    let VerityTableMaxCount = 10
    /// 현재 DB 버전
    let DB_VERSION = "5"
    
    // MARK: - 초기화 (DB 오픈 + 테이블 생성)
    
    /// 생성자 (앱 구동 시점에 1회 실행)
    init(){
        // 1) DB 파일 경로 준비
        let fileURL = try! FileManager.default.url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
            .appendingPathComponent("koces.db")
        
        debugPrint("SQLite DB 경로:", fileURL.path)
        
        // 2) sqlite3_open
        if sqlite3_open(fileURL.path, &db_point) == SQLITE_OK {
            debugPrint("DB 연결 성공. 포인터 주소:", db_point as Any)
        } else {
            debugPrint("DB 연결 실패")
        }

        // 3) 테이블 생성 (DDL)
        //    아래는 필요한 모든 테이블을 간단히 생성하는 구문들입니다.
        //    - 각각의 구문에 별도 파라미터 바인딩이 필요한 값이 없습니다.
        createTable_Verity()
        createTable_Store()
        createTable_Trade()
        createTable_AppToApp()
        createTable_ProductInfo()
        createTable_ProductDetail()
 
    }
    
    /// 소멸자 (인스턴스 해제 시점)
    deinit {
        sqlite3_close(db_point)
    }
    
    // MARK: - 테이블 생성 함수들 (DDL)
        
    /// 무결성 결과 테이블 생성
    private func createTable_Verity() -> Bool {
        let createQuery = """
            CREATE TABLE IF NOT EXISTS \(define.DB_Verity) (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                mode TEXT,
                result TEXT
            );
        """
        return execDDL(createQuery, errorContext: "무결성 결과 테이블 생성")
    }
    
    /// 가맹점 테이블 생성
    private func createTable_Store() -> Bool {
        let createQuery = """
            CREATE TABLE IF NOT EXISTS \(define.DB_Store) (
                AsNum TEXT,
                ShpNm TEXT,
                Tid TEXT,
                BsnNo TEXT,
                PreNm TEXT,
                ShpAdr TEXT,
                ShpTel TEXT,
                PointCount TEXT,
                PointInfo TEXT,
                MchData TEXT
            );
        """
        return execDDL(createQuery, errorContext: "상점 테이블 생성")
    }
    
    /// 일반 거래 테이블 생성
    private func createTable_Trade() -> Bool {
        let createQuery = """
            CREATE TABLE IF NOT EXISTS \(define.DB_Trade) (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                Tid TEXT,
                StoreName TEXT,
                StoreAddr TEXT,
                StoreNumber TEXT,
                StorePhone TEXT,
                StoreOwner TEXT,
                Trade TEXT,
                Cancel TEXT,
                Money TEXT,
                GiftAmt TEXT,
                Tax TEXT,
                Svc TEXT,
                Txf TEXT,
                Inst TEXT,
                CashTarget TEXT,
                CashInputType TEXT,
                CashNum TEXT,
                CardNum TEXT,
                CardType TEXT,
                CardInpNm TEXT,
                CardIssuer TEXT,
                MchNo TEXT,
                AuDate TEXT,
                OriAuData TEXT,
                AuNum TEXT,
                OriAuNum TEXT,
                TradeNo TEXT,
                Message TEXT,
                KakaoMessage TEXT,
                PayType TEXT,
                KakaoAuMoney TEXT,
                KakaoSaleMoney TEXT,
                KakaoMemberCd TEXT,
                KakaoMemberNo TEXT,
                Otc TEXT,
                Pem TEXT,
                Trid TEXT,
                CardBin TEXT,
                SearchNo TEXT,
                PrintBarcd TEXT,
                PrintUse TEXT,
                PrintNm TEXT,
                MchFee TEXT,
                MchRefund TEXT,
                PcKind TEXT,
                PcCoupon TEXT,
                PcPoint TEXT,
                PcCard TEXT,
                MineTrade TEXT,
                ProductNum TEXT,
                OriAuDateTime TEXT,
                DDCYn TEXT,
                EDCYn TEXT,
                ICInputType TEXT,
                EMVTradeType TEXT,
                PtPointCode TEXT,
                PtServiceName TEXT,
                PtEarnPoint TEXT,
                PtUsePoint TEXT,
                PtTotalPoint TEXT,
                PtPercent TEXT,
                PtUserName TEXT,
                PtPointStoreNumber TEXT,
                MemberCardType TEXT,
                MemberServiceType TEXT,
                MemberServiceName TEXT,
                MemberTradeMoney TEXT,
                MemberSaleMoney TEXT,
                MemberAfterTradeMoney TEXT,
                MemberAfterMemberPoint TEXT,
                MemberOptionCode TEXT,
                MemberStoreNo TEXT
            );
        """
        return execDDL(createQuery, errorContext: "일반 거래 테이블 생성")
    }
    
    /// 앱투앱 거래 테이블 생성
    private func createTable_AppToApp() -> Bool {
        let createQuery = """
            CREATE TABLE IF NOT EXISTS \(define.DB_AppToApp) (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                TrdType TEXT,
                TermID TEXT,
                TrdDate TEXT,
                AnsCode TEXT,
                Message TEXT,
                AuNo TEXT,
                TradeNo TEXT,
                CardNo TEXT,
                Keydate TEXT,
                MchData TEXT,
                CardKind TEXT,
                OrdCd TEXT,
                OrdNm TEXT,
                InpCd TEXT,
                InpNm TEXT,
                DDCYn TEXT,
                EDCYn TEXT,
                GiftAmt TEXT,
                MchNo TEXT,
                BillNo TEXT,
                DisAmt TEXT,
                AuthType TEXT,
                AnswerTrdNo TEXT,
                ChargeAmt TEXT,
                RefundAmt TEXT,
                QrKind TEXT,
                OriAuDate TEXT,
                OriAuNo TEXT,
                TrdAmt TEXT,
                TaxAmt TEXT,
                SvcAmt TEXT,
                TaxFreeAmt TEXT,
                Month TEXT,
                PcKind TEXT,
                PcCoupon TEXT,
                PcPoint TEXT,
                PcCard TEXT,
                MineTrade TEXT,
                ProductNum TEXT,
                OriAuDateTime TEXT,
                PtPointCode TEXT,
                PtServiceName TEXT,
                PtEarnPoint TEXT,
                PtUsePoint TEXT,
                PtTotalPoint TEXT,
                PtPercent TEXT,
                PtUserName TEXT,
                PtPointStoreNumber TEXT,
                MemberCardType TEXT,
                MemberServiceType TEXT,
                MemberServiceName TEXT,
                MemberTradeMoney TEXT,
                MemberSaleMoney TEXT,
                MemberAfterTradeMoney TEXT,
                MemberAfterMemberPoint TEXT,
                MemberOptionCode TEXT,
                MemberStoreNo TEXT
            );
        """
        return execDDL(createQuery, errorContext: "앱투앱 거래 테이블 생성")
    }
    
    //상품거래 시 디테일 내용 테이블 생성
    private func createTable_ProductDetail() -> Bool {
        let createQuery = """
        CREATE TABLE IF NOT EXISTS \(define.DB_ProductTradeDetailTable) (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ProductNum TEXT,
            Tid TEXT,
            StoreName TEXT,
            StoreAddr TEXT,
            StoreNumber TEXT,
            StorePhone TEXT,
            StoreOwner TEXT,
            Trade TEXT,
            Code TEXT,
            Name TEXT,
            Category TEXT,
            Price TEXT,
            Count TEXT,
            isCombine TEXT,
            isCancel TEXT,
            AuDate TEXT,
            OriAuDateTime TEXT
        );
        """
        return execDDL(createQuery, errorContext: "상품 거래 디테일 테이블 생성")
    }
    
    //상품정보 등록 테이블 생성
    private func createTable_ProductInfo() -> Bool {
        let createQuery = """
         CREATE TABLE IF NOT EXISTS \(define.DB_ProductTable) (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             Tid TEXT,
             ProductSeq TEXT,
             TableNo TEXT,
             Code TEXT,
             Name TEXT,
             Category TEXT,
             Price TEXT,
             Date TEXT,
             Barcode TEXT,
             IsUse TEXT,
             ImgUrl TEXT,
             ImgString TEXT,
             VATUSE INTEGER,
             VATAUTO VARCHAR(1),
             VATINCLUDE VARCHAR(1),
             VATRATE VARCHAR(3),
             VATWON TEXT,
             SVCUSE INTEGER,
             SVCAUTO VARCHAR(1),
             SVCINCLUDE VARCHAR(1),
             SVCRATE VARCHAR(3),
             SVCWON TEXT,
             TotalPrice TEXT,
             IsImgUse TEXT
         );
         """
        return execDDL(createQuery, errorContext: "상품정보 등록 테이블 생성")
    }
    
 
    
    // MARK: - DB 업데이트 (onUpgrade)
        
    /// 앱 구동 후 DB Version 체크하여, 테이블 컬럼 추가 등 마이그레이션 수행
    func DBUpdate() {
        // 설정에 저장된 버전을 읽어와서 현재 DB_VERSION("5")과 다르면 onUpgrade 수행
        if Setting.shared.getDefaultUserData(_key: "DB_VERSION") != DB_VERSION {
            do {
                try onUpgrade(dbname: "Trade2", dbname2: "Apptoapp")
            } catch {
                debugPrint("DB 업그레이드 실패: \(error)")
            }
        }
        
        // 업그레이드 수행 후, 현재 버전으로 갱신
        Setting.shared.setDefaultUserData(_data: DB_VERSION, _key: "DB_VERSION")
    }
    
    /// 거래내역에 컬럼 추가 필요 시 DB 업그레이드 수행
    /// - Parameters:
    ///   - db: 첫 번째 테이블 이름
    ///   - db2: 두 번째 테이블 이름
    /// - Returns: 작업 결과(0: 정상)
    func onUpgrade(dbname db: String, dbname2 db2: String) throws -> Int {
        // 기존 버전 vs 새 버전 비교
        let versionName = Setting.shared.getDefaultUserData(_key: "DB_VERSION")
        let vNS = Int(DB_VERSION) ?? 5     // 새 버전
        let vN  = (versionName == "") ? 0 : (Int(versionName) ?? 0) // 기존 버전
        
        // 마이그레이션 대상 컬럼들
        let columns = [
            "PcKind", "PcCoupon", "PcPoint", "PcCard", "MineTrade", "ProductNum",
            "OriAuDateTime", "isCancel", "DDCYn", "EDCYn", "ICInputType",
            "EMVTradeType", "IsImgUse", "AuDate", "PtPointCode", "PtServiceName",
            "PtEarnPoint", "PtUsePoint", "PtTotalPoint", "PtPercent", "PtUserName",
            "PtPointStoreNumber", "MemberCardType", "MemberServiceType", "MemberServiceName",
            "MemberTradeMoney", "MemberSaleMoney", "MemberAfterTradeMoney",
            "MemberAfterMemberPoint", "MemberOptionCode", "MemberStoreNo"
        ]
        
        // vN < vNS 인 경우만 업그레이드 진행
        if vN < vNS {
            [db, db2].forEach { database in
                columns.forEach { columnName in
                    addColumn(to: database, columnName: columnName)
                }
            }
        }
        return 0
    }
    
    /// 특정 테이블에 컬럼 추가
    /// - Parameters:
    ///   - database: 컬럼 추가 대상 테이블명
    ///   - columnName: 새로 추가할 컬럼명
    func addColumn(to database: String, columnName: String) {
        // 테이블명 / 컬럼명 자체는 바인딩으로 처리할 수 없으므로 문자열로 직접 작성
        let sql = "ALTER TABLE \(database) ADD COLUMN \(columnName) TEXT DEFAULT ''"
        
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        // prepare
        if sqlite3_prepare_v2(db_point, sql, -1, &statement, nil) == SQLITE_OK {
            // step
            if sqlite3_step(statement) == SQLITE_DONE {
                debugPrint("Field \(columnName) added to \(database)")
            } else {
                debugPrint("Failed to add field \(columnName) to \(database)")
            }
        } else {
            debugPrint("Failed to prepare statement for \(columnName) on \(database)")
        }
    }
    
    // MARK: - 공용 DDL 실행 함수 (exec)
    
    /// DDL 계열 쿼리 실행 전용 함수
    /// - Parameters:
    ///   - sql: 실행할 쿼리문 (예: CREATE TABLE, DROP TABLE, ALTER TABLE 등)
    ///   - errorContext: 디버그 로깅을 위해, 어떤 작업인지 표시
    private func execDDL(_ sql: String, errorContext: String) -> Bool {
        let result = sqlite3_exec(db_point, sql, nil, nil, nil)
        if result != SQLITE_OK {
            // errmsg 포인터 -> Swift String
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            debugPrint("\(errorContext) 실패: \(errMsg)")
            return false
        } else {
            debugPrint("\(errorContext) 성공")
            return true
        }
    }
    
    /// 문자열 컬럼 추출 헬퍼
    private func stringColumn(_ statement: OpaquePointer, _ index: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: cString)
    }
    
    // MARK: - 테이블 제거 후 재생성
    func dropAndCreateTable(TableName table :String) -> Bool {
        var result = false
        
        // 1) DROP
        let dropQuery = "DROP TABLE IF EXISTS \(table)"
        if sqlite3_exec(db_point, dropQuery, nil, nil, nil) == SQLITE_OK {
            result = true
        } else {
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            print("dropAndCreateProductTradeTable - DROP 실패: \(errMsg)")
            result = false
        }
        
        // 2) CREATE
        if result {
            switch(table) {
            case define.DB_Trade:
                result = createTable_Trade()
                break
            case define.DB_AppToApp:
                result = createTable_AppToApp()
                break
            case define.DB_ProductTradeDetailTable:
                result = createTable_ProductDetail()
                break
            case define.DB_ProductTable:
                result = createTable_ProductInfo()
                break
            default:
                break
            }
        }
        
        return result
    }
    
    // MARK: - 상품정보 등록 / 수정 / 일괄정보 가져오기
    func getProductCount() -> Int {
        let countQuery = "SELECT count(*) FROM \(define.DB_ProductTable);"
        var queryStatement: OpaquePointer? = nil
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        // prepare
        guard sqlite3_prepare_v2(db_point, countQuery, -1, &queryStatement, nil) == SQLITE_OK else {
            debugPrint("SELECT count(*) 준비 실패")
            return 0
        }
        
        // step
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            debugPrint("카운트 조회 실패")
            return 0
        }
        
        let rowCount = Int(sqlite3_column_int(queryStatement, 0))
        return rowCount
    }
    
    func getCategoryList() -> [String] {
        var categories: [String] = []
        // Category 값만 추출하며 중복 없이 가져오기 위해 DISTINCT 사용
        let query = "SELECT DISTINCT Category FROM \(define.DB_ProductTable);"
        
        var statement: OpaquePointer? = nil
        // prepare 단계
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            if let errorPointer = sqlite3_errmsg(db_point) {
                let errorMessage = String(cString: errorPointer)
                print("getCategoryList - prepare 실패: \(errorMessage)")
            }
            return categories
        }
        
        // step 단계: 각 행마다 Category 컬럼의 값을 가져옴
        while sqlite3_step(statement) == SQLITE_ROW {
            if let cString = sqlite3_column_text(statement, 0) {
                let category = String(cString: cString)
                categories.append(category)
            }
        }
        
        sqlite3_finalize(statement)
        return categories
    }
    
    
    /// 상품 정보를 INSERT (새로운 레코드 추가)
    /// - Returns: 성공 시 true, 실패 시 false
    func insertProductInfo(
        tid: String,
        productSeq: String,
        tableNo: Int,
        pcode: String,
        pname: String,
        pcategory: String,
        price: String,
        pdate: String,
        barcode: String,
        isUse: Int,
        imgUrl: String,
        imgBitmapString: String,
        useVAT: Int, autoVAT: Int, includeVAT: Int, vatRate: Int, vatWon: String,
        useSVC: Int, autoSVC: Int, includeSVC: Int, svcRate: Int, svcWon: String,
        totalPrice: String,
        isImgUse: Int
    ) -> Bool {
        // 1) 쿼리
        let insertQuery = """
            INSERT INTO \(define.DB_ProductTable)
            (Tid, ProductSeq, TableNo, Code, Name, Category, Price, Date,
             Barcode, IsUse, ImgUrl, ImgString,
             VATUSE, VATAUTO, VATINCLUDE, VATRATE, VATWON,
             SVCUSE, SVCAUTO, SVCINCLUDE, SVCRATE, SVCWON,
             TotalPrice, IsImgUse)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        // 2) prepare
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db_point, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            print("insertProductInfo - prepare 실패: \(errMsg)")
            return false
        }
        
        // 3) bind
        //    순서대로 Tid, ProductSeq, TableNo, Code, Name, ...
        //    Int32(index+1) 형태로 position 결정
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, 1, tid, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, productSeq, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 3, Int32(tableNo))
        sqlite3_bind_text(statement, 4, pcode, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 5, pname, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 6, pcategory, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 7, price, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 8, pdate, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 9, barcode, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 10, Int32(isUse))
        sqlite3_bind_text(statement, 11, imgUrl, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 12, imgBitmapString, -1, SQLITE_TRANSIENT)
        
        sqlite3_bind_int(statement, 13, Int32(useVAT))
        sqlite3_bind_int(statement, 14, Int32(autoVAT))
        sqlite3_bind_int(statement, 15, Int32(includeVAT))
        sqlite3_bind_int(statement, 16, Int32(vatRate))
        sqlite3_bind_text(statement, 17, vatWon, -1, SQLITE_TRANSIENT)
        
        sqlite3_bind_int(statement, 18, Int32(useSVC))
        sqlite3_bind_int(statement, 19, Int32(autoSVC))
        sqlite3_bind_int(statement, 20, Int32(includeSVC))
        sqlite3_bind_int(statement, 21, Int32(svcRate))
        sqlite3_bind_text(statement, 22, svcWon, -1, SQLITE_TRANSIENT)
        
        sqlite3_bind_text(statement, 23, totalPrice, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 24, Int32(isImgUse))
        
        // 4) step
        if sqlite3_step(statement) == SQLITE_DONE {
            print("insertProductInfo - INSERT 성공")
            return true
        } else {
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            print("insertProductInfo - INSERT 실패: \(errMsg)")
            return false
        }
    }
    
    /// 상품 정보 UPDATE
    /// - Returns: 성공 시 true, 실패 시 false
    func updateProductInfo(
        tid: String,
        productSeq: String,
        tableNo: Int,
        pname: String,
        pcategory: String,
        price: String,
        pdate: String,
        barcode: String,
        isUse: Int,
        imgUrl: String,
        imgBitmapString: String,
        useVAT: Int, autoVAT: Int, includeVAT: Int, vatRate: Int, vatWon: String,
        useSVC: Int, autoSVC: Int, includeSVC: Int, svcRate: Int, svcWon: String,
        totalPrice: String,
        isImgUse: Int
    ) -> Bool {
        // 1) 쿼리
        //    WHERE ProductSeq=? AND Tid=?
        //    -> bind 순서 맨 뒤에 productSeq, tid
        let updateQuery = """
            UPDATE \(define.DB_ProductTable)
            SET
                TableNo=?,
                Name=?,
                Category=?,
                Price=?,
                Date=?,
                Barcode=?,
                IsUse=?,
                ImgUrl=?,
                ImgString=?,
                VATUSE=?,
                VATAUTO=?,
                VATINCLUDE=?,
                VATRATE=?,
                VATWON=?,
                SVCUSE=?,
                SVCAUTO=?,
                SVCINCLUDE=?,
                SVCRATE=?,
                SVCWON=?,
                TotalPrice=?,
                IsImgUse=?
            WHERE ProductSeq=?
              AND Tid=?;
        """
        
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db_point, updateQuery, -1, &statement, nil) == SQLITE_OK else {
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            print("updateProductInfo - prepare 실패: \(errMsg)")
            return false
        }
        
        // bind
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_int(statement, 1, Int32(tableNo))
        sqlite3_bind_text(statement, 2, pname, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 3, pcategory, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 4, price, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 5, pdate, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 6, barcode, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 7, Int32(isUse))
        sqlite3_bind_text(statement, 8, imgUrl, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 9, imgBitmapString, -1, SQLITE_TRANSIENT)
        
        sqlite3_bind_int(statement, 10, Int32(useVAT))
        sqlite3_bind_int(statement, 11, Int32(autoVAT))
        sqlite3_bind_int(statement, 12, Int32(includeVAT))
        sqlite3_bind_int(statement, 13, Int32(vatRate))
        sqlite3_bind_text(statement, 14, vatWon, -1, SQLITE_TRANSIENT)
        
        sqlite3_bind_int(statement, 15, Int32(useSVC))
        sqlite3_bind_int(statement, 16, Int32(autoSVC))
        sqlite3_bind_int(statement, 17, Int32(includeSVC))
        sqlite3_bind_int(statement, 18, Int32(svcRate))
        sqlite3_bind_text(statement, 19, svcWon, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 20, totalPrice, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 21, Int32(isImgUse))
        
        // WHERE ProductSeq=?, Tid=?
        sqlite3_bind_text(statement, 22, productSeq, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 23, tid, -1, SQLITE_TRANSIENT)
        
        // step
        if sqlite3_step(statement) == SQLITE_DONE {
            print("updateProductInfo - UPDATE 성공")
            return true
        } else {
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            print("updateProductInfo - UPDATE 실패: \(errMsg)")
            return false
        }
    }
    
    /// 전체 상품 리스트 혹은 특정 productSeq 에 해당하는 상품 리스트를 가져온다
    /// - Parameter pSeq: "" 이면 전체, 아니면 해당 pSeq만
    /// - Returns: [DBProductInfoResult]
    func getProductInfoAllList(pSeq: String) -> [DBProductInfoResult]? {
        var result = [DBProductInfoResult]()
        
        // 1) 쿼리 구성
        let selectAll = "SELECT * FROM \(define.DB_ProductTable) ORDER BY id ASC;"
        let selectBySeq = "SELECT * FROM \(define.DB_ProductTable) WHERE ProductSeq=?;"
        
        // 실제 사용할 쿼리와 바인딩할 값
        var query = ""
        var bindValues: [String] = []
        
        if pSeq.isEmpty {
            query = selectAll
        } else {
            query = selectBySeq
            bindValues = [pSeq]
        }
        
        // prepare
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            print("getProductInfoAllList - prepare 실패")
            return nil
        }
        
        // bind
        if !pSeq.isEmpty {
            sqlite3_bind_text(statement, 1, pSeq, -1, nil)
        }
        
        // step & fetch
        while sqlite3_step(statement) == SQLITE_ROW {
            // 컬럼 인덱스와 순서를 주의 (CREATE TABLE 순서)
            let colId = sqlite3_column_int(statement, 0)
            let colTid = stringColumn(statement!, 1)
            let colProductSeq = stringColumn(statement!, 2)
            let colTableNo = stringColumn(statement!, 3)
            let colCode = stringColumn(statement!, 4)
            let colName = stringColumn(statement!, 5)
            let colCategory = stringColumn(statement!, 6)
            let colPrice = stringColumn(statement!, 7)
            let colDate = stringColumn(statement!, 8)
            let colBarcode = stringColumn(statement!, 9)
            let colIsUse = sqlite3_column_int(statement!, 10)
            let colImgUrl = stringColumn(statement!, 11)
            let colImgString = stringColumn(statement!, 12)
            
            let colVatUse = sqlite3_column_int(statement!, 13)
            let colVatMode = sqlite3_column_int(statement!, 14)
            let colVatInclude = sqlite3_column_int(statement!, 15)
            let colVatRate = sqlite3_column_int(statement!, 16)
            let colVatWon = stringColumn(statement!, 17)
            
            let colSvcUse = sqlite3_column_int(statement!, 18)
            let colSvcMode = sqlite3_column_int(statement!, 19)
            let colSvcInclude = sqlite3_column_int(statement!, 20)
            let colSvcRate = sqlite3_column_int(statement!, 21)
            let colSvcWon = stringColumn(statement!, 22)
            
            let colTotalPrice = stringColumn(statement!, 23)
            let colIsImgUse = sqlite3_column_int(statement, 24)
            
            // Swift에서는 custom struct DBProductInfoResult 정의하여 초기화
            let info = DBProductInfoResult(
                id: Int(colId),
                tid: colTid,
                productSeq: colProductSeq,
                tableNo: colTableNo,
                code: colCode,
                name: colName,
                category: colCategory,
                price: colPrice,
                date: colDate,
                barcode: colBarcode,
                isUse: Int(colIsUse),
                imgUrl: colImgUrl,
                imgString: colImgString,
                vatUse: Int(colVatUse),
                vatMode: Int(colVatMode),
                vatInclude: Int(colVatInclude),
                vatRate: Int(colVatRate),
                vatWon: colVatWon,
                svcUse: Int(colSvcUse),
                svcMode: Int(colSvcMode),
                svcInclude: Int(colSvcInclude),
                svcRate: Int(colSvcRate),
                svcWon: colSvcWon,
                totalPrice: colTotalPrice,
                isImgUse: Int(colIsImgUse)
            )
            
            result.append(info)
        }
        
        return result
    }
    
    // MARK: - 상품정보 파일(csv) 로 내보내기
    /// ProductTable 내용을 CSV로 내보내기
    /// - Parameter fileURL: CSV를 작성할 파일 경로(URL)
    /// - Returns: 성공 시 fileURL, 실패 시 nil
    func exportProductTable(to fileURL: URL) -> URL? {
        // 1) SELECT 쿼리 준비
        let selectQuery = "SELECT * FROM \(define.DB_ProductTable)"
        var statement: OpaquePointer? = nil
        
        guard sqlite3_prepare_v2(db_point, selectQuery, -1, &statement, nil) == SQLITE_OK else {
            print("exportProductTable - prepare 실패")
            return nil
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        // 2) 파일 열기 (쓰기 모드)
        //    이 예시에선 기존 파일을 덮어쓴다고 가정
        do {
            // 파일이 이미 있으면 제거
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            
            guard let fileHandle = try? FileHandle(forWritingTo: fileURL) else {
                print("exportProductTable - 파일 열기 실패")
                return nil
            }
            defer {
                fileHandle.closeFile()
            }
            
            // 3) 결과 행 반복
            while sqlite3_step(statement) == SQLITE_ROW {
                // 각 컬럼 추출
                // 예시: 0=Tid, 1=ProductSeq, 2=TableNo, 3=Code, ...
                // 실제 인덱스는 CREATE TABLE 순서와 동일하게 맞춰야 함
                // 여기서는 일단 "SELECT *" -> 해당 테이블 순서를 참고
                var tid = stringColumn(statement!, 1)
                tid = "idt"
                let productSeq = stringColumn(statement!, 2)
                let tableNo = stringColumn(statement!, 3)
                let code = stringColumn(statement!, 4)
                let name = stringColumn(statement!, 5)
                let category = stringColumn(statement!, 6)
                let price = stringColumn(statement!, 7)
                let date = stringColumn(statement!, 8)
                let barcode = stringColumn(statement!, 9)
                let isUse = stringColumn(statement!, 10)
                let imgUrl = stringColumn(statement!, 11)
                let imgString = stringColumn(statement!, 12)
                let vatUse = stringColumn(statement!, 13)
                let vatAuto = stringColumn(statement!, 14)
                let vatInclude = stringColumn(statement!, 15)
                let vatRate = stringColumn(statement!, 16)
                let vatWon = stringColumn(statement!, 17)
                let svcUse = stringColumn(statement!, 18)
                let svcAuto = stringColumn(statement!, 19)
                let svcInclude = stringColumn(statement!, 20)
                let svcRate = stringColumn(statement!, 21)
                let svcWon = stringColumn(statement!, 22)
                let totalPrice = stringColumn(statement!, 23)
                let isImgUse = stringColumn(statement!, 24)
                
                // 4) CSV 한 줄 만들기 (쉼표 구분)
                //    실제 CSV 포맷에 맞춰 따옴표 등 escaping 필요할 수 있음
                let rowData = [
                    tid,
                    productSeq,
                    tableNo,
                    code,
                    name,
                    category,
                    price,
                    date,
                    barcode,
                    isUse,
                    imgUrl,
                    imgString,
                    vatUse,
                    vatAuto,
                    vatInclude,
                    vatRate,
                    vatWon,
                    svcUse,
                    svcAuto,
                    svcInclude,
                    svcRate,
                    svcWon,
                    totalPrice,
                    isImgUse
                ]
                
                let csvLine = rowData.joined(separator: ",") + "\n"
                if let lineData = csvLine.data(using: .utf8) {
                    fileHandle.write(lineData)
                }
            }
            
            return fileURL
        } catch {
            print("exportProductTable - 파일 처리 중 오류: \(error)")
            return nil
        }
    }
    
    // MARK: - 여기부터 상품거래 내역 INSERT
    /// 상품거래 상세내역 INSERT
    func insertProductTradeDetail(
        productNum: String,
        tid: String,
        storeName: String,
        storeAddr: String,
        storeNumber: String,
        storePhone: String,
        storeOwner: String,
        trade: String,
        code: String,
        name: String,
        category: String,
        price: String,
        count: String,
        isCombine: String,
        isCancel: String,
        auDate: String,
        oriAuDateTime: String
    ) -> Bool {
        let insertQuery = """
            INSERT INTO \(define.DB_ProductTradeDetailTable)
            (ProductNum, Tid, StoreName, StoreAddr, StoreNumber, StorePhone, StoreOwner,
             Trade, Code, Name, Category, Price, Count, isCombine, isCancel, AuDate, OriAuDateTime)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db_point, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            print("insertProductTradeDetail - prepare 실패")
            return false
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, 1, productNum, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, tid, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 3, storeName, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 4, storeAddr, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 5, storeNumber, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 6, storePhone, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 7, storeOwner, -1, SQLITE_TRANSIENT)
        
        sqlite3_bind_text(statement, 8, trade, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 9, code, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 10, name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 11, category, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 12, price, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 13, count, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 14, isCombine, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 15, isCancel, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 16, auDate, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 17, oriAuDateTime, -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("insertProductTradeDetail - INSERT 성공")
            return true
        } else {
            let errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                errMsg = String(cString: cString)
            } else {
                errMsg = "No error message"
            }
            print("insertProductTradeDetail - INSERT 실패: \(errMsg)")
            return false
        }
    }
    
    /// 상품거래 상세내역 조회
    /// - Parameter pNum: ProductNum
    /// - Returns: [DBProductTradeResult]?
    func getProductTradeAllList(pNum: String) -> [DBProductTradeResult]? {
        var result = [DBProductTradeResult]()
        
        // WHERE ProductNum=?
        let query = """
            SELECT *
            FROM \(define.DB_ProductTradeDetailTable)
            WHERE ProductNum=?
        """
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            print("getProductTradeAllList - prepare 실패")
            return nil
        }
        
        // bind
        sqlite3_bind_text(statement, 1, pNum, -1, nil)
        
        // step
        while sqlite3_step(statement) == SQLITE_ROW {
            let colId = sqlite3_column_int(statement, 0)
            let colProductNum = stringColumn(statement!, 1)
            let colTid = stringColumn(statement!, 2)
            let colStoreName = stringColumn(statement!, 3)
            let colStoreAddr = stringColumn(statement!, 4)
            let colStoreNumber = stringColumn(statement!, 5)
            let colStorePhone = stringColumn(statement!, 6)
            let colStoreOwner = stringColumn(statement!, 7)
            let colTrade = stringColumn(statement!, 8)
            let colCode = stringColumn(statement!, 9)
            let colName = stringColumn(statement!, 10)
            let colCategory = stringColumn(statement!, 11)
            let colPrice = stringColumn(statement!, 12)
            let colCount = stringColumn(statement!, 13)
            let colIsCombine = stringColumn(statement!, 14)
            let colIsCancel = stringColumn(statement!, 15)
            let colAuDate = stringColumn(statement!, 16)
            let colOriAuDateTime = stringColumn(statement!, 17)
            
            // Swift에서 DBProductTradeResult 구조체를 만들어서 처리
            let detail = DBProductTradeResult(
                id: Int(colId),
                productNum: colProductNum,
                tid: colTid,
                storeName: colStoreName,
                storeAddr: colStoreAddr,
                storeNumber: colStoreNumber,
                storePhone: colStorePhone,
                storeOwner: colStoreOwner,
                trade: colTrade,
                code: colCode,
                name: colName,
                category: colCategory,
                price: colPrice,
                count: colCount,
                isCombine: colIsCombine,
                isCancel: colIsCancel,
                auDate: colAuDate,
                oriAuDateTime: colOriAuDateTime
            )
            
            // 원본 코드에서 CAT vs BLE 여부에 따라 리스트 추가할지 말지 분기
            // if DeviceType() == CAT => if detail.trade.contains("(CAT)") => add
            // else => if !detail.trade.contains("(CAT)") => add
            // ...
            
            result.append(detail)
        }
        
        return result
    }
    
    // MARK: - 여기부터 무결성 검사
    
    /// 무결성 검사 결과 추가 함수
    /// - Parameters:
    ///   - _date: 날짜 (yyMMddhhmmss)
    ///   - _mode: 자동, 수동모드 (auto, manual)   0- 자동, 1- 수동
    ///   - _result: 성공 실패 (success, fail)  0-성공, 1-실패
    /// - Returns: verity DB 데이터
    @discardableResult
    func InsertVerity(Date _date: String,
                      Mode _mode: String,
                      Result _result: String) -> [DBVerityResult] {
        
        // 1) INSERT 구문 (파라미터 바인딩 사용)
        let insertQuery = """
            INSERT INTO \(define.DB_Verity) (date, mode, result)
            VALUES (?, ?, ?);
        """
        
        var insertStatement: OpaquePointer? = nil

        // 2) prepare
        guard sqlite3_prepare_v2(db_point, insertQuery, -1, &insertStatement, nil) == SQLITE_OK else {
            debugPrint("무결성 검사 테이블 인서트 준비 실패")
            return getVerityList()
        }
        
        defer {
            // 함수 종료 시점에 finalize
            sqlite3_finalize(insertStatement)
        }
        
        // 3) 파라미터 바인딩
        sqlite3_bind_text(insertStatement, 1, (_date as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStatement, 2, (_mode as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStatement, 3, (_result as NSString).utf8String, -1, nil)
        
        // 4) 실제 실행
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            debugPrint("무결성검사 추가DB 성공")
        } else {
            debugPrint("무결성 검사 테이블 인서트 실패")
        }
        
        // 5) Insert 후, 만일 최대 개수를 초과하면 오래된 데이터 삭제
        while getVerityCount() > VerityTableMaxCount {
            removeOldestVerity()
        }
        
        // 6) 최신 리스트 반환
        return getVerityList()
    }
    
    /// 현재 무결성 테이블의 레코드 개수를 가져오는 함수
    /// (파라미터 바인딩 대상이 되는 동적 변수가 없으므로, 고정 쿼리 그대로 사용)
    private func getVerityCount() -> Int {
        let countQuery = "SELECT count(*) FROM \(define.DB_Verity);"
        var queryStatement: OpaquePointer? = nil
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        // prepare
        guard sqlite3_prepare_v2(db_point, countQuery, -1, &queryStatement, nil) == SQLITE_OK else {
            debugPrint("SELECT count(*) 준비 실패")
            return 0
        }
        
        // step
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            debugPrint("카운트 조회 실패")
            return 0
        }
        
        let rowCount = Int(sqlite3_column_int(queryStatement, 0))
        return rowCount
    }

    /// 가장 오래된 Verity 레코드를 삭제하는 함수
    /// - 여기서는 "오래된" 기준을 ID의 최소값으로 보고 삭제
    ///   (ID가 AUTOINCREMENT라고 가정)
    private func removeOldestVerity() {
        // 파라미터 바인딩할 변수가 따로 없으므로 exec로 직접 실행
        let deleteQuery = """
            DELETE FROM \(define.DB_Verity)
            WHERE ID = (SELECT MIN(ID) FROM \(define.DB_Verity));
        """
        
        if sqlite3_exec(db_point, deleteQuery, nil, nil, nil) != SQLITE_OK {
            var errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                // cString 이 nil 이 아닐 경우
                errMsg = String(cString: cString)
            } else {
                // cString 이 nil 일 경우
                errMsg = "No error message"
            }
            debugPrint("가장 오래된 무결성 레코드 삭제 실패: \(errMsg)")
        } else {
            debugPrint("가장 오래된 무결성 레코드 삭제 성공")
        }
    }

    /// 무결성 검사 리스트 조회 함수
    /// - Returns: 무결성검사 결과 DBVerityResult 구조체 배열
    func getVerityList() -> [DBVerityResult] {
        var result: [DBVerityResult] = []

        // 레코드를 오래된 순으로 보고 싶다면 ORDER BY ID ASC
        // 필요한 경우 date 기준으로 정렬하는 것도 가능: ORDER BY date ASC
        let query = "SELECT * FROM \(define.DB_Verity) ORDER BY ID ASC;"
        
        var queryStatement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        // prepare
        guard sqlite3_prepare_v2(db_point, query, -1, &queryStatement, nil) == SQLITE_OK else {
            debugPrint("무결성 리스트 조회 쿼리 준비 실패")
            return result
        }
        
        // step
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            // 컬럼 인덱스:
            // 0 -> ID, 1 -> date, 2 -> mode, 3 -> result
            guard
                let datePtr   = sqlite3_column_text(queryStatement, 1),
                let modePtr   = sqlite3_column_text(queryStatement, 2),
                let resultPtr = sqlite3_column_text(queryStatement, 3)
            else {
                continue
            }
            
            let date = String(cString: datePtr)
            let mode = String(cString: modePtr)
            let res  = String(cString: resultPtr)
            
            // mode, result가 "0"인지 "1"인지에 따라 표시
            let modeDisplay = (mode == "0") ? "자동" : "수동"
            let resDisplay  = (res  == "0") ? "성공" : "실패"
            
            let item = DBVerityResult(date: date,
                                      mode: modeDisplay,
                                      result: resDisplay)
            result.append(item)
        }
        
        debugPrint("무결성점검 전체 테이블 : \(result)")
        return result
    }
    
    // MARK: - 여기부터 일반 거래 insert
    /// 거래내역 입력
    /// - Parameters:
    ///   - _Tid: 거래 시 사용한 TID
    ///   - _Trade: <#_Trade description#>
    ///   - _cancel: <#_cancel description#>
    ///   - _money: <#_money description#>
    ///   - _giftAmt: 선불카드 잔액
    ///   - _tax: 세금
    ///   - _Scv: 봉사료
    ///   - _Txf: 비과세
    ///   - _InstallMent: 할부
    ///   - _CashTarget: <#_CashTarget description#>
    ///   - _CashInputType: <#_CashInputType description#>
    ///   - _CashNum: <#_CashNum description#>
    ///   - _CardNum: <#_CardNum description#>
    ///   - _CardType: <#_CardType description#>
    ///   - _CardInpNm: <#_CardInpNm description#>
    ///   - _CardIssuer: <#_CardIssuer description#>
    ///   - _MchNo: <#_MchNo description#>
    ///   - _AuDate: 승인 날짜
    ///   - _OriAuDate: 취소시에 원거래일자 기록
    ///   - _AuNum: 인증 번호
    ///   - _KocesTradeNo: 코세스 고유 번호
    func InsertTrade(
        Tid _Tid: String,
        StoreName _storeName: String,
        StoreAddr _storeAddr: String,
        StoreNumber _storeNumber: String,
        StorePhone _storePhone: String,
        StoreOwner _storeOwner: String,
        신용현금 _Trade: define.TradeMethod,
        취소여부 _cancel: define.TradeMethod,
        금액 _money: Int,
        선불카드잔액 _giftamt: String,
        세금 _tax: Int,
        봉사료 _Scv: Int,
        비과세 _Txf: Int,
        할부 _InstallMent: Int,
        현금영수증타겟 _CashTarget: define.TradeMethod,
        현금영수증발급형태 _CashInputType: define.TradeMethod,
        현금발급번호 _CashNum: String,
        카드번호 _CardNum: String,
        카드종류 _CardType: String,
        카드매입사 _CardInpNm: String,
        카드발급사 _CardIssuer: String,
        가맹점번호 _MchNo: String,
        승인날짜 _AuDate: String,
        원거래일자 _OriAuDate: String,
        승인번호 _AuNum: String,
        원승인번호 _OriAuNum: String,
        코세스고유거래키 _KocesTradeNo: String,
        응답메시지 _Message: String,
        KakaoMessage _KakaoMessage: String,
        PayType _PayType: String,
        KakaoAuMoney _KakaoAuMoney: String,
        KakaoSaleMoney _KakaoSaleMoney: String,
        KakaoMemberCd _KakaoMemberCd: String,
        KakaoMemberNo _KakaoMemberNo: String,
        Otc _Otc: String,
        Pem _Pem: String,
        Trid _Trid: String,
        CardBin _CardBin: String,
        SearchNo _SearchNo: String,
        PrintBarcd _PrintBarcd: String,
        PrintUse _PrintUse: String,
        PrintNm _PrintNm: String,
        MchFee _MchFee: String,
        MchRefund _MchRefund: String,
        PcKind _PcKind: String,
        PcCoupon _PcCoupon: String,
        PcPoint _PcPoint: String,
        PcCard _PcCard: String,
        ProductNum _productNum: String,
        _ddc: String,
        _edc: String,
        _icInputType: String,
        _emvTradeType: String,
        _pointCode: String,
        _serviceName: String,
        _earnPoint: String,
        _usePoint: String,
        _totalPoint: String,
        _percent: String,
        _userName: String,
        _pointStoreNumber: String,
        _MemberCardTypeText: String,
        _MemberServiceTypeText: String,
        _MemberServiceNameText: String,
        _MemberTradeMoneyText: String,
        _MemberSaleMoneyText: String,
        _MemberAfterTradeMoneyText: String,
        _MemberAfterMemberPointText: String,
        _MemberOptionCodeText: String,
        _MemberStoreNoText: String
    ) -> String {
        // 1) 취소 거래인지 확인
        //    - 취소라면 기존 거래가 있는지 검색해서 업데이트할지, 아니면 Insert 할지 결정
        var audateTimeValue = ""   // OriAuDateTime에 들어갈 값
        var mineTradeValue = ""    // "1" or "2" 등 상태 값

        if _cancel == define.TradeMethod.Cancel {
            mineTradeValue = "2"  // "취소"라는 표시 (예시로 "2" 사용)
            
            // 기존 거래가 있는지 확인 (getUpdateTrade)
            // - 존재하면 해당 거래를 Update (mineTradeValue = "1")
            audateTimeValue = getUpdateTrade(원거래일자: _OriAuDate.replacingOccurrences(of: " ", with: ""),
                                             원승인번호: _OriAuNum.replacingOccurrences(of: " ", with: ""))

            if !audateTimeValue.isEmpty {
                // 기존 거래가 존재하므로 Update로 처리
                mineTradeValue = "1"
                UpdateTradeList(
                    Tid: _Tid,
                    StoreName: _storeName,
                    StoreAddr: _storeAddr,
                    StoreNumber: _storeNumber,
                    StorePhone: _storePhone,
                    StoreOwner: _storeOwner,
                    신용현금: _Trade,
                    취소여부: _cancel,
                    금액: _money,
                    선불카드잔액: _giftamt,
                    세금: _tax,
                    봉사료: _Scv,
                    비과세: _Txf,
                    할부: _InstallMent,
                    현금영수증타겟: _CashTarget,
                    현금영수증발급형태: _CashInputType,
                    현금발급번호: _CashNum,
                    카드번호: _CardNum,
                    카드종류: _CardType,
                    카드매입사: _CardInpNm,
                    카드발급사: _CardIssuer,
                    가맹점번호: _MchNo,
                    승인날짜: _AuDate,
                    원거래일자: _OriAuDate,
                    승인번호: _AuNum,
                    원승인번호: _OriAuNum,
                    코세스고유거래키: _KocesTradeNo,
                    응답메시지: _Message,
                    KakaoMessage: _KakaoMessage,
                    PayType: _PayType,
                    KakaoAuMoney: _KakaoAuMoney,
                    KakaoSaleMoney: _KakaoSaleMoney,
                    KakaoMemberCd: _KakaoMemberCd,
                    KakaoMemberNo: _KakaoMemberNo,
                    Otc: _Otc,
                    Pem: _Pem,
                    Trid: _Trid,
                    CardBin: _CardBin,
                    SearchNo: _SearchNo,
                    PrintBarcd: _PrintBarcd,
                    PrintUse: _PrintUse,
                    PrintNm: _PrintNm,
                    MchFee: _MchFee,
                    MchRefund: _MchRefund,
                    PcKind: _PcKind,
                    PcCoupon: _PcCoupon,
                    PcPoint: _PcPoint,
                    PcCard: _PcCard,
                    MineTrade: mineTradeValue,
                    ProductNum: _productNum,
                    AudateTime: audateTimeValue,   // getUpdateTrade 리턴값
                    _ddc: _ddc,
                    _edc: _edc,
                    _icInputType: _icInputType,
                    _emvTradeType: _emvTradeType,
                    _pointCode: _pointCode,
                    _serviceName: _serviceName,
                    _earnPoint: _earnPoint,
                    _usePoint: _usePoint,
                    _totalPoint: _totalPoint,
                    _percent: _percent,
                    _userName: _userName,
                    _pointStoreNumber: _pointStoreNumber,
                    _MemberCardTypeText: _MemberCardTypeText,
                    _MemberServiceTypeText: _MemberServiceTypeText,
                    _MemberServiceNameText: _MemberServiceNameText,
                    _MemberTradeMoneyText: _MemberTradeMoneyText,
                    _MemberSaleMoneyText: _MemberSaleMoneyText,
                    _MemberAfterTradeMoneyText: _MemberAfterTradeMoneyText,
                    _MemberAfterMemberPointText: _MemberAfterMemberPointText,
                    _MemberOptionCodeText: _MemberOptionCodeText,
                    _MemberStoreNoText: _MemberStoreNoText
                )
                return audateTimeValue
            }
        }

        // 2) 기존 거래가 없거나, 취소가 아닌 경우 => INSERT
        //    - DB_Trade 테이블에 레코드 추가
        let columns = """
            Tid,StoreName,StoreAddr,StoreNumber,StorePhone,StoreOwner,Trade,Cancel,
            Money,GiftAmt,Tax,Svc,Txf,Inst,CashTarget,CashInputType,CashNum,
            CardNum,CardType,CardInpNm,CardIssuer,MchNo,AuDate,OriAuData,AuNum,
            OriAuNum,TradeNo,Message,KakaoMessage,PayType,KakaoAuMoney,KakaoSaleMoney,
            KakaoMemberCd,KakaoMemberNo,Otc,Pem,Trid,CardBin,SearchNo,PrintBarcd,
            PrintUse,PrintNm,MchFee,MchRefund,PcKind,PcCoupon,PcPoint,PcCard,
            MineTrade,ProductNum,OriAuDateTime,DDCYn,EDCYn,ICInputType,EMVTradeType,
            PtPointCode,PtServiceName,PtEarnPoint,PtUsePoint,PtTotalPoint,PtPercent,
            PtUserName,PtPointStoreNumber,MemberCardType,MemberServiceType,MemberServiceName,
            MemberTradeMoney,MemberSaleMoney,MemberAfterTradeMoney,MemberAfterMemberPoint,
            MemberOptionCode,MemberStoreNo
        """
        // 총 72개 필드 => 파라미터도 72개가 필요
        let placeholders = Array(repeating: "?", count: 72).joined(separator: ",")

        let query = "INSERT INTO \(define.DB_Trade) (\(columns)) VALUES (\(placeholders));"

        var insertStatement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(insertStatement)
        }

        guard sqlite3_prepare_v2(db_point, query, -1, &insertStatement, nil) == SQLITE_OK else {
            debugPrint("Failed to prepare trade INSERT statement.")
            return audateTimeValue
        }

        // Bind할 값 (순서 중요!)
        let bindValues: [Any] = [
            _Tid, _storeName, _storeAddr, _storeNumber, _storePhone, _storeOwner,
            _Trade.rawValue, _cancel.rawValue, String(_money), _giftamt, String(_tax),
            String(_Scv), String(_Txf), String(_InstallMent), _CashTarget.rawValue,
            _CashInputType.rawValue, _CashNum, _CardNum, _CardType, _CardInpNm,
            _CardIssuer, _MchNo, _AuDate, _OriAuDate, _AuNum, _OriAuNum, _KocesTradeNo,
            _Message, _KakaoMessage, _PayType, _KakaoAuMoney, _KakaoSaleMoney,
            _KakaoMemberCd, _KakaoMemberNo, _Otc, _Pem, _Trid, _CardBin, _SearchNo,
            _PrintBarcd, _PrintUse, _PrintNm, _MchFee, _MchRefund, _PcKind, _PcCoupon,
            _PcPoint, _PcCard, mineTradeValue, _productNum, audateTimeValue, _ddc, _edc,
            _icInputType, _emvTradeType, _pointCode, _serviceName, _earnPoint, _usePoint,
            _totalPoint, _percent, _userName, _pointStoreNumber, _MemberCardTypeText,
            _MemberServiceTypeText, _MemberServiceNameText, _MemberTradeMoneyText,
            _MemberSaleMoneyText, _MemberAfterTradeMoneyText, _MemberAfterMemberPointText,
            _MemberOptionCodeText, _MemberStoreNoText
        ]

        // 한 줄짜리 유틸 함수로 빼도 좋지만, 여기서는 직접 바인딩
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(insertStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding string failed: \(errMsg)")
                    return audateTimeValue
                }
            case let intValue as Int:
                if sqlite3_bind_int(insertStatement, position, Int32(intValue)) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding int failed: \(errMsg)")
                    return audateTimeValue
                }
            default:
                // 필요한 경우 Double, etc. 로 확장 가능
                let stringValue = "\(value)"
                if sqlite3_bind_text(insertStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding unknown type failed: \(errMsg)")
                    return audateTimeValue
                }
            }
        }

        // 실제 Insert 실행
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            switch _Trade {
            case .Credit:
                debugPrint("신용거래 INSERT 성공")
            case .Cash:
                debugPrint("현금거래 INSERT 성공")
            case .Kakao:
                debugPrint("카카오거래 INSERT 성공")
            default:
                debugPrint("기타거래 INSERT 성공")
            }
        } else {
            debugPrint("Failed to insert trade.")
        }
        
        return audateTimeValue
    }
    
    // 기존 거래가 있는지 확인하는 함수
    /// 해당 취소 거래가 이미 있는지 확인 후, 있으면 그 거래의 AuDate 반환
    /// (파라미터 바인딩 적용)
    private func getUpdateTrade(원거래일자 _OriAuDate: String,
                                원승인번호 _OriAuNum: String) -> String {
        var result = ""
        let query = """
            SELECT AuDate
            FROM \(define.DB_Trade)
            WHERE AuNum LIKE ?
              AND AuDate LIKE ?
            ORDER BY id DESC
            LIMIT 1;
        """
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("SELECT statement could not be prepared: getUpdateTrade")
            return result
        }
        
        // 파라미터 바인딩 (LIKE 절에 들어갈 '%')
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let oriAuNumLike = "\(_OriAuNum)%"
        let oriAuDateLike = "\(_OriAuDate)%"
        
        sqlite3_bind_text(statement, 1, oriAuNumLike, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, oriAuDateLike, -1, SQLITE_TRANSIENT)

        while sqlite3_step(statement) == SQLITE_ROW {
            let cText = sqlite3_column_text(statement, 0)
            if let cString = cText {
                result = String(cString: cString)
            }
        }
        
        return result
    }
    
    // 기존 거래 UPDATE
    /// 기존 거래를 취소로 변경(또는 정보 갱신)
    func UpdateTradeList(
        Tid _Tid: String,
        StoreName _storeName: String,
        StoreAddr _storeAddr: String,
        StoreNumber _storeNumber: String,
        StorePhone _storePhone: String,
        StoreOwner _storeOwner: String,
        신용현금 _Trade: define.TradeMethod,
        취소여부 _cancel: define.TradeMethod,
        금액 _money: Int,
        선불카드잔액 _giftamt: String,
        세금 _tax: Int,
        봉사료 _Scv: Int,
        비과세 _Txf: Int,
        할부 _InstallMent: Int,
        현금영수증타겟 _CashTarget: define.TradeMethod,
        현금영수증발급형태 _CashInputType: define.TradeMethod,
        현금발급번호 _CashNum: String,
        카드번호 _CardNum: String,
        카드종류 _CardType: String,
        카드매입사 _CardInpNm: String,
        카드발급사 _CardIssuer: String,
        가맹점번호 _MchNo: String,
        승인날짜 _AuDate: String,
        원거래일자 _OriAuDate: String,
        승인번호 _AuNum: String,
        원승인번호 _OriAuNum: String,
        코세스고유거래키 _KocesTradeNo: String,
        응답메시지 _Message: String,
        KakaoMessage _KakaoMessage: String,
        PayType _PayType: String,
        KakaoAuMoney _KakaoAuMoney: String,
        KakaoSaleMoney _KakaoSaleMoney: String,
        KakaoMemberCd _KakaoMemberCd: String,
        KakaoMemberNo _KakaoMemberNo: String,
        Otc _Otc: String,
        Pem _Pem: String,
        Trid _Trid: String,
        CardBin _CardBin: String,
        SearchNo _SearchNo: String,
        PrintBarcd _PrintBarcd: String,
        PrintUse _PrintUse: String,
        PrintNm _PrintNm: String,
        MchFee _MchFee: String,
        MchRefund _MchRefund: String,
        PcKind _PcKind: String,
        PcCoupon _PcCoupon: String,
        PcPoint _PcPoint: String,
        PcCard _PcCard: String,
        MineTrade _mineTrade: String,
        ProductNum _productNum: String,
        AudateTime _AudateTime: String,
        _ddc: String,
        _edc: String,
        _icInputType: String,
        _emvTradeType: String,
        _pointCode: String,
        _serviceName: String,
        _earnPoint: String,
        _usePoint: String,
        _totalPoint: String,
        _percent: String,
        _userName: String,
        _pointStoreNumber: String,
        _MemberCardTypeText: String,
        _MemberServiceTypeText: String,
        _MemberServiceNameText: String,
        _MemberTradeMoneyText: String,
        _MemberSaleMoneyText: String,
        _MemberAfterTradeMoneyText: String,
        _MemberAfterMemberPointText: String,
        _MemberOptionCodeText: String,
        _MemberStoreNoText: String
    ) {
        // UPDATE 쿼리: SET [컬럼 = ? ...] WHERE AuNum=? AND AuDate LIKE ?
        // 주의: 본문에 '항상 2개 파라미터' (AuNum, AuDate LIKE)가 뒤에 추가됨
        let columns = [
            "Tid", "Trade", "Cancel", "Money", "GiftAmt", "Tax", "Svc", "Txf",
            "Inst", "CashTarget", "CashInputType", "CashNum", "CardNum", "CardType",
            "CardInpNm", "CardIssuer", "MchNo", "AuDate", "OriAuData", "AuNum",
            "OriAuNum", "TradeNo", "Message", "KakaoMessage", "PayType", "KakaoAuMoney",
            "KakaoSaleMoney", "KakaoMemberCd", "KakaoMemberNo", "Otc", "Pem", "Trid",
            "CardBin", "SearchNo", "PrintBarcd", "PrintUse", "PrintNm", "MchFee",
            "MchRefund", "PcKind", "PcCoupon", "PcPoint", "PcCard", "MineTrade",
            "ProductNum", "OriAuDateTime", "DDCYn", "EDCYn", "ICInputType", "EMVTradeType",
            "PtPointCode", "PtServiceName", "PtEarnPoint", "PtUsePoint", "PtTotalPoint",
            "PtPercent", "PtUserName", "PtPointStoreNumber", "MemberCardType",
            "MemberServiceType", "MemberServiceName", "MemberTradeMoney", "MemberSaleMoney",
            "MemberAfterTradeMoney", "MemberAfterMemberPoint", "MemberOptionCode", "MemberStoreNo"
        ]
        let setClause = columns.map { "\($0) = ?" }.joined(separator: ", ")
        let query = """
            UPDATE \(define.DB_Trade)
            SET \(setClause)
            WHERE AuNum = ?
              AND AuDate LIKE ?
        """

        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }

        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("거래내역 UPDATE statement 준비 실패")
            return
        }

        // 바인딩할 값(=SET할 필드들) + WHERE 조건 2개(AuNum, AuDate LIKE)
        let bindValues: [Any] = [
            _Tid, _Trade.rawValue, _cancel.rawValue, _money, _giftamt, _tax, _Scv, _Txf,
            _InstallMent, _CashTarget.rawValue, _CashInputType.rawValue, _CashNum, _CardNum,
            _CardType, _CardInpNm, _CardIssuer, _MchNo, _AuDate, _OriAuDate, _AuNum, _OriAuNum,
            _KocesTradeNo, _Message, _KakaoMessage, _PayType, _KakaoAuMoney, _KakaoSaleMoney,
            _KakaoMemberCd, _KakaoMemberNo, _Otc, _Pem, _Trid, _CardBin, _SearchNo, _PrintBarcd,
            _PrintUse, _PrintNm, _MchFee, _MchRefund, _PcKind, _PcCoupon, _PcPoint, _PcCard,
            _mineTrade, _productNum, _AudateTime, _ddc, _edc, _icInputType, _emvTradeType,
            _pointCode, _serviceName, _earnPoint, _usePoint, _totalPoint, _percent,
            _userName, _pointStoreNumber, _MemberCardTypeText, _MemberServiceTypeText,
            _MemberServiceNameText, _MemberTradeMoneyText, _MemberSaleMoneyText,
            _MemberAfterTradeMoneyText, _MemberAfterMemberPointText, _MemberOptionCodeText,
            _MemberStoreNoText,
            
            // WHERE 조건:
            _OriAuNum,
            "\(_OriAuDate)%"
        ]

        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        // 실제 바인딩
        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(statement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var err: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        err = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        err = "No error message"
                    }
                    print("UpdateTradeList - bind string failed: \(err)")
                    return
                }
            case let intValue as Int:
                if sqlite3_bind_int(statement, position, Int32(intValue)) != SQLITE_OK {
                    var err: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        err = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        err = "No error message"
                    }
                    print("UpdateTradeList - bind int failed: \(err)")
                    return
                }
            default:
                // 필요하다면 Double 등 추가
                let strVal = "\(value)"
                if sqlite3_bind_text(statement, position, strVal, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var err: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        err = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        err = "No error message"
                    }
                    print("UpdateTradeList - bind unknown type failed: \(err)")
                    return
                }
            }
        }

        // UPDATE 실행
        if sqlite3_step(statement) == SQLITE_DONE {
            switch _Trade {
            case .Credit:
                debugPrint("신용거래 UPDATE 성공")
            case .Cash:
                debugPrint("현금거래 UPDATE 성공")
            case .Kakao:
                debugPrint("간편거래 UPDATE 성공")
            default:
                debugPrint("기타거래 UPDATE 성공")
            }
        } else {
            debugPrint("거래 내역 테이블 UPDATE 실패")
        }
    }
    
    
    /// DBTradeResult 객체를 만드는 공용 함수
    /// (0~72번 컬럼을 일일이 꺼내는 로직을 한 군데에 모으는 게 깔끔합니다)
    private func mapDBTradeResult(_ statement: OpaquePointer) -> DBTradeResult {
        // 각 컬럼 인덱스별로 문자열 추출
        // (주의: 실제 테이블 구조, 컬럼 순서에 맞춰야 함)
        let _id = Int(sqlite3_column_int(statement, 0))
        let _Tid = stringColumn(statement, 1)
        let _storeName = stringColumn(statement,  2)
        let _StoreAddr = stringColumn(statement,  3)
        let _StoreNumber = stringColumn(statement,  4)
        let _StorePhone = stringColumn(statement,  5)
        let _StoreOwner = stringColumn(statement,  6)
        let _Trade = stringColumn(statement,  7)
        let _Cancel = stringColumn(statement,  8)
        let _Money = stringColumn(statement,  9)
        let _GiftAmt = stringColumn(statement,  10)
        let _Tax = stringColumn(statement,  11)
        let _Svc = stringColumn(statement,  12)
        let _Txf = stringColumn(statement,  13)
        let _Inst = stringColumn(statement,  14)
        let _CashTarget = stringColumn(statement,  15)
        let _CashInputMethod = stringColumn(statement,  16)
        let _CashNum = stringColumn(statement,  17)
        let _CardNum = stringColumn(statement,  18)
        let _CardType = stringColumn(statement,  19)
        let _CardInpNm = stringColumn(statement,  20)
        let _CardIssuer = stringColumn(statement,  21)
        let _MchNo = stringColumn(statement,  22)
        let _AuDate = stringColumn(statement,  23)
        let _OriAuDate = stringColumn(statement,  24)
        let _AuNum = stringColumn(statement,  25)
        let _OriAuNum = stringColumn(statement,  26)
        let _TradeNo = stringColumn(statement,  27)
        let _Message = stringColumn(statement,  28)
        let _KakaoMessage = stringColumn(statement,  29)
        let _PayType = stringColumn(statement,  30)
        let _KakaoAuMoney = stringColumn(statement,  31)
        let _KakaoSaleMoney = stringColumn(statement,  32)
        let _KakaoMemberCd = stringColumn(statement,  33)
        let _KakaoMemberNo = stringColumn(statement,  34)
        let _Otc = stringColumn(statement,  35)
        let _Pem = stringColumn(statement,  36)
        let _Trid = stringColumn(statement,  37)
        let _CardBin = stringColumn(statement,  38)
        let _SearchNo = stringColumn(statement,  39)
        let _PrintBarcd = stringColumn(statement,  40)
        let _PrintUse = stringColumn(statement,  41)
        let _PrintNm = stringColumn(statement,  42)
        let _MchFee = stringColumn(statement,  43)
        let _MchRefund = stringColumn(statement,  44)
        let _PcKind = stringColumn(statement,  45)
        let _PcCoupon = stringColumn(statement,  46)
        let _PcPoint = stringColumn(statement,  47)
        let _PcCard = stringColumn(statement,  48)
        let _MineTrade = stringColumn(statement,  49)
        let _ProductNum = stringColumn(statement,  50)
        let _OriAuDateTime = stringColumn(statement,  51)
        let _DDCYn = stringColumn(statement,  52)
        let _EDCYn = stringColumn(statement,  53)
        let _ICInputType = stringColumn(statement,  54)
        let _EMVTradeType = stringColumn(statement,  55)
        let _PtPointCode = stringColumn(statement,  56)
        let _PtServiceName = stringColumn(statement,  57)
        let _PtEarnPoint = stringColumn(statement,  58)
        let _PtUsePoint = stringColumn(statement,  59)
        let _PtTotalPoint = stringColumn(statement,  60)
        let _PtPercent = stringColumn(statement,  61)
        let _PtUserName = stringColumn(statement,  62)
        let _PtPointStoreNumber = stringColumn(statement,  63)
        let _MemberCardType = stringColumn(statement,  64)
        let _MemberServiceType = stringColumn(statement,  65)
        let _MemberServiceName = stringColumn(statement,  66)
        let _MemberTradeMoney = stringColumn(statement,  67)
        let _MemberSaleMoney = stringColumn(statement,  68)
        let _MemberAfterTradeMoney = stringColumn(statement,  69)
        let _MemberAfterMemberPoint = stringColumn(statement,  70)
        let _MemberOptionCode = stringColumn(statement,  71)
        let _MemberStoreNo = stringColumn(statement,  72)

        // 최종 구조체 생성
        let tradeResult = DBTradeResult(
            id: _id,
            Tid: _Tid,
            StoreName: _storeName,
            StoreAddr: _StoreAddr,
            StoreNumber: _StoreNumber,
            StorePhone: _StorePhone,
            StoreOwner: _StoreOwner,
            Trade: _Trade,
            Cancel: _Cancel,
            Money: _Money,
            GiftAmt: _GiftAmt,
            Tax: _Tax,
            Svc: _Svc,
            Txf: _Txf,
            Inst: _Inst,
            CashTarget: _CashTarget,
            CashInputMethod: _CashInputMethod,
            CashNum: _CashNum,
            CardNum: _CardNum,
            CardType: _CardType,
            CardInpNm: _CardInpNm,
            CardIssuer: _CardIssuer,
            MchNo: _MchNo,
            AuDate: _AuDate,
            OriAuDate: _OriAuDate,
            AuNum: _AuNum,
            OriAuNum: _OriAuNum,
            TradeNo: _TradeNo,
            Message: _Message,
            KakaoMessage: _KakaoMessage,
            PayType: _PayType,
            KakaoAuMoney: _KakaoAuMoney,
            KakaoSaleMoney: _KakaoSaleMoney,
            KakaoMemberCd: _KakaoMemberCd,
            KakaoMemberNo: _KakaoMemberNo,
            Otc: _Otc,
            Pem: _Pem,
            Trid: _Trid,
            CardBin: _CardBin,
            SearchNo: _SearchNo,
            PrintBarcd: _PrintBarcd,
            PrintUse: _PrintUse,
            PrintNm: _PrintNm,
            MchFee: _MchFee,
            MchRefund: _MchRefund,
            PcKind: _PcKind,
            PcCoupon: _PcCoupon,
            PcPoint: _PcPoint,
            PcCard: _PcCard,
            MineTrade: _MineTrade,
            ProductNum: _ProductNum,
            OriAuDateTime: _OriAuDateTime,
            DDCYn: _DDCYn,
            EDCYn: _EDCYn,
            ICInputType: _ICInputType,
            EMVTradeType: _EMVTradeType,
            PtPointCode: _PtPointCode,
            PtServiceName: _PtServiceName,
            PtEarnPoint: _PtEarnPoint,
            PtUsePoint: _PtUsePoint,
            PtTotalPoint: _PtTotalPoint,
            PtPercent: _PtPercent,
            PtUserName: _PtUserName,
            PtPointStoreNumber: _PtPointStoreNumber,
            MemberCardType: _MemberCardType,
            MemberServiceType: _MemberServiceType,
            MemberServiceName: _MemberServiceName,
            MemberTradeMoney: _MemberTradeMoney,
            MemberSaleMoney: _MemberSaleMoney,
            MemberAfterTradeMoney: _MemberAfterTradeMoney,
            MemberAfterMemberPoint: _MemberAfterMemberPoint,
            MemberOptionCode: _MemberOptionCode,
            MemberStoreNo: _MemberStoreNo
        )
        return tradeResult
    }

  
    // MARK: - 여기부터 거래 내역 리스트 가져오기 - 거래내역, 매출정보 에서 사용
    /// 거래 내역 리스트 가져오는 함수 (TID 필터 적용)
    /// - Parameter _tid: 특정 TID (없으면 "")
    /// - Returns: [DBTradeResult] 배열
    func getTradeList(tid _tid: String = "") -> [DBTradeResult] {
        var result: [DBTradeResult] = []
        var queryStatement: OpaquePointer? = nil
        defer { sqlite3_finalize(queryStatement) }

        // 1) TID 후보군 가져오기 (0 ~ 10까지)
        let isTargetBLE = (Utils.getIsBT())
        let prefixKey = isTargetBLE ? define.STORE_TID : define.CAT_STORE_TID

        // “tidPlaceholders”는 여러 개 TID를 저장 (빈 문자열 제외)
        var tidList: [String] = []
        for i in 0...10 {
            let key = (i == 0) ? prefixKey : "\(prefixKey)\(i)"
            let val = Setting.shared.getDefaultUserData(_key: key)
            if !val.isEmpty {
                tidList.append(val)
            }
        }
        
        // 추가로, 함수 인자로 전달된 _tid가 있을 경우 우선순위로 사용
        // (원래 코드에서는 “_tid != ''” 시 단일 TID만 쓰므로, 아래처럼 조건화)
        var bindValues: [String] = []
        
        let whereClause: String
        if !_tid.isEmpty {
            // “TID = ? OR TID = ''”
            whereClause = "(Tid = ? OR Tid = '')"
            bindValues = [_tid]
        }
        else if !tidList.isEmpty {
            // 여러 TID(OR 연결) + "Tid = ''"
            // 예: "(Tid = ? OR Tid = ? OR ... OR Tid = '')"
            //    bindValues = ["xxx", "yyy", ...]
            
            // tidList 만약 1개라도 있으면 => (Tid = ?) OR (Tid = ?)...
            // 마지막에 OR Tid = '' 추가
            // 예) tidList.count = 3 => "Tid=? OR Tid=? OR Tid=? OR Tid=''"
            let tidPlaceholders = tidList.map { _ in "Tid = ?" }.joined(separator: " OR ")
            whereClause = "(\(tidPlaceholders) OR Tid = '')"
            bindValues = tidList
        }
        else {
            // 예외: TID가 하나도 없는 경우 => 조회 불가
            debugPrint("Error: No valid TID values. Return empty.")
            return result
        }

        // 2) 최종 쿼리 작성
        let query = """
            SELECT *
            FROM \(define.DB_Trade)
            WHERE \(whereClause)
            ORDER BY id DESC
        """
        
        // 3) prepare
        guard sqlite3_prepare_v2(db_point, query, -1, &queryStatement, nil) == SQLITE_OK else {
            var errMsg: String
            if let cString = sqlite3_errmsg(db_point) {
                // cString 이 nil 이 아닐 경우
                errMsg = String(cString: cString)
            } else {
                // cString 이 nil 일 경우
                errMsg = "No error message"
            }
            debugPrint("SELECT statement prepare failed: \(errMsg)")
            return result
        }
        
        // 4) 파라미터 바인딩
//        for (index, value) in bindValues.enumerated() {
//            sqlite3_bind_text(queryStatement, Int32(index + 1), value, -1, nil)
//        }
        
        // 한 줄짜리 유틸 함수로 빼도 좋지만, 여기서는 직접 바인딩
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(queryStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding string failed: \(errMsg)")
                    return result
                }
            case let intValue as Int:
                if sqlite3_bind_int(queryStatement, position, Int32(intValue)) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding int failed: \(errMsg)")
                    return result
                }
            default:
                // 필요한 경우 Double, etc. 로 확장 가능
                let stringValue = "\(value)"
                if sqlite3_bind_text(queryStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding unknown type failed: \(errMsg)")
                    return result
                }
            }
        }
        
        // 5) step
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            // 여기서 0~72번 컬럼을 꺼내서 DBTradeResult를 구성
            let tradeResult = mapDBTradeResult(queryStatement!)
            // “(C)” 여부 필터링 (원본 코드와 동일)
            if isTargetBLE && tradeResult.Trade.contains("(C)") {
                continue
            } else if !isTargetBLE && !tradeResult.Trade.contains("(C)") {
                continue
            }
            result.append(tradeResult)
        }
        
        return result
    }

    /// 기간/거래타입 등 조건으로 거래 내역을 조회하는 함수
    func getTradeListByFilter(
        tid: String,
        fromDate: String?,
        toDate: String?,
        tradeMethods: [String]?
    ) -> [DBTradeResult] {
        var result = [DBTradeResult]()
        var statement: OpaquePointer? = nil
        var bindValues: [String] = []
        var whereClauses: [String] = []
        
        // TID 조건: tid가 비어있지 않으면 (Tid = ? OR Tid = '')
        if !tid.isEmpty {
            whereClauses.append("(Tid = ? OR Tid = '')")
            bindValues.append(tid)
        }
        
        // 날짜 범위 조건
        if let fd = fromDate, !fd.isEmpty,
           let td = toDate, !td.isEmpty {
            whereClauses.append("(AuDate >= ? AND AuDate <= ?)")
            bindValues.append(fd)
            bindValues.append(td)
        }
        
        // 거래타입 조건: 각 항목에 대해 LIKE 조건을 추가
        if let tm = tradeMethods, !tm.isEmpty {
            let methodClause = tm.map { _ in "Trade LIKE ?" }.joined(separator: " OR ")
            whereClauses.append("(\(methodClause))")
            for method in tm {
                bindValues.append("%\(method)%")
            }
        }
        
        let whereClause = whereClauses.isEmpty ? "" : "WHERE " + whereClauses.joined(separator: " AND ")
        
        let query = """
            SELECT *
            FROM \(define.DB_Trade)
            \(whereClause)
            ORDER BY id DESC
        """
        
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("getTradeListByFilter - prepare failed")
            return result
        }
        
//        for (index, value) in bindValues.enumerated() {
//            sqlite3_bind_text(statement, Int32(index + 1), value, -1, nil)
//        }
        
        // 한 줄짜리 유틸 함수로 빼도 좋지만, 여기서는 직접 바인딩
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(statement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding string failed: \(errMsg)")
                    return result
                }
            case let intValue as Int:
                if sqlite3_bind_int(statement, position, Int32(intValue)) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding int failed: \(errMsg)")
                    return result
                }
            default:
                // 필요한 경우 Double, etc. 로 확장 가능
                let stringValue = "\(value)"
                if sqlite3_bind_text(statement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding unknown type failed: \(errMsg)")
                    return result
                }
            }
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let row = mapDBTradeResult(statement!)
            result.append(row)
        }
        
        defer { sqlite3_finalize(statement) }
        return result
    }


    /// 기간별 거래 내역 조회 함수 (TID가 빈 경우 날짜 조건만 적용)
    func getTradeListPeriod(Tid _tid: String = "", from _fdate: String, to _tdate: String) -> [DBTradeResult] {
        let fromDate = _fdate + "000000"
        let toDate = _tdate + "235959"
        return getTradeListByFilter(tid: _tid, fromDate: fromDate, toDate: toDate, tradeMethods: nil)
    }
    
    ///거래 내역 기간별 조회
//    func getTradeListPeriod(Tid _tid:String = "", from _fdate:String,to _tdate:String ) -> [DBTradeResult] {
//        var result:[DBTradeResult] = Array()
//        let fromDate:String = _fdate + "000000"
//        let toDate:String = _tdate +  "235959"
//        
//        var queryStatementString = ""
//        if _tid != "" {
//            queryStatementString = "SELECT * FROM \(define.DB_Trade) where (Tid = '\(_tid)' OR Tid = '')  AND (cast(AuDate as long) > \(fromDate)) AND (cast(AuDate as long) < \(toDate)) ORDER BY id DESC"
//        }
//        else {
//            queryStatementString = "SELECT * FROM \(define.DB_Trade) where (cast(AuDate as long) > \(fromDate)) AND (cast(AuDate as long) < \(toDate)) ORDER BY id DESC"
//        }
//        
//
//        var queryStatement: OpaquePointer? = nil
//        guard sqlite3_prepare_v2(db_point, queryStatementString, EOF, &queryStatement, nil) == SQLITE_OK else {
//            debugPrint("SELECT statement could not be prepared")
//            return result
//        }
//        
//        // 실행 및 결과 매핑
//        while sqlite3_step(queryStatement) == SQLITE_ROW {
//            let row = mapDBTradeResult(queryStatement!)
//            result.append(row)
//        }
//
//        sqlite3_finalize(queryStatement)
//        return result
//    }
    
    func getTradeListParsingData(Tid _tid: String = "",
                                   결제구분 _trade: define.TradeMethod,
                                   from _fdate: String,
                                   to _tdate: String) -> [DBTradeResult] {
        var fromDate: String = ""
        if !_fdate.isEmpty {
            fromDate = _fdate + "000000"
        }
        var toDate: String = ""
        if !_tdate.isEmpty {
            toDate = _tdate + "235959"
        }
        
        var result: [DBTradeResult] = []
        var queryStatementString = ""
        var bindValues: [String] = []
        
        // 분기별 쿼리 작성
        if _trade == define.TradeMethod.EasyPay {
            if _tdate.isEmpty {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(define.TradeMethod.Kakao.rawValue)
                    bindValues.append(define.TradeMethod.Zero.rawValue)
                    bindValues.append(define.TradeMethod.Wechat.rawValue)
                    bindValues.append(define.TradeMethod.Ali.rawValue)
                    bindValues.append(define.TradeMethod.AppCard.rawValue)
                    bindValues.append(define.TradeMethod.EmvQr.rawValue)
                    bindValues.append(define.TradeMethod.CAT_App.rawValue)
                    bindValues.append(define.TradeMethod.CAT_We.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Ali.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Zero.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Payco.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Kakao.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(define.TradeMethod.Kakao.rawValue)
                    bindValues.append(define.TradeMethod.Zero.rawValue)
                    bindValues.append(define.TradeMethod.Wechat.rawValue)
                    bindValues.append(define.TradeMethod.Ali.rawValue)
                    bindValues.append(define.TradeMethod.AppCard.rawValue)
                    bindValues.append(define.TradeMethod.EmvQr.rawValue)
                    bindValues.append(define.TradeMethod.CAT_App.rawValue)
                    bindValues.append(define.TradeMethod.CAT_We.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Ali.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Zero.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Payco.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Kakao.rawValue)
                }
            } else {  // _tdate is not empty
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (AuDate >= ? AND AuDate <= ?)
                    AND (
                      (Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ?)
                      OR
                      (Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ?)
                    )
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    // 첫 그룹 (6개)
                    bindValues.append(define.TradeMethod.Kakao.rawValue)
                    bindValues.append(define.TradeMethod.Zero.rawValue)
                    bindValues.append(define.TradeMethod.Wechat.rawValue)
                    bindValues.append(define.TradeMethod.Ali.rawValue)
                    bindValues.append(define.TradeMethod.AppCard.rawValue)
                    bindValues.append(define.TradeMethod.EmvQr.rawValue)
                    // 두 번째 그룹 (6개)
                    bindValues.append(define.TradeMethod.CAT_App.rawValue)
                    bindValues.append(define.TradeMethod.CAT_We.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Ali.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Zero.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Payco.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Kakao.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (AuDate >= ? AND AuDate <= ?)
                    AND (
                      (Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ?)
                      OR
                      (Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ? OR Trade LIKE ?)
                    )
                    ORDER BY id DESC
                    """
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.Kakao.rawValue)
                    bindValues.append(define.TradeMethod.Zero.rawValue)
                    bindValues.append(define.TradeMethod.Wechat.rawValue)
                    bindValues.append(define.TradeMethod.Ali.rawValue)
                    bindValues.append(define.TradeMethod.AppCard.rawValue)
                    bindValues.append(define.TradeMethod.EmvQr.rawValue)
                    bindValues.append(define.TradeMethod.CAT_App.rawValue)
                    bindValues.append(define.TradeMethod.CAT_We.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Ali.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Zero.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Payco.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Kakao.rawValue)
                }
            }
        } else if _trade == define.TradeMethod.NULL {
            if _tdate.isEmpty {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                } else {
                    queryStatementString = "SELECT * FROM \(define.DB_Trade) ORDER BY id DESC"
                }
            } else {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (AuDate >= ? AND AuDate <= ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (AuDate >= ? AND AuDate <= ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                }
            }
        } else if _trade == define.TradeMethod.Credit {
            if _tdate.isEmpty {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(define.TradeMethod.Credit.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Credit.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(define.TradeMethod.Credit.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Credit.rawValue)
                }
            } else {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.Credit.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Credit.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.Credit.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Credit.rawValue)
                }
            }
        } else if _trade == define.TradeMethod.Cash {
            if _tdate.isEmpty {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(define.TradeMethod.Cash.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Cash.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(define.TradeMethod.Cash.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Cash.rawValue)
                }
            } else {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.Cash.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Cash.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ? OR Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.Cash.rawValue)
                    bindValues.append(define.TradeMethod.CAT_Cash.rawValue)
                }
            }
        } else if _trade == define.TradeMethod.CAT_CashIC {
            if _tdate.isEmpty {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(define.TradeMethod.CAT_CashIC.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(define.TradeMethod.CAT_CashIC.rawValue)
                }
            } else {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.CAT_CashIC.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(define.TradeMethod.CAT_CashIC.rawValue)
                }
            }
        } else {
            // 그 외의 경우
            if _tdate.isEmpty {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(_trade.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_trade.rawValue)
                }
            } else {
                if _tid != "" {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (Tid = ? OR Tid = '')
                    AND (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(_tid)
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(_trade.rawValue)
                } else {
                    queryStatementString = """
                    SELECT * FROM \(define.DB_Trade)
                    WHERE (AuDate >= ? AND AuDate <= ?)
                    AND (Trade LIKE ?)
                    ORDER BY id DESC
                    """
                    bindValues.append(fromDate)
                    bindValues.append(toDate)
                    bindValues.append(_trade.rawValue)
                }
            }
        }
        
        var queryStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db_point, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK else {
            debugPrint("SELECT statement could not be prepared")
            return result
        }
        
        // 바인딩 처리
//        for (index, value) in bindValues.enumerated() {
//            sqlite3_bind_text(queryStatement, Int32(index + 1), (value as NSString).utf8String, -1, nil)
//        }
        
        // 한 줄짜리 유틸 함수로 빼도 좋지만, 여기서는 직접 바인딩
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(queryStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding string failed: \(errMsg)")
                    return result
                }
            case let intValue as Int:
                if sqlite3_bind_int(queryStatement, position, Int32(intValue)) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding int failed: \(errMsg)")
                    return result
                }
            default:
                // 필요한 경우 Double, etc. 로 확장 가능
                let stringValue = "\(value)"
                if sqlite3_bind_text(queryStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding unknown type failed: \(errMsg)")
                    return result
                }
            }
        }
        
        
        // 쿼리 실행 및 결과 매핑
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let row = mapDBTradeResult(queryStatement!)
            result.append(row)
        }
        
        sqlite3_finalize(queryStatement)
        return result
    }
    
    /// 마지막 거래 내역 데이터 가져 오는 함수
    func getTradeLastData(tid _tid: String = "") -> DBTradeResult {
        var result = DBTradeResult()
        
        var query = "SELECT * FROM \(define.DB_Trade)"
        var whereClauses: [String] = []
        var bindValues: [String] = []
        
        // 1) TID가 있으면 “Tid=? OR Tid=''”
        //    없으면 Setting에서 CAT/BLE TID 여러개 로 OR 구성
        if !_tid.isEmpty {
            whereClauses.append("(Tid = ? OR Tid = '')")
            bindValues.append(_tid)
        } else {
            // 다수 TID from Setting
            let isBLE = (Utils.getIsBT())
            let prefix = isBLE ? define.STORE_TID : define.CAT_STORE_TID
            
            var tidList: [String] = []
            for i in 0...10 {
                let key = (i == 0) ? prefix : "\(prefix)\(i)"
                let val = Setting.shared.getDefaultUserData(_key: key)
                if !val.isEmpty {
                    tidList.append(val)
                }
            }
            if !tidList.isEmpty {
                // (Tid=? OR Tid=? OR ... OR Tid='')
                let placeholders = tidList.map { _ in "Tid=?" }.joined(separator: " OR ")
                let clause = "(\(placeholders) OR Tid='')"
                whereClauses.append(clause)
                bindValues.append(contentsOf: tidList)
            }
        }
        
        // 2) WHERE 절 조합
        if !whereClauses.isEmpty {
            query += " WHERE " + whereClauses.joined(separator: " AND ")
        }
        
        // 3) ORDER BY + LIMIT
        query += " ORDER BY AuDate DESC LIMIT 1"
        
        // prepare
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("getTradeLastData - prepare failed")
            return result
        }
        
        // bind
//        for (index, val) in bindValues.enumerated() {
//            sqlite3_bind_text(statement, Int32(index + 1), val, -1, nil)
//        }
        // 한 줄짜리 유틸 함수로 빼도 좋지만, 여기서는 직접 바인딩
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(statement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding string failed: \(errMsg)")
                    return result
                }
            case let intValue as Int:
                if sqlite3_bind_int(statement, position, Int32(intValue)) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding int failed: \(errMsg)")
                    return result
                }
            default:
                // 필요한 경우 Double, etc. 로 확장 가능
                let stringValue = "\(value)"
                if sqlite3_bind_text(statement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding unknown type failed: \(errMsg)")
                    return result
                }
            }
        }
        
        // step
        if sqlite3_step(statement) == SQLITE_ROW {
            result = mapDBTradeResult(statement!)
        }
        
        return result
    }
    
    // MARK: - 여기부터 가맹점 등록 시 포인트관련 데이터를 저장하기 위한 함수. 포인트관련만 저장해도 되는데 그냥 몇몇 정보도 같이 저장
    
    /// DB_Store 테이블에 가맹점 정보를 1건만 유지하도록 하는 Upsert 함수
    ///
    /// - Parameters:
    ///   - _AsNum: A/S번호
    ///   - _ShpNm: 상점 이름
    ///   - _Tid:   단말TID
    ///   - ... (이하 생략)
    /// - Returns: 성공 여부 (Bool)
    func upsertStore(AsNum _AsNum:String,
                     ShpNm _ShpNm:String,
                     Tid _Tid:String,
                     BsnNo _BsnNo:String,
                     PreNm _PreNm:String,
                     ShpAdr _ShpAdr:String,
                     ShpTel _ShpTel:String,
                     PointCount _PointCount:String,
                     PointInfo _PointInfo:String,
                     MchData _MchData:String) -> Bool {
        // 1) DB_Store에 현재 레코드가 몇 개 있는지 확인
           let storeCount = getStoreCount()
        
        if storeCount == 0 {
                // 2) 없으면 => INSERT
                return insertStore(
                    AsNum: _AsNum,
                    ShpNm: _ShpNm,
                    Tid: _Tid,
                    BsnNo: _BsnNo,
                    PreNm: _PreNm,
                    ShpAdr: _ShpAdr,
                    ShpTel: _ShpTel,
                    PointCount: _PointCount,
                    PointInfo: _PointInfo,
                    MchData: _MchData
                )
            } else {
                // 3) 1건 이상 있으면 => 그 중 첫 번째(또는 id가 가장 작은) 레코드를 UPDATE
                return updateStore(
                    AsNum: _AsNum,
                    ShpNm: _ShpNm,
                    Tid: _Tid,
                    BsnNo: _BsnNo,
                    PreNm: _PreNm,
                    ShpAdr: _ShpAdr,
                    ShpTel: _ShpTel,
                    PointCount: _PointCount,
                    PointInfo: _PointInfo,
                    MchData: _MchData
                )
            }
    }
    
    /// DB_Store 테이블의 레코드 개수를 반환
    private func getStoreCount() -> Int {
        let query = "SELECT COUNT(*) FROM \(define.DB_Store);"
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("getStoreCount - prepare 실패")
            return 0
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            debugPrint("getStoreCount - step 실패")
            return 0
        }
        
        return Int(sqlite3_column_int(statement, 0))
    }
    
    /// 가맹점 정보 INSERT (새 레코드 추가)
    ///
    /// - Returns: 성공 여부
    private func insertStore(AsNum _AsNum:String,
                             ShpNm _ShpNm:String,
                             Tid _Tid:String,
                             BsnNo _BsnNo:String,
                             PreNm _PreNm:String,
                             ShpAdr _ShpAdr:String,
                             ShpTel _ShpTel:String,
                             PointCount _PointCount:String,
                             PointInfo _PointInfo:String,
                             MchData _MchData:String
    ) -> Bool {
        let insertQuery = """
            INSERT INTO \(define.DB_Store)
            (AsNum, ShpNm, Tid, BsnNo, PreNm, ShpAdr, ShpTel, PointCount, PointInfo, MchData)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_prepare_v2(db_point, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("가맹점 정보 Insert 준비 실패")
            return false
        }
        
        // 바인딩
        sqlite3_bind_text(statement, 1, _AsNum, -1, nil)
        sqlite3_bind_text(statement, 2, _ShpNm, -1, nil)
        sqlite3_bind_text(statement, 3, _Tid,  -1, nil)
        sqlite3_bind_text(statement, 4, _BsnNo, -1, nil)
        sqlite3_bind_text(statement, 5, _PreNm, -1, nil)
        sqlite3_bind_text(statement, 6, _ShpAdr, -1, nil)
        sqlite3_bind_text(statement, 7, _ShpTel, -1, nil)
        sqlite3_bind_text(statement, 8, _PointCount, -1, nil)
        sqlite3_bind_text(statement, 9, _PointInfo, -1, nil)
        sqlite3_bind_text(statement, 10, _MchData, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            debugPrint("가맹점 정보 Insert 성공")
            return true
        } else {
            debugPrint("가맹점 정보 Insert 실패")
            return false
        }
    }
    
    /// 기존 가맹점 정보(첫 번째 레코드)를 UPDATE
    ///
    /// - Returns: 성공 여부
    private func updateStore(AsNum _AsNum:String,
                             ShpNm _ShpNm:String,
                             Tid _Tid:String,
                             BsnNo _BsnNo:String,
                             PreNm _PreNm:String,
                             ShpAdr _ShpAdr:String,
                             ShpTel _ShpTel:String,
                             PointCount _PointCount:String,
                             PointInfo _PointInfo:String,
                             MchData _MchData:String
    ) -> Bool {
        // rowid가 가장 작은 레코드(혹은 id)가 가장 작은 레코드)를 1건만 업데이트
        // - SQLite는 "UPDATE ~ WHERE rowid = (SELECT MIN(rowid) ... )" 형식 등으로 가능
        // - 만약 "id INTEGER PRIMARY KEY AUTOINCREMENT"라면, "id = (SELECT MIN(id) FROM ...)" 로도 가능
        let updateQuery = """
            UPDATE \(define.DB_Store)
            SET AsNum=?,
                ShpNm=?,
                Tid=?,
                BsnNo=?,
                PreNm=?,
                ShpAdr=?,
                ShpTel=?,
                PointCount=?,
                PointInfo=?,
                MchData=?
            WHERE id = (
                SELECT MIN(id)
                FROM \(define.DB_Store)
            );
        """
        
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_prepare_v2(db_point, updateQuery, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("가맹점 정보 Update 준비 실패")
            return false
        }
        
        // 바인딩 (순서 주의!)
        sqlite3_bind_text(statement, 1, _AsNum,      -1, nil)
        sqlite3_bind_text(statement, 2, _ShpNm,      -1, nil)
        sqlite3_bind_text(statement, 3, _Tid,        -1, nil)
        sqlite3_bind_text(statement, 4, _BsnNo,      -1, nil)
        sqlite3_bind_text(statement, 5, _PreNm,      -1, nil)
        sqlite3_bind_text(statement, 6, _ShpAdr,     -1, nil)
        sqlite3_bind_text(statement, 7, _ShpTel,     -1, nil)
        sqlite3_bind_text(statement, 8, _PointCount, -1, nil)
        sqlite3_bind_text(statement, 9, _PointInfo,  -1, nil)
        sqlite3_bind_text(statement, 10, _MchData,   -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            debugPrint("가맹점 정보 Update 성공")
            return true
        } else {
            debugPrint("가맹점 정보 Update 실패")
            return false
        }
    }
    
    /// 가맹점 정보(첫 번째 레코드)를 Dictionary<String,String> 형태로 반환
    /// - Returns: [String:String] (AsNum, ShpNm, Tid, ...)
    func getStoreData() -> [String: String] {
        var result: [String: String] = [:]
        
        // 1) 쿼리 (가장 작은 id 한 건만)
        let selectQuery = """
            SELECT id, AsNum, ShpNm, Tid, BsnNo, PreNm, ShpAdr, ShpTel, PointCount, PointInfo, MchData
            FROM \(define.DB_Store)
            ORDER BY id ASC
            LIMIT 1
        """
        
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_prepare_v2(db_point, selectQuery, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("getStoreData - prepare 실패")
            return result
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            // 컬럼 인덱스
            // 0: id, 1: AsNum, 2: ShpNm, 3: Tid, 4: BsnNo, 5: PreNm, ...
            let colId        = String(cString: sqlite3_column_text(statement, 0))
            let colAsNum     = stringColumn(statement!, 1)
            let colShpNm     = stringColumn(statement!, 2)
            let colTid       = stringColumn(statement!, 3)
            let colBsnNo     = stringColumn(statement!, 4)
            let colPreNm     = stringColumn(statement!, 5)
            let colShpAdr    = stringColumn(statement!, 6)
            let colShpTel    = stringColumn(statement!, 7)
            let colPointCount = stringColumn(statement!, 8)
            let colPointInfo  = stringColumn(statement!, 9)
            let colMchData    = stringColumn(statement!, 10)
            
            result["id"]        = colId
            result["AsNum"]     = colAsNum
            result["ShpNm"]     = colShpNm
            result["Tid"]       = colTid
            result["BsnNo"]     = colBsnNo
            result["PreNm"]     = colPreNm
            result["ShpAdr"]    = colShpAdr
            result["ShpTel"]    = colShpTel
            result["PointCount"] = colPointCount
            result["PointInfo"]  = colPointInfo
            result["MchData"]    = colMchData
        }
        
        return result
    }
    
    // MARK: - 여기부터 앱투앱 거래 insert
    
    /// 앱투앱(AppToApp) 거래 내역 INSERT
    /// - Parameter resultData: [String: String] 형태의 거래정보
    func insertAppToAppData(resultData: [String: String]) {
        // 1) 모든 필드를 꺼내 문자열 정리 (Nil Coalescing + 공백제거)
        //    실제 필드가 매우 많으므로, 로직 중복을 줄이려면 별도 헬퍼 함수를 쓸 수도 있음
        let TrdType         = (resultData["TrdType"] ?? "").trimmingCharacters(in: .whitespaces)
        let TermID          = (resultData["TermID"] ?? "").trimmingCharacters(in: .whitespaces)
        let TrdDate         = (resultData["TrdDate"] ?? Utils.getDate(format:"yyMMdd")).trimmingCharacters(in: .whitespaces)
        let AnsCode         = (resultData["AnsCode"] ?? "").trimmingCharacters(in: .whitespaces)
        let Message         = (resultData["Message"] ?? "").trimmingCharacters(in: .whitespaces)
        let AuNo            = (resultData["AuNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let TradeNo         = (resultData["TradeNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let CardNo          = (resultData["CardNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let Keydate         = (resultData["Keydate"] ?? "").trimmingCharacters(in: .whitespaces)
        let MchData         = (resultData["MchData"] ?? "").trimmingCharacters(in: .whitespaces)
        let CardKind        = (resultData["CardKind"] ?? "").trimmingCharacters(in: .whitespaces)
        let OrdCd           = (resultData["OrdCd"] ?? "").trimmingCharacters(in: .whitespaces)
        let OrdNm           = (resultData["OrdNm"] ?? "").trimmingCharacters(in: .whitespaces)
        let InpCd           = (resultData["InpCd"] ?? "").trimmingCharacters(in: .whitespaces)
        let InpNm           = (resultData["InpNm"] ?? "").trimmingCharacters(in: .whitespaces)
        let DDCYn           = (resultData["DDCYn"] ?? "").trimmingCharacters(in: .whitespaces)
        let EDCYn           = (resultData["EDCYn"] ?? "").trimmingCharacters(in: .whitespaces)
        let GiftAmt         = (resultData["GiftAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let MchNo           = (resultData["MchNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let BillNo          = (resultData["BillNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let DisAmt          = (resultData["DisAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let AuthType        = (resultData["AuthType"] ?? "").trimmingCharacters(in: .whitespaces)
        let AnswerTrdNo     = (resultData["AnswerTrdNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let ChargeAmt       = (resultData["ChargeAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let RefundAmt       = (resultData["RefundAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let QrKind          = (resultData["QrKind"] ?? "").trimmingCharacters(in: .whitespaces)
        let OriAuDate       = (resultData["OriAuDate"] ?? "").trimmingCharacters(in: .whitespaces)
        let OriAuNo         = (resultData["OriAuNo"] ?? "").trimmingCharacters(in: .whitespaces)
        let TrdAmt          = (resultData["TrdAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let TaxAmt          = (resultData["TaxAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let SvcAmt          = (resultData["SvcAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let TaxFreeAmt      = (resultData["TaxFreeAmt"] ?? "").trimmingCharacters(in: .whitespaces)
        let Month           = (resultData["Month"] ?? "").trimmingCharacters(in: .whitespaces)
        let PcKind          = (resultData["PcKind"] ?? "").trimmingCharacters(in: .whitespaces)
        let PcCoupon        = (resultData["PcCoupon"] ?? "").trimmingCharacters(in: .whitespaces)
        let PcPoint         = (resultData["PcPoint"] ?? "").trimmingCharacters(in: .whitespaces)
        let PcCard          = (resultData["PcCard"] ?? "").trimmingCharacters(in: .whitespaces)
        let MineTrade       = (resultData["MineTrade"] ?? "").trimmingCharacters(in: .whitespaces)
        let ProductNum      = (resultData["ProductNum"] ?? "").trimmingCharacters(in: .whitespaces)
        let OriAuDateTime   = (resultData["OriAuDateTime"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtPointCode     = (resultData["PtPointCode"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtServiceName   = (resultData["PtServiceName"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtEarnPoint     = (resultData["PtEarnPoint"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtUsePoint      = (resultData["PtUsePoint"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtTotalPoint    = (resultData["PtTotalPoint"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtPercent       = (resultData["PtPercent"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtUserName      = (resultData["PtUserName"] ?? "").trimmingCharacters(in: .whitespaces)
        let PtPointStoreNumber = (resultData["PtPointStoreNumber"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberCardType  = (resultData["MemberCardType"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberServiceType = (resultData["MemberServiceType"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberServiceName = (resultData["MemberServiceName"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberTradeMoney = (resultData["MemberTradeMoney"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberSaleMoney  = (resultData["MemberSaleMoney"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberAfterTradeMoney  = (resultData["MemberAfterTradeMoney"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberAfterMemberPoint = (resultData["MemberAfterMemberPoint"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberOptionCode = (resultData["MemberOptionCode"] ?? "").trimmingCharacters(in: .whitespaces)
        let MemberStoreNo    = (resultData["MemberStoreNo"] ?? "").trimmingCharacters(in: .whitespaces)
        
        // 2) INSERT 쿼리 작성 (파라미터 바인딩 방식)
        //    테이블: define.DB_AppToApp
        //    컬럼  : (TrdType, TermID, TrdDate, AnsCode, ..., MemberStoreNo)
        //    placeholder 개수: 필드 개수에 맞춰서
        let insertQuery = """
            INSERT INTO \(define.DB_AppToApp)
            (TrdType,TermID,TrdDate,AnsCode,Message,AuNo,TradeNo,CardNo,Keydate,MchData,CardKind,OrdCd,OrdNm,InpCd,InpNm,DDCYn,EDCYn,GiftAmt,MchNo,BillNo,DisAmt,AuthType,AnswerTrdNo,ChargeAmt,RefundAmt,QrKind,OriAuDate,OriAuNo,TrdAmt,TaxAmt,SvcAmt,TaxFreeAmt,Month,PcKind,PcCoupon,PcPoint,PcCard,MineTrade,ProductNum,OriAuDateTime,PtPointCode,PtServiceName,PtEarnPoint,PtUsePoint,PtTotalPoint,PtPercent,PtUserName,PtPointStoreNumber,MemberCardType,MemberServiceType,MemberServiceName,MemberTradeMoney,MemberSaleMoney,MemberAfterTradeMoney,MemberAfterMemberPoint,MemberOptionCode,MemberStoreNo)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var insertStatement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        // 3) prepare
        guard sqlite3_prepare_v2(db_point, insertQuery, -1, &insertStatement, nil) == SQLITE_OK else {
            debugPrint("앱투앱 거래내역 INSERT 준비 실패")
            return
        }
        
        // 4) 바인딩할 값들 (순서 중요!)
        let bindValues: [String] = [
            TrdType, TermID, TrdDate, AnsCode, Message, AuNo, TradeNo, CardNo, Keydate,
            MchData, CardKind, OrdCd, OrdNm, InpCd, InpNm, DDCYn, EDCYn, GiftAmt, MchNo, BillNo,
            DisAmt, AuthType, AnswerTrdNo, ChargeAmt, RefundAmt, QrKind, OriAuDate, OriAuNo,
            TrdAmt, TaxAmt, SvcAmt, TaxFreeAmt, Month, PcKind, PcCoupon, PcPoint, PcCard,
            MineTrade, ProductNum, OriAuDateTime, PtPointCode, PtServiceName, PtEarnPoint,
            PtUsePoint, PtTotalPoint, PtPercent, PtUserName, PtPointStoreNumber,
            MemberCardType, MemberServiceType, MemberServiceName, MemberTradeMoney,
            MemberSaleMoney, MemberAfterTradeMoney, MemberAfterMemberPoint,
            MemberOptionCode, MemberStoreNo
        ]
        
        // 5) 실제 바인딩 (SQLite에서는 문자열은 text로 바인딩)
        //    bindValues.count == 58 이어야 함
//        for (index, value) in bindValues.enumerated() {
//            let position = Int32(index + 1)
//            sqlite3_bind_text(insertStatement, position, value, -1, nil)
//        }
        
        // 한 줄짜리 유틸 함수로 빼도 좋지만, 여기서는 직접 바인딩
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        for (index, value) in bindValues.enumerated() {
            let position = Int32(index + 1)
            
            switch value {
            case let stringValue as String:
                if sqlite3_bind_text(insertStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding string failed: \(errMsg)")
                    return
                }
            case let intValue as Int:
                if sqlite3_bind_int(insertStatement, position, Int32(intValue)) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding int failed: \(errMsg)")
                    return
                }
            default:
                // 필요한 경우 Double, etc. 로 확장 가능
                let stringValue = "\(value)"
                if sqlite3_bind_text(insertStatement, position, stringValue, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    var errMsg: String
                    if let cString = sqlite3_errmsg(db_point) {
                        // cString 이 nil 이 아닐 경우
                        errMsg = String(cString: cString)
                    } else {
                        // cString 이 nil 일 경우
                        errMsg = "No error message"
                    }
                    print("Binding unknown type failed: \(errMsg)")
                    return
                }
            }
        }
        
        // 6) 실행
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            debugPrint("앱투앱 거래내역 INSERT 성공")
        } else {
            debugPrint("앱투앱 거래내역 INSERT 실패")
        }
    }
    
    /// 앱투앱 거래 1건 조회
    ///
    /// - Parameters:
    ///   - _tid:    TermID
    ///   - _audate: 날짜 (yyMMdd 형태)
    ///   - _billno: 전표번호
    /// - Returns: [String: String] (조회 결과)
    func getAppToAppTrade(TermId _tid: String, AuDate _audate: String, BillNo _billno: String) -> [String: String] {
        var result: [String: String] = [:]
        
        // 1) 쿼리 (파라미터 바인딩: BillNo=?, TermID=?, TrdDate LIKE ?)
        let query = """
            SELECT *
            FROM \(define.DB_AppToApp)
            WHERE BillNo = ?
              AND TermID = ?
              AND TrdDate LIKE ?
        """
        
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        
        // 2) prepare
        guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
            debugPrint("앱투앱 거래내역 SELECT 준비 실패")
            result["Message"] = "거래 내역이 존재하지 않습니다"
            return result
        }
        
        // 3) 바인딩
        //    TrdDate LIKE '\( _audate )%' 형태 => Swift 에서는 "\(audate)%"
        sqlite3_bind_text(statement, 1, _billno, -1, nil)
        sqlite3_bind_text(statement, 2, _tid, -1, nil)
        let dateLike = "\(_audate)%"
        sqlite3_bind_text(statement, 3, dateLike, -1, nil)
        
        // 4) step => row 추출
        while sqlite3_step(statement) == SQLITE_ROW {
            // 각 컬럼을 하나씩 가져옴
            // (앱투앱 테이블: id(0), TrdType(1), TermID(2), TrdDate(3), ... MemberStoreNo(57))
            
            let TrdType = stringColumn(statement!, 1)
            let TermID  = stringColumn(statement!, 2)
            let TrdDate = stringColumn(statement!, 3)
            let AnsCode = stringColumn(statement!, 4)
            let Message = stringColumn(statement!, 5)
            let AuNo    = stringColumn(statement!, 6)
            let TradeNo = stringColumn(statement!, 7)
            
            // CardNo 추출 후 파싱
            var CardNo  = stringColumn(statement!, 8)
            // (원본 코드에서 TrdType "A15"/"A25"면 신용, "B15"/"B25"면 현금, 그 외 간편)
            if TrdType == "A15" || TrdType == "A25" {
                CardNo = Utils.CardParser(카드번호: CardNo, 날짜90일경과: true)
            } else if TrdType == "B15" || TrdType == "B25" {
                CardNo = Utils.CashParser(현금영수증번호: CardNo, 날짜90일경과: true)
            } else {
                CardNo = Utils.EasyParser(바코드qr번호: CardNo, 날짜90일경과: true)
            }
            
            let Keydate = stringColumn(statement!, 9)
            let MchData = stringColumn(statement!, 10)
            let CardKind = stringColumn(statement!, 11)
            let OrdCd   = stringColumn(statement!, 12)
            let OrdNm   = stringColumn(statement!, 13)
            let InpCd   = stringColumn(statement!, 14)
            let InpNm   = stringColumn(statement!, 15)
            let DDCYn   = stringColumn(statement!, 16)
            let EDCYn   = stringColumn(statement!, 17)
            let GiftAmt = stringColumn(statement!, 18)
            let MchNo   = stringColumn(statement!, 19)
            let BillNo  = stringColumn(statement!, 20)
            let DisAmt  = stringColumn(statement!, 21)
            let AuthType = stringColumn(statement!, 22)
            let AnswerTrdNo = stringColumn(statement!, 23)
            let ChargeAmt   = stringColumn(statement!, 24)
            let RefundAmt   = stringColumn(statement!, 25)
            let QrKind      = stringColumn(statement!, 26)
            let OriAuDate   = stringColumn(statement!, 27)
            let OriAuNo     = stringColumn(statement!, 28)
            let TrdAmt      = stringColumn(statement!, 29)
            let TaxAmt      = stringColumn(statement!, 30)
            let SvcAmt      = stringColumn(statement!, 31)
            let TaxFreeAmt  = stringColumn(statement!, 32)
            let Month       = stringColumn(statement!, 33)
            
            let PcKind      = stringColumn(statement!, 34)
            let PcCoupon    = stringColumn(statement!, 35)
            let PcPoint     = stringColumn(statement!, 36)
            let PcCard      = stringColumn(statement!, 37)
            
            // let MineTrade   = stringColumn(statement!, 38)
            // let ProductNum  = stringColumn(statement!, 39)
            // let OriAuDateTime = stringColumn(statement!, 40)
            
            let PtPointCode = stringColumn(statement!, 41)
            let PtServiceName = stringColumn(statement!, 42)
            let PtEarnPoint   = stringColumn(statement!, 43)
            let PtUsePoint    = stringColumn(statement!, 44)
            let PtTotalPoint  = stringColumn(statement!, 45)
            let PtPercent     = stringColumn(statement!, 46)
            let PtUserName    = stringColumn(statement!, 47)
            let PtPointStoreNumber = stringColumn(statement!, 48)
            let MemberCardType     = stringColumn(statement!, 49)
            let MemberServiceType  = stringColumn(statement!, 50)
            let MemberServiceName  = stringColumn(statement!, 51)
            let MemberTradeMoney   = stringColumn(statement!, 52)
            let MemberSaleMoney    = stringColumn(statement!, 53)
            let MemberAfterTradeMoney = stringColumn(statement!, 54)
            let MemberAfterMemberPoint = stringColumn(statement!, 55)
            let MemberOptionCode   = stringColumn(statement!, 56)
            let MemberStoreNo      = stringColumn(statement!, 57)
            
            // 5) Dictionary에 담기
            result["TrdType"] = TrdType
            result["TermID"]  = TermID
            result["TrdDate"] = TrdDate
            result["AnsCode"] = AnsCode
            result["Message"] = Message
            result["AuNo"] = AuNo
            result["TradeNo"] = TradeNo
            result["CardNo"]  = CardNo
            result["Keydate"] = Keydate
            result["MchData"] = MchData
            result["CardKind"] = CardKind
            result["OrdCd"] = OrdCd
            result["OrdNm"] = OrdNm
            result["InpCd"] = InpCd
            result["InpNm"] = InpNm
            result["DDCYn"] = DDCYn
            result["EDCYn"] = EDCYn
            result["GiftAmt"] = GiftAmt
            result["MchNo"] = MchNo
            result["BillNo"] = BillNo
            result["DisAmt"] = DisAmt
            result["AuthType"] = AuthType
            result["AnswerTrdNo"] = AnswerTrdNo
            result["ChargeAmt"]   = ChargeAmt
            result["RefundAmt"]   = RefundAmt
            result["QrKind"]      = QrKind
            result["OriAuDate"]   = OriAuDate
            result["OriAuNo"]     = OriAuNo
            result["TrdAmt"]      = TrdAmt
            result["TaxAmt"]      = TaxAmt
            result["SvcAmt"]      = SvcAmt
            result["TaxFreeAmt"]  = TaxFreeAmt
            result["Month"]       = Month
            result["PcKind"]      = PcKind
            result["PcCoupon"]    = PcCoupon
            result["PcPoint"]     = PcPoint
            result["PcCard"]      = PcCard
            
            result["PtPointCode"] = PtPointCode
            result["PtServiceName"] = PtServiceName
            result["PtEarnPoint"]   = PtEarnPoint
            result["PtUsePoint"]    = PtUsePoint
            result["PtTotalPoint"]  = PtTotalPoint
            result["PtPercent"]     = PtPercent
            result["PtUserName"]    = PtUserName
            result["PtPointStoreNumber"] = PtPointStoreNumber
            result["MemberCardType"]    = MemberCardType
            result["MemberServiceType"] = MemberServiceType
            result["MemberServiceName"] = MemberServiceName
            result["MemberTradeMoney"]  = MemberTradeMoney
            result["MemberSaleMoney"]   = MemberSaleMoney
            result["MemberAfterTradeMoney"] = MemberAfterTradeMoney
            result["MemberAfterMemberPoint"] = MemberAfterMemberPoint
            result["MemberOptionCode"]  = MemberOptionCode
            result["MemberStoreNo"]     = MemberStoreNo
        }
        
        return result
    }

    /// 앱투앱(AppToApp) 거래가 존재하는지 체크
    /// - Parameters:
    ///   - _tid: TermID
    ///   - _billNo: 전표번호(BillNo)
    ///   - _audate: 날짜(yyMMdd 형태)
    /// - Returns: Bool (존재하면 true, 없으면 false)
    func checkAppToAppList(TermID _tid: String, BillNo _billNo: String, AuDate _audate: String) -> Bool {
        var result = false
           
           // 1) 쿼리 (파라미터 바인딩 사용)
           //    TrdDate LIKE ?
           //    LIMIT 1 로 첫 레코드만 확인
           let query = """
               SELECT 1
               FROM \(define.DB_AppToApp)
               WHERE TermID = ?
                 AND BillNo = ?
                 AND TrdDate LIKE ?
               LIMIT 1
           """
           
           var statement: OpaquePointer? = nil
           defer {
               // 함수 끝나면 finalize
               sqlite3_finalize(statement)
           }
           
           // 2) prepare
           guard sqlite3_prepare_v2(db_point, query, -1, &statement, nil) == SQLITE_OK else {
               debugPrint("SELECT statement could not be prepared in checkAppToAppList()")
               return result
           }
           
           // 3) 바인딩
           //    TrdDate LIKE '\(_audate)%'
           //    => Swift 쪽에서 "\(_audate)%" 문자열을 만들어 바인딩
           let dateLike = "\(_audate)%"
           sqlite3_bind_text(statement, 1, _tid, -1, nil)
           sqlite3_bind_text(statement, 2, _billNo, -1, nil)
           sqlite3_bind_text(statement, 3, dateLike, -1, nil)
           
           // 4) step
           if sqlite3_step(statement) == SQLITE_ROW {
               // 한 줄이라도 나오면 존재(true)
               result = true
           }
           
           return result
    }
}
