//
//  UserDetails.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct UserDetails: Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url, htmlURL, followersURL: String
    let followingURL, gistsURL, starredURL: String
    let subscriptionsURL, organizationsURL, reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let siteAdmin: Bool
    let location, email: String?
    let hireable: Bool?
    let bio: String?
    let publicRepos, publicGists, followers, following: Int
    let createdAt, updatedAt: String

    private enum CodingKeys: String, CodingKey {
        case login, id, url
        case location, email, hireable, bio, followers, following
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case siteAdmin = "site_admin"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension UserDetails {
    typealias Completion = (Result<Self, NetworkError>) -> Void
    typealias CompletionWithResponse = (Result<Self, NetworkError>, HTTPURLResponse?) -> Void
    private static var endpoint: URL = {
        var urlC = URLComponents()
        urlC.scheme = "https"
        urlC.host = "api.github.com"
        urlC.path = "/users"
        return urlC.url!
    }()
    
    static func getUserDetails(networkManager: NetworkManager, user: String, callback: @escaping CompletionWithResponse) {
        guard var urlC = URLComponents(url: endpoint, resolvingAgainstBaseURL: true) else { return }
        urlC.path += "/\(user)"
        guard let url = urlC.url else { return }
        networkManager.getRESTDataFrom(url: url) { (result: Result<Self, NetworkError>, response) in
            callback(result, response)
        }
    }
}
