import Foundation

// MARK: - Shared envelope
public struct Info: Codable, Hashable {
    public let count: Int
    public let pages: Int
    public let next: String?
    public let prev: String?
}

// MARK: - Characters
public struct CharactersResponse: Codable, Hashable {
    public let info: Info
    public let results: [RMCharacter]
}

public struct RMCharacter: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let image: String
    public let episode: [String]
}

// MARK: - Episodes
public struct EpisodesResponse: Codable, Hashable {
    public let info: Info
    public let results: [Episode]
}

public struct Episode: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let air_date: String
    public let episode: String   // e.g. "S01E01"
}

// MARK: - Locations
public struct LocationsResponse: Codable, Hashable {
    public let info: Info
    public let results: [RMLocation]
}

public struct RMLocation: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let type: String
    public let dimension: String
    public let residents: [String]
}

