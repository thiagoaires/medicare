import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../view_model/care_plan_view_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

class CarePlanFormScreen extends StatefulWidget {
  final CarePlanEntity? planToEdit;

  const CarePlanFormScreen({super.key, this.planToEdit});

  @override
  State<CarePlanFormScreen> createState() => _CarePlanFormScreenState();
}

class _CarePlanFormScreenState extends State<CarePlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _patientIdController =
      TextEditingController(); // Defines text shown in field
  String? _selectedPatientId; // Stores the actual ID
  late DateTime _selectedDate;

  bool get _isEditing => widget.planToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final plan = widget.planToEdit!;
      _titleController.text = plan.title;
      _descriptionController.text = plan.description;
      _selectedPatientId = plan.patientId;
      _patientIdController.text = plan.patientName ?? plan.patientId;
      _selectedDate = plan.startDate;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Logic validation for Patient ID (since it might be hidden/typeahead)
      if (_selectedPatientId == null || _selectedPatientId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um paciente.')),
        );
        return;
      }

      final viewModel = context.read<CarePlanViewModel>();

      final plan = CarePlanEntity(
        id: _isEditing ? widget.planToEdit!.id : '',
        title: _titleController.text,
        description: _descriptionController.text,
        doctorId: _isEditing
            ? widget.planToEdit!.doctorId
            : '', // Backend handles ID on create
        patientId: _selectedPatientId!,
        startDate: _selectedDate,
        patientName:
            _patientIdController.text, // Use the name from the controller
      );

      if (_isEditing) {
        await viewModel.updatePlan(plan);
      } else {
        await viewModel.createPlan(plan);
      }

      if (mounted) {
        if (viewModel.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
        } else {
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Plano' : 'Criar Plano de Cuidado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CarePlanViewModel>(
          builder: (context, viewModel, child) {
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Patient Search Field (Email-based)
                  TypeAheadField<UserEntity>(
                    controller: _patientIdController,
                    builder: (context, controller, focusNode) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Buscar paciente por e-mail',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione um paciente';
                          }
                          if (_selectedPatientId == null) {
                            return 'Selecione um paciente da lista';
                          }
                          return null;
                        },
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      if (pattern.length < 3)
                        return []; // Optional optimization
                      return await viewModel.searchPatients(pattern);
                    },
                    itemBuilder: (context, UserEntity user) {
                      return ListTile(
                        title: Text(user.email),
                        subtitle: Text(user.name),
                      );
                    },
                    onSelected: (UserEntity user) {
                      setState(() {
                        _selectedPatientId = user.id;
                        // Display Format: Email (Name)
                        _patientIdController.text =
                            "${user.email} (${user.name})";
                      });
                    },
                    emptyBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum paciente encontrado.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Data de Início: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _isEditing ? 'Salvar Alterações' : 'Criar Plano',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
