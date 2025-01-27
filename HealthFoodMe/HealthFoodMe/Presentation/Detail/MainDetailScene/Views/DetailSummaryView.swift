//
//  DetailSummaryView.swift
//  HealthFoodMe
//
//  Created by Junho Lee on 2022/07/05.
//

import UIKit

import SnapKit

final class DetailSummaryView: UIView {
    
    // MARK: - UI Components
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = ImageLiterals.MainDetail.tempMuseum
        return iv
    }()
    
    private let restaurantNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "서브웨이 동대문역사문화공원역점"
        lb.textColor = .helfmeBlack
        lb.lineBreakMode = .byWordWrapping
        lb.numberOfLines = 0
        lb.font = .NotoBold(size: 16)
        return lb
    }()
    
    private let titleStackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 6
        st.distribution = .fillProportionally
        st.alignment = .leading
        return st
    }()
    
    private let starRateStackView: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.spacing = 2
        st.distribution = .fillProportionally
        st.alignment = .leading
        return st
    }()
    
    private let starRateView: StarRatingView = {
        let st = StarRatingView(starScale: 14)
        st.rate = 4.3
        return st
    }()
    
    private let rateLabel: UILabel = {
        let lb = UILabel()
        lb.text = "(4.3)"
        lb.textColor = .lightGray
        lb.font = .NotoRegular(size: 12)
        return lb
    }()
    
    // MARK: View Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension DetailSummaryView {
    func setData(data: MainDetailEntity) {
        logoImageView.setImage(with: data.restaurant.logo)
        // 별점도 할당하기
        restaurantNameLabel.text = data.restaurant.name
    }
}

// MARK: - UI & Layout

extension DetailSummaryView {
   
    private func setUI() {
        self.backgroundColor = .white
    }
    
    private func setLayout() {
        self.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(140)
        }
        
        self.addSubviews(logoImageView, titleStackView)
        
        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(15)
            make.width.height.equalTo(112)
        }
        
        titleStackView.addArrangedSubviews(restaurantNameLabel, starRateStackView)
        starRateStackView.addArrangedSubviews(starRateView, rateLabel)
        
        starRateView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.centerY.equalToSuperview()
        }
        
        restaurantNameLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(200)
        }
        
        rateLabel.snp.makeConstraints { make in
            make.height.equalTo(13)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.leading.equalTo(logoImageView.snp.trailing).offset(16)
            make.centerY.equalTo(logoImageView)
        }
    }
}
