//
//  CacheService.swift
//  To Do App Sample
//
//  Created by Shakhzod Botirov on 27/02/25.
//

import Foundation

final class CacheService {
    private let todosKey = "cached_todos"
    private let usersKey = "cached_users"
    
    func saveTodos(_ todos: [Todo]) {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.setValue(data, forKey: todosKey)
        }
    }
    
    func saveUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.setValue(data, forKey: usersKey)
        }
    }
    
    func getCachedTodos() -> [Todo]? {
        guard let data = UserDefaults.standard.data(forKey: todosKey) else { return nil }
        return try? JSONDecoder().decode([Todo].self, from: data)
    }
    
    func getCachedUsers() -> [User]? {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else { return nil }
        return try? JSONDecoder().decode([User].self, from: data)
    }
}
