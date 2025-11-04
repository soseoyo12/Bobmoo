//
//  SettingsViewController.swift
//  BobmooUIKit
//
//  Created by SeongYongSong on 10/3/25.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var selectedCafeteria: String {
        get {
            UserDefaults(suiteName: AppGroup.identifier)?
                .string(forKey: "selectedCafeteria") ?? "학생식당"
        }
        set {
            UserDefaults(suiteName: AppGroup.identifier)?
                .set(newValue, forKey: "selectedCafeteria")
        }
    }
    
    private let availableCafeterias = [
        ("학생식당", "학생식당"),
        ("교직원식당", "교직원식당"),
        ("기숙사식당", "생활관식당")
    ]
    
    private let widgetInfoItems = [
        ("위젯 업데이트", "6시간마다"),
        ("지원 위젯 크기", "1x1, 1x2"),
        ("1x1 위젯", "선택된 식당 1개"),
        ("1x2 위젯", "모든 식당 표시")
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "InfoCell")
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return availableCafeterias.count
        case 1:
            return widgetInfoItems.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let cafeteria = availableCafeterias[indexPath.row]
            
            cell.textLabel?.text = cafeteria.1
            cell.textLabel?.font = .systemFont(ofSize: 16)
            cell.selectionStyle = .none
            
            if selectedCafeteria == cafeteria.0 {
                cell.accessoryView = {
                    let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
                    imageView.tintColor = .systemBlue
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                    return imageView
                }()
            } else {
                cell.accessoryView = nil
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            let info = widgetInfoItems[indexPath.row]
            
            cell.textLabel?.text = info.0
            cell.textLabel?.font = .systemFont(ofSize: 16)
            
            let detailLabel = UILabel()
            detailLabel.text = info.1
            detailLabel.font = .systemFont(ofSize: 16)
            detailLabel.textColor = .secondaryLabel
            detailLabel.sizeToFit()
            cell.accessoryView = detailLabel
            
            cell.selectionStyle = .none
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "위젯 설정"
        case 1:
            return "정보"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "1x1 위젯에 표시할 식당을 선택하세요"
        }
        return nil
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cafeteria = availableCafeterias[indexPath.row]
            selectedCafeteria = cafeteria.0
            
            // Reload the section to update checkmarks
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            // Reload widget timelines (if WidgetKit is available)
            // Note: WidgetKit is not directly accessible from UIKit app,
            // but the UserDefaults change will be picked up by widgets
        }
    }
}
