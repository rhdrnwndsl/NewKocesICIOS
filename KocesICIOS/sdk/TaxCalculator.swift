//
//  TaxCalculator.swift
//  KocesICIOS
//
//  Created by 金載龍 on 2021/07/01.
//

import Foundation

class TaxCalculator {
    
    public enum TAXParameter:String {
        case Included       = "Included"
        case NotIncluded    = "NotIncluded"
        case Auto           = "Auto"
        case Manual         = "Manual"
        case Integrated     = "Integrated"
        case Use            = "Use"
        case Unused         = "Unused"
    }
    
    static let Instance:TaxCalculator = TaxCalculator()
    var mApplyVat:TAXParameter = TAXParameter.Use //부가세 사용 여부
    var mIncludeVat:TAXParameter = TAXParameter.Included //부가세 포함 여부
    var mVatMethod:TAXParameter = TAXParameter.Auto //부가세 방식
    var mVatRate:Int = 10    //부가세 비율
    var mApplySvc:TAXParameter = TAXParameter.Unused //봉사료 사용 여부
    var mIncludeSvc:TAXParameter = TAXParameter.Included //봉사료 포함 여부
    var mSvcMethod:TAXParameter = TAXParameter.Auto //봉사료 방식
    var mSvcRate:Int = 0    //봉사료 비율
    var mTxfAuto:TAXParameter = TAXParameter.Auto //비과세 자동 여부
    var mIncludeTxf:TAXParameter = TAXParameter.Included //비과세 포함 여부
    
    let mSetting:Setting = Setting.shared
    
    init() {
        getTaxOption()
    }
    
    //2021년 7월 16일 새로운 설정 적용 kim.jy
    func setTaxOption(부가세적용 _useVat:TAXParameter,부가세방식 _vatMethod:TAXParameter,부가세포함여부 _vatInclude:TAXParameter,부가세 _vatRate:Int,봉사료적용 _useSvc:TAXParameter,봉사료포함여부 _svcInclude:TAXParameter,봉사료자동수동 _svcMethod:TAXParameter,봉사료율 _svcRate:Int, 비과세포함여부 _txfInclude:TAXParameter){
        mApplyVat = _useVat
        mIncludeVat = _vatInclude
        mVatMethod = _vatMethod
        mVatRate = _vatRate
        mApplySvc = _useSvc
        mIncludeSvc = _svcInclude
        mSvcMethod = _svcMethod
        mSvcRate = _svcRate
        mIncludeTxf = _txfInclude
    
        
        mSetting.setDefaultUserData(_data: mApplyVat.rawValue, _key: define.TAX_VAT_USE)    //부가세사용
        mSetting.setDefaultUserData(_data: mIncludeVat.rawValue, _key: define.TAX_VAT_INCLUDE)  //부가세포함
        mSetting.setDefaultUserData(_data: mVatMethod.rawValue, _key: define.TAX_VAT_METHOD)    //부가세 자동,수동,통합
        if mApplyVat == TAXParameter.Use {
            mSetting.setDefaultUserData(_data: "\(mVatRate)", _key: define.TAX_VAT_VALUE)  //부가세사용의 경우
        }
        else{
            mSetting.setDefaultUserData(_data: "\(mVatRate)", _key: define.TAX_VAT_VALUE) //부가세율
        }
        
        mSetting.setDefaultUserData(_data: mApplySvc.rawValue, _key: define.TAX_SVC_USE)    //봉사료 사용
        mSetting.setDefaultUserData(_data: mIncludeSvc.rawValue, _key: define.TAX_SVC_INCLUDE)  //봉사료,포함 미포함
        mSetting.setDefaultUserData(_data: mSvcMethod.rawValue, _key: define.TAX_SVC_METHOD)    //봉사료 자동,수동
        if mApplySvc == TAXParameter.Use {
            mSetting.setDefaultUserData(_data: "\(mSvcRate)", _key: define.TAX_SVC_VALUE)   //봉사료 사용의 경우
        }
        else{
            //mSetting.setDefaultUserData(_data: "0", _key: define.TAX_SVC_VALUE) //봉사료를 사용 하지 않는 경우 0으로 만든다. 2021-08-16
            mSetting.setDefaultUserData(_data: "\(mSvcRate)", _key: define.TAX_SVC_VALUE)   //봉사료 사용의 경우
        }
        //2021-07-21 kim.jy 비과세는 전부 미포함으로 처리 하기 때문에 미포함으로 저장한다.
        mSetting.setDefaultUserData(_data: TAXParameter.NotIncluded.rawValue, _key: define.TAX_TXF_INCLUDE)  //비과세 포함, 미포함
        //mSetting.setDefaultUserData(_data: mIncludeTxf.rawValue, _key: define.TAX_TXF_INCLUDE)  //비과세 포함, 미포함
        
    }
    //세금 설정 가져오기
    func getTaxOption(){
        
//        if mSetting.getDefaultUserData(_key: define.TAX_VAT_USE) == "" {
//            setTaxOption(부가세적용: TAXParameter.Use, 부가세방식: TAXParameter.Auto, 부가세포함여부: TAXParameter.Included, 부가세: 10, 봉사료적용: TAXParameter.Unused, 봉사료포함여부: TAXParameter.Included,봉사료자동수동: TAXParameter.Auto, 봉사료율: 15, 비과세포함여부: TAXParameter.Included)
//            mSetting.setDefaultUserData(_data: "50000", _key: define.INSTALLMENT_MINVALUE)
//            mSetting.setDefaultUserData(_data: "50000", _key: define.UNSIGNED_SETMONEY)
//        }
        //최초에 한번 실행 될 때 세금 데이터가 없는 관계로 강제로 설정한다.
        //이 때 봉사료를 15에서 10으로 설정한다.
        if mSetting.getDefaultUserData(_key: define.TAX_VAT_USE) == "" {
            setTaxOption(부가세적용: TAXParameter.Use, 부가세방식: TAXParameter.Auto, 부가세포함여부: TAXParameter.Included, 부가세: 10, 봉사료적용: TAXParameter.Unused, 봉사료포함여부: TAXParameter.Included,봉사료자동수동: TAXParameter.Auto, 봉사료율: 10, 비과세포함여부: TAXParameter.Included)
            mSetting.setDefaultUserData(_data: "50000", _key: define.INSTALLMENT_MINVALUE)
            mSetting.setDefaultUserData(_data: "50000", _key: define.UNSIGNED_SETMONEY)
        }
        
        /* - 부가세 - */
        //부가세 적용 여부
        if mSetting.getDefaultUserData(_key: define.TAX_VAT_USE) == TAXParameter.Use.rawValue {
            mApplyVat = TAXParameter.Use    //부가세 적용
        }else{
            mApplyVat = TAXParameter.Unused
        }
        
        //부가세 방식
        if mSetting.getDefaultUserData(_key: define.TAX_VAT_METHOD) == TAXParameter.Auto.rawValue {
            mVatMethod = TAXParameter.Auto
        }else{
            mVatMethod = TAXParameter.Integrated
        }
        
        //부가세 포함 여부
        if mSetting.getDefaultUserData(_key: define.TAX_VAT_INCLUDE) == TAXParameter.Included.rawValue {
            mIncludeVat = TAXParameter.Included
        }else{
            mIncludeVat = TAXParameter.NotIncluded
        }
        //부가세율
        mVatRate = Int(mSetting.getDefaultUserData(_key: define.TAX_VAT_VALUE))!
        
        /* - 봉사료 - */
        //봉사료 적용 여부
        if mSetting.getDefaultUserData(_key: define.TAX_SVC_USE) == TAXParameter.Use.rawValue {
            mApplySvc = TAXParameter.Use
        }else{
            mApplySvc = TAXParameter.Unused
        }
        
        //봉사료 방식
        if mSetting.getDefaultUserData(_key: define.TAX_SVC_METHOD) == TAXParameter.Auto.rawValue {
            mSvcMethod = TAXParameter.Auto
        }else{
            mSvcMethod = TAXParameter.Manual
        }
        
        //봉사료 포함 여부
        if mSetting.getDefaultUserData(_key: define.TAX_SVC_INCLUDE) == TAXParameter.Included.rawValue {
            mIncludeSvc = TAXParameter.Included
        }else{
            mIncludeSvc = TAXParameter.NotIncluded
        }
        //봉사료율
        mSvcRate = Int(mSetting.getDefaultUserData(_key: define.TAX_SVC_VALUE))!
        
        /* - 비과세 - */
        //비과세 포함 여부
        if mSetting.getDefaultUserData(_key: define.TAX_TXF_INCLUDE) == TAXParameter.Included.rawValue {
            mIncludeTxf = TAXParameter.Included
        }else {
            mIncludeTxf = TAXParameter.NotIncluded
        }
        
        /* - 할부 최소 금액 - */
        /* - 서명 최소 금액 - */
        
    }
//    func getOption(){
//        //최초에는 세금 설정이 되어 있지 않기 때문에 호출 될 경우 정상적으로 처리 되지 않는다. 이 떼문에 최초에 한번만 실행 코드 추가
//        if mSetting.getDefaultUserData(_key: define.VAT_USE) == "" {
//            setOption(부가세적용: true, 부가세포함: true, 부가세율: 10, 봉사료적용: false, 봉사료포함: false, 봉사료율: 0, 비과세: false, 비과세오토: true, 비과세포함: true)
//
//            mSetting.setDefaultUserData(_data: "50000", _key: define.INSTALLMENT_MINVALUE)
//            mSetting.setDefaultUserData(_data: "50000", _key: define.UNSIGNED_SETMONEY)
//        }
//
//
//        //부가세
//        mApplyVat = ConvertBoolType(defineStr: define.VAT_USE)
//        mIncludeVat = ConvertBoolType(defineStr: define.VAT_INCLUDE)
//        mVatRate = Int(mSetting.getDefaultUserData(_key: define.VAT_VALUE)) ?? 0
//
//        //봉사료
//        mApplySvc = ConvertBoolType(defineStr: define.SVC_USE)
//        mIncludeSvc = ConvertBoolType(defineStr: define.SVC_INCLUDE)
//        mSvcRate = Int(mSetting.getDefaultUserData(_key: define.SVC_VALUE)) ?? 0
//
//        //비과세
//        mApplyTxf = ConvertBoolType(defineStr: define.TXF_USE)
//        mTxfAuto = ConvertBoolType(defineStr: define.TXF_AUTOMANUAL)
//        mIncludeTxf = ConvertBoolType(defineStr: define.TXF_INCLUDE)
//
//    }

    private func ConvertBoolType(defineStr str:String) -> Bool {
        let result:String = mSetting.getDefaultUserData(_key: str)
        return result == "1" ?true:false
    }
    //======================================== 세금 계산 ==============================================//
    /// 현재 설정된 세금을 기준으로 원금, 세금, 봉사료 계산 하는 함수
    /// - Parameter _Money: 총금액
    /// - Returns: Dictionary 타입 keys => "Money","VAT","SVC"
    func TaxCalc(금액 _Money:Int,비과세금액 _TaxFree:Int,봉사료 _ServiceCharge:Int,BleUse bleUse:Bool = true) -> Dictionary<String, Int> {
        getTaxOption()
        var err:Int = 0
        var Money:Int = _Money
        var value:Dictionary = [String:Int]()
        var originalMoney:Int = Money
        var PayMentMoney:Int = 0
        var VAT:Int = 0
        var SVC:Int = 0
        var TXF:Int = _TaxFree
        
        if bleUse {     //ble인 경우
        //제일 먼저 처리 할 것은 봉사료를 빼는 일이다.
            if mApplySvc == TAXParameter.Use {  //봉사료를 사용하는 것을
                if mSvcMethod == TAXParameter.Auto{ //봉사료가 자동인 경우에 비율에 따라서 금액을 처리 한다.
                    var svcRt:Double = Double(mSvcRate) / 100.0
                    SVC = Int(Double(Money) * svcRt)
                    if mIncludeSvc == TAXParameter.Included { //봉사료 원금 포함의 경우
                        originalMoney = originalMoney - SVC
                    }
                }else{      //봉사료 수동 입력
                    if mIncludeSvc == TAXParameter.Included{    //봉사료 원금 포함의 경우
                        SVC = _ServiceCharge
                        originalMoney = originalMoney - SVC
                    }else{
                        SVC = _ServiceCharge                    //봉사료 원금 미포함의 경우
                    }
                }
            }
            
            //세금 계산 부분
            if mApplyVat == TAXParameter.Use {
                var vatRt:Double = Double(mVatRate) / 100.0
                if mIncludeVat == TAXParameter.Included {
                    VAT =  Int(Double(originalMoney) - (Double(originalMoney) / (1.0 + vatRt)))
                    originalMoney = originalMoney - VAT
                }
                else{   //세금 미포함
                    VAT = Int(Double(originalMoney) * vatRt)
                }
            }
            else{   //세금적용 안함.
                VAT = 0
            }
            
            originalMoney = originalMoney + TXF

            if mApplySvc == TAXParameter.Use && mIncludeSvc == TAXParameter.NotIncluded {  //봉사료 적용, 봉사료 미포함
                //PayMentMoney = PayMentMoney + SVC
            }
            
            if mIncludeTxf == TAXParameter.NotIncluded {  //비과세 적용, 비과세 미포함
                //PayMentMoney = PayMentMoney + TXF
            }
            
            if mApplyVat == TAXParameter.Use && mIncludeVat == TAXParameter.NotIncluded {  //세금 적용,세금 비포함
                //PayMentMoney = PayMentMoney + VAT
            }
        }
        else
        {   //ble 아니라 CAT에 따른 계산
            if mApplySvc == TAXParameter.Use {  //봉사료 적용
                if mSvcMethod == TAXParameter.Auto{         //봉사료 방식이 자동인 경우
                    var svcRt:Double = Double(mSvcRate) / 100.0
                    SVC = Int(Double(Money) * svcRt)
                    if mIncludeSvc == TAXParameter.Included { //봉사료 원금 포함의 경우
                        originalMoney = originalMoney - SVC
                    }
                }else{          //봉사료 방식이 수동인 경우
                    if mIncludeSvc == TAXParameter.Included {   //봉사료가 원금 포함의 경우
                        SVC = _ServiceCharge
                        originalMoney = originalMoney - SVC
                    }else{
                        //2021-08-17 kim.jy 이완재 과장님과 통화 후에 CAT봉사료 미포함 거래를 추가함
                        SVC = _ServiceCharge                    //봉사료 원금 미포함의 경우
                    }
                }
            }
            
            
            if mApplyVat == TAXParameter.Use {
                var vatRt:Double = Double(mVatRate) / 100.0
                if mIncludeVat == TAXParameter.Included {
                    VAT =  Int(Double(originalMoney) - (Double(originalMoney) / (1.0 + vatRt)))
                    originalMoney = originalMoney - VAT
                }
                else{   //세금 미포함
                    VAT = Int(Double(originalMoney) * vatRt)
                }
            }
            else{   //세금적용 안함.
                VAT = 0
            }
            
        }
        //value["Money"] = originalMoney + PayMentMoney //CAT에서는 원금에서 공급가액 + 세금 + 봉사료만 처리하고 비과세는 금액만 산정하여 리턴 한다.
        value["Money"] = originalMoney
        value["VAT"] = VAT
        value["SVC"] = SVC
        value["TXF"] = TXF
        value["Error"] = err
        
        return value
    }
    
    //int _Money,int _TaxFree,String _svcWon,
    //int _auto,int _vatMode, int _svcRate, int _vatRate, int SVCInclude, int VATInclude,
    //int UseSVC, int UseVAT, String _vatWon,
    //Boolean UsebleOrCat
    
    func TaxCalcProduct(금액 _Money:Int,
                        비과세금액 _TaxFree:Int,
                        봉사료액 _svcWon:Int,
                        봉사료자동수동 _auto:Int,
                        부가세자동수동 _vatMode:Int,
                        봉사료율 _svcRate:Int,
                        부가세율 _vatRate:Int,
                        봉사료포함미포함 SVCInclude:Int,
                        부가세포함미포함 VATInclude:Int,
                        봉사료사용미사용 UseSVC:Int,
                        부가세사용미사용 UseVAT:Int,
                        부가세액 _vatWon:Int,
                        BleUse bleUse:Bool = true) -> Dictionary<String, Int> {
        getTaxOption()
        var err:Int = 0
        var Money:Int = _Money
        var value:Dictionary = [String:Int]()
        var originalMoney:Int = Money
//        var PayMentMoney:Int = 0
        var VAT:Int = 0
        var SVC:Int = 0
        var TXF:Int = _TaxFree
        
        var __svcWon:Int = _svcWon
        var __vatWon:Int = _vatWon
        
        let Auto:Int = 0    //0=AUTO 1=MANUAL
        let Included:Int = 0    //0=포함, 1=미포함
        let NotIncluded:Int = 1
        
        if bleUse {     //ble인 경우
            //제일 먼저 처리 할 것은 봉사료를 빼는 일이다.
            if UseSVC == 0 {  //봉사료를 사용하는 것을
                if _auto == Auto { //봉사료가 자동인 경우에 비율에 따라서 금액을 처리 한다. 0=AUTO 1=MANUAL
                    var svcRt:Double = Double(_svcRate) / 100.0
                    SVC = Int(Double(Money) * svcRt)
                    if SVCInclude == Included { //봉사료 원금 포함의 경우 0=포함, 1=미포함
                        originalMoney = originalMoney - SVC
                    }
                } else {      //봉사료 수동 입력
                    if SVCInclude == Included {    //봉사료 원금 포함의 경우
                        SVC = __svcWon
                        originalMoney = originalMoney - SVC
                    } else{
                        SVC = __svcWon                    //봉사료 원금 미포함의 경우
                    }
                }
            }
            
            //세금 계산 부분
            if UseVAT == 0 {
                if _vatMode == Auto {
                    //부가세가 자동인경우
                    var vatRt:Double = Double(mVatRate) / 100.0
                    if VATInclude == Included {
                        VAT =  Int(Double(originalMoney) - (Double(originalMoney) / (1.0 + vatRt)))
                        originalMoney = originalMoney - VAT
                    } else{   //세금 미포함
                        VAT = Int(Double(originalMoney) * vatRt)
                    }
                } else {
                    //부가세가 수동인경우
                    if VATInclude == Included {   //부가세가 포함인경우
                        VAT = __vatWon
                        originalMoney = originalMoney - __vatWon
                    } else{   //세금 미포함
                        VAT = __vatWon
                    }
                }
        
            } else {   //세금적용 안함.
                VAT = 0
            }
 
            originalMoney = originalMoney + TXF
            
            if(UseSVC == 0 && SVCInclude==NotIncluded){  //봉사료 적용, 봉사료 미포함
                //PayMentMoney = PayMentMoney + SVC
            }

            if(UseVAT == 0 && VATInclude==NotIncluded){  //세금 적용,세금 비포함
                //PayMentMoney = PayMentMoney + VAT
            }

        } else {
            //ble 아니라 CAT에 따른 계산
            if UseSVC == 0 {  //봉사료 적용
                if _auto == Auto{         //봉사료 방식이 자동인 경우
                    var svcRt:Double = Double(mSvcRate) / 100.0
                    SVC = Int(Double(Money) * svcRt)
                    if SVCInclude == Included { //봉사료 원금 포함의 경우
                        originalMoney = originalMoney - SVC
                    }
                }else{          //봉사료 방식이 수동인 경우
                    if SVCInclude == Included {   //봉사료가 원금 포함의 경우
                        SVC = __svcWon
                        originalMoney = originalMoney - SVC
                    }else{
                        //2021-08-17 kim.jy 이완재 과장님과 통화 후에 CAT봉사료 미포함 거래를 추가함
                        SVC = __svcWon                    //봉사료 원금 미포함의 경우
                    }
                }
            }

            if UseVAT == 0 {
                if _vatMode == Auto {
                    //부가세가 자동인경우
                    var vatRt:Double = Double(mVatRate) / 100.0
                    if VATInclude == Included {
                        VAT =  Int(Double(originalMoney) - (Double(originalMoney) / (1.0 + vatRt)))
                        originalMoney = originalMoney - VAT
                    } else { //세금 미포함
                        VAT = Int(Double(originalMoney) * vatRt)
                    }
                } else {
                    if VATInclude==Included {   //부가세가 포함인경우
                        VAT = __vatWon
                        originalMoney = originalMoney - __vatWon
                    }
                    else{   //세금 미포함
                        VAT = __vatWon
                    }
                }
            } else{   //세금적용 안함.
                VAT = 0
            }
        }

        //value["Money"] = originalMoney + PayMentMoney //CAT에서는 원금에서 공급가액 + 세금 + 봉사료만 처리하고 비과세는 금액만 산정하여 리턴 한다.
        value["Money"] = originalMoney
        value["VAT"] = VAT
        value["SVC"] = SVC
        value["TXF"] = TXF
        value["Error"] = err
        
        return value
    }
}
    
    
