import Foundation
import RxCocoa
import RxSwift

class MainViewModel {
  enum Transition {
    case searchRepository
    case error(String)
  }

  public let gitHubApi: GitHubAPI

  public let loadingSubject = BehaviorRelay<Bool>(value: false)
  public let repositoriesSubject = BehaviorRelay<[Repository]>(value: [])
  public let transitionSubject = PublishSubject<Transition>()
  private let disposeBag = DisposeBag()

  init(gitHubApi: GitHubAPI) {
    self.gitHubApi = gitHubApi
  }

  func onEndInputUserName(text: String) {
    loadingSubject.accept(true)
    gitHubApi.fetchUserRepositories(userName: text)
      .subscribe { [weak self] event in
        self?.loadingSubject.accept(false)
        switch event {
        case let .success(repositories):
          self?.repositoriesSubject.accept(repositories)
        case let .failure(error):
          self?.transitionSubject.onNext(.error(error.localizedDescription))
        }
      }
      .disposed(by: disposeBag)
  }

  func onTapMoveSearchRepositoryButton() {
    transitionSubject.onNext(.searchRepository)
  }
}
