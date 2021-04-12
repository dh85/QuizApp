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
    let singleAnswerQuestion = Question.singleAnswer("Q1")
    let singleAnswerQuestion2 = Question.singleAnswer("Q2")
    let multipleAnswerQuestion = Question.multipleAnswer("Q1")

    lazy var sut: NavigationControllerRouter = {
        NavigationControllerRouter(navigationController, factory: factory)
    }()

    func test_routeToQuestion_showsQuestionController() {
        let viewController = UIViewController()
        let secondViewController = UIViewController()
        factory.stub(question: singleAnswerQuestion, with: viewController)
        factory.stub(question: singleAnswerQuestion2, with: secondViewController)

        sut.routeTo(question: singleAnswerQuestion, answerCallback: { _ in })
        sut.routeTo(question: singleAnswerQuestion2, answerCallback: { _ in })

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
        XCTAssertEqual(navigationController.viewControllers.last, secondViewController)
    }

    func test_routeToQuestion_singleAnswer_answerCallback_progressesToNextQuestion() {
        var callbackWasFired = false
        sut.routeTo(question: singleAnswerQuestion, answerCallback: { _ in callbackWasFired = true })
        factory.answerCallback[singleAnswerQuestion]!(["anything"])

        XCTAssertTrue(callbackWasFired)
    }

    func test_routeToQuestion_singleAnswer_doesNotConfigureViewControllerWithSubmitButton() {
        let viewController = UIViewController()
        factory.stub(question: singleAnswerQuestion, with: viewController)

        sut.routeTo(question: singleAnswerQuestion, answerCallback: { _ in })

        XCTAssertNil(viewController.navigationItem.rightBarButtonItem)
    }

    func test_routeToQuestion_multipleAnswer_answerCallback_doesNotProgressToNextQuestion() {
        var callbackWasFired = false
        sut.routeTo(question: multipleAnswerQuestion, answerCallback: { _ in callbackWasFired = true })
        factory.answerCallback[multipleAnswerQuestion]!(["anything"])

        XCTAssertFalse(callbackWasFired)
    }

    func test_routeToQuestion_multipleAnswer_configuresViewControllerWithSubmitButton() {
        let viewController = UIViewController()
        factory.stub(question: multipleAnswerQuestion, with: viewController)

        sut.routeTo(question: multipleAnswerQuestion, answerCallback: { _ in })

        XCTAssertNotNil(viewController.navigationItem.rightBarButtonItem)
    }

    func test_routeToQuestion_multipleAnswerSubmitButton_isDisabledWhenZeroAnswersSelected() {
        let viewController = UIViewController()
        factory.stub(question: multipleAnswerQuestion, with: viewController)

        sut.routeTo(question: multipleAnswerQuestion, answerCallback: { _ in })
        XCTAssertFalse(viewController.navigationItem.rightBarButtonItem!.isEnabled)

        factory.answerCallback[multipleAnswerQuestion]!(["anything"])
        XCTAssertTrue(viewController.navigationItem.rightBarButtonItem!.isEnabled)

        factory.answerCallback[multipleAnswerQuestion]!([])
        XCTAssertFalse(viewController.navigationItem.rightBarButtonItem!.isEnabled)
    }

    func test_routeToQuestion_multipleAnswerSubmitButton_progressesToNextQuestion() {
        let viewController = UIViewController()
        factory.stub(question: multipleAnswerQuestion, with: viewController)

        var callbackWasFired = false
        sut.routeTo(question: multipleAnswerQuestion, answerCallback: { _ in callbackWasFired = true })

        factory.answerCallback[multipleAnswerQuestion]!(["anything"])

        viewController.navigationItem.rightBarButtonItem?.simulateTap()

        XCTAssertTrue(callbackWasFired)
    }

    func test_routeToResult_showsResultController() {
        let viewController = UIViewController()
        let result = GameResult.make(answers: [singleAnswerQuestion: ["A1"]], score: 10)

        let secondViewController = UIViewController()
        let secondResult = GameResult.make(answers: [singleAnswerQuestion2: ["A2"]], score: 20)

        factory.stub(result: result, with: viewController)
        factory.stub(result: secondResult, with: secondViewController)

        sut.routeTo(result: result)
        sut.routeTo(result: secondResult)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
        XCTAssertEqual(navigationController.viewControllers.last, secondViewController)
    }


    // MARK: Helpers

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

        func resultsViewController(for userAnswers: Answers) -> UIViewController {
            UIViewController()
        }

        func resultsViewController(for result: GameResult<Question<String>, [String]>) -> UIViewController {
            stubbedResults[result] ?? UIViewController()
        }
    }

}

private extension UIBarButtonItem {
    func simulateTap() {
        target!.performSelector(onMainThread: action!, with: nil, waitUntilDone: true)
    }
}
