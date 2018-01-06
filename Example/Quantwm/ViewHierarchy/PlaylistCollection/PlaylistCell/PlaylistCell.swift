//
//  PlaylistCell.swift
//  deezer
//
//  Created by Xavier Lasne on 02/12/2017.
//  Copyright  MIT License
//

import UIKit
import AlamofireImage

struct PlaylistCoverInfo {
    let playlistID: PlaylistID?
    let title: String?
    let imageUrl: URL?
}

class PlaylistCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var coverInfo: PlaylistCoverInfo?

    func configureCell(coverInfo: PlaylistCoverInfo?) {
        displayTitle(title: coverInfo?.title)

        let placeholderImage = UIImage(named: "placeholder")!
        if let url = coverInfo?.imageUrl {
            imageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        } else {
            imageView.image = placeholderImage
        }
    }

    func displayTitle(title: String?) {
        if let title = title {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.titleLabel.text = title
                self?.titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            }
        } else {
            titleLabel.text = ""
            titleLabel.backgroundColor = UIColor.clear
        }
    }

}
