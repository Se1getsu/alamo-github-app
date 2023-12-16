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
}

protocol PresenterOutput {
    /// `PresenterInput`の`gitRepositories`の変更を反映させる。
    func reflectGitRepositoriesChanges()
    
    /// エラーメッセージを表示する。ユーザには [再試行] および [キャンセル] の選択肢を与える。
    func showRetryOrCancelAlert(title: String, message: String, retryEvent: () -> (), cancelEvent: () -> ())
}

class Presenter {
    private let repository: Repository
    private var gitReposiotries = [GitRepository]()
    
    init(repository: Repository) {
        self.repository = repository
    }
}
