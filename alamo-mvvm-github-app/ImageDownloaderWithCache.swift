//
//  ImageDownloaderWithCache.swift
//  alamo-mvvm-github-app
//  
//  Created by Seigetsu on 2023/12/17
//  
//

import Alamofire
import UIKit

actor ImageDownloaderWithCache {
    static let shared = ImageDownloaderWithCache()
    private var cache = [URL: UIImage?]()
    
    func image(url: URL) async throws -> UIImage? {
        if let cachedImage = cache[url] {
            return cachedImage
        }
        
        let image = try await downloadImage(url: url)
        
        cache[url] = cache[url, default: image]
        return image
    }
    
    private func downloadImage(url: URL) async throws -> UIImage? {
        let response = await AF.request(url).serializingData().result
        switch response {
        case .success(let data):
            return UIImage(data: data)
        case .failure(let error):
            throw error
        }
    }
}
