import Foundation

struct Repository: Decodable {
  let id: Int
  let name: String
  let fullName: String
  let isPrivate: Bool
  let owner: Owner
  let url: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case fullName = "full_name"
    case isPrivate = "private"
    case owner
    case url
  }
}
