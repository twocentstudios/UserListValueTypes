//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import UIKit
import ReactiveCocoa

class UsersViewController: UITableViewController {

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
        
        usersViewModel.reloadSignal
            .observeOn(UIScheduler())
            .observeNext { [weak tableView] _ in
                tableView?.reloadData()
            }
        
        usersViewModel.reloadIndexPathsSignal
            .observeOn(UIScheduler())
            .observeNext { [weak tableView] indexPaths in
                guard let tableView = tableView, indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else { return }
                let visibleRowsSet = Set(indexPathsForVisibleRows)
                let changedIndexPathsSet = Set(indexPaths)
                let intersectingIndexPathsSet = visibleRowsSet.intersect(changedIndexPathsSet)
                let intersectingIndexPaths = Array(intersectingIndexPathsSet)
                if !intersectingIndexPaths.isEmpty {
                    tableView.reloadRowsAtIndexPaths(intersectingIndexPaths, withRowAnimation: .None)
                }
            }
    }
    
    override func viewDidAppear(animated: Bool) {
        usersViewModel.fetchUserViewModels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! UserCell
        cell.userViewModel = usersViewModel.userViewModels?[indexPath.row]
        usersViewModel.activateIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

