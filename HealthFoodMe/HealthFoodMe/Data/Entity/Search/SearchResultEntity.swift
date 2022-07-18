//
//  SearchResultEntity.swift
//  HealthFoodMe
//
//  Created by 김영인 on 2022/07/19.
//

import Foundation

struct SearchResultEntity: Codable {
    let _id: String
    let name: String
    let category: String
    let score: Double
    let distance: Int
    let logo: String
}
