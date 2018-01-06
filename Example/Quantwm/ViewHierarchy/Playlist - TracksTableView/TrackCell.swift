//
//  TrackCell.swift
//  deezer
//
//  Created by Xavier Lasne on 03/12/2017.
//  Copyright  MIT License
//

import UIKit

struct TrackInfo {
    let trackLabel: String
    let artistLabel: String
    let duration: String
    let evenRow: Bool
}

@IBDesignable
class TrackCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBOutlet var trackLabel: UILabel?
    @IBOutlet var artistLabel: UILabel?
    @IBOutlet var duration: UILabel?

// MARK: Cell Configuration
    func configureCell(track: TrackInfo) {
        self.trackLabel?.text = track.trackLabel
        self.artistLabel?.text = track.artistLabel
        self.duration?.text = track.duration

        if track.evenRow {
            self.contentView.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
        } else {
            self.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 73.0/255.0, blue: 73.0/255.0, alpha: 1)
        }
    }
}


