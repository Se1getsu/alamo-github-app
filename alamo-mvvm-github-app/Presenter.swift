//
//  ViewModel.swift
//  alamo-mvvm-github-app
//  
//  Created by Seigetsu on 2023/12/16
//  
//

import UIKit

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
    
    private func fetchGitRepositoriesAndUpdateView() {
        Task {
            do {
                gitRepositories = try await repository.getMyGitRepositories()
                await MainActor.run {
                    view.reflectGitRepositoriesChanges()
                }
            } catch {
                let content: (title: String, message: String)
                switch error {
                case APIError.authorizationFailed:
                    content = (title: "認証エラー", message: "認証に失敗しました。\n再試行しますか？")
                    
                case APIError.unknownError(let error):
                    content = (title: "通信エラー", message: "通信時にエラーが発生しました。\n再試行しますか？")
                    print(error)
                    
                default:
                    content = (title: "エラー", message: "エラーが発生しました。\n再試行しますか？")
                    print(error)
                }
                
                await MainActor.run {
                    view.showRetryOrCancelAlert(title: content.title, message: content.message, retryEvent: self.fetchGitRepositoriesAndUpdateView)
                }
            }
        }
    }
    
    private func openInBrowser(gitRepository: GitRepository) {
        let htmlURL = gitRepository.htmlURL
        guard let url = URL(string: htmlURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension Presenter: PresenterInput {
    func viewDidLoad() {
        fetchGitRepositoriesAndUpdateView()
    }
    
    func didSelectGitRepository(at indexPath: IndexPath) {
        openInBrowser(gitRepository: gitRepositories[indexPath.row])
    }
    
    func didTapSearchButton(targetText: String) {
        print("Searched \(targetText)")
    }
    
    func didTapSearchCancelButton() {
        didTapSearchButton(targetText: "")
    }
}
