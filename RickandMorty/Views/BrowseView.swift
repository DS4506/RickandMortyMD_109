//
//  BrowseView.swift
//  RickandMorty
//
//  Created by Willie Earl on 9/24/25.
//

import SwiftUI

struct BrowseView: View {
    @StateObject private var vm = BrowseVM()

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack { content }
            } else {
                NavigationView { content }
            }
        }
        .task { vm.firstLoad() }
        .searchable(
            text: $vm.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search name"
        )
        .onSubmit(of: .search) { vm.applySearch() }
    }

    @ViewBuilder private var content: some View {
        VStack(spacing: 0) {
            Picker("Resource", selection: $vm.selected) {
                ForEach(Resource.allCases) { res in
                    Text(res.rawValue).tag(res)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .top])

            Group {
                switch vm.state {
                case .idle, .loading:
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                case .failed(let message):
                    VStack(spacing: 12) {
                        Text("Something went wrong").font(.headline)
                        Text(message).font(.subheadline).foregroundColor(.secondary)
                        Button("Retry") { vm.firstLoad() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding()

                case .loaded:
                    if currentItemsIsEmpty {
                        VStack(spacing: 8) {
                            Text("No results").font(.headline)
                            Text("Try a different name or clear the search.")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        listContent
                    }
                }
            }

            HStack(spacing: 12) {
                Button("Prev") { vm.prevPage() }
                    .buttonStyle(.bordered)
                    .disabled(vm.info?.prev == nil)

                Button("Next") { vm.nextPage() }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.info?.next == nil)

                Spacer()

                if let i = vm.info {
                    Text("Pages: \(i.pages)")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .lineLimit(1)
                }
            }
            .padding()
        }
        .navigationTitle("Rick & Morty")
    }

    private var currentItemsIsEmpty: Bool {
        switch vm.selected {
        case .characters: return vm.characters.isEmpty
        case .episodes:   return vm.episodes.isEmpty
        case .locations:  return vm.locations.isEmpty
        }
    }

    @ViewBuilder private var listContent: some View {
        List {
            switch vm.selected {
            case .characters:
                ForEach(vm.characters) { c in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: c.image)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Color.secondary.opacity(0.2)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                Color.secondary.opacity(0.2)
                            }
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(c.name).font(.headline)
                            Text("\(c.species) · \(c.status)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

            case .episodes:
                ForEach(vm.episodes) { e in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(e.episode).font(.headline)    // S01E01
                        Text(e.name).font(.subheadline)
                        Text(e.air_date)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }

            case .locations:
                ForEach(vm.locations) { l in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(l.name).font(.headline)
                        Text("\(l.type) · \(l.dimension)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Residents: \(l.residents.count)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .listStyle(.plain)
    }
}

#if DEBUG
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BrowseView().previewDisplayName("Light")
            BrowseView().preferredColorScheme(.dark).previewDisplayName("Dark")
        }
    }
}
#endif
