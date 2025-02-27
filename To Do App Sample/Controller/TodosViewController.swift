//
//  TodosViewController.swift
//  To Do App Sample
//
//  Created by Shakhzod Botirov on 27/02/25.
//

import UIKit

class TodosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let viewModel = TodosViewModel()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let loadingLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        showLoader()
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.tableView.reloadData()
                self?.showNoResultsIfNeeded()
            }
        }

        viewModel.fetchData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Todos List"
      
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterMenu))

        searchBar.delegate = self
        searchBar.placeholder = "Search by title or user name"
        searchBar.scopeButtonTitles = ["All", "Completed", "Not Completed"] 
        searchBar.showsScopeBar = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

       
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        view.addSubview(tableView)

        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showLoader() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }

    private func hideLoader() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }

    private func showNoResultsIfNeeded() {
        loadingLabel.text = viewModel.filteredTodos.isEmpty ? "No results found." : nil
        loadingLabel.isHidden = !viewModel.filteredTodos.isEmpty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTodos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        let todo = viewModel.filteredTodos[indexPath.row]
        let user = viewModel.allUsers.first(where: { $0.id == todo.userId })?.name ?? "Unknown User"
        
        cell.titleLabel.attributedText = highlightSearchText(todo.title, query: searchBar.text ?? "")
       
        cell.userLabel.attributedText = highlightSearchText("By: \(user)", query: searchBar.text ?? "")

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.filteredTodos.count - 1 {
            viewModel.loadMore()
        }
    }

    private func highlightSearchText(_ text: String, query: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        guard !query.isEmpty else { return attributedString }
        
        let range = (text as NSString).range(of: query, options: .caseInsensitive)
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range)
        }
        
        return attributedString
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            viewModel.filterByCompletion(isCompleted: nil)
        case 1:
            viewModel.filterByCompletion(isCompleted: true)
        case 2:
            viewModel.filterByCompletion(isCompleted: false)
        default:
            break
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTodo = viewModel.filteredTodos[indexPath.row]
        guard let user = viewModel.allUsers.first(where: { $0.id == selectedTodo.userId }) else {
            return
        }

        let detailVC = TodoDetailViewController(todo: selectedTodo, user: user)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func showFilterMenu() {
        let alert = UIAlertController(title: "Filter by User", message: nil, preferredStyle: .actionSheet)
        
        for user in viewModel.allUsers {
            alert.addAction(UIAlertAction(title: user.name, style: .default) { _ in
                self.viewModel.filterByUser(name: user.name)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Clear Filter", style: .destructive) { _ in
            self.viewModel.filterByUser(name: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}






