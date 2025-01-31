//
//  NetworkSettingController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/07.
//

import UIKit

class StoreSettingController: UIViewController, UIScrollViewDelegate {
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var listener: TcpResult?
    let mSqlite:sqlite = sqlite.instance
    
    //상단 pos 인지 cat 인지 체크
    @IBOutlet weak var mTitleTextLabel: UILabel!
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    /** 대표가맹점등록정보 */
    @IBOutlet weak var mShopTid: UILabel!
    @IBOutlet weak var mShopStoreNum: UILabel!
    @IBOutlet weak var mShopName: UILabel!
    @IBOutlet weak var mShopPhone: UILabel!
    @IBOutlet weak var mShopAddr: UILabel!
    @IBOutlet weak var mShopOwner: UILabel!
    
    /** 서브1가맹점등록정보 */
    @IBOutlet weak var mSub1ShopTid: UILabel!
    @IBOutlet weak var mSub1ShopStoreNum: UILabel!
    @IBOutlet weak var mSub1ShopName: UILabel!
    @IBOutlet weak var mSub1ShopPhone: UILabel!
    @IBOutlet weak var mSub1ShopAddr: UILabel!
    @IBOutlet weak var mSub1ShopOwner: UILabel!
    /** 서브2가맹점등록정보 */
    @IBOutlet weak var mSub2ShopTid: UILabel!
    @IBOutlet weak var mSub2ShopStoreNum: UILabel!
    @IBOutlet weak var mSub2ShopName: UILabel!
    @IBOutlet weak var mSub2ShopPhone: UILabel!
    @IBOutlet weak var mSub2ShopAddr: UILabel!
    @IBOutlet weak var mSub2ShopOwner: UILabel!
    /** 서브3가맹점등록정보 */
    @IBOutlet weak var mSub3ShopTid: UILabel!
    @IBOutlet weak var mSub3ShopStoreNum: UILabel!
    @IBOutlet weak var mSub3ShopName: UILabel!
    @IBOutlet weak var mSub3ShopPhone: UILabel!
    @IBOutlet weak var mSub3ShopAddr: UILabel!
    @IBOutlet weak var mSub3ShopOwner: UILabel!
    /** 서브4가맹점등록정보 */
    @IBOutlet weak var mSub4ShopTid: UILabel!
    @IBOutlet weak var mSub4ShopStoreNum: UILabel!
    @IBOutlet weak var mSub4ShopName: UILabel!
    @IBOutlet weak var mSub4ShopPhone: UILabel!
    @IBOutlet weak var mSub4ShopAddr: UILabel!
    @IBOutlet weak var mSub4ShopOwner: UILabel!
    /** 서브5가맹점등록정보 */
    @IBOutlet weak var mSub5ShopTid: UILabel!
    @IBOutlet weak var mSub5ShopStoreNum: UILabel!
    @IBOutlet weak var mSub5ShopName: UILabel!
    @IBOutlet weak var mSub5ShopPhone: UILabel!
    @IBOutlet weak var mSub5ShopAddr: UILabel!
    @IBOutlet weak var mSub5ShopOwner: UILabel!
    /** 서브6가맹점등록정보 */
    @IBOutlet weak var mSub6ShopTid: UILabel!
    @IBOutlet weak var mSub6ShopStoreNum: UILabel!
    @IBOutlet weak var mSub6ShopName: UILabel!
    @IBOutlet weak var mSub6ShopPhone: UILabel!
    @IBOutlet weak var mSub6ShopAddr: UILabel!
    @IBOutlet weak var mSub6ShopOwner: UILabel!
    /** 서브7가맹점등록정보 */
    @IBOutlet weak var mSub7ShopTid: UILabel!
    @IBOutlet weak var mSub7ShopStoreNum: UILabel!
    @IBOutlet weak var mSub7ShopName: UILabel!
    @IBOutlet weak var mSub7ShopPhone: UILabel!
    @IBOutlet weak var mSub7ShopAddr: UILabel!
    @IBOutlet weak var mSub7ShopOwner: UILabel!
    /** 서브8가맹점등록정보 */
    @IBOutlet weak var mSub8ShopTid: UILabel!
    @IBOutlet weak var mSub8ShopStoreNum: UILabel!
    @IBOutlet weak var mSub8ShopName: UILabel!
    @IBOutlet weak var mSub8ShopPhone: UILabel!
    @IBOutlet weak var mSub8ShopAddr: UILabel!
    @IBOutlet weak var mSub8ShopOwner: UILabel!
    /** 서브9가맹점등록정보 */
    @IBOutlet weak var mSub9ShopTid: UILabel!
    @IBOutlet weak var mSub9ShopStoreNum: UILabel!
    @IBOutlet weak var mSub9ShopName: UILabel!
    @IBOutlet weak var mSub9ShopPhone: UILabel!
    @IBOutlet weak var mSub9ShopAddr: UILabel!
    @IBOutlet weak var mSub9ShopOwner: UILabel!
    /** 서브10가맹점등록정보 */
    @IBOutlet weak var mSub10ShopTid: UILabel!
    @IBOutlet weak var mSub10ShopStoreNum: UILabel!
    @IBOutlet weak var mSub10ShopName: UILabel!
    @IBOutlet weak var mSub10ShopPhone: UILabel!
    @IBOutlet weak var mSub10ShopAddr: UILabel!
    @IBOutlet weak var mSub10ShopOwner: UILabel!
    
    @IBOutlet weak var mSubStoreStackView1: UIStackView!
    @IBOutlet weak var mSubStoreStackView2: UIStackView!
    @IBOutlet weak var mSubStoreStackView3: UIStackView!
    @IBOutlet weak var mSubStoreStackView4: UIStackView!
    @IBOutlet weak var mSubStoreStackView5: UIStackView!
    @IBOutlet weak var mSubStoreStackView6: UIStackView!
    @IBOutlet weak var mSubStoreStackView7: UIStackView!
    @IBOutlet weak var mSubStoreStackView8: UIStackView!
    @IBOutlet weak var mSubStoreStackView9: UIStackView!
    @IBOutlet weak var mSubStoreStackView10: UIStackView!
    
    //가맹점등록버튼
    @IBOutlet weak var mBtnStoreRegist0: UIButton!
    @IBOutlet weak var mBtnStoreRegist1: UIButton!
    @IBOutlet weak var mBtnStoreRegist2: UIButton!
    @IBOutlet weak var mBtnStoreRegist3: UIButton!
    @IBOutlet weak var mBtnStoreRegist4: UIButton!
    @IBOutlet weak var mBtnStoreRegist5: UIButton!
    @IBOutlet weak var mBtnStoreRegist6: UIButton!
    @IBOutlet weak var mBtnStoreRegist7: UIButton!
    @IBOutlet weak var mBtnStoreRegist8: UIButton!
    @IBOutlet weak var mBtnStoreRegist9: UIButton!
    @IBOutlet weak var mBtnStoreRegist10: UIButton!
    //가맹점제거버튼
//    @IBOutlet weak var mBtnStoreDelete0: UIButton!
    @IBOutlet weak var mBtnStoreDelete1: UIButton!
    @IBOutlet weak var mBtnStoreDelete2: UIButton!
    @IBOutlet weak var mBtnStoreDelete3: UIButton!
    @IBOutlet weak var mBtnStoreDelete4: UIButton!
    @IBOutlet weak var mBtnStoreDelete5: UIButton!
    @IBOutlet weak var mBtnStoreDelete6: UIButton!
    @IBOutlet weak var mBtnStoreDelete7: UIButton!
    @IBOutlet weak var mBtnStoreDelete8: UIButton!
    @IBOutlet weak var mBtnStoreDelete9: UIButton!
    @IBOutlet weak var mBtnStoreDelete10: UIButton!
    
    @IBOutlet weak var mBtnAddStore: UIButton!      //가맹점을 수동 추가(CAT)
    @IBOutlet weak var mBtnMultiStoreAppend: UIButton!  //복수가맹점 정보를 모두 보여주는 확장버튼

    @IBOutlet weak var mScrollUIView: UIView!   //복수가맹점시 서브뷰때문에 최대높이를 변경해 주어야 한다
    
    var heightAnchor:NSLayoutConstraint?    //위의 뷰의 높이를 설정하는 레이아웃
    
    var countAck: Int = 0
    
    let CharMaxLength = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //사인뷰 테스트를 위해 여기서 해본다

    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        initRes()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initRes(){
        
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            mTitleTextLabel.text = "CAT"
            mBtnAddStore.isHidden = false
            mBtnAddStore.alpha = 1.0
            
            //가맹점등록버튼은 숨긴다
            mBtnStoreRegist0.isHidden = true
            mBtnStoreRegist1.isHidden = true
            mBtnStoreRegist2.isHidden = true
            mBtnStoreRegist3.isHidden = true
            mBtnStoreRegist4.isHidden = true
            mBtnStoreRegist5.isHidden = true
            mBtnStoreRegist6.isHidden = true
            mBtnStoreRegist7.isHidden = true
            mBtnStoreRegist8.isHidden = true
            mBtnStoreRegist9.isHidden = true
            mBtnStoreRegist10.isHidden = true
            mBtnStoreRegist0.alpha = 0.0
            mBtnStoreRegist1.alpha = 0.0
            mBtnStoreRegist2.alpha = 0.0
            mBtnStoreRegist3.alpha = 0.0
            mBtnStoreRegist4.alpha = 0.0
            mBtnStoreRegist5.alpha = 0.0
            mBtnStoreRegist6.alpha = 0.0
            mBtnStoreRegist7.alpha = 0.0
            mBtnStoreRegist8.alpha = 0.0
            mBtnStoreRegist9.alpha = 0.0
            mBtnStoreRegist10.alpha = 0.0
            //가맹점제거버튼은 ㅂ여준다
//            mBtnStoreDelete0.isHidden = false
            mBtnStoreDelete1.isHidden = false
            mBtnStoreDelete2.isHidden = false
            mBtnStoreDelete3.isHidden = false
            mBtnStoreDelete4.isHidden = false
            mBtnStoreDelete5.isHidden = false
            mBtnStoreDelete6.isHidden = false
            mBtnStoreDelete7.isHidden = false
            mBtnStoreDelete8.isHidden = false
            mBtnStoreDelete9.isHidden = false
            mBtnStoreDelete10.isHidden = false
//            mBtnStoreDelete0.alpha = 1.0
            mBtnStoreDelete1.alpha = 1.0
            mBtnStoreDelete2.alpha = 1.0
            mBtnStoreDelete3.alpha = 1.0
            mBtnStoreDelete4.alpha = 1.0
            mBtnStoreDelete5.alpha = 1.0
            mBtnStoreDelete6.alpha = 1.0
            mBtnStoreDelete7.alpha = 1.0
            mBtnStoreDelete8.alpha = 1.0
            mBtnStoreDelete9.alpha = 1.0
            mBtnStoreDelete10.alpha = 1.0
        } else {
            mTitleTextLabel.text = "POS"
            mBtnAddStore.isHidden = true
            mBtnAddStore.alpha = 0.0
            
            //가맹점등록버튼은 보여준다
            mBtnStoreRegist0.isHidden = false
            mBtnStoreRegist1.isHidden = false
            mBtnStoreRegist2.isHidden = false
            mBtnStoreRegist3.isHidden = false
            mBtnStoreRegist4.isHidden = false
            mBtnStoreRegist5.isHidden = false
            mBtnStoreRegist6.isHidden = false
            mBtnStoreRegist7.isHidden = false
            mBtnStoreRegist8.isHidden = false
            mBtnStoreRegist9.isHidden = false
            mBtnStoreRegist10.isHidden = false
            mBtnStoreRegist0.alpha = 1.0
            mBtnStoreRegist1.alpha = 1.0
            mBtnStoreRegist2.alpha = 1.0
            mBtnStoreRegist3.alpha = 1.0
            mBtnStoreRegist4.alpha = 1.0
            mBtnStoreRegist5.alpha = 1.0
            mBtnStoreRegist6.alpha = 1.0
            mBtnStoreRegist7.alpha = 1.0
            mBtnStoreRegist8.alpha = 1.0
            mBtnStoreRegist9.alpha = 1.0
            mBtnStoreRegist10.alpha = 1.0
            //가맹점제거버튼은 ㅂ숨긴다
//            mBtnStoreDelete0.isHidden = true
            mBtnStoreDelete1.isHidden = true
            mBtnStoreDelete2.isHidden = true
            mBtnStoreDelete3.isHidden = true
            mBtnStoreDelete4.isHidden = true
            mBtnStoreDelete5.isHidden = true
            mBtnStoreDelete6.isHidden = true
            mBtnStoreDelete7.isHidden = true
            mBtnStoreDelete8.isHidden = true
            mBtnStoreDelete9.isHidden = true
            mBtnStoreDelete10.isHidden = true
//            mBtnStoreDelete0.alpha = 0.0
            mBtnStoreDelete1.alpha = 0.0
            mBtnStoreDelete2.alpha = 0.0
            mBtnStoreDelete3.alpha = 0.0
            mBtnStoreDelete4.alpha = 0.0
            mBtnStoreDelete5.alpha = 0.0
            mBtnStoreDelete6.alpha = 0.0
            mBtnStoreDelete7.alpha = 0.0
            mBtnStoreDelete8.alpha = 0.0
            mBtnStoreDelete9.alpha = 0.0
            mBtnStoreDelete10.alpha = 0.0
        }

        //** 주소에 한해서만 2줄로 표시 할 수 있도록 수정한다. 2020-03-12 kim.jy */
        mShopAddr.numberOfLines = 2
        mShopAddr.translatesAutoresizingMaskIntoConstraints = false
        mShopAddr.lineBreakMode = .byWordWrapping
        
        setStoreInfo()
        
        mScrollUIView.translatesAutoresizingMaskIntoConstraints = false
        heightAnchor?.isActive = false
        heightAnchor = mScrollUIView.heightAnchor.constraint(equalToConstant: CGFloat(1000))
//        heightAnchor?.constant = 3500.0
        heightAnchor?.isActive = true
    }

    /**
     현재 복수가맹점으로 등록된 모든 가맹점 정보를 보여준다
     */
    var _clickCount:Bool = false
    @IBAction func clicked_btn_multistore(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }

        if _clickCount {
            _clickCount = false
        } else {
            _clickCount = true
        }
        
        var keyCount:Int = 0
        
        var _TidCount:Int = 0
        //대표가맹점 없음 = 대표가맹점뷰만 보임 or
        //대표가맹점 1개 = 대표가맹점뷰만 보임 or
        //대표가맹점 1개. 이유는 서브가맹점0 역시 대표가맹점이기 떄문. 즉 현재 대표가맹점 정보만 2개임 = 대표가맹점뷰만 보임
        mSubStoreStackView1.isHidden = true
        mSubStoreStackView1.alpha = 0.0
        mSubStoreStackView2.isHidden = true
        mSubStoreStackView2.alpha = 0.0
        mSubStoreStackView3.isHidden = true
        mSubStoreStackView3.alpha = 0.0
        mSubStoreStackView4.isHidden = true
        mSubStoreStackView4.alpha = 0.0
        mSubStoreStackView5.isHidden = true
        mSubStoreStackView5.alpha = 0.0
        mSubStoreStackView6.isHidden = true
        mSubStoreStackView6.alpha = 0.0
        mSubStoreStackView7.isHidden = true
        mSubStoreStackView7.alpha = 0.0
        mSubStoreStackView8.isHidden = true
        mSubStoreStackView8.alpha = 0.0
        mSubStoreStackView9.isHidden = true
        mSubStoreStackView9.alpha = 0.0
        mSubStoreStackView10.isHidden = true
        mSubStoreStackView10.alpha = 0.0
        
        if _clickCount == false {
            mScrollUIView.translatesAutoresizingMaskIntoConstraints = false
            heightAnchor?.isActive = false
            heightAnchor?.constant = 1000.0
            heightAnchor?.isActive = true
//            mScrollUIView.heightAnchor.constraint(equalToConstant: CGFloat(1000)).isActive = true
        } else {
            mScrollUIView.translatesAutoresizingMaskIntoConstraints = false
            
            if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key.contains(define.STORE_TID) {
                        if (value as! String) != "" {
                            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                                if key == "CAT_STORE_TID" {
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID1" {
                                    mSubStoreStackView1.isHidden = false
                                    mSubStoreStackView1.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID2" {
                                    mSubStoreStackView2.isHidden = false
                                    mSubStoreStackView2.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID3" {
                                    mSubStoreStackView3.isHidden = false
                                    mSubStoreStackView3.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID4" {
                                    mSubStoreStackView4.isHidden = false
                                    mSubStoreStackView4.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID5" {
                                    mSubStoreStackView5.isHidden = false
                                    mSubStoreStackView5.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID6" {
                                    mSubStoreStackView6.isHidden = false
                                    mSubStoreStackView6.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID7" {
                                    mSubStoreStackView7.isHidden = false
                                    mSubStoreStackView7.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID8" {
                                    mSubStoreStackView8.isHidden = false
                                    mSubStoreStackView8.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID9" {
                                    mSubStoreStackView9.isHidden = false
                                    mSubStoreStackView9.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "CAT_STORE_TID10" {
                                    mSubStoreStackView10.isHidden = false
                                    mSubStoreStackView10.alpha = 1.0
                                    _TidCount += 1
                                }
                            } else {
                                //로컬 가맹점 정보 읽어서 표시 하기
                                if key == "STORE_TID" {
                                    _TidCount += 1
                                } else if key == "STORE_TID1" {
                                    mSubStoreStackView1.isHidden = false
                                    mSubStoreStackView1.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID2" {
                                    mSubStoreStackView2.isHidden = false
                                    mSubStoreStackView2.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID3" {
                                    mSubStoreStackView3.isHidden = false
                                    mSubStoreStackView3.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID4" {
                                    mSubStoreStackView4.isHidden = false
                                    mSubStoreStackView4.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID5" {
                                    mSubStoreStackView5.isHidden = false
                                    mSubStoreStackView5.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID6" {
                                    mSubStoreStackView6.isHidden = false
                                    mSubStoreStackView6.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID7" {
                                    mSubStoreStackView7.isHidden = false
                                    mSubStoreStackView7.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID8" {
                                    mSubStoreStackView8.isHidden = false
                                    mSubStoreStackView8.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID9" {
                                    mSubStoreStackView9.isHidden = false
                                    mSubStoreStackView9.alpha = 1.0
                                    _TidCount += 1
                                } else if key == "STORE_TID10" {
                                    mSubStoreStackView10.isHidden = false
                                    mSubStoreStackView10.alpha = 1.0
                                    _TidCount += 1 //기본적으로 TID 값이 정상적으로 있는지 체크하며 1개만 있는 경우는 단일 가맹점이다. 2개일경우 단일가맹점으로 설정된 1개 + 복수가맹점 대표TID 1개가 있는거고 있는거고 3개면 단일1개 복수2개 이런식이다. 만일 단일가맹점다운로드 없이 복수가맹점다운로드만 진행되었다고 해도 단일가맹점용 1개가 자동으로 셋팅된다.
                                }
                            }
                        }
                        
                    }
                }
            }

            let _height:Float = Float(_TidCount * 500)
            heightAnchor?.isActive = false
            heightAnchor = mScrollUIView.heightAnchor.constraint(equalToConstant: CGFloat(_height < 1000 ? 1000:_height))
            heightAnchor?.constant = CGFloat(_height < 1000 ? 1000:_height)
            heightAnchor?.isActive = true
//            mScrollUIView.heightAnchor.constraint(equalToConstant: CGFloat(_height < 1000 ? 1000:_height)).isActive = true
            
        }
        
    }
    
    @IBAction func click_btn_store_regist(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        guard let registerVC = self.storyboard?.instantiateViewController(identifier: "StoreRegistController") as? StoreRegistController  else {
            return
        }
        NotificationCenter.default.removeObserver(self)
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    //가맹점 수동추가
    @IBAction func clicked_btn_addInfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        var _checkCount = 0
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            /** 0 */
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key.contains(define.CAT_STORE_TID) {
                    if (value as! String) != "" {
                        if key == "CAT_STORE_TID" ||  key == "CAT_STORE_TID0"{
                            _checkCount = 1
                        }
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 0)
                return
            }
            
            /** 1 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID1"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 1)
                return
            }
            
            /** 2 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID2"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 2)
                return
            }
            
            /** 3 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID3"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 3)
                return
            }
            
            /** 4 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID4"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 4)
                return
            }
            
            /** 5 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID5"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 5)
                return
            }
            
            /** 6 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID6"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 6)
                return
            }
            
            /** 7 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID7"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 7)
                return
            }
            
            /** 8 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID8"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 8)
                return
            }
            
            /** 9 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID9"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 9)
                return
            }
            
            /** 10 */
            _checkCount = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key == "CAT_STORE_TID10"{
                    if (value as! String) != "" {
                        _checkCount = 1
                    }
                }
            }
            
            if _checkCount == 0 {
                Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                StoreRegInfo(StoreNumber: 10)
                return
            }
        }
        else {
            return
        }
        
    }
    
    //가맹점 정보를 제거한다(CAT)
    @IBAction func clicked_reg_delete1(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 1)
    }
    @IBAction func clicked_reg_delete2(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 2)
    }
    @IBAction func clicked_reg_delete3(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 3)
    }
    @IBAction func clicked_reg_delete4(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 4)
    }
    @IBAction func clicked_reg_delete5(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 5)
    }
    @IBAction func clicked_reg_delete6(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 6)
    }
    @IBAction func clicked_reg_delete7(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 7)
    }
    @IBAction func clicked_reg_delete8(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 8)
    }
    @IBAction func clicked_reg_delete9(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 9)
    }
    @IBAction func clicked_reg_delete10(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreDeleteInfo(StoreNumber: 10)
    }
    
    func StoreDeleteInfo(StoreNumber _sn:Int){
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            if _sn == 0 {
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_TID)
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_TID + "0")
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_NAME)
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_NAME + "0")
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_BSN)
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_BSN + "0")
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_OWNER)
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_OWNER + "0")
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_PHONE)
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_PHONE + "0")
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_ADDR)
                Setting.shared.setDefaultUserData(_data:  "", _key: define.CAT_STORE_ADDR + "0")

                mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
                mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)
                mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)
                mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)
                mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)
                mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER)
            } else {
                Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_TID + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_NAME + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_BSN  + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_OWNER + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_PHONE + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_ADDR + String(_sn))
                
                switch _sn {
                case 1:
                    mSub1ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub1ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub1ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub1ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub1ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub1ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 2:
                    mSub2ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub2ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub2ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub2ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub2ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub2ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 3:
                    mSub3ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub3ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub3ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub3ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub3ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub3ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 4:
                    mSub4ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub4ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub4ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub4ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub4ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub4ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 5:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 6:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 7:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 8:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 9:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                case 10:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    break
                default:
                    mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
                    mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)
                    mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)
                    mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)
                    mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)
                    mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER)
                    break
                }

            }
        } else {
            if _sn == 0 {
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_TID)
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_TID + "0")
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_NAME)
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_NAME + "0")
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_BSN)
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_BSN + "0")
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_OWNER)
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_OWNER + "0")
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_PHONE)
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_PHONE + "0")
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_ADDR)
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_ADDR + "0")

                mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID)
                mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN)
                mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME)
                mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)
                mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)
                mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER)
            } else {
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_TID + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_NAME + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_BSN  + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_OWNER + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_PHONE + String(_sn))
                Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_ADDR + String(_sn))
                
                switch _sn {
                case 1:
                    mSub1ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub1ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub1ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub1ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub1ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub1ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 2:
                    mSub2ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub2ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub2ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub2ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub2ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub2ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 3:
                    mSub3ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub3ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub3ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub3ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub3ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub3ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 4:
                    mSub4ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub4ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub4ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub4ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub4ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub4ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 5:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 6:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 7:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 8:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 9:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                case 10:
                    mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                    mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                    mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    break
                default:
                    mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID)
                    mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN)
                    mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME)
                    mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)
                    mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)
                    mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER)
                    break
                }

            }
        }
        
        switch _sn {
        case 1:
            mSubStoreStackView1.isHidden = true
            mSubStoreStackView1.alpha = 0.0
            break
        case 2:
            mSubStoreStackView2.isHidden = true
            mSubStoreStackView2.alpha = 0.0
            break
        case 3:
            mSubStoreStackView3.isHidden = true
            mSubStoreStackView3.alpha = 0.0
            break
        case 4:
            mSubStoreStackView4.isHidden = true
            mSubStoreStackView4.alpha = 0.0
            break
        case 5:
            mSubStoreStackView5.isHidden = true
            mSubStoreStackView5.alpha = 0.0
            break
        case 6:
            mSubStoreStackView6.isHidden = true
            mSubStoreStackView6.alpha = 0.0
            break
        case 7:
            mSubStoreStackView7.isHidden = true
            mSubStoreStackView7.alpha = 0.0
            break
        case 8:
            mSubStoreStackView8.isHidden = true
            mSubStoreStackView8.alpha = 0.0
            break
        case 9:
            mSubStoreStackView9.isHidden = true
            mSubStoreStackView9.alpha = 0.0
            break
        case 10:
            mSubStoreStackView10.isHidden = true
            mSubStoreStackView10.alpha = 0.0
            break
        default:
            break
        }

    }
    
    
    //저장된 대표사업자 정보를 수정한다
    @IBAction func clicked_reInfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            
        } else {
            //ble 일 경우 만일 한번도 등록다운로드를 하지 않았다면 수정을 할 수 없게 막는다
            if Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" {
                AlertBox(title: "사업자 정보 수정", message: "먼저 등록다운로드를 진행하여야 합니다", text: "확인")
                return
            }
            
        }
        StoreRegInfo(StoreNumber: 0)

    }
    
    //저장된 서브1 사업자정보를 수정한다
    @IBAction func clicked_sub1reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreRegInfo(StoreNumber: 1)
    }
    
    @IBAction func clicked_sub2reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreRegInfo(StoreNumber: 2)
    }
    
    @IBAction func clicked_sub3reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreRegInfo(StoreNumber: 3)
    }
    
    @IBAction func clicked_sub4reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreRegInfo(StoreNumber: 4)
    }
    
    @IBAction func clicked_sub5reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        StoreRegInfo(StoreNumber: 5)
    }
    
    @IBAction func clicked_sub6reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch : UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            return
        }
        StoreRegInfo(StoreNumber: 6)
    }
    
    @IBAction func clicked_sub7reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch : UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            return
        }
        StoreRegInfo(StoreNumber: 7)
    }
    
    @IBAction func clicked_sub8reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch : UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            return
        }
        StoreRegInfo(StoreNumber: 8)
    }
    
    @IBAction func clicked_sub9reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch : UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            return
        }
        StoreRegInfo(StoreNumber: 9)
    }
    
    @IBAction func clicked_sub10reginfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch : UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            return
        }
        StoreRegInfo(StoreNumber: 10)
    }
    
    //사업자정보 수정, 대표사업자 = 0 서브는 순서대로 1~10
    func StoreRegInfo(StoreNumber _sn:Int) {
        
        
        let alert = UIAlertController(title: "사업자 정보 수정", message: "아래 항목을 정확히 입력하세요.", preferredStyle: .alert)
        //CAT 연동일 때 처리
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            alert.addTextField { (textField) in
                textField.placeholder = "TID를 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
                    } else if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "사업자번호를 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)
                    } else if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "가맹점명을 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)
                    } else if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "대표자명을 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER)
                    } else if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "전화번호를 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)
                    } else if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "가맹점주소를 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)
                    } else if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                    }
                }
            }
        }
        //여기부터 BLE 연동일 때 처리
        else {
            alert.addTextField { (textField) in
                textField.placeholder = "가맹점명을 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_NAME) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_NAME)
                    } else if Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "대표자명을 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER)
                    } else if Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "전화번호를 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)
                    } else if Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                    }
                }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "가맹점주소를 입력하세요"
                if _sn == 0 {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)
                    } else if Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0") != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0")
                    }
                } else {
                    if Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn)) != "" {
                        textField.text = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                    }
                }
            }
        }
      
        
        

        alert.addAction(UIAlertAction(title: "취소", style: .default, handler: { [self] UIAlertAction in
            AlertBox(title: "사업자 정보 수정", message: "정보 수정을 취소하였습니다", text: "확인")
        }))
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self, alert] (_) in
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                if alert.textFields?[0].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "TID를 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[1].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "사업자번호를 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[2].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "가맹점명을 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[3].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "대표자명을 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[4].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "전화번호를 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[5].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "가맹점주소를 잘못 입력하였습니다", text: "확인")
                    return
                }
            } else {
                
                if alert.textFields?[0].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "가맹점명을 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[1].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "대표자명을 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[2].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "전화번호를 잘못 입력하였습니다", text: "확인")
                    return
                }
                
                if alert.textFields?[3].text?.replacingOccurrences(of: " ", with: "") == "" {
                    AlertBox(title: "사업자 정보 수정", message: "가맹점주소를 잘못 입력하였습니다", text: "확인")
                    return
                }
            }

            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                if _sn == 0 {
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[0].text) ?? "", _key: define.CAT_STORE_TID)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[0].text) ?? "", _key: define.CAT_STORE_TID + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[1].text) ?? "", _key: define.CAT_STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[1].text) ?? "", _key: define.CAT_STORE_BSN + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[2].text) ?? "", _key: define.CAT_STORE_NAME)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[2].text) ?? "", _key: define.CAT_STORE_NAME + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[3].text) ?? "", _key: define.CAT_STORE_OWNER)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[3].text) ?? "", _key: define.CAT_STORE_OWNER + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[4].text) ?? "", _key: define.CAT_STORE_PHONE)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[4].text) ?? "", _key: define.CAT_STORE_PHONE + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[5].text) ?? "", _key: define.CAT_STORE_ADDR)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[5].text) ?? "", _key: define.CAT_STORE_ADDR + "0")

                    mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
                    mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)
                    mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)
                    mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)
                    mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)
                    mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER)
                } else {
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[0].text) ?? "", _key: define.CAT_STORE_TID + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[1].text) ?? "", _key: define.CAT_STORE_BSN  + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[2].text) ?? "", _key: define.CAT_STORE_NAME + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[3].text) ?? "", _key: define.CAT_STORE_OWNER + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[4].text) ?? "", _key: define.CAT_STORE_PHONE + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[5].text) ?? "", _key: define.CAT_STORE_ADDR + String(_sn))
                    
                    switch _sn {
                    case 1:
                        mSub1ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub1ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub1ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub1ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub1ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub1ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 2:
                        mSub2ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub2ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub2ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub2ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub2ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub2ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 3:
                        mSub3ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub3ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub3ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub3ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub3ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub3ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 4:
                        mSub4ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub4ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub4ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub4ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub4ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub4ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 5:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 6:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 7:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 8:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 9:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    case 10:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + String(_sn))
                        break
                    default:
                        mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
                        mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)
                        mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)
                        mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)
                        mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)
                        mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER)
                        break
                    }

                }
            } else {
                if _sn == 0 {
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[0].text) ?? "", _key: define.STORE_NAME)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[0].text) ?? "", _key: define.STORE_NAME + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[1].text) ?? "", _key: define.STORE_OWNER)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[1].text) ?? "", _key: define.STORE_OWNER + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[2].text) ?? "", _key: define.STORE_PHONE)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[2].text) ?? "", _key: define.STORE_PHONE + "0")
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[3].text) ?? "", _key: define.STORE_ADDR)
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[3].text) ?? "", _key: define.STORE_ADDR + "0")

                    mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID)
                    mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN)
                    mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME)
                    mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)
                    mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)
                    mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER)
                } else {
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[0].text) ?? "", _key: define.STORE_NAME + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[1].text) ?? "", _key: define.STORE_OWNER + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[2].text) ?? "", _key: define.STORE_PHONE + String(_sn))
                    Setting.shared.setDefaultUserData(_data: (alert.textFields?[3].text) ?? "", _key: define.STORE_ADDR + String(_sn))
                    
                    switch _sn {
                    case 1:
                        mSub1ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub1ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub1ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub1ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub1ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub1ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 2:
                        mSub2ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub2ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub2ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub2ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub2ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub2ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 3:
                        mSub3ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub3ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub3ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub3ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub3ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub3ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 4:
                        mSub4ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub4ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub4ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub4ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub4ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub4ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 5:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 6:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 7:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 8:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 9:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    case 10:
                        mSub5ShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID + String(_sn))
                        mSub5ShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN + String(_sn))
                        mSub5ShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME + String(_sn))
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + String(_sn))
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + String(_sn))
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + String(_sn))
                        break
                    default:
                        mShopTid.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_TID)
                        mShopStoreNum.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_BSN)
                        mShopName.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_NAME)
                        mShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)
                        mShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)
                        mShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER)
                        break
                    }

                }
            }
            
            AlertBox(title: "사업자 정보 수정", message: "정보를 수정하였습니다", text: "확인")
        }))

        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
    }
    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
        }
    
    //로딩 박스
    func AlertLoadingBox(title _title:String) {
        alertLoading = UIAlertController(title: _title, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        alertLoading.view.addSubview(activityIndicator)
        alertLoading.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: alertLoading.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: alertLoading.view.bottomAnchor, constant: -20).isActive = true

        present(alertLoading, animated: true, completion: nil)
    }
    
    /// 로컬 가맹점 정보를 읽어서 표시 한다.
    func setStoreInfo()
    {
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(define.STORE_TID) {
                if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                    if key == "CAT_STORE_TID" || key == "CAT_STORE_TID0" {
                        mShopName.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME))
                        mShopPhone.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE))
                        mShopAddr.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR))
                        mShopOwner.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
                        
                        mShopTid.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
                        mShopStoreNum.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN))
                        
                    } else if key == "CAT_STORE_TID1" {
                        mSub1ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "1")
                        mSub1ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "1")
                        mSub1ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "1")
                        mSub1ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "1")
                        mSub1ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "1")
                        mSub1ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "1")
                    } else if key == "CAT_STORE_TID2" {
                        mSub2ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "2")
                        mSub2ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "2")
                        mSub2ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "2")
                        mSub2ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "2")
                        mSub2ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "2")
                        mSub2ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "2")
                    } else if key == "CAT_STORE_TID3" {
                        mSub3ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "3")
                        mSub3ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "3")
                        mSub3ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "3")
                        mSub3ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "3")
                        mSub3ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "3")
                        mSub3ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "3")
                    } else if key == "CAT_STORE_TID4" {
                        mSub4ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "4")
                        mSub4ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "4")
                        mSub4ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "4")
                        mSub4ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "4")
                        mSub4ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "4")
                        mSub4ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "4")
                    } else if key == "CAT_STORE_TID5" {
                        mSub5ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "5")
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "5")
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "5")
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "5")
                        mSub5ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "5")
                        mSub5ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "5")
                    } else if key == "CAT_STORE_TID6" {
                        mSub6ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "6")
                        mSub6ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "6")
                        mSub6ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "6")
                        mSub6ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "6")
                        mSub6ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "6")
                        mSub6ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "6")
                    } else if key == "CAT_STORE_TID7" {
                        mSub7ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "7")
                        mSub7ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "7")
                        mSub7ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "7")
                        mSub7ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "7")
                        mSub7ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "7")
                        mSub7ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "7")
                    } else if key == "CAT_STORE_TID8" {
                        mSub8ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "8")
                        mSub8ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "8")
                        mSub8ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "8")
                        mSub8ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "8")
                        mSub8ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "8")
                        mSub8ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "8")
                    } else if key == "CAT_STORE_TID9" {
                        mSub9ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "9")
                        mSub9ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "9")
                        mSub9ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "9")
                        mSub9ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "9")
                        mSub9ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "9")
                        mSub9ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "9")
                    } else if key == "CAT_STORE_TID10" {
                        mSub10ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "10")
                        mSub10ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "10")
                        mSub10ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "10")
                        mSub10ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "10")
                        mSub10ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "10")
                        mSub10ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "10")
                    }
                } else {
                    //로컬 가맹점 정보 읽어서 표시 하기
                    if key == "STORE_TID" || key == "STORE_TID0" {
                        mShopName.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_NAME))
                        mShopPhone.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_PHONE))
                        mShopAddr.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_ADDR))
                        mShopOwner.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
                        
                        mShopTid.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
                        mShopStoreNum.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_BSN))
                        
                    } else if key == "STORE_TID1" {
                        mSub1ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "1")
                        mSub1ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "1")
                        mSub1ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "1")
                        mSub1ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "1")
                        mSub1ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "1")
                        mSub1ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "1")
                    } else if key == "STORE_TID2" {
                        mSub2ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "2")
                        mSub2ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "2")
                        mSub2ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "2")
                        mSub2ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "2")
                        mSub2ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "2")
                        mSub2ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "2")
                    } else if key == "STORE_TID3" {
                        mSub3ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "3")
                        mSub3ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "3")
                        mSub3ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "3")
                        mSub3ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "3")
                        mSub3ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "3")
                        mSub3ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "3")
                    } else if key == "STORE_TID4" {
                        mSub4ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "4")
                        mSub4ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "4")
                        mSub4ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "4")
                        mSub4ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "4")
                        mSub4ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "4")
                        mSub4ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "4")
                    } else if key == "STORE_TID5" {
                        mSub5ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "5")
                        mSub5ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "5")
                        mSub5ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "5")
                        mSub5ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "5")
                        mSub5ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "5")
                        mSub5ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "5")
                    } else if key == "STORE_TID6" {
                        mSub6ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "6")
                        mSub6ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "6")
                        mSub6ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "6")
                        mSub6ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "6")
                        mSub6ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "6")
                        mSub6ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "6")
                    } else if key == "STORE_TID7" {
                        mSub7ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "7")
                        mSub7ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "7")
                        mSub7ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "7")
                        mSub7ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "7")
                        mSub7ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "7")
                        mSub7ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "7")
                    } else if key == "STORE_TID8" {
                        mSub8ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "8")
                        mSub8ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "8")
                        mSub8ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "8")
                        mSub8ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "8")
                        mSub8ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "8")
                        mSub8ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "8")
                    } else if key == "STORE_TID9" {
                        mSub9ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "9")
                        mSub9ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "9")
                        mSub9ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "9")
                        mSub9ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "9")
                        mSub9ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "9")
                        mSub9ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "9")
                    } else if key == "STORE_TID10" {
                        mSub10ShopName.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "10")
                        mSub10ShopPhone.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "10")
                        mSub10ShopAddr.text = "  " +  Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "10")
                        mSub10ShopOwner.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "10")
                        mSub10ShopTid.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_TID + "10")
                        mSub10ShopStoreNum.text = "  " + Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "10")
                    }
                }
                
                
                
            }
        }
        
    
        //로컬 가맹점 정보 읽어서 표시 하기
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            mShopName.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME))
            mShopPhone.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE))
            mShopAddr.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR))
            mShopOwner.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
            
            mShopTid.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
            mShopStoreNum.text = "  " + (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN))

        } else {
            mShopName.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_NAME))
            mShopPhone.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_PHONE))
            mShopAddr.text = "  " +  (Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_ADDR))
            mShopOwner.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            
            mShopTid.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_TID))
            mShopStoreNum.text = "  " + (Setting.shared.getDefaultUserData(_key: define.STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_BSN))

        }
        
        mSubStoreStackView1.isHidden = true
        mSubStoreStackView1.alpha = 0.0
        mSubStoreStackView2.isHidden = true
        mSubStoreStackView2.alpha = 0.0
        mSubStoreStackView3.isHidden = true
        mSubStoreStackView3.alpha = 0.0
        mSubStoreStackView4.isHidden = true
        mSubStoreStackView4.alpha = 0.0
        mSubStoreStackView5.isHidden = true
        mSubStoreStackView5.alpha = 0.0
        mSubStoreStackView6.isHidden = true
        mSubStoreStackView6.alpha = 0.0
        mSubStoreStackView7.isHidden = true
        mSubStoreStackView7.alpha = 0.0
        mSubStoreStackView8.isHidden = true
        mSubStoreStackView8.alpha = 0.0
        mSubStoreStackView9.isHidden = true
        mSubStoreStackView9.alpha = 0.0
        mSubStoreStackView10.isHidden = true
        mSubStoreStackView10.alpha = 0.0
        _clickCount = false
        mScrollUIView.translatesAutoresizingMaskIntoConstraints = false
        if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            var _TidCount:Int = 0
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key.contains(define.STORE_TID) {
                    if (value as! String) != "" {
                        _TidCount += 1  //기본적으로 TID 값이 정상적으로 있는지 체크하며 1개만 있는 경우는 단일 가맹점이다. 2개일경우 단일가맹점으로 설정된 1개 + 복수가맹점 대표TID 1개가 있는거고 있는거고 3개면 단일1개 복수2개 이런식이다. 만일 단일가맹점다운로드 없이 복수가맹점다운로드만 진행되었다고 해도 단일가맹점용 1개가 자동으로 셋팅된다.
                    }
                }
            }
            let _height:Float = Float(_TidCount * 500)
            heightAnchor?.isActive = false
            heightAnchor = mScrollUIView.heightAnchor.constraint(equalToConstant: CGFloat(_height < 1000 ? 1000:_height))
            heightAnchor?.constant = CGFloat(_height < 1000 ? 1000:_height)
            heightAnchor?.isActive = true
        } else {
            heightAnchor?.isActive = false
            heightAnchor?.constant = 1000.0
            heightAnchor?.isActive = true
        }
    }

}

extension StoreSettingController: CustomAlertDelegate
{
    func OkButtonTapped() {
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            mKocesSdk.manager.connect(uuid: mKocesSdk.isPaireduuid)
        }
    }
    
    func CancelButtonTapped() {
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
            mKocesSdk.manager.scan()
        }
    }
}
