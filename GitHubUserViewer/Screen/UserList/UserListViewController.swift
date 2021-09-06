//
//  UserListViewController.swift
//  GitHubUserViewer
//
//  Created by Reimi Matsumoto on 2021/09/05.
//

import UIKit

final class UserListViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    private var viewModel = UserListViewModel()
    private var contentTableViewController = UserListContentViewController.instantiate()
    private var errorViewController = ErrorViewController.instantiate()
    private var searchText: String? {
        didSet {
            search(by: searchText)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupSubviews()
    }
    
    static func instantieate() -> UserListViewController {
        return R.storyboard.userListViewController.instantiateInitialViewController()!
    }
}

// MARK: - Private Functions
private extension UserListViewController {
    func setupSubviews() {
        loadingView.isHidden = true
        searchBar.delegate = self
        contentTableViewController.delegate = self
        errorViewController.action = { [weak self] in
            guard let self = self else { return }
            self.search(by: self.searchText)
        }
    }
    
    func search(by word: String?) {
        guard let word = word, !word.isEmpty else {
            showEmptyError()
            return
        }
        viewModel.search(by: word)
    }
    
    func showEmptyError() {
        UIAlertController
            .okAlert(message: R.string.localizable.error_empty()) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            .show(from: self)
    }
}

// MARK: - UISearchBarDelegate
extension UserListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text
    }
}

// MARK: - UserListContentViewControllerDelegate
extension UserListViewController: UserListContentViewControllerDelegate {
    func userListContentViewController(_ viewController: UserListContentViewController, didSelect user: User) {
        let viewController = UserDetailViewController.instantieate(user: user)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UserListViewModelDelegate
extension UserListViewController: UserListViewModelDelegate {
    func userListViewModel(_ viewModel: UserListViewModel, didUpdate state: UserListViewModelState) {
        switch state {
        case .idle:
            break
        case .loading:
            loadingView.startLoading()
        case .loaded:
            loadingView.stopLoading()
            add(contentTableViewController, container: containerView)
            contentTableViewController.updateUserList(viewModel.userList)
        case .error(let message):
            loadingView.stopLoading()
            add(errorViewController, container: containerView)
            errorViewController.setMessssge(message)
        }
    }
}
