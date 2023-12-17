//
//  Model.swift
//  alamo-mvvm-github-app
//  
//  Created by Seigetsu on 2023/12/16
//  
//

import Foundation

struct GitRepository: Codable {
    let id: Int
    let name: String
    let fullName: String
    let htmlURL: String
    let description: String?
    let visibility: String
    let owner: Owner
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case htmlURL = "html_url"
        case description
        case visibility
        case owner
    }
}

struct Owner: Codable {
    let id: Int
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatarURL = "avatar_url"
    }
}
