import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

/// Helper that wraps [TaskTile] in MaterialApp + Scaffold so it renders
/// correctly in the test environment.
Widget _buildTestable({
  required Task task,
  required VoidCallback onToggle,
  required VoidCallback onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TaskTile(
        task: task,
        onToggle: onToggle,
        onDelete: onDelete,
      ),
    ),
  );
}

void main() {
  // ══════════════════════════════════════════════════════════════════
  // GROUP 1: TaskTile — Rendering
  // ══════════════════════════════════════════════════════════════════
  group('TaskTile — Rendering', () {
    testWidgets('displays the task title', (WidgetTester tester) async {
      final task = Task(
        id: 'r-1',
        title: 'Buy Groceries',
        priority: Priority.medium,
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      expect(find.text('Buy Groceries'), findsOneWidget);
    });

    testWidgets('displays the priority label in uppercase', (WidgetTester tester) async {
      final task = Task(
        id: 'r-2',
        title: 'Priority Task',
        priority: Priority.high,
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('checkbox reflects isCompleted state (unchecked)', (WidgetTester tester) async {
      final task = Task(
        id: 'r-3',
        title: 'Unchecked',
        dueDate: DateTime(2026, 12, 31),
        isCompleted: false,
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('delete icon button is present', (WidgetTester tester) async {
      final task = Task(
        id: 'r-4',
        title: 'Deletable',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 2: TaskTile — Checkbox Interaction
  // ══════════════════════════════════════════════════════════════════
  group('TaskTile — Checkbox Interaction', () {
    testWidgets('onToggle is called when the checkbox is tapped', (WidgetTester tester) async {
      int toggleCount = 0;
      final task = Task(
        id: 'cb-1',
        title: 'Checkbox Task',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () => toggleCount++,
        onDelete: () {},
      ));

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(toggleCount, greaterThan(0));
    });

    testWidgets('onToggle is called exactly once per tap', (WidgetTester tester) async {
      int toggleCount = 0;
      final task = Task(
        id: 'cb-2',
        title: 'Single Tap',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () => toggleCount++,
        onDelete: () {},
      ));

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(toggleCount, equals(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 3: TaskTile — Delete Interaction
  // ══════════════════════════════════════════════════════════════════
  group('TaskTile — Delete Interaction', () {
    testWidgets('onDelete is called when the delete icon button is tapped', (WidgetTester tester) async {
      int deleteCount = 0;
      final task = Task(
        id: 'del-1',
        title: 'Delete Task',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () => deleteCount++,
      ));

      await tester.tap(find.byKey(Key('delete_del-1')));
      await tester.pump();

      expect(deleteCount, greaterThan(0));
    });

    testWidgets('onDelete is called exactly once per tap', (WidgetTester tester) async {
      int deleteCount = 0;
      final task = Task(
        id: 'del-2',
        title: 'Single Delete',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () => deleteCount++,
      ));

      await tester.tap(find.byKey(Key('delete_del-2')));
      await tester.pump();

      expect(deleteCount, equals(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 4: TaskTile — Completed State UI
  // ══════════════════════════════════════════════════════════════════
  group('TaskTile — Completed State UI', () {
    testWidgets('applies line-through decoration when task is completed', (WidgetTester tester) async {
      final task = Task(
        id: 'ui-1',
        title: 'Done Task',
        dueDate: DateTime(2026, 12, 31),
        isCompleted: true,
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      final titleWidget = tester.widget<Text>(find.byKey(Key('title_ui-1')));
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('has no line-through decoration when task is active', (WidgetTester tester) async {
      final task = Task(
        id: 'ui-2',
        title: 'Active Task',
        dueDate: DateTime(2026, 12, 31),
        isCompleted: false,
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      final titleWidget = tester.widget<Text>(find.byKey(Key('title_ui-2')));
      expect(titleWidget.style?.decoration, TextDecoration.none);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 5: TaskTile — Key Assertions
  // ══════════════════════════════════════════════════════════════════
  group('TaskTile — Key Assertions', () {
    testWidgets('ListTile has a ValueKey matching the task id', (WidgetTester tester) async {
      final task = Task(
        id: 'key-1',
        title: 'Key Task',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      expect(find.byKey(const ValueKey('key-1')), findsOneWidget);
    });

    testWidgets('checkbox and delete button have correctly formatted keys', (WidgetTester tester) async {
      final task = Task(
        id: 'key-2',
        title: 'Key Check',
        dueDate: DateTime(2026, 12, 31),
      );

      await tester.pumpWidget(_buildTestable(
        task: task,
        onToggle: () {},
        onDelete: () {},
      ));

      expect(find.byKey(Key('checkbox_key-2')), findsOneWidget);
      expect(find.byKey(Key('delete_key-2')), findsOneWidget);
    });
  });
}
