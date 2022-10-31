//
//  SearchRepositoryViewModel.swift
//  ViewModelSample
//
//  Created by 阿部 紘明 on 2022/10/27.
//

import Foundation
import RxCocoa
import RxSwift

class SearchRepositoryViewModel {
  enum Transition {
    case pop
    case error(String)
  }
  
  public let loadingRelay = BehaviorRelay<Bool>(value: false)
  public let searchResultRelay = PublishRelay<[Repository]>()
  public let transitionSubject = PublishSubject<Transition>()
  
  private let githubAPI: GitHubAPI
  private let disposeBag = DisposeBag()
  
  init(githubAPI: GitHubAPI) {
    self.githubAPI = githubAPI
  }
  
  func onEndInputRepositoryName(text: String) {
    loadingRelay.accept(true)
    githubAPI.searchRepository(word: text)
      .subscribe { [weak self] event in
        self?.loadingRelay.accept(false)
        switch event {
        case .success(let searchResult):
          self?.searchResultRelay.accept(searchResult.items)
        case .failure(let error):
          self?.transitionSubject.onNext(.error(error.localizedDescription))
        }
      }
      .disposed(by: disposeBag)
  }
}
