import 'jellyfin_api.dart';
import 'models/culture_dto.dart';

extension LocalizationApi on JellyfinApi {
  /// Languages the server knows (for the audio / subtitle pickers).
  Future<List<CultureDto>> cultures() =>
      getJsonList('/Localization/Cultures', CultureDto.fromJson);
}
