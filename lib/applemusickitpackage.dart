library applemusickitpackage;

import 'dart:convert';

import 'package:applemusickitpackage/search.dart';
import 'package:http/http.dart' as http;

import 'album.dart';
import 'artist.dart';
import 'chart.dart';
import 'home.dart';

part 'genre.dart';
part 'song.dart';

class AppleMusicStore {
  AppleMusicStore._privateConstructor();

  static final AppleMusicStore instance = AppleMusicStore._privateConstructor();
  static const STOREFRONT = 'in';
  static const BASE_URL = 'https://api.music.apple.com/v1/catalog';
  static const GENRE_URL = "$BASE_URL/$STOREFRONT/genres";
  static const _SONG_URL = "$BASE_URL/$STOREFRONT/songs";
  static const _ALBUM_URL = "$BASE_URL/$STOREFRONT/albums";
  static const _CHART_URL = "$BASE_URL/$STOREFRONT/charts";
  static const _ARTIST_URL = "$BASE_URL/$STOREFRONT/artists";
  static const _SEARCH_URL = "$BASE_URL/$STOREFRONT/search";
  static const JWT_KEY =
      'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhSRFQ5VFQ3NkwifQ.eyJpc3MiOiI1MlJVMlhYVUg2IiwiaWF0IjoxNjI5NjQ1NTIzLCJleHAiOjE2MzIyMzc1MjN9.ObMmO4APQqPzQX2X1DolEbLYqbr4LfYuPPGBw7eM3pLM63GUhCl4aB-cH-czqsv2ALh0RzkLM3w1SJDDP4aY7A';

  Future<dynamic> _fetchJSON(String url) async {
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': "Bearer $JWT_KEY"});
    print('STATUS CODE === ${response.statusCode}');
    if (response.statusCode == 200) {
      print('STATUS CODE === ${response.statusCode}');
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<Song> fetchSongById(String id) async {
    final json = await _fetchJSON("$_SONG_URL/$id");
    return Song.fromJson(json['data'][0]);
  }

  Future<List<Genre>> fetchGenres() async {
    final json = await _fetchJSON(GENRE_URL);
    final data = json['data'] as List;
    final genres = data.map((d) => Genre.fromJson(d));
    return genres.toList();
  }

  Future<Album> fetchAlbumById(String id) async {
    final json = await _fetchJSON("$_ALBUM_URL/$id");
    return Album.fromJson(json['data'][0]);
  }

  Future<Artist> fetchArtistById(String id) async {
    final json = await _fetchJSON("$_ARTIST_URL/$id?include=albums,songs");
    return Artist.fromJson(json['data'][0]);
  }

  Future<Chart> fetchAlbumsAndSongsTopChart() async {
    final url = "$_CHART_URL?types=songs,albums";
    final json = await _fetchJSON(url);
    final songChartJSON = json['results']['songs'][0];
    final songChart = SongChart.fromJson(songChartJSON);

    final albumChartJSON = json['results']['albums'][0];
    final albumChart = AlbumChart.fromJson(albumChartJSON);

    final chart = Chart(albumChart: albumChart, songChart: songChart);
    return chart;
  }

  Future<Search> search(String query) async {
    final url = "$_SEARCH_URL?types=artists,albums,songs&limit=15&term=$query";
    final encoded = Uri.encodeFull(url);
    final json = await _fetchJSON(encoded);

    final List<Album> albums = [];
    final List<Song> songs = [];
    final List<Artist> artists = [];

    final artistJSON = json['results']['artists'];
    if (artistJSON != null) {
      artists
          .addAll((artistJSON['data'] as List).map((a) => Artist.fromJson(a)));
    }

    final albumsJSON = json['results']['albums'];
    if (albumsJSON != null) {
      albums.addAll((albumsJSON['data'] as List).map((a) => Album.fromJson(a)));
    }

    final songJSON = json['results']['songs'];
    if (songJSON != null) {
      songs.addAll((songJSON['data'] as List).map((a) => Song.fromJson(a)));
    }

    return Search(albums: albums, songs: songs, artists: artists, term: query);
  }

  Future<Home> fetchBrowseHome() async {
    final chart = await fetchAlbumsAndSongsTopChart();
    final List<Album> albums = [];

    final album3 = await fetchAlbumById('1340242365');

    albums.add(album3);

    return Home(chart: chart, albums: albums);
  }
}
