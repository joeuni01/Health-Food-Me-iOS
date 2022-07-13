//
//  menuVC.swift
//  HealthFoodMe
//
//  Created by 최영린 on 2022/07/05.
//

import UIKit

import SnapKit

protocol ScrollDeliveryDelegate: AnyObject {
    func scrollStarted(velocity: CGFloat, scrollView: UIScrollView)
}

final class MenuTabVC: UIViewController {
    
    // MARK: - Properties
    
    var isMenu: Bool = true
    weak var delegate: ScrollDeliveryDelegate?
    
    // MARK: - UI Components
    
    private var headerView = HeaderView()
    
    private lazy var menuCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .helfmeWhite
        return cv
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        setDelegate()
        registerCell()
    }
}

// MARK: - Methods

extension MenuTabVC {
    private func setDelegate() {
        menuCV.delegate = self
        menuCV.dataSource = self
        headerView.delegate = self
    }
    
    private func setUI() {
        view.backgroundColor = .helfmeWhite
    }
    
    private func setLayout() {
        view.addSubviews(headerView, menuCV)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(68)
        }
        
        menuCV.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func registerCell() {
        MenuCellCVC.register(target: menuCV)
    }
}

extension MenuTabVC: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let yVelocity = scrollView.panGestureRecognizer .velocity(in: scrollView).y
        delegate?.scrollStarted(velocity: yVelocity, scrollView: scrollView)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension MenuTabVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MenuDataModel.sampleMenuData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = menuCV.dequeueReusableCell(withReuseIdentifier: MenuCellCVC.className, for: indexPath) as? MenuCellCVC
        else { return UICollectionViewCell() }
        cell.setData(menuData: MenuDataModel.sampleMenuData[indexPath.row])
        cell.changeCustomView(isMenu: isMenu)
        return cell
    }
}

extension MenuTabVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        
        let cellWidth = width * (335/375)
        let cellHeight = cellWidth * (120/335)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 60, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

// MARK: - Network

extension MenuTabVC {
    
}

extension MenuTabVC: MenuCVCDelegate {
    func controlSegement() {
        self.isMenu.toggle()
        menuCV.reloadData()
    }
}
