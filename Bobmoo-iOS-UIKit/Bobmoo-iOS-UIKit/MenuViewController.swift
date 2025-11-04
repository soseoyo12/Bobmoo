//
//  ViewController.swift
//  Bobmoo-iOS-UIKit
//
//  Created by 송성용 on 11/4/25.
//

import UIKit
import SwiftUI
import SnapKit
import Then


class MenuViewController: UIViewController {
    
    private let univName = UILabel()
    private let morningLanel = UILabel()
    private let lunchLanel = UILabel()
    private let dinnerLanel = UILabel()
    private let studentCafeteriaLabel = UILabel()
    private let facultyCafeteriaLabel = UILabel()
    private let dormitoryCafeteriaLabel = UILabel()
    private let morningOperatingTimeLabel = UILabel()
    private let lunchOperatingTimeLabel = UILabel()
    private let dinnerOperatingTimeLabel = UILabel()
    private let preOperatingImage = UIImageView()
    private let openOperatingImage = UIImageView()
    private let closedOperatingImage = UIImageView()
    private let menuTextView = UITextView()
    private let backgroundColor = UIImageView()
    private let dateButton = UIButton()
    private let settingImage = UIImageView()
    private let sunRiseImage = UIImageView()
    
    
    
    

    
    
    private func setUI() {
        
        view.backgroundColor = .white

        
        univName.do {
            $0.text = "인하대학교"
            $0.font = UIFont(name: "Pretendard-Bold", size: 30)
            $0.textColor = .black
        }
        
        backgroundColor.do {
            $0.image = UIImage(named: "titleBackground")
        }
        
        settingImage.do {
            $0.image = UIImage(named: "setting")
        }
        
        dateButton.do {
            $0.setTitle("2025년 11월 4일 (화)", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 12)
            $0.contentEdgeInsets = UIEdgeInsets(top: 1, left: 7, bottom: 1, right: 7)
            $0.backgroundColor = UIColor(named: "backDate")
            $0.layer.cornerRadius = 10
        }
        
        morningLanel.do {
            $0.text = "아침"
            $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
            $0.textColor = .black
        }
        
        sunRiseImage.do {
            $0.image = UIImage(named: "sunRise")
        }
        
        
        addSubviews(backgroundColor, univName, settingImage, dateButton,morningLanel, sunRiseImage)
    }
    
    private func setLayout() {
        
        univName.snp.makeConstraints {
            $0.top.equalToSuperview().inset(63)
            $0.leading.equalToSuperview().inset(26)
            $0.width.equalTo(249)
            $0.height.equalTo(49)
        }
        
        backgroundColor.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(0)
        }
        
        settingImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(75.5)
            $0.trailing.equalToSuperview().inset(22.4)
            $0.width.height.equalTo(25)
        }
        
        dateButton.snp.makeConstraints {
            $0.top.equalTo(univName.snp.bottom).offset(0)
            $0.leading.equalToSuperview().inset(26)
        }
        
        morningLanel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(184)
            $0.leading.equalToSuperview().inset(63)
            $0.width.equalTo(38)
            $0.height.equalTo(23)
        }
        
        sunRiseImage.snp.makeConstraints {
            $0.trailing.equalTo(morningLanel.snp.leading).offset(-5)
            $0.centerY.equalTo(morningLanel.snp.centerY)
            $0.width.equalTo(23)
            $0.height.equalTo(18)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
    }


}

#Preview {
    MenuViewController()
}
