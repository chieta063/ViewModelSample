import Foundation
import Moya
import RxMoya
import RxSwift

enum APIError: Error, LocalizedError {
  case failure

  var errorDescription: String? {
    return "Error"
  }
}

protocol GitHubAPI {
  func fetchUserRepositories(userName: String) -> Single<[Repository]>
  func searchRepository(word: String) -> Single<SearchRepositoryResult>
}

class GitHubAPIImpl: GitHubAPI {
  private let provider = MoyaProvider<GitHubAPIService>()

  func fetchUserRepositories(userName: String) -> Single<[Repository]> {
    provider.rx.request(.ownRepositories(userName))
      .map { response -> Data in
        guard response.statusCode == 200 else {
          throw APIError.failure
        }
        return response.data
      }
      .asObservable()
      .decode(type: [Repository].self, decoder: JSONDecoder())
      .asSingle()
      .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
      .observe(on: MainScheduler.instance)
  }
  
  func searchRepository(word: String) -> Single<SearchRepositoryResult> {
    provider.rx.request(.searchRepository(word))
      .map { response in
        guard response.statusCode == 200 else {
          throw APIError.failure
        }
        return response.data
      }
      .asObservable()
      .decode(type: SearchRepositoryResult.self, decoder: JSONDecoder())
      .asSingle()
      .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
      .observe(on: MainScheduler.instance)
  }
}
