//
//  SocialLoginEntity.swift
//  HealthFoodMe
//
//  Created by 강윤서 on 2022/07/18.
//

import Foundation

struct SocialLoginEntity: Codable {
    let user: UserAuth
    let accessToken, refreshToken: String
}

struct UserAuth: Codable {
    let _id: String
    let name: String
    let social: String
    let socialId: String
    let email: String
    let scrapRestaurants: [String]
    let refreshToken: String
    let __v: Int
}