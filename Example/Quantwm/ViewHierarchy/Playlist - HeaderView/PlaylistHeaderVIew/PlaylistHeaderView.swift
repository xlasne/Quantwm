//
//  PlaylistHeaderView.swift
//  deezer
//
//  Created by Xavier Lasne on 03/12/2017.
//  Copyright  MIT License
//

import UIKit

struct PlaylistHeaderInfo {
    let playlistID: PlaylistID?
    let title: String?
    let imageUrl: URL?
    let largeImageUrl: URL?
    let durationTime: String?
    let playlistAuthor: String?
    let total: String?
}


@IBDesignable
class PlaylistHeaderView: UIView {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var playlistAuthor: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func configure(headerInfo: PlaylistHeaderInfo) {

        let placeholderImage = UIImage(named: "placeholder")!
        if let url = headerInfo.imageUrl {
            coverImageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        } else {
            coverImageView.image = placeholderImage
        }
        if let url = headerInfo.largeImageUrl {
            coverImageView.af_setImage(withURL: url)
        }

        playlistName.text = headerInfo.title ?? "..."
        playlistAuthor.text = headerInfo.playlistAuthor ?? "..."
        durationTime.text = headerInfo.durationTime ?? "..."
        totalLabel.text = headerInfo.total ?? ""
    }

}
