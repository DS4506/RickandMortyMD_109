import Foundation

struct APIClient {
    let baseURL = URL(string: "https://rickandmortyapi.com/api")!

    // Generic GET returning raw Data after status check
    func get(_ path: String, query: [URLQueryItem]? = nil) async throws -> Data {
        var comps = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        comps.queryItems = query
        let url = comps.url!

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }

    // Decode /character into CharactersResponse (with Info + [RMCharacter])
    func fetchCharacters(page: Int?, name: String?) async throws -> CharactersResponse {
        var items: [URLQueryItem] = []
        if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
        if let name = name, !name.isEmpty { items.append(URLQueryItem(name: "name", value: name)) }

        let data = try await get("character", query: items.isEmpty ? nil : items)
        let dec = JSONDecoder()
        return try dec.decode(CharactersResponse.self, from: data)
    }
}
