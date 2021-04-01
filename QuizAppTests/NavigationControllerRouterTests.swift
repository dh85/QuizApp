//
//  NavigationControllerRouterTests.swift
//  QuizAppTests
//
//  Created by David Hughes on 01/04/2021.
//

import QuizEngine
import XCTest
@testable import QuizApp
@testable import QuizEngine

class NavigationControllerRouterTests: XCTestCase {

    let navigationController = NonAnimatedNavigationController()
    let factory = ViewControllerFactoryStub()

    lazy var sut: NavigationControllerRouter = {
        NavigationControllerRouter(navigationController, factory: factory)
    }()

    func test_routeToQuestion_showsQuestionController() {
        let viewController = UIViewController()
        let secondViewController = UIViewController()
        factory.stub(question: Question.singleAnswer("Q1"), with: viewController)
        factory.stub(question: Question.singleAnswer("Q2"), with: secondViewController)

        sut.routeTo(question: Question.singleAnswer("Q1"), answerCallback: { _ in })
        sut.routeTo(question: Question.singleAnswer("Q2"), answerCallback: { _ in })

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
        XCTAssertEqual(navigationController.viewControllers.last, secondViewController)
    }

    func test_routeToQuestion_presentsQuestionControllerWithRightCallback() {
        var callbackWasFired = false
        sut.routeTo(question: Question.singleAnswer("Q1"), answerCallback: { _ in callbackWasFired = true })
        factory.answerCallback[Question.singleAnswer("Q1")]!(["anything"])

        XCTAssertTrue(callbackWasFired)
    }

    func test_routeToResult_showsResultController() {
        let viewController = UIViewController()
        let result = GameResult.make(answers: [Question.singleAnswer("Q1"): ["A1"]], score: 10)

        let secondViewController = UIViewController()
        let secondResult = GameResult.make(answers: [Question.singleAnswer("Q2"): ["A2"]], score: 20)

        factory.stub(result: result, with: viewController)
        factory.stub(result: secondResult, with: secondViewController)

        sut.routeTo(result: result)
        sut.routeTo(result: secondResult)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
        XCTAssertEqual(navigationController.viewControllers.last, secondViewController)
    }

    class NonAnimatedNavigationController: UINavigationController {
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            super.pushViewController(viewController, animated: false)
        }
    }

    class ViewControllerFactoryStub: ViewControllerFactory {
        private var stubbedQuestions = [Question<String>: UIViewController]()
        private var stubbedResults = [GameResult<Question<String>, [String]>: UIViewController]()
        var answerCallback = [Question<String>: ([String]) -> Void]()

        func stub(question: Question<String>, with viewController: UIViewController) {
            stubbedQuestions[question] = viewController
        }

        func stub(result: GameResult<Question<String>, [String]>, with viewController: UIViewController) {
            stubbedResults[result] = viewController
        }

        func questionViewController(for question: Question<String>, answerCallback: @escaping ([String]) -> Void) -> UIViewController {
            self.answerCallback[question] = answerCallback
            return stubbedQuestions[question] ?? UIViewController()
        }

        func resultsViewController(for result: GameResult<Question<String>, [String]>) -> UIViewController {
            return stubbedResults[result] ?? UIViewController()
        }
    }

}

extension GameResult: Hashable {
    public static func == (lhs: GameResult<Question, Answer>, rhs: GameResult<Question, Answer>) -> Bool {
        lhs.score == rhs.score
    }

    static func make(answers: [Question: Answer] = [:], score: Int = 0) -> GameResult<Question, Answer> {
        GameResult(answers: answers, score: score)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(1)
    }
}
