import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_kuldeep_practical/constants/enums.dart';
import 'package:task_management_kuldeep_practical/model/common_model.dart';
import 'package:task_management_kuldeep_practical/model/task_model.dart';
import 'package:task_management_kuldeep_practical/view_model/user_prefs_viewmodel.dart';

import '../constants/constants.dart';
import '../constants/utils.dart';
import '../model/user_model.dart';
import '../view_model/task_viewmodel.dart';

class TasksView extends ConsumerWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TasksConsumerClass(ref: ref);
  }
}

class TasksConsumerClass extends HookWidget {
  final WidgetRef ref;

  const TasksConsumerClass({required this.ref, super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final taskViewModel = ref.read(tasksProvider.notifier);
    final userViewModel = ref.read(userProvider.notifier);
    final userModel = ref.watch(userProvider);
    final isShowPending = useState(false);
    final isLoading = useState(false);

    useEffect(() {
      isLoading.value = true;
      Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          userViewModel.getUserData();
          taskViewModel.loadAllTasks(sortBy: userModel.sortBy);
          isLoading.value = false;
          timer.cancel();
        },
      );
      return null;
    }, []);

    return Scaffold(
      appBar: getAppBar(userModel, userViewModel),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 18, left: 18, bottom: 18.0, top: 10),
          child: Column(
            children: [
              titleAndFiltersView(isShowPending, taskViewModel, userViewModel),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    taskViewModel.loadAllTasks(sortBy: userModel.sortBy);
                  },
                  child: isLoading.value ? const Center(child: CircularProgressIndicator()) : tasksListView(tasks, taskViewModel),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBarView(context, taskViewModel),
    );
  }

  Row titleAndFiltersView(ValueNotifier<bool> isShowPending, TaskViewModel taskViewModel, UserPrefsViewMode userViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "To do tasks",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                isShowPending.value = !isShowPending.value;
                taskViewModel.sortByStatus(isShowPending.value);
              },
              child: const Row(
                children: [
                  Text(
                    "Status",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Icon(
                      Icons.compare_arrows,
                      color: Colors.deepPurple,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<CommonModel>(
              onSelected: (CommonModel value) {
                if (value.isShowByDate ?? false) {
                  taskViewModel.sortByDate(value.value);
                  userViewModel.setDefaultSortOrder(
                    value.value ? SortByDefault.newest.name : SortByDefault.oldest.name,
                  );
                } else {
                  taskViewModel.filterData(value);
                  userViewModel.setDefaultSortOrder(value.value);
                }
              },
              itemBuilder: (BuildContext context) {
                return filerList.map((CommonModel option) {
                  return PopupMenuItem<CommonModel>(
                    value: option,
                    child: Text(option.title ?? ""),
                  );
                }).toList();
              },
              child: const Text(
                "Filter",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  SafeArea bottomNavBarView(BuildContext context, TaskViewModel taskViewModel) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: getElevatedButton(() async {
          showForm(
            context: context,
            taskViewModel: taskViewModel,
          );
        }, "Add Task", context),
      ),
    );
  }

  tasksListView(List<TaskModel> tasks, TaskViewModel taskViewModel) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "You haven't any tasks!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        final data = tasks[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.taskName ?? "",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data.priority != null && data.priority!.isNotEmpty)
                        getPriorityCard(
                          data.priority ?? "",
                        ),
                      if (data.priority != null && data.priority!.isNotEmpty) const SizedBox(width: 5),
                      if (data.priority != null && data.priority!.isNotEmpty)
                        getChipCard(
                          data.isCompleted == 0 ? TaskStatus.pending.name : TaskStatus.completed.name,
                          data.isCompleted == 1,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.description ?? "",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getIconButton(
                        onTap: () {
                          showForm(
                            taskData: data,
                            context: context,
                            taskViewModel: taskViewModel,
                          );
                        },
                        icon: Icons.edit,
                      ),
                      const SizedBox(width: 10),
                      getIconButton(
                        onTap: () {
                          showDeleteDialog(data, context, taskViewModel);
                        },
                        icon: Icons.delete,
                        iconColor: Colors.red,
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: tasks.length,
    );
  }

  Container getChipCard(
    String title, [
    bool? isTaskCompleted,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isTaskCompleted ?? false ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        Utils.capitalize(title),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Container getPriorityCard(String title) {
    Color bgColor;
    if (TaskPriority.high.name == title.toLowerCase()) {
      bgColor = Colors.deepOrange;
    } else if (TaskPriority.medium.name == title.toLowerCase()) {
      bgColor = Colors.amber;
    } else {
      bgColor = Colors.teal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        Utils.capitalize(title),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  SizedBox getIconButton({
    required IconData icon,
    Color? iconColor,
    required Function() onTap,
  }) {
    return SizedBox(
      height: 24,
      width: 24,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }

  getTextFormFiled({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText is required';
        }
        return null;
      },
    );
  }

  ElevatedButton getElevatedButton(
    Function() onTap,
    String buttonText,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(
          Size(MediaQuery.of(context).size.width, 52),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  AppBar getAppBar(UserModel userModel, UserPrefsViewMode userViewModel) {
    return AppBar(
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: CircleAvatar(child: Icon(Icons.person)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userModel.username ?? "",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            userModel.userEmail ?? "",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: userModel.isLightTheme == false ? Colors.white.withOpacity(.5) : Colors.black54,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            userViewModel.changeTheme();
          },
          icon: Icon(
            userModel.isLightTheme ?? false ? Icons.dark_mode : Icons.brightness_7,
          ),
        ),
      ],
    );
  }

  void showForm({
    TaskModel? taskData,
    required BuildContext context,
    required TaskViewModel taskViewModel,
  }) async {
    String? selectedValue;
    String? selectedStatus;
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    if (taskData != null) {
      taskNameDialogController.text = taskData.taskName ?? '';
      descriptionDialogController.text = taskData.description ?? "";
      selectedValue = taskData.priority;
      selectedStatus = taskData.isCompleted == 0 ? "pending" : "completed";
    } else {
      taskNameDialogController.clear();
      descriptionDialogController.clear();
      selectedValue = TaskPriority.low.name;
      selectedStatus = "pending";
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 15, left: 15, right: 15),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  taskData == null ? 'Add New Task' : 'Update Task',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              getTextFormFiled(
                controller: taskNameDialogController,
                hintText: "Enter task name",
                labelText: "Task Name",
              ),
              const SizedBox(height: 15),
              getTextFormFiled(
                controller: descriptionDialogController,
                hintText: "Enter task description",
                labelText: "Description",
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: getDropDown(
                      value: selectedValue ?? TaskPriority.low.name,
                      items: [
                        'high',
                        'medium',
                        'low',
                      ],
                      onChanged: (val) {
                        selectedValue = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: getDropDown(
                      value: selectedStatus ?? TaskStatus.pending.name,
                      items: [
                        'pending',
                        'completed',
                      ],
                      onChanged: (val) {
                        selectedStatus = val;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              getElevatedButton(
                () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final task = TaskModel(
                    id: taskData?.id,
                    taskName: taskNameDialogController.text.trim(),
                    description: descriptionDialogController.text.trim(),
                    priority: selectedValue,
                    isCompleted: selectedStatus == TaskStatus.completed.name ? 1 : 0,
                    createdAt: taskData?.createdAt,
                  );

                  if (taskData != null) {
                    taskViewModel.updateTask(task);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Task updated successfully',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    taskViewModel.addNewTask(task);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Task added successfully',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
                taskData != null ? "Update" : "Add",
                context,
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }

  getDropDown({
    required String value,
    required List items,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Priority',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(Utils.capitalize(item)),
        );
      }).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }

  void showDeleteDialog(TaskModel? taskData, BuildContext context, TaskViewModel taskViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (taskData != null) {
                  taskViewModel.deleteTask(taskData);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Something went wrong, Please try later',
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
