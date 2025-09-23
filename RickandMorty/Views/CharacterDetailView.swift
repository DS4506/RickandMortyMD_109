import SwiftUI

struct CharacterDetailView: View {
    let character: RMCharacter
    @State private var noteText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detail")
                    .font(.largeTitle).bold()

                AsyncImage(url: URL(string: character.image)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure(_): Color.secondary
                    case .empty: ProgressView()
                    @unknown default: Color.secondary
                    }
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 6) {
                    Text(character.name).font(.title2).bold()
                    Text("\(character.species) • \(character.status)")
                        .foregroundStyle(.secondary)
                }

                Text("Episodes: \(character.episode.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("My Notes").font(.headline)
                    TextEditor(text: $noteText)
                        .frame(minHeight: 110)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(.quaternary, lineWidth: 1)
                        )
                }

                Button(action: saveNote) {
                    Text("Save Note")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadNote() }
    }

    private var storageKey: String { "rm_note_\(character.id)" }

    private func loadNote() {
        noteText = UserDefaults.standard.string(forKey: storageKey) ?? ""
    }
    private func saveNote() {
        UserDefaults.standard.set(noteText, forKey: storageKey)
    }
}

#if DEBUG
struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CharacterDetailView(
                character: RMCharacter(
                    id: 1,
                    name: "Rick Sanchez",
                    status: "Alive",
                    species: "Human",
                    image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                    episode: Array(repeating: "e", count: 8)
                )
            )
        }
    }
}
#endif
