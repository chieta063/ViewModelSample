import Foundation
import Moya

enum GitHubAPIService {
  case ownRepositories(String)
  case searchRepository(String)
}

extension GitHubAPIService: TargetType {
  var baseURL: URL {
    .init(string: "https://api.github.com/")!
  }

  var path: String {
    switch self {
    case let .ownRepositories(userName):
      return "users/\(userName)/repos"
    case .searchRepository:
      return "search/repositories"
    }
  }

  var method: Moya.Method {
    switch self {
    case .ownRepositories, .searchRepository:
      return .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .ownRepositories:
      return .requestPlain
    case .searchRepository(let word):
      return .requestParameters(parameters: ["q":word], encoding: URLEncoding.queryString)
    }
  }

  var headers: [String: String]? {
    return ["Content-type": "application/json"]
  }
}
