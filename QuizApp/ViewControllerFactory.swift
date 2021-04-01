//
//  ViewControllerFactory.swift
//  QuizApp
//
//  Created by David Hughes on 01/04/2021.
//

import UIKit
import QuizEngine

protocol ViewControllerFactory {
    func questionViewController(for question: Question<String>, answerCallback: @escaping ([String]) -> Void) -> UIViewController

    func resultsViewController(for result: GameResult<Question<String>, [String]>) -> UIViewController
}
