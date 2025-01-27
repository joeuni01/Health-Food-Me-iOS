//
//  SocialLoginVC.swift
//  HealthFoodMe
//
//  Created by 강윤서 on 2022/07/05.
//

import UIKit

import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import SnapKit

class SocialLoginVC: UIViewController {

    var social: String = ""
    var accessToken: String = ""
    private let userManager = UserManager.shared

    // MARK: - Properties
    
    private var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = I18N.Auth.title
        lb.font = UIFont(name: AppFontName.GodoB, size: 58)
        lb.textColor = .mainRed
        lb.textAlignment = .center
        
        return lb
    }()
    
    private var subTitleLabel: UILabel = {
        let lb = UILabel()
        let boldFont = UIFont(name: AppFontName.appleSDGothicNeoBold, size: 14)!
        lb.text = I18N.Auth.subTitle
        lb.font = UIFont(name: AppFontName.appleSDGothicNeoMedium, size: 14)
        lb.textColor = .helfmeGray1
        lb.numberOfLines = 2
        lb.textAlignment = .center

        return lb
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
       let button = UIButton()
        button.setBackgroundImage(ImageLiterals.Auth.kakaoLoginBtn, for: .normal)
        return button
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(ImageLiterals.Auth.appleLoginBtn, for: .normal)
        return button
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setAddTarget()
    }
}

// MARK: - extension
extension SocialLoginVC {
    private func presentToMainMap() {
        let mainVC = ModuleFactory.resolve().makeMainMapNavigationController()
        mainVC.modalPresentationStyle = .overFullScreen
        self.present(mainVC, animated: false)
    }
    
    
    private func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if error != nil { self.showKakaoLoginFailMessage() } else {
                    if let accessToken = oauthToken?.accessToken {
                        // 엑세스 토큰 받아와서 서버에게 넘겨주는 로직 작성
                        self.accessToken = accessToken
                        self.social = "kakao"
                        print("TOKEN", accessToken)
                        
                        self.getUserId()
                    }
                }
            }
        } else { // 웹으로 로그인해도 똑같이 처리되도록
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if error != nil { self.showKakaoLoginFailMessage() } else {
                    if let accessToken = oauthToken?.accessToken {
                        self.accessToken = accessToken
                        self.social = "kakao"
                        print("TOKEN", accessToken)
                        
                        self.getUserId()
                    }
                }
            }
        }
    }
    
    private func getUserId() {
        UserApi.shared.me {(user, error) in
            if let error = error {
                print(error)
            } else {
                if let userID = user?.id {
                    self.userManager.setUserId(userId: String(userID))
                    self.userManager.setSocialType(isAppleLogin: false)
                    self.postSocialLoginData()
                }
            }
        }
    }
    
    private func showKakaoLoginFailMessage() {
        self.makeAlert(title: I18N.Alert.error, message: I18N.Auth.kakaoLoginError, okAction: nil, completion: nil)
    }
    
    private func postSocialLoginData() {
        AuthService.shared.requestAuth(social: social,
                                       token: accessToken) { networkResult in
            switch networkResult {
            case .success(let data):
                self.userManager.setSocialToken(token: self.accessToken)
                if let data = data as? SocialLoginEntity {
                    self.userManager.updateAuthToken(data.accessToken, data.refreshToken)
                    self.userManager.setCurrentUser(data.user)
                }
                self.presentToMainMap()
            case .requestErr(let message):
                print("SocialLogin - requestErr: \(message)")
            case .pathErr:
                print("SocialLogin - pathErr")
            case .serverErr:
                print("SocialLogin - serverErr")
            case .networkFail:
                print("SocialLogin - networkFail")
            }
        }
    }
    
    private func appleLogin() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    private func setLayout() {
        view.addSubviews(titleLabel, subTitleLabel, kakaoLoginButton, appleLoginButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(140)
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        let loginButtonWidth = UIScreen.main.bounds.width - 100
        appleLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(120)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(loginButtonWidth * 41/275)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(appleLoginButton.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(loginButtonWidth * 41/275)
        }
    }
    
    private func setAddTarget() {
        kakaoLoginButton.addTarget(self, action: #selector(doKakaoLogin), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(doAppleLogin), for: .touchUpInside)
    }
    
    // MARK: - @objc Methods
    @objc func doKakaoLogin() {
        kakaoLogin()
    }
    
    @objc func doAppleLogin() {
        appleLogin()
    }
}

extension SocialLoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SocialLoginVC: ASAuthorizationControllerDelegate {
    // Apple ID 연동 성공시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential :
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID : \(userIdentifier)")
            print("User Email : \(email ?? "")")
            print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
            
            let identityToken = appleIDCredential.identityToken
            let tokenString = String(data: identityToken!, encoding: .utf8)
            
            userManager.setSocialType(isAppleLogin: true)
            userManager.setUserId(userId: userIdentifier)
            
            if let token = tokenString {
                self.accessToken = token
                self.social = "apple"
                postSocialLoginData()
            }
            
            
        default:
            // 실패 시 실패VC로 이동
            print("애플아이디 로그인 실패")
        }
    }
}
