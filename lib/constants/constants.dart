import '../model/common_model.dart';
import 'enums.dart';

class StringRes {
  static const userPrefs = "User Prefs";
}

List<CommonModel> filerList = [
  CommonModel(
    title: "Show high priority",
    value: TaskPriority.high.name,
    isShowByDate: false,
  ),
  CommonModel(
    title: "Show medium priority",
    value: TaskPriority.medium.name,
    isShowByDate: false,
  ),
  CommonModel(
    title: "Show low priority",
    value: TaskPriority.low.name,
    isShowByDate: false,
  ),
  CommonModel(
    title: "Newest first (All)",
    value: true,
    isShowByDate: true,
  ),
  CommonModel(
    title: "Oldest first",
    value: false,
    isShowByDate: true,
  ),
];
