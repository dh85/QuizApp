//
//  ResultsPresenter.swift
//  QuizApp
//
//  Created by David Hughes on 01/04/2021.
//

import Foundation
import QuizEngine

final class ResultsPresenter {
    typealias Answers = [(question: Question<String>, answers: [String])]
    typealias Scorer = ([[String]], [[String]]) -> Int

    private let userAnswers: Answers
    private let correctAnswers: Answers
    private let scorer: Scorer

    init(userAnswers: Answers, correctAnswers: Answers, scorer: @escaping Scorer) {
        self.userAnswers = userAnswers
        self.correctAnswers = correctAnswers
        self.scorer = scorer
    }

    init(result: GameResult<Question<String>, [String]>, questions: [Question<String>], correctAnswers: [Question<String>: [String]]) {
        self.userAnswers = questions.map { question in
            (question, result.answers[question]!)
        }
        self.correctAnswers = questions.map { question in
            (question, correctAnswers[question]!)
        }
        self.scorer = { _, _ in result.score }
    }

    var title: String {
        "Result"
    }

    var summary: String {
        "You got \(score)/\(userAnswers.count) correct"
    }

    private var score: Int {
        scorer(userAnswers.map { $0.answers }, correctAnswers.map { $0.answers })
    }

    var presentableAnswers: [PresentableAnswer] {
        zip(userAnswers, correctAnswers).map { userAnswer, correctAnswer in
            presentableAnswer(userAnswer.question, userAnswer.answers, correctAnswer.answers)
        }
    }

    private func presentableAnswer(_ question: Question<String>, _ userAnswer: [String], _ correctAnswer: [String]) -> PresentableAnswer {
        switch question {
        case .singleAnswer(let value), .multipleAnswer(let value):
            return PresentableAnswer(
                question: value,
                answer: formattedAnswer(correctAnswer),
                wrongAnswer: formattedWrongAnswer(userAnswer, correctAnswer)
            )
        }
    }

    private func formattedAnswer(_ answer: [String]) -> String {
        answer.joined(separator: ", ")
    }

    private func formattedWrongAnswer(_ userAnswer: [String], _ correctAnswer: [String]) -> String? {
        correctAnswer == userAnswer ? nil : formattedAnswer(userAnswer)
    }
}
