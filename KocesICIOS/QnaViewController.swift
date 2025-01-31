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
        Section(title: "6. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "7. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "8. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "9. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "10. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "11. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "12. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "13. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "14. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "15. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
        Section(title: "16. CAT단말기 연결이 안되요", items: [
            "- CAT단말기가 휴대폰/태블릿과 동일한 네트워크 인지 확인해 주세요, 휴대폰은 WIFI로 통신설정해야 합니다. (LTE/5G 불가) \n - CAT단말기의 IP주소가 맞는지 확인해주세요.\n(설정방법은 사용자매뉴얼 참조)"
        ], isExpanded: false),
    ]
    
    // 테이블 뷰를 프로퍼티로 선언
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
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
        tableView.estimatedRowHeight = 60
    }
        
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].isExpanded
            ? sections[section].items.count + 1
            : 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // 여러 줄 표시 설정
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if indexPath.row == 0 {
            // 헤더
            cell.textLabel?.text = sections[indexPath.section].title
            cell.textLabel?.textColor = .label
            cell.backgroundColor = define.trackgrey
        } else {
            // 아이템
            cell.textLabel?.text = sections[indexPath.section].items[indexPath.row - 1]
            cell.textLabel?.textColor = .label
            cell.backgroundColor = .white
        }
        return cell
    }
        
    // MARK: - UITableViewDelegate
        
    // (1) 아코디언 펼치기/접기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 헤더 탭
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
            // 아이템 탭하면 해당 섹션 닫기
            sections[indexPath.section].isExpanded = false
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
        
    // (2) 셀 높이 설정: 한 줄이면 60, 여러 줄이면 automaticDimension
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // ① 현재 셀의 텍스트 가져오기
        let text: String
        if indexPath.row == 0 {
            // 헤더
            text = sections[indexPath.section].title
        } else {
            // 아이템
            text = sections[indexPath.section].items[indexPath.row - 1]
        }
        
        // ② 한 줄로 표시 가능한지 판단 (boundingRect 사용)
        let maxWidth = tableView.bounds.width - 40  // 좌우 마진 고려
        let font = UIFont.systemFont(ofSize: 17)
        
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        // ③ 한 줄 높이(대략) 측정
        //    - 여기선 시스템 폰트 17pt 기준으로 약 20~22사이로 나옴
        //    - 패딩 등을 고려해서 높이를 좀 더 여유 있게 계산
        let singleLineHeight: CGFloat = font.lineHeight  // 대략 20.16 정도
        
        // ④ 판별
        if rect.height <= singleLineHeight {
            // 한 줄로 충분하면 고정 높이 60
            return 60
        } else {
            // 여러 줄이 필요하면 자동 계산
            return UITableView.automaticDimension
        }
    }
}
