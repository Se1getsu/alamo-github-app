//
//  Repository.swift
//  alamo-mvvm-github-app
//  
//  Created by Seigetsu on 2023/12/16
//  
//

import Alamofire

enum APIError: Error {
    case authorizationFailed
    case unknownError(AFError)
}

struct Repository {
    func getMyGitRepositories() async throws -> [GitRepository] {
        let url = "https://api.github.com/user/repos"
        let parameters = [String: String]()
        let headers: HTTPHeaders = [
            "Accept": "application/vnd.github+json",
            "Authorization": "Bearer \(AccessTokens.gitHubAccessToken)",
            "X-GitHub-Api-Version": "2022-11-28"
        ]
        let response = await AF.request(url, parameters: parameters, headers: headers).serializingDecodable([GitRepository].self).response
        
        guard response.response?.statusCode != 401 else {
            throw APIError.authorizationFailed
        }
        switch response.result {
        case .success(let data):
            return data
            
        case .failure(let error):
            throw APIError.unknownError(error)
        }
    }
}
