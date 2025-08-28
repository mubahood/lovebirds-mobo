import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/utils/Utilities.dart';

class ManifestModel {
  final List<NewMovieModel> top_movie = [];
  final List<String> vj = [];
  final List<String> genres = [];
  final List<MovieCategoryList> lists = [];
  int APP_VERSION = 0;
  String IOS_LINK = '';
  String ANDROID_LINK = '';
  String WHATSAPP_CONTAT_NUMBER = '';
  String UPDATE_NOTES = '';
  String platform_type = '';
  ManifestModel();

  factory ManifestModel.fromJson(Map<String, dynamic> json) {
    // Parse top movies
    List<NewMovieModel> topMovies = [];
    if (json['top_movie'] != null && json['top_movie'] is List) {
      topMovies =
          (json['top_movie'] as List)
              .map((e) => NewMovieModel.fromJson(e))
              .toList();
    }
    print("===========");
    Utils.log(topMovies.length.toString());
    print("===========");

    // Parse vj list
    List<String> vjList = [];
    if (json['vj'] != null && json['vj'] is List) {
      vjList = List<String>.from(json['vj']);
    }
    // Parse genres list
    List<String> genresList = [];
    if (json['genres'] != null && json['genres'] is List) {
      genresList = List<String>.from(json['genres']);
    }
    // Parse categorized movie lists
    List<MovieCategoryList> categoryLists = [];
    if (json['lists'] != null && json['lists'] is List) {
      categoryLists =
          (json['lists'] as List)
              .map((e) => MovieCategoryList.fromJson(e))
              .toList();
    }

    ManifestModel m = ManifestModel();
    m.top_movie.addAll(topMovies);
    m.vj.addAll(vjList);
    m.genres.addAll(genresList);
    m.lists.addAll(categoryLists);
    //if json['APP_VERSION']
    if (json['UPDATE_NOTES'] != null) {
      m.UPDATE_NOTES = Utils.to_str(json['UPDATE_NOTES'], "");
    } else {
      m.UPDATE_NOTES = "We have added new features and fixed bugs";
    }

    m.platform_type = '';
    if (json['platform_type'] != null) {
      m.platform_type = Utils.to_str(json['platform_type'], "");
    }
    if (json['WHATSAPP_CONTAT_NUMBER'] != null) {
      m.WHATSAPP_CONTAT_NUMBER = Utils.to_str(
        json['WHATSAPP_CONTAT_NUMBER'],
        "+1 (647) 968-6445",
      );
    } else {
      m.WHATSAPP_CONTAT_NUMBER = "+1 (647) 968-6445";
    }
    if (json['IOS_LINK'] != null) {
      m.IOS_LINK = Utils.to_str(
        json['IOS_LINK'],
        "https://play.google.com/store/apps/details?id=ugflix.com",
      );
    } else {
      m.IOS_LINK = "https://play.google.com/store/apps/details?id=ugflix.com";
    }
    if (json['ANDROID_LINK'] != null) {
      m.ANDROID_LINK = Utils.to_str(
        json['ANDROID_LINK'],
        "https://play.google.com/store/apps/details?id=ugflix.com",
      );
    } else {
      m.ANDROID_LINK =
          "https://play.google.com/store/apps/details?id=ugflix.com";
    }

    if (json['APP_VERSION'] != null) {
      m.APP_VERSION = Utils.int_parse(json['APP_VERSION']);
    } else {
      m.APP_VERSION = 0;
    }

    return m;
  }
}

class MovieCategoryList {
  final String title;
  final List<NewMovieModel> movies;

  MovieCategoryList({required this.title, required this.movies});

  factory MovieCategoryList.fromJson(Map<String, dynamic> json) {
    String title = Utils.to_str(json['title'], "");
    List<NewMovieModel> moviesList = [];

    // The "movies" field might be a List or a Map
    if (json['movies'] is List) {
      moviesList =
          (json['movies'] as List)
              .map((m) => NewMovieModel.fromJson(m))
              .toList();
    } else if (json['movies'] is Map) {
      moviesList =
          (json['movies'] as Map).values
              .map((m) => NewMovieModel.fromJson(m))
              .toList();
    }
    return MovieCategoryList(title: title, movies: moviesList);
  }
}
