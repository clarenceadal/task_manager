import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════
  // GROUP 1: Task Model — Constructor & Properties
  // ══════════════════════════════════════════════════════════════════
  group('Task Model — Constructor & Properties', () {
    test('creates a task with all required fields and correct defaults', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        dueDate: DateTime(2026, 12, 31),
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, '');
      expect(task.priority, Priority.medium);
      expect(task.isCompleted, false);
    });

    test('stores due date correctly', () {
      final date = DateTime(2026, 6, 15);
      final task = Task(id: '2', title: 'Dated Task', dueDate: date);

      expect(task.dueDate, date);
    });

    test('assigns priority correctly when provided', () {
      final task = Task(
        id: '3',
        title: 'High Priority',
        dueDate: DateTime(2026, 12, 31),
        priority: Priority.high,
      );

      expect(task.priority, Priority.high);
    });

    test('accepts all optional parameters when explicitly provided', () {
      final task = Task(
        id: '4',
        title: 'Full Task',
        description: 'A full description',
        priority: Priority.low,
        dueDate: DateTime(2026, 1, 1),
        isCompleted: true,
      );

      expect(task.description, 'A full description');
      expect(task.priority, Priority.low);
      expect(task.isCompleted, true);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 2: Task Model — copyWith()
  // ══════════════════════════════════════════════════════════════════
  group('Task Model — copyWith()', () {
    late Task original;

    setUp(() {
      original = Task(
        id: 'copy-1',
        title: 'Original',
        description: 'Desc',
        priority: Priority.low,
        dueDate: DateTime(2026, 5, 1),
        isCompleted: false,
      );
    });

    test('partial update changes only specified fields', () {
      final updated = original.copyWith(title: 'Updated Title');

      expect(updated.title, 'Updated Title');
      expect(updated.id, original.id);
      expect(updated.description, original.description);
      expect(updated.priority, original.priority);
      expect(updated.dueDate, original.dueDate);
      expect(updated.isCompleted, original.isCompleted);
    });

    test('full update changes all fields', () {
      final newDate = DateTime(2027, 1, 1);
      final updated = original.copyWith(
        id: 'copy-2',
        title: 'New Title',
        description: 'New Desc',
        priority: Priority.high,
        dueDate: newDate,
        isCompleted: true,
      );

      expect(updated.id, 'copy-2');
      expect(updated.title, 'New Title');
      expect(updated.description, 'New Desc');
      expect(updated.priority, Priority.high);
      expect(updated.dueDate, newDate);
      expect(updated.isCompleted, true);
    });

    test('original task remains unchanged after copyWith', () {
      original.copyWith(title: 'Changed');

      expect(original.title, 'Original');
      expect(original.description, 'Desc');
      expect(original.priority, Priority.low);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 3: Task Model — isOverdue getter
  // ══════════════════════════════════════════════════════════════════
  group('Task Model — isOverdue getter', () {
    test('returns true when task is incomplete and due date is in the past', () {
      final task = Task(
        id: 'od-1',
        title: 'Overdue Task',
        dueDate: DateTime(2020, 1, 1),
        isCompleted: false,
      );

      expect(task.isOverdue, isTrue);
    });

    test('returns false when due date is in the future', () {
      final task = Task(
        id: 'od-2',
        title: 'Future Task',
        dueDate: DateTime(2099, 12, 31),
        isCompleted: false,
      );

      expect(task.isOverdue, isFalse);
    });

    test('returns false when task is completed even if due date is in the past', () {
      final task = Task(
        id: 'od-3',
        title: 'Completed Past Task',
        dueDate: DateTime(2020, 1, 1),
        isCompleted: true,
      );

      expect(task.isOverdue, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 4: Task Model — toJson() / fromJson()
  // ══════════════════════════════════════════════════════════════════
  group('Task Model — toJson() / fromJson()', () {
    test('serialization round-trip preserves all fields', () {
      final original = Task(
        id: 'json-1',
        title: 'JSON Task',
        description: 'Details',
        priority: Priority.high,
        dueDate: DateTime(2026, 7, 4),
        isCompleted: true,
      );

      final json = original.toJson();
      final restored = Task.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.priority, original.priority);
      expect(restored.dueDate, original.dueDate);
      expect(restored.isCompleted, original.isCompleted);
    });

    test('toJson produces correct field types', () {
      final task = Task(
        id: 'json-2',
        title: 'Type Check',
        priority: Priority.medium,
        dueDate: DateTime(2026, 3, 15),
      );

      final json = task.toJson();

      expect(json['id'], isA<String>());
      expect(json['title'], isA<String>());
      expect(json['description'], isA<String>());
      expect(json['priority'], isA<int>());
      expect(json['dueDate'], isA<String>());
      expect(json['isCompleted'], isA<bool>());
    });

    test('Priority index mapping is correct through serialization', () {
      for (final p in Priority.values) {
        final task = Task(
          id: 'json-p-${p.index}',
          title: 'Priority ${p.name}',
          priority: p,
          dueDate: DateTime(2026, 1, 1),
        );

        final json = task.toJson();
        expect(json['priority'], p.index);

        final restored = Task.fromJson(json);
        expect(restored.priority, p);
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 5: TaskService — addTask()
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — addTask()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
    });

    test('adds a valid task and it appears in allTasks', () {
      final task = Task(
        id: 'a-1',
        title: 'New Task',
        dueDate: DateTime(2026, 12, 31),
      );

      service.addTask(task);

      expect(service.allTasks.length, 1);
      expect(service.allTasks.first.title, 'New Task');
    });

    test('throws ArgumentError when title is empty', () {
      final task = Task(
        id: 'a-2',
        title: '   ',
        dueDate: DateTime(2026, 12, 31),
      );

      expect(() => service.addTask(task), throwsA(isA<ArgumentError>()));
    });

    test('allows adding tasks with duplicate IDs', () {
      final task1 = Task(id: 'dup', title: 'First', dueDate: DateTime(2026, 1, 1));
      final task2 = Task(id: 'dup', title: 'Second', dueDate: DateTime(2026, 1, 2));

      service.addTask(task1);
      service.addTask(task2);

      expect(service.allTasks.length, 2);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 6: TaskService — deleteTask()
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — deleteTask()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
    });

    test('deletes an existing task by ID', () {
      final task = Task(id: 'd-1', title: 'Delete Me', dueDate: DateTime(2026, 6, 1));
      service.addTask(task);

      service.deleteTask('d-1');

      expect(service.allTasks, isEmpty);
    });

    test('does nothing silently when deleting a non-existent ID', () {
      final task = Task(id: 'd-2', title: 'Keep Me', dueDate: DateTime(2026, 6, 1));
      service.addTask(task);

      service.deleteTask('non-existent');

      expect(service.allTasks.length, 1);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 7: TaskService — toggleComplete()
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — toggleComplete()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
    });

    test('toggles an incomplete task to completed (false → true)', () {
      final task = Task(
        id: 't-1',
        title: 'Toggle Task',
        dueDate: DateTime(2026, 6, 1),
        isCompleted: false,
      );
      service.addTask(task);

      service.toggleComplete('t-1');

      expect(service.allTasks.first.isCompleted, isTrue);
    });

    test('toggles a completed task back to incomplete (true → false)', () {
      final task = Task(
        id: 't-2',
        title: 'Toggle Back',
        dueDate: DateTime(2026, 6, 1),
        isCompleted: false,
      );
      service.addTask(task);
      service.toggleComplete('t-2'); // false → true

      service.toggleComplete('t-2'); // true → false

      expect(service.allTasks.first.isCompleted, isFalse);
    });

    test('throws StateError when toggling an unknown ID', () {
      expect(
        () => service.toggleComplete('unknown-id'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 8: TaskService — getByStatus()
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — getByStatus()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
      service.addTask(Task(
        id: 'f-1',
        title: 'Active Task',
        dueDate: DateTime(2026, 12, 31),
        isCompleted: false,
      ));
      service.addTask(Task(
        id: 'f-2',
        title: 'Completed Task',
        dueDate: DateTime(2026, 12, 31),
        isCompleted: false,
      ));
      service.toggleComplete('f-2');
    });

    test('returns only active (incomplete) tasks when completed is false', () {
      final active = service.getByStatus(completed: false);

      expect(active.length, 1);
      expect(active.first.id, 'f-1');
    });

    test('returns only completed tasks when completed is true', () {
      final completed = service.getByStatus(completed: true);

      expect(completed.length, 1);
      expect(completed.first.id, 'f-2');
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 9: TaskService — sortByPriority()
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — sortByPriority()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
      service.addTask(Task(
        id: 'sp-1',
        title: 'Low',
        priority: Priority.low,
        dueDate: DateTime(2026, 1, 1),
      ));
      service.addTask(Task(
        id: 'sp-2',
        title: 'High',
        priority: Priority.high,
        dueDate: DateTime(2026, 1, 2),
      ));
      service.addTask(Task(
        id: 'sp-3',
        title: 'Medium',
        priority: Priority.medium,
        dueDate: DateTime(2026, 1, 3),
      ));
    });

    test('returns tasks sorted with highest priority first', () {
      final sorted = service.sortByPriority();

      expect(sorted[0].priority, Priority.high);
      expect(sorted[1].priority, Priority.medium);
      expect(sorted[2].priority, Priority.low);
    });

    test('does not modify the original task list order', () {
      final originalFirst = service.allTasks.first.id;
      service.sortByPriority();

      expect(service.allTasks.first.id, originalFirst);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 10: TaskService — sortByDueDate()
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — sortByDueDate()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
      service.addTask(Task(
        id: 'sd-1',
        title: 'Later',
        dueDate: DateTime(2026, 12, 31),
      ));
      service.addTask(Task(
        id: 'sd-2',
        title: 'Earliest',
        dueDate: DateTime(2026, 1, 1),
      ));
      service.addTask(Task(
        id: 'sd-3',
        title: 'Middle',
        dueDate: DateTime(2026, 6, 15),
      ));
    });

    test('returns tasks sorted with earliest due date first', () {
      final sorted = service.sortByDueDate();

      expect(sorted[0].id, 'sd-2');
      expect(sorted[1].id, 'sd-3');
      expect(sorted[2].id, 'sd-1');
    });

    test('does not modify the original task list order', () {
      final originalFirst = service.allTasks.first.id;
      service.sortByDueDate();

      expect(service.allTasks.first.id, originalFirst);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 11: TaskService — statistics getter
  // ══════════════════════════════════════════════════════════════════
  group('TaskService — statistics getter', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
    });

    test('returns all zeros when there are no tasks', () {
      final stats = service.statistics;

      expect(stats['total'], 0);
      expect(stats['completed'], 0);
      expect(stats['overdue'], 0);
    });

    test('returns correct counts for mixed task states', () {
      service.addTask(Task(
        id: 'st-1',
        title: 'Active',
        dueDate: DateTime(2099, 12, 31),
        isCompleted: false,
      ));
      service.addTask(Task(
        id: 'st-2',
        title: 'Done',
        dueDate: DateTime(2099, 12, 31),
        isCompleted: false,
      ));
      service.toggleComplete('st-2');

      final stats = service.statistics;

      expect(stats['total'], 2);
      expect(stats['completed'], 1);
    });

    test('counts overdue tasks accurately', () {
      service.addTask(Task(
        id: 'st-3',
        title: 'Overdue Incomplete',
        dueDate: DateTime(2020, 1, 1),
        isCompleted: false,
      ));
      service.addTask(Task(
        id: 'st-4',
        title: 'Overdue But Done',
        dueDate: DateTime(2020, 1, 2),
        isCompleted: false,
      ));
      service.toggleComplete('st-4');

      final stats = service.statistics;

      expect(stats['overdue'], 1);
    });
  });
}
