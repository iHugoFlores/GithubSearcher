//
//  UserDetailsViewModel.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserDetailsViewModel {
    
    private var userDetails: UserDetails!
    
    private var avatarImage: Data!
    
    init(userDetails: UserDetails, avatar: Data) {
        self.userDetails = userDetails
        self.avatarImage = avatar
    }
    
    func getTitle() -> String {
        return userDetails.login
    }
    
    func getUserAvatar() -> Data {
        return avatarImage
    }
    
    func getUserDescription() -> NSMutableAttributedString {
        let stringContent = NSMutableAttributedString(
            string: "\(userDetails.login)\n",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
        ])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var joinDate = ""
        if let date = dateFormatter.date(from: userDetails.createdAt) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            joinDate = dateFormatter.string(from: date)
        }
        
        stringContent.append(NSAttributedString(
            string: "\(userDetails.email)\n\(userDetails.location)\n\(joinDate)\n",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.gray]
        ))

        stringContent.append(NSAttributedString(
            string: "\(userDetails.followers) followers\nFollowing \(userDetails.following)",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.gray]
        ))
        return stringContent
    }
    
    func getUserBiography() -> String {
        return userDetails.bio
    }
}
