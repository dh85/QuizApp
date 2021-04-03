//
//  BasicScore.swift
//  QuizApp
//
//  Created by David Hughes on 03/04/2021.
//

import Foundation

final class BasicScore {
    static func score(for answers: [String], comparingTo correctAnswers: [String]) -> Int {
        zip(answers, correctAnswers).reduce(0) { score, tuple in
            score + (tuple.0 == tuple.1 ? 1 : 0)
        }
    }
}
