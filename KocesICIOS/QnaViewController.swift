//
//  QnaViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 1/31/25.
//

import Foundation
import UIKit

class QnaViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
        
    struct Section {
        let title: String
        let items: [String]
        var isExpanded: Bool
    }
        
    var sections: [Section] = [
        Section(title: "1. 블루투스 리더기 연결이 안되요", items: [
            "- 휴대폰/태블릿의 “블루투스”, “위치” 설정이 활성화 되어있는지 확인해 주세요"
        ], isExpanded: false),
        Section(title: "2. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "3. USB 연결은 어떻게 하나요? 유선 프린터는 어떻게 연결하나요?", items: [
            "- IOS 는 유선/USB 통신을 지원하지 않습니다."
        ], isExpanded: false),
        Section(title: "4. 프린터는 어떻게 연결하나요?", items: [
            "- 장치설정 – 프린트설정 - 프린트 장치 설정 - NET 선택 \n CAT단말기를 NETWORK 프린터로 설정하시면 됩니다."
        ], isExpanded: false),
        Section(title: "5. 펌웨어 업데이트 했는데 장치연결이 안되요", items: [
            "- 펌웨어 업데이트 후 BT리더기가 종료됩니다. 전원을 다시 켠 후 'BT연결' 버튼을 눌러 다시 설정할 수 있습니다."
        ], isExpanded: false),
        Section(title: "6. 애플페이 지원이 되나요?", items: [
            "- BT 리더기 중 애플페이를 지원하는 제품 연결 시 애플페이가 지원됩니다."
        ], isExpanded: false),
        Section(title: "7. 거래중에 통신실패가 발생해요", items: [
            "- 휴대폰/테블릿의 통신상태를 확인해 주세요."
        ], isExpanded: false),
        Section(title: "8. 일반거래와 상품거래는 무슨 차이 인가요?", items: [
            "- 일반거래 : 거래시 금액을 수동으로 입력하여 거래 \n - 상품거래 : 상품을 등록 후 상품을 선택하여 거래"
        ], isExpanded: false),
        Section(title: "9. AppToApp 연동거래를 해야하는데 다른거래를 선택해서 바꾸고 싶어요", items: [
            "- 가맹점설정 – 결제설정 – 거래방식설정 에서 변경하실 수 있습니다."
        ], isExpanded: false),
        Section(title: "10. 상품데이터는 어떻게 백업하나요?", items: [
            "- 상품설정 – 상품관리 – 상품정보백업 – 내보내기 버튼을 통해 상품데이터를 저장, 공유하실 수 있습니다."
        ], isExpanded: false),
        Section(title: "11. 상품등록이 안되요", items: [
            "- 상품등록은 가맹점설정 후 사용이 가능합니다."
        ], isExpanded: false),
        Section(title: "12. 상품등록은 몇 개까지 등록 되나요?", items: [
            "- 상품은 최대 1,000개까지 등록이 가능합니다."
        ], isExpanded: false),
        Section(title: "13. 앱 삭제 시 결제내역 및 상품정보가 삭제되나요?", items: [
            "- 앱 삭제 시 결제내역 및 상품정보, 가맹점정보 등 모든 데이터가 삭제됩니다."
        ], isExpanded: false),
        Section(title: "14. 결재내역이나 상품정보 백업 방법이 있나요?", items: [
            "- 상품정보는 상품설정 – 상품관리 – 상품정보백업 – 내보내기 버튼으로 백업이 가능합니다. \n - 결재내역, 가맹점정보는 현재 백업이 불가합니다."
        ], isExpanded: false),
    ]
    
    // 테이블 뷰를 프로퍼티로 선언
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .white
        view.backgroundColor = .systemBackground
        self.title = "Q&A"
        
        // 테이블 뷰 설정
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 셀 등록
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // 오토레이아웃
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // 여러 줄 셀 자동 계산
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = define.pad_title_height
    }
        
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 헤더 1개 + 아이템 (펼쳐졌을 경우)
        return sections[section].isExpanded ? sections[section].items.count + 1 : 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // 여러 줄 표시 설정
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if indexPath.row == 0 {
            // 헤더: 질문 영역
            cell.textLabel?.text = sections[indexPath.section].title
            cell.textLabel?.textColor = .label
            cell.textLabel?.textColor = .darkGray
            cell.backgroundColor = define.layout_border_lightgrey
        } else {
            // 답변 영역
            cell.textLabel?.text = sections[indexPath.section].items[indexPath.row - 1]
            cell.textLabel?.textColor = .label
            cell.textLabel?.textColor = .darkGray
            cell.backgroundColor = .white
        }
        return cell
    }
        
    // MARK: - UITableViewDelegate
        
    // (1) 아코디언 펼치기/접기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 헤더 셀 선택 시 아코디언 효과
        if indexPath.row == 0 {
            let wasExpanded = sections[indexPath.section].isExpanded
            // 다른 섹션 모두 닫기
            for i in 0..<sections.count {
                sections[i].isExpanded = false
            }
            // 현재 섹션만 토글
            sections[indexPath.section].isExpanded = !wasExpanded
            tableView.reloadSections(IndexSet(integersIn: 0..<sections.count), with: .automatic)
        } else {
            // 답변 셀 선택 시 해당 섹션 닫기
            sections[indexPath.section].isExpanded = false
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
        
    // (2) 셀 높이 설정: 한 줄이면 고정, 여러 줄이면 automaticDimension
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text: String = (indexPath.row == 0) ? sections[indexPath.section].title : sections[indexPath.section].items[indexPath.row - 1]
        let maxWidth = tableView.bounds.width - 40  // 좌우 마진 고려
        let font = Utils.getTextFont()
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let singleLineHeight = font.lineHeight
        if rect.height <= singleLineHeight {
            return define.pad_title_height
        } else {
            return UITableView.automaticDimension
        }
    }
}
