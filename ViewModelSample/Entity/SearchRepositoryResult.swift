//
//  SearchRepositoryResult.swift
//  ViewModelSample
//
//  Created by 阿部 紘明 on 2022/10/27.
//

import Foundation

struct SearchRepositoryResult: Decodable {
  let totalCount: Int
  let items: [Repository]
  
  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case items
  }
}
