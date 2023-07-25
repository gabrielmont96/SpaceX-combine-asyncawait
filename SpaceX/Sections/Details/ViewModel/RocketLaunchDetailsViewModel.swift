//
//  RocketLaunchDetailsViewModel.swift
//  SpaceX
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 17/01/22.
//

import Foundation

enum RocketLaunchDetailsWebsite {
    case wikipedia
    case article
    case video
}

class RocketLaunchDetailsViewModel {
    private let links: Links
    
    var imageUrl: URL? {
        return links.smallImageUrl
    }
    
    init(links: Links) {
        self.links = links
    }
    
    func getUrl(for website: RocketLaunchDetailsWebsite) -> URL {
        let websiteUrl: String?
        switch website {
        case .article:
            websiteUrl = links.articleLink
        case .wikipedia:
            websiteUrl = links.wikipediaLink
        case .video:
            websiteUrl = links.videoLink
        }
        
        guard let urlString = websiteUrl,
              let url = URL(string: urlString) else {
            return URL(fileURLWithPath: "invalid url")
        }
        return url
    }
}
