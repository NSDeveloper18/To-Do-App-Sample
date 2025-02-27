//
//  APIService.swift
//  To Do App Sample
//
//  Created by Shakhzod Botirov on 27/02/25.
//

import Foundation

final class APIService {
    static let shared = APIService()
    
    private let todosURL = "https://jsonplaceholder.typicode.com/todos"
    private let usersURL = "https://jsonplaceholder.typicode.com/users"
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        fetch(urlString: todosURL, completion: completion)
    }
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(urlString: usersURL, completion: completion)
    }
    
    private func fetch<T: Codable>(urlString: String, completion: @escaping (Result<[T], Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode([T].self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
