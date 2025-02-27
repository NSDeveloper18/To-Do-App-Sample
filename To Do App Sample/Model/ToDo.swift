//
//  ToDo.swift
//  To Do App Sample
//
//  Created by Shakhzod Botirov on 27/02/25.
//

import Foundation

struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
    let userId: Int
}
