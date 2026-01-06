import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../view_model/care_plan_view_model.dart';

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
  final _patientIdController = TextEditingController();
  late DateTime _selectedDate;

  bool get _isEditing => widget.planToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final plan = widget.planToEdit!;
      _titleController.text = plan.title;
      _descriptionController.text = plan.description;
      _patientIdController.text = plan.patientId;
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
      final viewModel = context.read<CarePlanViewModel>();

      final plan = CarePlanEntity(
        id: _isEditing ? widget.planToEdit!.id : '',
        title: _titleController.text,
        description: _descriptionController.text,
        doctorId: _isEditing
            ? widget.planToEdit!.doctorId
            : '', // Backend handles ID on create
        patientId: _patientIdController.text,
        startDate: _selectedDate,
        patientName: _isEditing ? widget.planToEdit!.patientName : null,
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
                  TextFormField(
                    controller: _patientIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID do Paciente',
                    ),
                    readOnly: _isEditing, // Lock if editing
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o ID do paciente';
                      }
                      return null;
                    },
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
