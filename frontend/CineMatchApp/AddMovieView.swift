import SwiftUI
import Combine

struct AddMovieView: View {
    @Binding var watchedMovies: [RankingView.MovieRating]
    @Binding var editingMovieId: Int?
    @Binding var editingTitle: String
    @Binding var editingScore: Double
    var saveMovies: () -> Void
    var fetchPosters: () -> Void
    var fetchDetails: (String, @escaping ([String]) -> Void) -> Void

    @Environment(\.presentationMode) var presentationMode

    @State private var movieTitle: String = ""
    @State private var genres: [String] = []
    @State private var userChoice: String? = nil
    @State private var suggestions: [String] = []
    @State private var suggestionCancellable: AnyCancellable?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Rank New Movie")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))
                    .padding(.top, 30)

                HStack {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.yellow)
                    Text("Add a Movie You Just Watched")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                    TextField("Movie Title", text: $movieTitle)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .onChange(of: movieTitle) { newValue in
                            fetchSuggestions(for: newValue)
                            if newValue.count > 2 {
                                fetchDetails(newValue) { fetchedGenres in
                                    print("🎯 Genres fetched: \(fetchedGenres)")
                                    self.genres = fetchedGenres
                                }
                            }
                        }
                    }
                    .frame(height: 50)
                if !suggestions.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(suggestions, id: \.self) { title in
                                Button(action: {
                                    withAnimation {
                                        suggestions.removeAll()
                                        movieTitle = title
                                    }
                                }) {
                                    HStack {
                                        Text(title)
                                            .foregroundColor(.white)
                                            .padding()
                                        Spacer()
                                    }
                                    .background(Color.white.opacity(0.05))
                                
                                }
                            }
                        }
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }


                Text("How did you feel about it?")
                    .font(.system(size: 18))
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    ForEach(["Loved it", "It was fine", "Didn't like it"], id: \.self) { option in
                        Button(option) {
                            userChoice = option
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(userChoice == option ? Color.blue : Color.white.opacity(0.1))
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

                if let choice = userChoice {
                    VStack(alignment: .leading, spacing: 12) {
                        let sameMoodMovies = watchedMovies.filter { determineChoice(from: $0.score) == choice }

                        if let reference = sameMoodMovies.sorted(by: { $0.score > $1.score }).first {
                            Text("Compared to \(reference.title), was this movie better or worse?")
                                .foregroundColor(.white.opacity(0.7))
                            HStack(spacing: 16) {
                                Button("Better") {
                                    assignMovieScore(better: true, reference: reference)
                                }
                                .foregroundColor(.yellow)

                                Button("Worse") {
                                    assignMovieScore(better: false, reference: reference)
                                }
                                .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.top, 12)
                }

                Button(editingMovieId != nil ? "Save Changes" : "Add to Tier List") {
                    assignMovieScore(better: nil, reference: nil)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                )
                .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))

                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.95).edgesIgnoringSafeArea(.all))
            .navigationTitle("")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func determineChoice(from score: Double) -> String {
        switch score {
        case 8.5...10: return "Loved it"
        case 6.5..<8.5: return "It was fine"
        case 1.0..<6.5: return "Didn't like it"
        default: return "Unknown"
        }
    }

    func assignMovieScore(better: Bool?, reference: RankingView.MovieRating?) {
        guard let choice = userChoice else { return }

        let sameMoodMovies = watchedMovies.filter { determineChoice(from: $0.score) == choice }
        let score: Double

        if let ref = reference, let better = better {
            let delta = Double.random(in: 0.1...0.3)
            score = better ? min(10.0, ref.score + delta) : max(1.0, ref.score - delta)
        } else if sameMoodMovies.isEmpty {
            score = generateScore(for: choice, newTitle: movieTitle)
        } else {
            score = sameMoodMovies.map(\.score).reduce(0, +) / Double(sameMoodMovies.count)
        }

        let imdbScore = Double.random(in: 5.0...9.0)
        let year = Int.random(in: 1990...2025)

        if let editId = editingMovieId,
           let index = watchedMovies.firstIndex(where: { $0.id == editId }) {
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
            watchedMovies.append(newMovie)
        }

        saveMovies()
        fetchPosters()

        editingMovieId = nil
        editingTitle = ""
        editingScore = 5.0
        presentationMode.wrappedValue.dismiss()
    }

    func generateScore(for choice: String, newTitle: String) -> Double {
        switch choice {
        case "Loved it": return 10.0
        case "It was fine": return 8.4
        case "Didn't like it": return 6.4
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
