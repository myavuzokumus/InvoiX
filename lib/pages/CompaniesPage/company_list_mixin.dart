part of 'company_list.dart';

mixin _CompanyListMixin on ConsumerState<CompanyList> {

  late Set<String> filters;
  late final TextEditingController companyTextController;
  late final GlobalKey<FormState> _companyNameformKey;

  @override
  void initState() {
    filters = <String>{};
    companyTextController = TextEditingController();
    _companyNameformKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    companyTextController.dispose();
    super.dispose();
  }

  List<String> searchQuery(final String query, final AsyncSnapshot<List<String>> company) {
    if (query.isNotEmpty) {
      company.data!.removeWhere((String element) {
        element = element.toLowerCase();
        //print("$element - ${query.similarityTo(element)} - ${element.contains(query)}");
        if (0.15 < query.similarityTo(element)) {
          return false;
        } else {
          return !element.contains(query);
        }});
    }

    final List<String> companyList = List.from(company.data!);

    //Look if filters fulfill the needs
    companyList.removeWhere((final element) {
      if (filters.length == 1) {
        return !filters.every((final e) => element.toUpperCase().contains(e.toUpperCase()));
      } else if (filters.length > 1) {
        return !filters.any((final e) => element.toUpperCase().contains(e.toUpperCase()));
      }
      return false;
    });
    return companyList;
  }

}
