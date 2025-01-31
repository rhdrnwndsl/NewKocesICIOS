//
//  SettingItem.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 12/30/24.
//

import UIKit

struct SettingItem {
    let title: String
    let hasSwitch: Bool // 스위치가 있는지 여부
    let detail: String? // 세부 내용
    let action: (() -> Void)? // 클릭 시 동작
}

struct SettingSection {
    let title: String
    let items: [SettingItem]
}
