import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/category_data.dart';
import '../../../data/models/lesson.dart';
import '../../../navigation/app_router.dart';
import '../../commons/base_page.dart';
import 'bloc/lesson_bloc.dart';
import 'widget/category_item.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryData category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final queriedLesson = query.isNotEmpty
        ? widget.category.lessons.where((element) {
            return element.title.toLowerCase().contains(query.toLowerCase()) ||
                (element.subTitle?.toLowerCase() ?? "").contains(query.toLowerCase());
          }).toList()
        : widget.category.lessons;
    return BasePage(
      title: widget.category.title,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _onSearch,
            onSubmitted: _onSearch,
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: queriedLesson.length,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CategoryItem(
                    isBeta: widget.category.isBeta,
                    onTap: () {
                      _openDetailScreen(context, queriedLesson[index]);
                    },
                    onMark: (value) {
                      _onMark(queriedLesson[index], value);
                    },
                    lesson: queriedLesson[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDetailScreen(BuildContext context, Lesson lesson) {
    context.push(
      RoutePaths.lesson,
      extra: {
        'lesson': lesson,
      },
    );
  }

  void _onSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void _onMark(Lesson queriedLesson, bool? value) {
    context.read<LessonBloc>().add(LessonEvent.markLesson(id: queriedLesson.id, isMarked: value ?? false));
  }
}
