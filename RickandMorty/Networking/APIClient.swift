import Foundation

struct APIClient {
    private let baseURL = URL(string: "https://rickandmortyapi.com/api")!

    private func buildURL(path: String, query: [URLQueryItem]?) throws -> URL {
        var comps = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        comps?.queryItems = query?.isEmpty == true ? nil : query
        guard let url = comps?.url else { throw URLError(.badURL) }
        return url
    }

    private func get(_ path: String, query: [URLQueryItem]? = nil) async throws -> Data {
        let url = try buildURL(path: path, query: query)
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    // MARK: - Characters
    func fetchCharacters(page: Int?, name: String?) async throws -> CharactersResponse {
        var items: [URLQueryItem] = []
        if let page { items.append(.init(name: "page", value: String(page))) }
        if let name, !name.isEmpty { items.append(.init(name: "name", value: name)) }
        let data = try await get("character", query: items.isEmpty ? nil : items)
        return try JSONDecoder().decode(CharactersResponse.self, from: data)
    }

    // MARK: - Episodes
    func fetchEpisodes(page: Int?, name: String?) async throws -> EpisodesResponse {
        var items: [URLQueryItem] = []
        if let page { items.append(.init(name: "page", value: String(page))) }
        if let name, !name.isEmpty { items.append(.init(name: "name", value: name)) }
        let data = try await get("episode", query: items.isEmpty ? nil : items)
        return try JSONDecoder().decode(EpisodesResponse.self, from: data)
    }

    // MARK: - Locations
    func fetchLocations(page: Int?, name: String?) async throws -> LocationsResponse {
        var items: [URLQueryItem] = []
        if let page { items.append(.init(name: "page", value: String(page))) }
        if let name, !name.isEmpty { items.append(.init(name: "name", value: name)) }
        let data = try await get("location", query: items.isEmpty ? nil : items)
        return try JSONDecoder().decode(LocationsResponse.self, from: data)
    }
}
