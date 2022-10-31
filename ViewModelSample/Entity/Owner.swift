import Foundation

struct Owner: Decodable {
  let id: Int
  let loginName: String
  let avatarUrl: String

  enum CodingKeys: String, CodingKey {
    case id
    case loginName = "login"
    case avatarUrl = "avatar_url"
  }
}
