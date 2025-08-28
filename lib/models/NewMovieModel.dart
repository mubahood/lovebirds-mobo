import '../utils/Utilities.dart';
import 'RespondModel.dart';

class NewMovieModel {
  static String end_point = "movies";
  static String tableName = "movie_models";

  // Core properties
  int id = 0;
  String created_at = "";
  String updated_at = "";
  String title = "";
  String external_url = "";
  String url = "";
  String image_url = "";
  String thumbnail_url = "";
  String description = "";
  String year = "";
  String rating = "";
  String duration = "";
  String size = "";
  String genre = "";
  String director = "";
  String stars = "";
  String country = "";
  String language = "";
  String video_url = "";
  String imdb_url = "";
  String imdb_rating = "";
  String imdb_votes = "";
  String imdb_id = "";
  String type = "";
  String status = "";
  String error = "";
  String error_message = "";
  String downloads_count = "";
  String views_count = "";
  String likes_count = "";
  String dislikes_count = "";
  String comments_count = "";
  String comments = "";
  String video_is_downloaded_to_server = "";
  String video_downloaded_to_server_start_time = "";
  String video_downloaded_to_server_end_time = "";
  String video_downloaded_to_server_duration = "";
  String video_is_downloaded_to_server_status = "";
  String video_is_downloaded_to_server_error_message = "";
  String category = "";
  String category_id = "";
  String is_processed = "";
  String downloaded_from_google = "";
  String uploaded_to_from_google = "";
  String local_video_link = "";
  String plays_on_google = "";
  String downloaded_to_new_server = "";
  String new_server_path = "";
  String server_fail_reason = "";
  String actor = "";
  String vj = "";
  String content_type = "";
  String content_is_video = "";
  String content_type_processed = "";
  String content_type_processed_time = "";
  String is_premium = "";
  int episode_number = 0;
  double watch_progress = 0.0;
  double max_progress = 0.0;
  String watch_status = "";
  String watched_movie = 'No';

  NewMovieModel();

  String getThumbnail() {
    return thumbnail_url.isNotEmpty ? thumbnail_url : image_url;
  }

  String get_video_url() {
    return url.isNotEmpty ? url : external_url;
  }

  double get watched_percentage {
    if (max_progress == 0) {
      return 0.0;
    }
    return (max_progress > 0) ? (watch_progress / max_progress) : 0.0;
  }

  String make_title() {
    String slug = title.toLowerCase().replaceAll(" ", "-");
    slug = slug.replaceAll('.', '');
    slug = slug.replaceAll(',', '');

    // Check if is series and put prefix of 'episode-'
    if (type.toLowerCase() == "series") {
      slug = '${slug}-Episode-${episode_number}';
    }

    return "LOVEBIRDS-$slug";
  }

  factory NewMovieModel.fromJson(Map<String, dynamic> json) {
    NewMovieModel obj = NewMovieModel();
    obj.id = Utils.int_parse(json['id']);
    obj.created_at = Utils.to_str(json['created_at'], '');
    obj.updated_at = Utils.to_str(json['updated_at'], '');
    obj.title = Utils.to_str(json['title'], '');
    obj.external_url = Utils.to_str(json['external_url'], '');
    obj.url = Utils.to_str(json['url'], '');
    obj.image_url = Utils.to_str(json['image_url'], '');
    obj.thumbnail_url = Utils.to_str(json['thumbnail_url'], '');
    obj.description = Utils.to_str(json['description'], '');
    obj.year = Utils.to_str(json['year'], '');
    obj.rating = Utils.to_str(json['rating'], '');
    obj.duration = Utils.to_str(json['duration'], '');
    obj.size = Utils.to_str(json['size'], '');
    obj.genre = Utils.to_str(json['genre'], '');
    obj.director = Utils.to_str(json['director'], '');
    obj.stars = Utils.to_str(json['stars'], '');
    obj.country = Utils.to_str(json['country'], '');
    obj.language = Utils.to_str(json['language'], '');
    obj.video_url = Utils.to_str(json['video_url'], '');
    obj.imdb_url = Utils.to_str(json['imdb_url'], '');
    obj.imdb_rating = Utils.to_str(json['imdb_rating'], '');
    obj.imdb_votes = Utils.to_str(json['imdb_votes'], '');
    obj.imdb_id = Utils.to_str(json['imdb_id'], '');
    obj.type = Utils.to_str(json['type'], '');
    obj.status = Utils.to_str(json['status'], '');
    obj.error = Utils.to_str(json['error'], '');
    obj.error_message = Utils.to_str(json['error_message'], '');
    obj.downloads_count = Utils.to_str(json['downloads_count'], '');
    obj.views_count = Utils.to_str(json['views_count'], '');
    obj.likes_count = Utils.to_str(json['likes_count'], '');
    obj.dislikes_count = Utils.to_str(json['dislikes_count'], '');
    obj.comments_count = Utils.to_str(json['comments_count'], '');
    obj.comments = Utils.to_str(json['comments'], '');
    obj.video_is_downloaded_to_server = Utils.to_str(
      json['video_is_downloaded_to_server'],
      '',
    );
    obj.video_downloaded_to_server_start_time = Utils.to_str(
      json['video_downloaded_to_server_start_time'],
      '',
    );
    obj.video_downloaded_to_server_end_time = Utils.to_str(
      json['video_downloaded_to_server_end_time'],
      '',
    );
    obj.video_downloaded_to_server_duration = Utils.to_str(
      json['video_downloaded_to_server_duration'],
      '',
    );
    obj.video_is_downloaded_to_server_status = Utils.to_str(
      json['video_is_downloaded_to_server_status'],
      '',
    );
    obj.video_is_downloaded_to_server_error_message = Utils.to_str(
      json['video_is_downloaded_to_server_error_message'],
      '',
    );
    obj.category = Utils.to_str(json['category'], '');
    obj.category_id = Utils.to_str(json['category_id'], '');
    obj.is_processed = Utils.to_str(json['is_processed'], '');
    obj.downloaded_from_google = Utils.to_str(
      json['downloaded_from_google'],
      '',
    );
    obj.uploaded_to_from_google = Utils.to_str(
      json['uploaded_to_from_google'],
      '',
    );
    obj.local_video_link = Utils.to_str(json['local_video_link'], '');
    obj.plays_on_google = Utils.to_str(json['plays_on_google'], '');
    obj.downloaded_to_new_server = Utils.to_str(
      json['downloaded_to_new_server'],
      '',
    );
    obj.new_server_path = Utils.to_str(json['new_server_path'], '');
    obj.server_fail_reason = Utils.to_str(json['server_fail_reason'], '');
    obj.actor = Utils.to_str(json['actor'], '');
    obj.vj = Utils.to_str(json['vj'], '');
    obj.content_type = Utils.to_str(json['content_type'], '');
    obj.content_is_video = Utils.to_str(json['content_is_video'], '');
    obj.content_type_processed = Utils.to_str(
      json['content_type_processed'],
      '',
    );
    obj.content_type_processed_time = Utils.to_str(
      json['content_type_processed_time'],
      '',
    );
    obj.is_premium = Utils.to_str(json['is_premium'], '');
    obj.episode_number = Utils.int_parse(json['episode_number']);
    obj.watch_progress =
        (json['watch_progress'] != null)
            ? double.tryParse(json['watch_progress'].toString()) ?? 0.0
            : 0.0;
    obj.max_progress =
        (json['max_progress'] != null)
            ? double.tryParse(json['max_progress'].toString()) ?? 0.0
            : 0.0;
    obj.watch_status = Utils.to_str(json['watch_status'], '');
    obj.watched_movie = Utils.to_str(json['watched_movie'], 'No');

    return obj;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'title': title,
      'external_url': external_url,
      'url': url,
      'image_url': image_url,
      'thumbnail_url': thumbnail_url,
      'description': description,
      'year': year,
      'rating': rating,
      'duration': duration,
      'size': size,
      'genre': genre,
      'director': director,
      'stars': stars,
      'country': country,
      'language': language,
      'video_url': video_url,
      'imdb_url': imdb_url,
      'imdb_rating': imdb_rating,
      'imdb_votes': imdb_votes,
      'imdb_id': imdb_id,
      'type': type,
      'status': status,
      'error': error,
      'error_message': error_message,
      'downloads_count': downloads_count,
      'views_count': views_count,
      'likes_count': likes_count,
      'dislikes_count': dislikes_count,
      'comments_count': comments_count,
      'comments': comments,
      'video_is_downloaded_to_server': video_is_downloaded_to_server,
      'video_downloaded_to_server_start_time':
          video_downloaded_to_server_start_time,
      'video_downloaded_to_server_end_time':
          video_downloaded_to_server_end_time,
      'video_downloaded_to_server_duration':
          video_downloaded_to_server_duration,
      'video_is_downloaded_to_server_status':
          video_is_downloaded_to_server_status,
      'video_is_downloaded_to_server_error_message':
          video_is_downloaded_to_server_error_message,
      'category': category,
      'category_id': category_id,
      'is_processed': is_processed,
      'downloaded_from_google': downloaded_from_google,
      'uploaded_to_from_google': uploaded_to_from_google,
      'local_video_link': local_video_link,
      'plays_on_google': plays_on_google,
      'downloaded_to_new_server': downloaded_to_new_server,
      'new_server_path': new_server_path,
      'server_fail_reason': server_fail_reason,
      'actor': actor,
      'vj': vj,
      'content_type': content_type,
      'content_is_video': content_is_video,
      'content_type_processed': content_type_processed,
      'content_type_processed_time': content_type_processed_time,
      'is_premium': is_premium,
      'episode_number': episode_number,
      'watch_progress': watch_progress,
      'max_progress': max_progress,
      'watch_status': watch_status,
      'watched_movie': watched_movie,
    };
  }

  Future<void> submitViewProgress(int position, int duration) async {
    watch_progress = position.toDouble();
    max_progress = duration.toDouble();
    watch_status = 'Active';
    watched_movie = 'Yes';

    try {
      RespondModel resp = await Utils.http_post("submit-view-progress", {
        'movie_id': id,
        'position': position,
        'duration': duration,
      });

      if (resp.code == 0) {
        Utils.toast(resp.message);
      }
    } catch (e) {
      Utils.toast("Failed to submit progress: ${e.toString()}");
    }
  }

  static Future<List<NewMovieModel>> searchMoviesOnline({
    String keyword = "",
    String query = "",
    String category_id = "",
    int page = 1,
    int limit = 100,
    int offset = 0,
  }) async {
    List<NewMovieModel> results = [];

    try {
      RespondModel resp = await Utils.http_post(end_point, {
        'search_keyword': keyword.isNotEmpty ? keyword : query,
        'category_id': category_id,
        'page': page,
        'limit': limit,
        'offset': offset,
      });

      if (resp.code == 1) {
        for (var jsonItem in resp.data) {
          // results.add(NewMovieModel.fromJson(jsonItem));
        }
      } else {
        Utils.toast(resp.message);
      }
    } catch (e) {
      Utils.toast("Failed to search movies: ${e.toString()}");
    }

    return results;
  }

  static Future<List<NewMovieModel>> getMoviesOnline({
    String category_id = "",
    int page = 1,
    int perPage = 100,
    int limit = 100,
    int offset = 0,
  }) async {
    List<NewMovieModel> results = [];

    try {
      RespondModel resp = await Utils.http_post(end_point, {
        'category_id': category_id,
        'page': page,
        'perPage': perPage,
        'limit': limit,
        'offset': offset,
      });

      if (resp.code == 1) {
        for (var jsonItem in resp.data) {
          results.add(NewMovieModel.fromJson(jsonItem));
        }
      } else {
        Utils.toast(resp.message);
      }
    } catch (e) {
      Utils.toast("Failed to load movies: ${e.toString()}");
    }

    return results;
  }
}
