//
//  ViewModel.swift
//  alamo-mvvm-github-app
//  
//  Created by Seigetsu on 2023/12/16
//  
//

import Foundation

protocol PresenterInput {
    /// 画面に表示するGitリポジトリのリスト。
    var gitRepositories: [GitRepository] { get }
    
    /// viewDidLoadで呼び出される処理。
    func viewDidLoad()
    
    /// Gitリポジトリが選択された時の処理。
    func didSelectGitRepository(at indexPath: IndexPath)
    
    /// 検索が行われた時の処理。
    /// - parameter targetText: 検索対象の文字列。
    func didTapSearchButton(targetText: String)
    
    /// 検索のキャンセルが行われた時の処理。
    func didTapSearchCancelButton()
}

protocol PresenterOutput: AnyObject {
    /// `PresenterInput`の`gitRepositories`の変更を反映させる。
    func reflectGitRepositoriesChanges()
    
    /// エラーメッセージを表示する。ユーザには [再試行] および [キャンセル] の選択肢を与える。
    func showRetryOrCancelAlert(title: String, message: String, retryEvent: @escaping () -> ())
}

class Presenter {
    private weak var view: PresenterOutput!
    private let repository: Repository
    private(set) var gitRepositories = [GitRepository]()
    
    init(view: PresenterOutput, repository: Repository) {
        self.view = view
        self.repository = repository
    }
    
    func fetchGitRepositoriesAndUpdateView() {
        Task {
            do {
                gitRepositories = try await repository.getMyGitRepositories()
                await MainActor.run {
                    view.reflectGitRepositoriesChanges()
                }
            } catch {
                switch error {
                case APIError.authorizationFailed:
                    await MainActor.run {
                        view.showRetryOrCancelAlert(title: "認証エラー", message: "認証に失敗しました。\n再試行しますか？", retryEvent: self.fetchGitRepositoriesAndUpdateView)
                    }
                    
                case APIError.unknownError(let error):
                    print(error)
                    await MainActor.run {
                        view.showRetryOrCancelAlert(title: "通信エラー", message: "通信時にエラーが発生しました。\n再試行しますか？", retryEvent: self.fetchGitRepositoriesAndUpdateView)
                    }
                    
                default:
                    print(error)
                    await MainActor.run {
                        view.showRetryOrCancelAlert(title: "エラー", message: "エラーが発生しました。\n再試行しますか？", retryEvent: self.fetchGitRepositoriesAndUpdateView)
                    }
                }
            }
        }
    }
}

extension Presenter: PresenterInput {
    func viewDidLoad() {
        fetchGitRepositoriesAndUpdateView()
    }
    
    func didSelectGitRepository(at indexPath: IndexPath) {
        print("Selected \(gitRepositories[indexPath.row].fullName)")
    }
    
    func didTapSearchButton(targetText: String) {
        print("Searched \(targetText)")
    }
    
    func didTapSearchCancelButton() {
        didTapSearchButton(targetText: "")
    }
}
