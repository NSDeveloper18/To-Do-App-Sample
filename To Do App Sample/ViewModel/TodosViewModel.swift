//
//  TodosViewModel.swift
//  To Do App Sample
//
//  Created by Shakhzod Botirov on 27/02/25.
//

import Foundation

class TodosViewModel {
    var allTodos: [Todo] = []
    var allUsers: [User] = []
    private(set) var filteredTodos: [Todo] = []
    
    var currentPage = 0
    let pageSize = 20
    
    var onDataUpdated: (() -> Void)?
    
    private var searchQuery: String = ""
    private var filterCompletion: Bool? = nil
    private var filterUserName: String? = nil // ✅ New user name filter
    
    func fetchData() {
        if let cachedTodos = CacheService().getCachedTodos(), let cachedUsers = CacheService().getCachedUsers() {
            self.allTodos = cachedTodos
            self.allUsers = cachedUsers
            self.resetPagination()
        }
        
        APIService.shared.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                APIService.shared.fetchUsers { result in
                    switch result {
                    case .success(let users):
                        self?.allTodos = todos
                        self?.allUsers = users
                        CacheService().saveTodos(todos)
                        CacheService().saveUsers(users)
                        self?.resetPagination()
                    case .failure:
                        break
                    }
                }
            case .failure:
                break
            }
        }
    }

    func resetPagination() {
        currentPage = 0
        filteredTodos = []
        loadMore()
    }

    func loadMore() {
        let start = currentPage * pageSize
        let end = min(start + pageSize, allTodos.count)
        
        if start < end {
            let newTodos = Array(allTodos[start..<end])
            filteredTodos.append(contentsOf: newTodos)
            currentPage += 1
            applyFilters() // ✅ Apply filters
        }
    }

    func search(query: String) {
        searchQuery = query
        applyFilters()
    }
    
    func filterByCompletion(isCompleted: Bool?) {
        filterCompletion = isCompleted
        applyFilters()
    }

    func filterByUser(name: String?) {
        filterUserName = name
        applyFilters()
    }

    private func applyFilters() {
        var results = allTodos
        
        if let isCompleted = filterCompletion {
            results = results.filter { $0.completed == isCompleted }
        }
        
        if let userName = filterUserName, !userName.isEmpty {
            results = results.filter { todo in
                let user = allUsers.first(where: { $0.id == todo.userId })?.name ?? ""
                return user == userName
            }
        }
        
        if !searchQuery.isEmpty {
            results = results.filter { todo in
                let userName = allUsers.first(where: { $0.id == todo.userId })?.name ?? ""
                return todo.title.localizedCaseInsensitiveContains(searchQuery) || userName.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        filteredTodos = Array(results.prefix(currentPage * pageSize)) // ✅ Apply pagination
        
        DispatchQueue.main.async {
            self.onDataUpdated?()
        }
    }
}



