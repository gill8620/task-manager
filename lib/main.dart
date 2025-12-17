import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Standard Flutter package for date formatting

// --- 1. DATA MODEL (ENUMS & CLASS) ---

enum TaskPriority { low, medium, high }
enum TaskStatus { pending, completed }

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = TaskPriority.low,
    this.status = TaskStatus.pending,
  });

  Task toggleStatus() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed,
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// --- MAIN APP ENTRY POINT ---

void main() {
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF7F52F7),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

// --- 2. HOME SCREEN ---

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock Data / App State
  List<Task> allTasks = [
    Task(id: '1', title: 'Complete project documentation', dueDate: DateTime(2024, 12, 26), priority: TaskPriority.medium),
    Task(id: '2', title: 'Review pull requests', dueDate: DateTime(2024, 12, 3), priority: TaskPriority.high, status: TaskStatus.completed),
    Task(id: '3', title: 'Hello', description: 'Hi! I am here', dueDate: DateTime(2025, 12, 4), priority: TaskPriority.low, status: TaskStatus.completed),
    Task(id: '4', title: 'Submit report to manager', dueDate: DateTime(2025, 12, 10), priority: TaskPriority.high),
  ];

  String selectedFilter = 'All Tasks';
  final Color primaryColor = const Color(0xFF7F52F7);

  List<Task> get filteredTasks {
    if (selectedFilter == 'Completed') {
      return allTasks.where((t) => t.status == TaskStatus.completed).toList();
    } else if (selectedFilter == 'Pending') {
      return allTasks.where((t) => t.status == TaskStatus.pending).toList();
    }
    return allTasks;
  }

  // --- Data Management Functions ---

  void _addTask(Task newTask) {
    setState(() {
      allTasks.add(newTask);
      allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    });
  }

  void _updateTask(Task updatedTask) {
    setState(() {
      final index = allTasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        allTasks[index] = updatedTask;
        allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      allTasks.removeWhere((t) => t.id == id);
    });
  }

  void _toggleTaskStatus(Task task) {
    _updateTask(task.toggleStatus());
  }

  // --- UI Component Builders ---

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ActionChip(
          label: Text(label),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: isSelected ? primaryColor : Colors.white,
          onPressed: () {
            setState(() {
              selectedFilter = label;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red.shade400;
        break;
      case TaskPriority.medium:
        color = const Color(0xFFFFC74C); // Amber/Yellow
        break;
      case TaskPriority.low:
      default:
        color = Colors.lightGreen.shade400;
        break;
    }
    return Chip(
      label: Text(
        priority.name.capitalize(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color color = status == TaskStatus.completed ? primaryColor.withOpacity(0.8) : Colors.blue.shade400;
    return Chip(
      label: Text(
        status.name.capitalize(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _buildTaskCard(Task task) {
    bool isOverdue = task.dueDate.isBefore(DateTime.now()) && task.status == TaskStatus.pending;
    String formattedDate = DateFormat('MMM d, yyyy').format(task.dueDate); // Using intl package

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => TaskDetailScreen(
                task: task,
                onUpdate: _updateTask,
                onDelete: _deleteTask,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.status == TaskStatus.completed,
                onChanged: (bool? newValue) {
                  _toggleTaskStatus(task);
                },
                activeColor: primaryColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: [
                        _buildPriorityChip(task.priority),
                        _buildStatusChip(task.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description.split('\n')[0],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: isOverdue ? Colors.red : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                        ),
                        if (isOverdue)
                          Text(
                            ' (Overdue)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.blueGrey.shade300),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AddEditTaskScreen(
                            taskToEdit: task,
                            onSave: _updateTask,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400),
                    onPressed: () => _confirmDelete(context, task),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTask(task.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              // FIX: Set title to null so nothing collapses into the AppBar
              title: null,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), primaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.only(top: 60, left: 16),
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    // FIX: Place the "Task Manager" text here, above the date.
                    const Text(
                        'Task Manager',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    const SizedBox(height: 4),
                    Text('Today ${DateFormat('MMM d, yyyy').format(DateTime.now())}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildFilterChip('All Tasks'),
                    _buildFilterChip('Pending'),
                    _buildFilterChip('Completed'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              return _buildTaskCard(filteredTasks[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddEditTaskScreen(onSave: _addTask),
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- 3. ADD/EDIT TASK SCREEN ---

class AddEditTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  final Function(Task) onSave;

  AddEditTaskScreen({this.taskToEdit, required this.onSave});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  TaskPriority _selectedPriority = TaskPriority.low;
  final Color primaryColor = const Color(0xFF7F52F7);

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _selectedDueDate = widget.taskToEdit!.dueDate;
      _selectedPriority = widget.taskToEdit!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate() && _selectedDueDate != null) {
      final newTask = Task(
        id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate!,
        priority: _selectedPriority,
        status: widget.taskToEdit?.status ?? TaskStatus.pending,
      );

      widget.onSave(newTask);
      Navigator.pop(context);
    } else {
      setState(() {
        _formKey.currentState!.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.taskToEdit == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title Field
              Text('Title *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Task Title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is mandatory.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Optional text area for details',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Due Date Field
              Text('Due Date *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDueDate == null
                            ? 'Select Due Date'
                            : DateFormat('dd/MM/yyyy').format(_selectedDueDate!), // Using intl package
                        style: TextStyle(
                          color: _selectedDueDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              if (_selectedDueDate == null && _formKey.currentState?.validate() == false)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Due Date is mandatory.', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 20),

              // Priority Dropdown
              Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: TaskPriority.values.map((TaskPriority priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.name.capitalize()),
                  );
                }).toList(),
                onChanged: (TaskPriority? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        widget.taskToEdit == null ? 'Save Task' : 'Save Changes',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: primaryColor.withOpacity(0.5)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- 4. TASK DETAIL SCREEN ---

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final Function(Task) onUpdate;
  final Function(String) onDelete;

  TaskDetailScreen({required this.task, required this.onUpdate, required this.onDelete});

  final Color primaryColor = const Color(0xFF7F52F7);

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete(task.id);
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isCompleted = task.status == TaskStatus.completed;
    bool isOverdue = task.dueDate.isBefore(DateTime.now()) && !isCompleted;

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red.shade400;
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFFFC74C);
        break;
      case TaskPriority.low:
      default:
        priorityColor = Colors.lightGreen.shade400;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Back to Tasks', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Status Chips Row
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  Chip(
                    label: Text(
                      '${task.priority.name.capitalize()} Priority',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: priorityColor,
                  ),
                  Chip(
                    label: Text(
                      task.status.name.capitalize(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: isCompleted ? primaryColor.withOpacity(0.8) : Colors.blue.shade400,
                  ),
                  if (isOverdue)
                    Chip(
                      label: const Text(
                        'Overdue',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.red.shade400,
                    ),
                ],
              ),

              const Divider(height: 30),

              // Due Date
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Due Date',
                DateFormat('EEEE, MMMM d, yyyy').format(task.dueDate), // Using intl package
                valueColor: isOverdue ? Colors.red : null,
              ),

              // Description
              _buildDetailRow(
                Icons.description_outlined,
                'Description',
                task.description.isEmpty ? 'No description provided.' : task.description,
              ),

              const SizedBox(height: 30),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    onUpdate(task.toggleStatus());
                    Navigator.pop(context);
                  },
                  icon: Icon(isCompleted ? Icons.undo : Icons.check_circle, color: Colors.white),
                  label: Text(isCompleted ? 'Mark as Pending' : 'Mark as Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.blueGrey : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Edit Task Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => AddEditTaskScreen(
                          taskToEdit: task,
                          onSave: onUpdate,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  label: const Text('Edit Task', style: TextStyle(color: Colors.blueGrey)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Delete Task Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}