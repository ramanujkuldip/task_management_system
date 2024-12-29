import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_kuldeep_practical/constants/enums.dart';
import 'package:task_management_kuldeep_practical/helper/sql_db_helper.dart';
import 'package:task_management_kuldeep_practical/model/common_model.dart';

import '../model/task_model.dart';

final tasksProvider = StateNotifierProvider<TaskViewModel, List<TaskModel>>((ref) => TaskViewModel([]));

final TextEditingController taskNameDialogController = TextEditingController();

final TextEditingController descriptionDialogController = TextEditingController();

class TaskViewModel extends StateNotifier<List<TaskModel>> {
  TaskViewModel(super.state);

  loadAllTasks({String? sortBy}) async {
    List<TaskModel> tasksList = [];
    List dbList = await DatabaseHelper.instance.getAllTasks() as List;

    if (sortBy != null) {
      if (sortBy == SortByDefault.newest.name) {
        sortByDate(true);
      } else if (sortBy == SortByDefault.oldest.name) {
        sortByDate(false);
      } else {
        filterData(CommonModel(value: sortBy));
      }
    } else {
      for (var e in dbList) {
        tasksList.add(TaskModel.fromMap(e));
      }
    }

    state = tasksList.reversed.toList();
  }

  filterData(CommonModel value) async {
    List<TaskModel> tasksList = [];
    List dbList = await DatabaseHelper.instance.getAllTasks() as List;
    for (var e in dbList) {
      final data = TaskModel.fromMap(e);
      if (data.priority == value.value) {
        tasksList.add(data);
      }
    }
    state = tasksList.reversed.toList();
  }

  sortByStatus(bool isShowPending) async {
    if (isShowPending) {
      state.sort((a, b) => a.isCompleted!.compareTo(b.isCompleted!));
    } else {
      state.sort((a, b) => b.isCompleted!.compareTo(a.isCompleted!));
    }
  }

  sortByDate(bool isShowNewest) async {
    List<TaskModel> tasksList = [];
    List dbList = await DatabaseHelper.instance.getAllTasks() as List;
    for (var e in dbList) {
      final data = TaskModel.fromMap(e);
      tasksList.add(data);
    }
    if (isShowNewest) {
      tasksList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    } else {
      tasksList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    }
    state = tasksList;
  }

  addNewTask(TaskModel task) {
    DatabaseHelper.instance.insertTask(task);
    state = [
      task,
      ...state,
    ];
  }

  updateTask(TaskModel task) {
    DatabaseHelper.instance.updateTask(task);
    int i = state.indexWhere((element) => element.id == task.id);
    state[i] = task;
    state = [...state];
  }

  deleteTask(TaskModel task) {
    DatabaseHelper.instance.deleteTask(task.id!);
    state.removeWhere((element) => element.id == task.id);
    state = [...state];
  }
}
