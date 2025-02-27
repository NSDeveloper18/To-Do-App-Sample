//
//  TodoDetailViewController.swift
//  To Do App Sample
//
//  Created by Shakhzod Botirov on 27/02/25.
//

import UIKit

class TodoDetailViewController: UIViewController {
    private let todo: Todo
    private let user: User

    private let titleLabel = UILabel()
    private let completedLabel = UILabel()
    private let userNameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()

    init(todo: Todo, user: User) {
        self.todo = todo
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Todo Details"

        let stackView = UIStackView(arrangedSubviews: [titleLabel, completedLabel, userNameLabel, emailLabel, phoneLabel])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func displayData() {
        titleLabel.text = "📌 Title: \(todo.title)"
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 3
        titleLabel.font = UIFont.systemFont(ofSize: 18)

        completedLabel.text = todo.completed ? "✅ Completed" : "❌ Not Completed"
        completedLabel.textColor = todo.completed ? .green : .red

        userNameLabel.text = "👤 Name: \(user.name)"
        emailLabel.text = "📧 Email: \(user.email)"
        phoneLabel.text = "📞 Phone: \(user.phone)"
    }
}

