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
    let type: String
    let siteAdmin: Bool
    let name, company: String
    let blog: String
    let location, email: String
    let hireable: Bool
    let bio: String
    let publicRepos, publicGists, followers, following: Int
    let createdAt, updatedAt: String

    private enum CodingKeys: String, CodingKey {
        case login, id, url, type, name, company
        case blog, location, email, hireable, bio, followers, following
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
    static func loadDummyResponse(callback: @escaping Completion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            let data: Self = JSONUtil.load(name: "UserDetails")
            callback(Result.success(data))
        }
    }
}
