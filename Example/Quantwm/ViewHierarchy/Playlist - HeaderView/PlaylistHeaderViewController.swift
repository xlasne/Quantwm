//
//  PlaylistHeaderViewController.swift
//  deezer
//
//  Created by Xavier on 03/12/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import UIKit
import Quantwm

class PlaylistHeaderViewController: UIViewController, MyModel {

    // Xib view allows to have IBInspectable Views in storyboard
    @IBOutlet weak var headerContainerView: XibView!
    var headerView: PlaylistHeaderView! {
        return headerContainerView.contentView as! PlaylistHeaderView
    }

    var viewModel: PlaylistHeaderViewModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)

        viewModel = PlaylistHeaderViewModel(dataModel: dataModel, owner: "PlaylistViewController")
        viewModel?.updateActionAndRefresh {
            viewModel?.registerObserver(
                target: self,
                registrationDesc: PlaylistHeaderViewController.playlistREG)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.unregisterDataSet(target: self)
        viewModel = nil
    }

    static let playlistREG: QWRegistration = QWRegistration(
        selector: #selector(PlaylistHeaderViewController.playlistUpdated),
        qwMap: PlaylistHeaderViewModel.currentPlaylistHeaderMap,
        name: "PlaylistHeaderViewController.playlistUpdated")
    
    @objc func playlistUpdated() {
        if let info = viewModel?.playlistHeaderInfoSelectedPlaylist() {
            headerView.configure(headerInfo: info)
        }
    }

}
