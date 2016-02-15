//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// UsersViewController shows a list of users and their avatar images in a standard UITableView.
final class UsersViewController: UITableViewController {

    /// userViewModel is an immutable reference type whose internal parameters are expected to change.
    let usersViewModel: UsersViewModel
    
    init(usersViewModel: UsersViewModel) {
        self.usersViewModel = usersViewModel
        super.init(style: .Plain)
        
        title = "User List"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        tableView.rowHeight = 70
        tableView.delegate = self
        tableView.dataSource = self
        
        /// reloadSignal triggers a full tableView reload.
        usersViewModel.reloadSignal
            .observeOn(UIScheduler())
            .observeNext { [weak tableView] _ in
                tableView?.reloadData()
            }
        
        /// reloadIndexPathsSignal triggers only the reload of indicies that have changed as determined by the view model.
        /// Additionally, we intersect with the visible rows as to not refresh rows that are not in the current viewport.
        /// The view controller could arguably ask for the view model to do this calculation for it.
        /// Note, we set the view model on the cell directly instead of calling `tableView.reloadRowsAtIndexPaths` because the latter
        /// will cause the tableView to recalculate its entire height on the main thread, causing stalls and poor performance.
        usersViewModel.reloadIndexPathsSignal
            .observeOn(UIScheduler())
            .observeNext { [unowned self] indexPaths in
                guard let tableView = self.tableView, indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else { return }
                let visibleRowsSet = Set(indexPathsForVisibleRows)
                let changedIndexPathsSet = Set(indexPaths)
                let intersectingIndexPathsSet = visibleRowsSet.intersect(changedIndexPathsSet)
                let intersectingIndexPaths = Array(intersectingIndexPathsSet)
                if !intersectingIndexPaths.isEmpty {
                    intersectingIndexPaths.forEach { indexPath in
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? UserCell {
                            cell.userViewModel = self.userViewModelAtIndexPath(indexPath)
                        }
                    }
                }
            }
    }
    
    /// Naively fetch the underlying user data on each viewDidAppear.
    /// We could optimize this depending on the use case.
    override func viewDidAppear(animated: Bool) {
        usersViewModel.fetchUserViewModels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // TODO: tell the viewModel which indexPaths are visible so it may clear the image data from the rest.
    }
    
    // MARK: - Private
    
    func userViewModelAtIndexPath(indexPath: NSIndexPath) -> UserViewModel? {
        return usersViewModel.userViewModels?[indexPath.row]
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersViewModel.userViewModels?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserCell.reuseIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    /// Pair a userViewModel with a userCell. Then alert the usersViewModel that this indexPath is now "active".
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! UserCell
        cell.userViewModel = userViewModelAtIndexPath(indexPath)
        usersViewModel.activateIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

