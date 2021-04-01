//
//  UITableViewExtensions.swift
//  QuizApp
//
//  Created by David Hughes on 31/03/2021.
//

import UIKit

extension UITableView {
    func register(_ type: UITableViewCell.Type) {
        let className = String(describing: type)
        register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
    }

    func dequeueReusableCell<T>(for type: T.Type) -> T? {
        let className = String(describing: type)
        return dequeueReusableCell(withIdentifier: className) as? T
    }
}
