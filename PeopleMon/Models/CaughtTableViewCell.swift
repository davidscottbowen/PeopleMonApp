//
//  CaughtTableViewCell.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/10/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit

class CaughtTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
    var people: People!
    
    func convertBase64ToImage(base64String: String?) -> UIImage? {
        if let base64String = base64String, let photoData = NSData(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: photoData as Data)
        }
        return #imageLiteral(resourceName: "blankAvatar")
    }
    
    func setupCell(people: People) {
        self.people = people
        cellTitle.text = people.username
        cellImage.image = convertBase64ToImage(base64String: people.avatar)
    }
}


