import SwiftUI
import Combine

struct AddMovieView: View {
    @Binding var watchedMovies: [RankingView.MovieRating]
    @Binding var editingMovieId: Int?
    @Binding var editingTitle: String
    @Binding var editingScore: Double
    var saveMovies: () -> Void
    var fetchPosters: () -> Void

    @Environment(\.presentationMode) var presentationMode

    @State private var movieTitle: String = ""
    @State private var genres: [String] = []
    @State private var userChoice: String? = nil
    @State private var suggestions: [String] = []
    @State private var suggestionCancellable: AnyCancellable?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(editingMovieId != nil ? "✏️ Edit Movie" : "🆕 Add a Movie You Just Watched")
                    .font(.headline)

                TextField("Movie Title", text: $movieTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: movieTitle) { newValue in
                        fetchSuggestions(for: newValue)
                    }

                if !suggestions.isEmpty {
                    List(suggestions, id: \.self) { title in
                        Button(action: {
                            movieTitle = title
                            suggestions = []
                        }) {
                            Text(title)
                        }
                    }
                    .frame(height: min(200, CGFloat(suggestions.count) * 44))
                }

                Text("How did you feel about it?")
                    .font(.subheadline)

                HStack(spacing: 16) {
                    ForEach(["Loved it", "It was fine", "Didn't like it"], id: \.self) { option in
                        Button(option) {
                            userChoice = option
                            print("🧠 Selected mood: \(option)")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(userChoice == option ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                Button(editingMovieId != nil ? "Save Changes" : "Add to Tier List") {
                    guard let choice = userChoice else {
                        print("⚠️ Mood not selected")
                        return
                    }

                    let score = generateScore(for: choice)
                    let imdbScore = Double.random(in: 5.0...9.0) // Placeholder
                    let year = Int.random(in: 1990...2025) // Placeholder

                    if let editId = editingMovieId,
                       let index = watchedMovies.firstIndex(where: { $0.id == editId }) {
                        print("✏️ Editing movie at index \(index)")
                        watchedMovies[index] = .init(id: editId, title: movieTitle, score: score, genres: genres, imdbScore: imdbScore, year: year)
                    } else {
                        let id = Int.random(in: 1000...9999)
                        let newMovie = RankingView.MovieRating(
                            id: id,
                            title: movieTitle,
                            score: score,
                            genres: genres,
                            imdbScore: imdbScore,
                            year: year
                        )
                        print("🎬 Before appending: \(watchedMovies.map { $0.title })")
                        watchedMovies.append(newMovie)
                        print("✅ After appending: \(watchedMovies.map { $0.title })")
                    }

                    saveMovies()
                    fetchPosters()

                    editingMovieId = nil
                    editingTitle = ""
                    editingScore = 5.0
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
                .disabled(movieTitle.isEmpty || userChoice == nil)

                Spacer()
            }
            .padding()
            .onAppear {
                if editingMovieId != nil {
                    movieTitle = editingTitle
                }
            }
            .onDisappear {
                print("👋 AddMovieView dismissed. Current movies: \(watchedMovies.map { $0.title })")
            }
            .navigationTitle("Rank New Movie")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func generateScore(for choice: String) -> Double {
        switch choice {
        case "Loved it": return Double.random(in: 8.5...10)
        case "It was fine": return Double.random(in: 6.5...8.4)
        case "Didn't like it": return Double.random(in: 1.0...6.4)
        default: return 5.0
        }
    }

    func fetchSuggestions(for query: String) {
        guard query.count >= 2 else {
            suggestions = []
            return
        }

        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(encoded)&api_key=01354bc576421f73305177aa13b63d86") else {
            return
        }

        suggestionCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: TMDbSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                response.results.map { $0.title }
                    .filter { $0.range(of: query, options: .caseInsensitive) != nil }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { titles in
                suggestions = Array(Set(titles)).sorted()
            }
    }

    struct TMDbSearchResponse: Codable {
        let results: [TMDbMovie]
    }

    struct TMDbMovie: Codable {
        let title: String
    }
}
