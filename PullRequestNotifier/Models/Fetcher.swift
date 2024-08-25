//
//  Fetcher.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import Foundation

protocol FetcherProtocol {
    func getPullRequests(host: String, user: String, repository: String, token: String) async throws -> [PullRequest]
}

struct Fetcher: FetcherProtocol {

    func getPullRequests(host: String, user: String, repository: String, token: String) async throws -> [PullRequest] {

        guard [host, user, repository, token].allSatisfy({ !$0.isEmpty }),
              let url = URL(string: "https://\(host)/repos/\(user)/\(repository)/pulls?state=open") else {
            throw Error.invalidParameters
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.badResponse
        }
        var pulls = try JSONDecoder().decode([PullRequest].self, from: data)

        try await withThrowingTaskGroup(of: (Int, [Review]).self) { group in
            pulls.enumerated().forEach { offset, element in
                group.addTask {
                    (offset, try await self.getReview(host: host, user: user, repository: repository, token: token, number: element.number))
                }
            }
            for try await (index, reviews) in group {
                pulls[index].reviews = reviews
            }
        }

        return pulls
    }

    func getReview(host: String, user: String, repository: String, token: String, number: Int) async throws -> [Review] {

        guard [host, user, repository, token].allSatisfy({ !$0.isEmpty }),
              let url = URL(string: "https://\(host)/repos/\(user)/\(repository)/pulls/\(number)/reviews") else {
            throw Error.invalidParameters
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.badResponse
        }
        let reviews = try JSONDecoder().decode([Review].self, from: data)
        return reviews
    }
}
