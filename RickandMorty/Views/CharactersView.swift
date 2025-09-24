import SwiftUI

struct CharactersView: View {
    @StateObject private var vm = CharactersVM()

    var body: some View {
        // Use NavigationView + navigationBarItems to avoid any toolbar overload ambiguity
        NavigationView {
            content
                .navigationTitle("Rick & Morty")
                .navigationBarItems(
                    trailing:
                        HStack(spacing: 8) {
                            // PREV
                            Button {
                                Task { await vm.prevPage() }
                            } label: {
                                Label("Prev", systemImage: "chevron.left")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(.gray)
                            .disabled(vm.info?.prev == nil || vm.state == .loading)

                            // NEXT
                            Button {
                                Task { await vm.nextPage() }
                            } label: {
                                Label("Next", systemImage: "chevron.right")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(.blue)
                            .disabled(vm.info?.next == nil || vm.state == .loading)
                        }
                )
        }
        // shared modifiers
        .task { await vm.firstLoad() }
        .searchable(text: $vm.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search name (e.g. Rick)")
        .onSubmit(of: .search) {
            Task { await vm.applySearch() }
        }
    }

    @ViewBuilder private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            VStack(spacing: 8) {
                Text("Failed to load").font(.headline)
                Text(message).font(.subheadline).foregroundStyle(.secondary)
                Button("Retry") { Task { await vm.firstLoad() } }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

        case .loaded:
            List(vm.characters) { ch in
                NavigationLink {
                    CharacterDetailView(character: ch)
                } label: {
                    CharacterRow(character: ch)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Row
private struct CharacterRow: View {
    let character: RMCharacter

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure(_): Color.secondary
                case .empty: ProgressView()
                @unknown default: Color.secondary
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(character.name).font(.headline)
                Text("\(character.species) • \(character.status)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            
//            Image(systemName: "chevron.right")
//                .font(.footnote)
//                .foregroundStyle(.tertiaryLabel)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helpers
private extension ShapeStyle where Self == Color {
    static var tertiaryLabel: Color {
        #if os(iOS)
        Color(UIColor.tertiaryLabel)
        #else
        .secondary
        #endif
    }
}

// MARK: - Previews
#if DEBUG
struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CharactersView()
                .previewDisplayName("Light")

            CharactersView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
        }
    }
}
#endif
