//
//  MainViewController.swift
//  BobmooUIKit
//
//  Storyboard 버전 - IBOutlet 및 IBAction 사용
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var dateHeaderView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var menu: CampusMenu?
    private var cafeteriaMeals: [CafeteriaMeals] = []
    private var selectedDate: Date = Date()
    private var errorMessage: String?
    
    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMenuData(for: selectedDate)
        
        // Add observer for app becoming active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 네비게이션 바 설정
        title = "인하대학교"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .customPastelBlue()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 날짜 버튼 업데이트
        updateDateButton()
        
        // StackView 설정
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
    }
    
    private func updateDateButton() {
        dateButton.setTitle(dateLabel, for: .normal)
    }
    
    // MARK: - Data Loading
    
    private func loadMenuData(for date: Date) {
        isLoading = true
        errorMessage = nil
        updateUI()
        
        Task {
            do {
                let menuData = try await NetworkService.fetch(date: date)
                await MainActor.run {
                    self.menu = menuData
                    self.cafeteriaMeals = makeMealArray(from: menuData, mealType: "breakfast")
                    self.isLoading = false
                    self.updateUI()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.updateUI()
                }
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if isLoading {
            // Loading indicator는 storyboard에서 처리
            return
        } else if let error = errorMessage {
            let errorView = createErrorView(message: error)
            contentStackView.addArrangedSubview(errorView)
        } else if cafeteriaMeals.isEmpty {
            let emptyView = createEmptyView()
            contentStackView.addArrangedSubview(emptyView)
        } else {
            // Create meal blocks in order
            for mealType in getMealOrder() {
                let mealBlock = createMealBlockView(mealType: mealType)
                contentStackView.addArrangedSubview(mealBlock)
            }
        }
        
        updateDateButton()
    }
    
    // MARK: - View Creation
    
    private func createMealBlockView(mealType: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.layer.shadowRadius = 3
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        container.addSubview(stackView)
        
        // Header
        let headerView = createMealHeaderView(mealType: mealType)
        stackView.addArrangedSubview(headerView)
        
        // Content
        if let menu = menu {
            let meals = makeMealArray(from: menu, mealType: mealType)
            
            if meals.isEmpty {
                let emptyLabel = createMealEmptyView(mealType: mealType)
                stackView.addArrangedSubview(emptyLabel)
            } else {
                for cafeteria in meals {
                    let cafeteriaView = createCafeteriaView(cafeteria: cafeteria, mealType: mealType)
                    stackView.addArrangedSubview(cafeteriaView)
                }
            }
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Add margin container
        let marginContainer = UIView()
        marginContainer.translatesAutoresizingMaskIntoConstraints = false
        marginContainer.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: marginContainer.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: marginContainer.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: marginContainer.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: marginContainer.bottomAnchor)
        ])
        
        return marginContainer
    }
    
    private func createMealHeaderView(mealType: String) -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 25, weight: .medium)
        
        switch mealType {
        case "breakfast":
            iconImageView.image = UIImage(systemName: "sun.horizon")
            titleLabel.text = "아침"
        case "lunch":
            iconImageView.image = UIImage(systemName: "sun.max")
            titleLabel.text = "점심"
        case "dinner":
            iconImageView.image = UIImage(systemName: "moon")
            titleLabel.text = "저녁"
        default:
            iconImageView.image = UIImage(systemName: "sun.horizon")
            titleLabel.text = "아침"
        }
        
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return headerView
    }
    
    private func createCafeteriaView(cafeteria: CafeteriaMeals, mealType: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Cafeteria header
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        nameLabel.text = cafeteria.cafeteriaName
        
        let hoursLabel = UILabel()
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false
        hoursLabel.font = .systemFont(ofSize: 12)
        hoursLabel.textColor = .secondaryLabel
        hoursLabel.text = cafeteria.operatingHours
        
        let status = operatingState(operatingHours: cafeteria.operatingHours)
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = .white
        statusLabel.text = status.text
        statusLabel.backgroundColor = status.color
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        
        headerView.addSubview(nameLabel)
        headerView.addSubview(hoursLabel)
        headerView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 11),
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),
            
            hoursLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            hoursLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            statusLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35)
        ])
        
        stackView.addArrangedSubview(headerView)
        
        // Menu items
        if cafeteria.meals.isEmpty {
            let mealDisplayName = mealType == "breakfast" ? "아침" : (mealType == "lunch" ? "점심" : "저녁")
            let emptyLabel = UILabel()
            emptyLabel.text = "\(mealDisplayName) 메뉴 없음"
            emptyLabel.font = .systemFont(ofSize: 16)
            emptyLabel.textColor = .secondaryLabel
            
            let emptyContainer = UIView()
            emptyContainer.translatesAutoresizingMaskIntoConstraints = false
            emptyContainer.addSubview(emptyLabel)
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                emptyLabel.leadingAnchor.constraint(equalTo: emptyContainer.leadingAnchor, constant: 14),
                emptyLabel.topAnchor.constraint(equalTo: emptyContainer.topAnchor),
                emptyLabel.bottomAnchor.constraint(equalTo: emptyContainer.bottomAnchor)
            ])
            
            stackView.addArrangedSubview(emptyContainer)
        } else {
            for meal in cafeteria.meals {
                let mealView = UIView()
                mealView.translatesAutoresizingMaskIntoConstraints = false
                
                let courseLabel = UILabel()
                courseLabel.translatesAutoresizingMaskIntoConstraints = false
                courseLabel.font = .systemFont(ofSize: 16, weight: .medium)
                courseLabel.text = meal.course
                courseLabel.setContentHuggingPriority(.required, for: .horizontal)
                
                let menuLabel = UILabel()
                menuLabel.translatesAutoresizingMaskIntoConstraints = false
                menuLabel.font = .systemFont(ofSize: 16)
                menuLabel.text = meal.mainMenu
                menuLabel.numberOfLines = 0
                
                mealView.addSubview(courseLabel)
                mealView.addSubview(menuLabel)
                
                NSLayoutConstraint.activate([
                    courseLabel.leadingAnchor.constraint(equalTo: mealView.leadingAnchor, constant: 14),
                    courseLabel.topAnchor.constraint(equalTo: mealView.topAnchor),
                    courseLabel.bottomAnchor.constraint(equalTo: mealView.bottomAnchor),
                    
                    menuLabel.leadingAnchor.constraint(equalTo: courseLabel.trailingAnchor, constant: 8),
                    menuLabel.topAnchor.constraint(equalTo: mealView.topAnchor),
                    menuLabel.trailingAnchor.constraint(equalTo: mealView.trailingAnchor, constant: -14),
                    menuLabel.bottomAnchor.constraint(equalTo: mealView.bottomAnchor)
                ])
                
                stackView.addArrangedSubview(mealView)
            }
        }
        
        // Divider
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .separator
        stackView.addArrangedSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createMealEmptyView(mealType: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "fork.knife"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let mealDisplayName = mealType == "breakfast" ? "아침" : (mealType == "lunch" ? "점심" : "저녁")
        let label = UILabel()
        label.text = "오늘의 \(mealDisplayName) 메뉴가 없습니다"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            
            container.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return container
    }
    
    private func createEmptyView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "fork.knife"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "오늘의 메뉴가 없습니다"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            
            container.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        return container
    }
    
    private func createErrorView(message: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .orange
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "오류가 발생했습니다"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 12)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            container.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        return container
    }
    
    // MARK: - Computed Properties
    
    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - IBActions
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.date = selectedDate
        
        let alert = UIAlertController(title: "날짜 선택", message: nil, preferredStyle: .actionSheet)
        
        let pickerContainer = UIView()
        pickerContainer.translatesAutoresizingMaskIntoConstraints = false
        pickerContainer.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: pickerContainer.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: pickerContainer.bottomAnchor),
            pickerContainer.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        alert.view.addSubview(pickerContainer)
        
        NSLayoutConstraint.activate([
            pickerContainer.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            pickerContainer.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            pickerContainer.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            alert.view.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        alert.addAction(UIAlertAction(title: "완료", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.selectedDate = datePicker.date
            self.loadMenuData(for: self.selectedDate)
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    // MARK: - Observers
    
    @objc private func appDidBecomeActive() {
        loadMenuData(for: selectedDate)
    }
}
