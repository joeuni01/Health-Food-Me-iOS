//
//  MainDetailVC.swift
//  HealthFoodMe
//
//  Created by Junho Lee on 2022/07/05.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class MainDetailVC: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    var viewModel: MainDetailViewModel!
    private var detailTabTVC = DetailTabTVC()
    private var detailTabTitleHeader = DetailTabTitleHeader()
    private var childVC = ModuleFactory.resolve().makeMenuTabVC()
    
    // MARK: - UI Components
    
    private lazy var mainTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .white
        tv.clipsToBounds = true
        tv.sectionFooterHeight = 0
        tv.allowsSelection = false
        if #available(iOS 15, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        registerCell()
        setDelegate()
        bindViewModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Methods

extension MainDetailVC {
    
    private func setUI() {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = false
        }
        view.backgroundColor = .white
        
        let backButton = UIButton()
        backButton.setImage(ImageLiterals.MainDetail.beforeIcon, for: .normal)
        backButton.tintColor = .helfmeBlack
        backButton.addAction(UIAction(handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        let scrapButton = UIButton()
        scrapButton.setImage(ImageLiterals.MainDetail.scrapIcon, for: .normal)
        scrapButton.setImage(ImageLiterals.MainDetail.scrapIcon_filled, for: .selected)
        scrapButton.addAction(UIAction(handler: { _ in
            scrapButton.isSelected.toggle()
        }), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scrapButton)
    }
    
    private func setLayout() {
        view.addSubviews(mainTableView)
        
        mainTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func registerCell() {
        MainInfoTVC.register(target: mainTableView)
        DetailTabTVC.register(target: mainTableView)
        DetailTabTitleHeader.register(target: mainTableView)
    }
    
    private func setDelegate() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    private func bindViewModels() {
        let input = MainDetailViewModel.Input()
        let output = self.viewModel.transform(from: input, disposeBag: self.disposeBag)
    }
}

// MARK: TableViewDelegate

extension MainDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return UIScreen.main.bounds.height - 104
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1,
              let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: DetailTabTitleHeader.className) as? DetailTabTitleHeader else { return nil }
        headerCell.titleButtonTapped.asDriver(onErrorJustReturn: 0)
            .drive { selectedIndex in
                self.detailTabTVC.scrollToSelectedIndex(index: selectedIndex)
            }.disposed(by: headerCell.disposeBag)
        detailTabTitleHeader = headerCell
        return headerCell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollHeaderHeight = mainTableView.rowHeight
        
        if scrollView.contentOffset.y <= scrollHeaderHeight {
            if scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets(top: -(scrollHeaderHeight+1), left: 0, bottom: 0, right: 0)
        }
    }
}

// MARK: TableViewDataSource

extension MainDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainInfoTVC.className, for: indexPath) as? MainInfoTVC else { return UITableViewCell() }
            cell.toggleButtonTapped.asDriver(onErrorJustReturn: ())
                .drive(onNext: {
                    self.mainTableView.reloadData()
                }).disposed(by: disposeBag)
            cell.directionButtonTapped.asDriver(onErrorJustReturn: ())
                .drive(onNext: {
                    self.presentFindDirectionSheet()
                }).disposed(by: disposeBag)
            cell.telePhoneLabelTapped.asDriver(onErrorJustReturn: "")
                .drive { phoneNumber in
                    URLSchemeManager.shared.loadTelephoneApp(phoneNumber: phoneNumber)
                }.disposed(by: disposeBag)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailTabTVC.className, for: indexPath) as? DetailTabTVC else { return UITableViewCell() }
            detailTabTVC = cell
            
            if childVC is MenuTabVC {
                childVC.delegate = self
            }
            
            self.addChild(childVC)
            cell.receiveChildVC(childVC: childVC)
            cell.scrollRatio.asDriver(onErrorJustReturn: 0)
                .drive { ratio in
                    self.detailTabTitleHeader.moveWithContinuousRatio(ratio: ratio)
                }.disposed(by: cell.disposeBag)
            cell.scrollEnded.asDriver(onErrorJustReturn: 0)
                .drive { pageIndex in
                    self.detailTabTitleHeader.setSelectedButton(buttonIndex: pageIndex)
                }.disposed(by: cell.disposeBag)
            return cell
        }
    }
    
    private func presentFindDirectionSheet() {
        let actionSheet = UIAlertController(title: "길 찾기", message: nil, preferredStyle: .actionSheet)
        
        let kakaoAction = UIAlertAction(title: "카카오맵", style: UIAlertAction.Style.default, handler: { _ in
            URLSchemeManager.shared.loadKakaoMapApp(myLocation: NameLocation(latitude: "37.4640070", longtitude: "126.9522394", name: "서울대학교"), destination: NameLocation(latitude: "37.5209436", longtitude: "127.1230074", name: "올림픽공원"))
        })
        
        let naverAction = UIAlertAction(title: "네이버지도", style: UIAlertAction.Style.default, handler: { _ in
            URLSchemeManager.shared.loadNaverMapApp(myLocation: NameLocation(latitude: "37.4640070", longtitude: "126.9522394", name: "서울대학교"), destination: NameLocation(latitude: "37.5209436", longtitude: "127.1230074", name: "올림픽공원"))
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        actionSheet.addAction(kakaoAction)
        actionSheet.addAction(naverAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true)
    }
}

extension MainDetailVC: ScrollDeliveryDelegate {
    
    // TODO: - 이 부분 touchesBegan으로 해보자
    
    func scrollStarted(velocity: CGFloat, scrollView: UIScrollView) {
        if velocity < 0 {
            self.mainTableView.setContentOffset(CGPoint(x: 0, y: 240), animated: true)
            if mainTableView.contentOffset.y < 230 {
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }
    }
}
