//
//  PlaylistTableViewController.swift
//  deezer
//
//  Created by Xavier on 03/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import UIKit
import Quantwm

class TracklistTableViewController: UITableViewController, MyModel {

    fileprivate let cellIdentifier: String = "trackCell"

    fileprivate var viewModel: TrackListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // With this configuration, tableView.dequeueReusableCell shall always
        // provide nice TrackCell when needed
        tableView.register(TrackCell.self, forCellReuseIdentifier: cellIdentifier)
        let cellNib = UINib(nibName: "TrackCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let viewModel = TrackListViewModel(
            dataModel: dataModel,
            owner: "TracklistTableViewController",
            trackListCollectionModel: QWModel.root.trackListCollection)

        self.viewModel = viewModel
        viewModel.updateActionAndRefresh {
            viewModel.registerObserver(
                registration: tracklistREG(viewModel: viewModel),
                target: self,
                selector: #selector(TracklistTableViewController.updateTable))
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.unregisterDataSet(target: self)
        viewModel = nil
    }

    // MARK: - Update at creation, and on completion of track list network request
    // This request has been triggerred by NetworkMgr, who is monitoring the playlist selection
    func tracklistREG(viewModel: TrackListViewModel) -> QWRegistration {
        return QWRegistration(
        smartWithReadMap: viewModel.mapForTracksTableDataSource,
        name: "TracklistTableViewController.updateTable")
    }

    @objc func updateTable() {
        tableView.reloadData()
    }
}

// MARK: - Table view data source
extension TracklistTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.nbTracks ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TrackCell {         let trackInfo = viewModel?.trackInfo(indexPath: indexPath)
            ?? TrackListViewModel.errorTrackInfo(indexPath: indexPath)
            cell.configureCell(track: trackInfo)
            return cell
        } else {
            // Paranoid check
            assert(false,"shall never occurs: dequeueReusableCell is badly configured. Need table register cell type and cell nib")
            let cell = UITableViewCell(style: UITableViewCellStyle.default,
                                       reuseIdentifier: cellIdentifier)
            return cell
        }
    }
}

