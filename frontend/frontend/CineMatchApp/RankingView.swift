import SwiftUI

struct RankingView: View {
    @State private var posterPaths: [String: String] = [:]
    @AppStorage("watchedMoviesData") private var watchedMoviesData: String = "" {
        didSet {
            print("📦 watchedMoviesData updated")
        }
    }

    @State private var watchedMovies: [MovieRating] = [] {
        didSet {
            saveWatchedMovies()
            print("💾 Updated watchedMovies: \(watchedMovies.map { $0.title })")
            fetchPostersForWatchedMovies()
        }
    }

    @State private var showAddMovie = false
    @State private var movieTitle: String = ""
    @State private var userScore: Double = 5.0
    @State private var editingMovieId: Int? = nil

    var favoriteGenre: String {
        let genreScores = watchedMovies.flatMap { movie -> [(String, Double)] in
            movie.genres.map { ($0, movie.score) }
        }

        let genreGroups = Dictionary(grouping: genreScores, by: { $0.0 })
        let genreAverages = genreGroups.mapValues {
            $0.map { $0.1 }.reduce(0, +) / Double($0.count)
        }

        return genreAverages.max(by: { $0.value < $1.value })?.key ?? "Unknown"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.15, blue: 0.12), Color(red: 0.15, green: 0.1, blue: 0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)

            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        favoriteGenreView
                        movieListView
                    }
                    .padding()
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.1, green: 0.15, blue: 0.12), Color(red: 0.15, green: 0.1, blue: 0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    )
                .sheet(isPresented: $showAddMovie) {
                    AddMovieView(
                        watchedMovies: $watchedMovies,
                        editingMovieId: $editingMovieId,
                        editingTitle: $movieTitle,
                        editingScore: $userScore,
                        saveMovies: saveWatchedMovies,
                        fetchPosters: fetchPostersForWatchedMovies
                    )
                }
                .toolbarBackground(Color.clear, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .onAppear {
                    print("🔄 RankingView appeared")
                    loadWatchedMovies()

                    // 👇 This makes NavigationView truly transparent
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = .clear
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }

            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Movie Tier List")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))
                Spacer()
                Button(action: {
                    showAddMovie = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 50)
    }




    private var favoriteGenreView: some View {
        HStack {
            Text("🌟 Your favorite genre might be:")
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
            Text(favoriteGenre)
                .font(.subheadline.bold())
                .foregroundColor(.purple)
        }
        .padding(.horizontal)
    }

    private var movieListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(watchedMovies.sorted(by: { $0.score > $1.score }), id: \.id) { movie in
                movieCard(movie)
            }
        }
    }

    private func movieCard(_ movie: MovieRating) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w154\(posterPaths[movie.title] ?? "")")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 70, height: 100)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.95, green: 0.9, blue: 0.8))
                Text("Release Year: \(String(movie.year))")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(spacing: 8) {

                    Text("IMDB: \(String(format: "%.1f", movie.imdbScore))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))


                }
                Spacer()
            

                
            }

            Spacer()

            Text(String(format: "%.1f", movie.score))
                .font(.subheadline.bold())
                .foregroundColor(.black)
                .frame(width: 32, height: 32)
                .background(Color.yellow.opacity(0.15))
                .clipShape(Circle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(1), lineWidth: 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.1))
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
    }

    private func posterView(for title: String) -> some View {
        if let poster = moviePosterPath(for: title) {
            return AnyView(
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w154\(poster)")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 70, height: 100)
                .cornerRadius(10)
            )
        } else {
            return AnyView(
                Color.gray.opacity(0.2)
                    .frame(width: 70, height: 100)
                    .cornerRadius(10)
            )
        }
    }

    func deleteMovie(at offsets: IndexSet) {
        watchedMovies.remove(atOffsets: offsets)
    }

    func tier(for score: Double) -> String {
        switch score {
        case 8.5...10: return "S-Tier"
        case 7.5..<8.5: return "A-Tier"
        case 6.5..<7.5: return "B-Tier"
        case 5.0..<6.5: return "C-Tier"
        default: return "Skip"
        }
    }

    func tierColor(for score: Double) -> Color {
        switch score {
        case 8.5...10: return Color.purple.opacity(0.8)
        case 7.5..<8.5: return Color.blue.opacity(0.7)
        case 6.5..<7.5: return Color.green.opacity(0.6)
        case 5.0..<6.5: return Color.orange.opacity(0.6)
        default: return Color.gray.opacity(0.5)
        }
    }

    func moviePosterPath(for title: String) -> String? {
        return posterPaths[title]
    }

    func fetchPostersForWatchedMovies() {
        print("🧾 Poster fetch triggered for \(watchedMovies.count) movies")
        for movie in watchedMovies {
            fetchPoster(for: movie.title)
        }
    }
    func fetchPoster(for title: String) {
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(encodedTitle)&api_key=01354bc576421f73305177aa13b63d86") else {
            print("❌ Invalid poster fetch URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  let response = try? JSONDecoder().decode(TMDbSearchResponse.self, from: data),
                  let posterPath = response.results.first?.poster_path else {
                print("❌ Failed to fetch poster for: \(title)")
                return
            }

            DispatchQueue.main.async {
                posterPaths[title] = posterPath
                print("🖼️ Poster path for \(title): \(posterPath)")
            }
        }.resume()
    }


    func fetchMovieDetails(for title: String) {
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let movieURL = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(encodedTitle)&api_key=01354bc576421f73305177aa13b63d86"),
              let genreURL = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=01354bc576421f73305177aa13b63d86") else {
            print("❌ Invalid API URL")
            return
        }

        URLSession.shared.dataTask(with: genreURL) { genreData, _, _ in
            guard let genreData = genreData,
                  let genreResponse = try? JSONDecoder().decode(GenreList.self, from: genreData) else {
                print("❌ Failed to fetch genre list")
                return
            }

            let genreDictionary = Dictionary(uniqueKeysWithValues: genreResponse.genres.map { ($0.id, $0.name) })

            URLSession.shared.dataTask(with: movieURL) { movieData, _, _ in
                guard let movieData = movieData,
                      let movieResponse = try? JSONDecoder().decode(TMDbSearchResponse.self, from: movieData),
                      let movie = movieResponse.results.first else {
                    print("❌ Failed to fetch movie details")
                    return
                }

                let genres = movie.genre_ids.compactMap { genreDictionary[$0] }
                let imdbScore = movie.vote_average
                let year = Int(movie.release_date.prefix(4)) ?? 0

                DispatchQueue.main.async {
                    let newMovie = MovieRating(
                        id: UUID().hashValue,
                        title: title,
                        score: 5.0,
                        genres: genres,
                        imdbScore: imdbScore,
                        year: year
                    )
                    watchedMovies.append(newMovie)
                    saveWatchedMovies()
                    print("✅ Retrieved movie details: \(newMovie)")
                }
            }.resume()
        }.resume()
    }

    func saveWatchedMovies() {
        print("🧐 Movies before encoding: \(watchedMovies)")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(watchedMovies) {
            watchedMoviesData = encoded.base64EncodedString()
            print("✅ Encoded Base64 String: \(watchedMoviesData)")
        } else {
            print("❌ Failed to encode watchedMovies")
        }
    }

    func loadWatchedMovies() {
        print("🧾 Raw stored string: \(watchedMoviesData)")
        guard let data = Data(base64Encoded: watchedMoviesData) else {
            print("❌ Failed to decode base64 string")
            return
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([MovieRating].self, from: data) {
            watchedMovies = decoded
            print("📥 Loaded \(watchedMovies.count) movies")
            fetchPostersForWatchedMovies()
        } else {
            print("❌ Failed to decode MovieRating list from JSON")
        }
    }

    struct GenreList: Codable {
        let genres: [Genre]
    }

    struct Genre: Codable {
        let id: Int
        let name: String
    }

    struct TMDbSearchResponse: Codable {
        let results: [TMDbMovie]
    }

    struct TMDbMovie: Codable {
        let title: String
        let genre_ids: [Int]
        let vote_average: Double
        let release_date: String
        let poster_path: String?
    }

    struct MovieRating: Codable, Identifiable {
        let id: Int
        let title: String
        let score: Double
        let genres: [String]
        let imdbScore: Double
        let year: Int
    }
}
