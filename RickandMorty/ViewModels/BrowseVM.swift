//
//  BrowseVM.swift
//  RickandMorty
//
//  Created by Willie Earl on 9/24/25.
//

import Foundation
import SwiftUI

enum LoadState: Equatable {
    case idle, loading, loaded, failed(String)
}

enum Resource: String, CaseIterable, Identifiable {
    case characters = "Characters"
    case episodes = "Episodes"
    case locations = "Locations"
    var id: String { rawValue }
}

@MainActor
final class BrowseVM: ObservableObject {
    // UI state
    @Published var selected: Resource = .characters {
        didSet { resetForNewResource() }
    }
    @Published var searchText: String = "" {
        didSet { debounceSearch() }
    }
    @Published var state: LoadState = .idle
    @Published var info: Info? = nil

    // Data
    @Published var characters: [RMCharacter] = []
    @Published var episodes: [Episode] = []
    @Published var locations: [RMLocation] = []

    // Paging
    private var currentPage: Int = 1

    // Tasks
    private var loadTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?

    private let api = APIClient()

    // MARK: - Public
    func firstLoad() {
        guard case .idle = state else { return }
        load(page: 1, name: currentQuery)
    }

    func nextPage() {
        guard let i = info, i.next != nil else { return }
        load(page: currentPage + 1, name: currentQuery)
    }

    func prevPage() {
        guard let i = info, i.prev != nil else { return }
        load(page: max(1, currentPage - 1), name: currentQuery)
    }

    func applySearch() {
        // manual search trigger (e.g., .onSubmit)
        load(page: 1, name: currentQuery)
    }

    // MARK: - Private
    private var currentQuery: String? {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchText
    }

    private func resetForNewResource() {
        cancelLoad()
        // reset page and info
        currentPage = 1
        info = nil
        // clear other arrays for visual clarity
        switch selected {
        case .characters:
            episodes.removeAll()
            locations.removeAll()
        case .episodes:
            characters.removeAll()
            locations.removeAll()
        case .locations:
            characters.removeAll()
            episodes.removeAll()
        }
        state = .idle
        firstLoad()
    }

    private func debounceSearch() {
        // Stretch goal: ~300ms debounce and cancel previous search Task
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.load(page: 1, name: self?.currentQuery)
            }
        }
    }

    private func cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
    }

    private func load(page: Int, name: String?) {
        cancelLoad()
        state = .loading
        currentPage = page

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                switch selected {
                case .characters:
                    let resp = try await api.fetchCharacters(page: page, name: name)
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.characters = resp.results
                        self.info = resp.info
                        self.state = resp.results.isEmpty ? .loaded : .loaded
                    }

                case .episodes:
                    let resp = try await api.fetchEpisodes(page: page, name: name)
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.episodes = resp.results
                        self.info = resp.info
                        self.state = .loaded
                    }

                case .locations:
                    let resp = try await api.fetchLocations(page: page, name: name)
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.locations = resp.results
                        self.info = resp.info
                        self.state = .loaded
                    }
                }
            } catch is CancellationError {
                // no-op
            } catch {
                await MainActor.run {
                    self.state = .failed(error.localizedDescription)
                }
            }
        }
    }
}
