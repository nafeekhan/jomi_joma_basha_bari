import 'search_filter.dart';

/// Arguments used when navigating to the property browse experience.
class PropertyBrowseArguments {
  final SearchFilter filter;
  final bool autoOpenAdvanced;

  const PropertyBrowseArguments({
    this.filter = const SearchFilter(),
    this.autoOpenAdvanced = false,
  });
}
