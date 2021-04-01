//
//  iOSViewControllerFactory.swift
//  QuizApp
//
//  Created by David Hughes on 01/04/2021.
//

import UIKit
import QuizEngine

class iOSViewControllerFactory: ViewControllerFactory {
    private let options: [Question<String>: [String]]

    init(options: [Question<String>: [String]]) {
        self.options = options
    }

    func questionViewController(for question: Question<String>, answerCallback: @escaping ([String]) -> Void) -> UIViewController {
        switch question {
        case .singleAnswer(let value):
            return QuestionViewController(question: value, options: options[question]!, selection: answerCallback)
        default:
            return UIViewController()
        }
    }

    func resultsViewController(for result: GameResult<Question<String>, [String]>) -> UIViewController {
        return UIViewController()
    }
}
