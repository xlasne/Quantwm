//
//  PlaylistHeaderViewController.swift
//  deezer
//
//  Created by Xavier on 03/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import UIKit
import Quantwm

class PlaylistHeaderViewController: UIViewController, Mediator {

    // Xib view allows to have IBInspectable Views in storyboard
    @IBOutlet weak var headerContainerView: XibView!
    var headerView: PlaylistHeaderView! {
        return headerContainerView.contentView as! PlaylistHeaderView
    }

    var viewModel: PlaylistHeaderViewModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)

        viewModel = PlaylistHeaderViewModel(mediator: qwMediator,
                                            owner: "PlaylistViewController")
        viewModel?.updateActionAndRefresh {
            viewModel?.registerObserver(
                registration: PlaylistHeaderViewController.playlistREG,
                target: self,
                selector: #selector(PlaylistHeaderViewController.playlistUpdated))
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.unregisterDataSet(target: self)
        viewModel = nil
    }

    static let playlistREG: QWRegistration = QWRegistration(
        smartWithReadMap: PlaylistHeaderViewModel.currentPlaylistHeaderMap,
        name: "PlaylistHeaderViewController.playlistUpdated")
    
    @objc func playlistUpdated() {
        if let info = viewModel?.playlistHeaderInfoSelectedPlaylist() {
            headerView.configure(headerInfo: info)
        }
    }

}
