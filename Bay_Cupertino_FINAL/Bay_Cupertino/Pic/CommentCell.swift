//
//  CommentCell.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/9/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

/*
    TODO DYNAMIC CELL HEIGHT
*/

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var commentTxt: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Configure the view for the selected state
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        commentTxt.translatesAutoresizingMaskIntoConstraints = false
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-5-[username]-(-2)-[comment]-5-|",
            options: [], metrics: nil, views: ["username":usernameBtn, "comment":commentTxt]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-15-[date]",
            options: [], metrics: nil, views: ["date":timestamp]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(40)]",
            options: [], metrics: nil, views: ["ava":profilePic]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(40)]-13-[comment]-20-|",
            options: [], metrics: nil, views: ["ava":profilePic, "comment":commentTxt]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[ava]-13-[username]",
            options: [], metrics: nil, views: ["ava":profilePic, "username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[date]-10-|",
            options: [], metrics: nil, views: ["date":timestamp]))
        
        
        // round ava
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //keep method in here...
    }

}
