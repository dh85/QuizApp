//
//  ResultHelper.swift
//  QuizAppTests
//
//  Created by David Hughes on 01/04/2021.
//

import Foundation
@testable import QuizEngine

extension GameResult {
    static func make(answers: [Question: Answer] = [:], score: Int = 0) -> GameResult<Question, Answer> {
        GameResult(answers: answers, score: score)
    }
}

extension GameResult: Equatable where Answer: Equatable {
    public static func == (lhs: GameResult<Question, Answer>, rhs: GameResult<Question, Answer>) -> Bool {
        lhs.score == rhs.score && lhs.answers == rhs.answers
    }
}

extension GameResult: Hashable where Answer: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(answers)
        hasher.combine(score)
    }
}
