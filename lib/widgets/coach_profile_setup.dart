import 'package:flutter/material.dart';
import 'package:probahini/models/coach_profile.dart';

class CoachProfileSetup extends StatefulWidget {
  final CoachProfile? profile;
  final Function(Map<String, dynamic>) onUpdate;

  const CoachProfileSetup({
    super.key,
    this.profile,
    required this.onUpdate,
  });

  @override
  _CoachProfileSetupState createState() => _CoachProfileSetupState();
}

class _CoachProfileSetupState extends State<CoachProfileSetup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _cycleLengthController;
  late TextEditingController _lastPeriodController;
  
  List<String> _selectedSymptoms = [];
  List<String> _selectedPreferences = [];
  Map<String, bool> _healthGoals = {};

  final List<String> _availableSymptoms = [
    'cramps',
    'mood_swings',
    'bloating',
    'headaches',
    'fatigue',
    'breast_tenderness',
    'acne',
    'food_cravings',
    'sleep_issues',
    'anxiety',
  ];

  final List<String> _availablePreferences = [
    'exercise',
    'meditation',
    'healthy_eating',
    'supplements',
    'natural_remedies',
    'medical_treatment',
    'lifestyle_changes',
    'stress_management',
  ];

  final List<String> _availableHealthGoals = [
    'reduce_cramps',
    'improve_mood',
    'better_sleep',
    'weight_management',
    'hormone_balance',
    'energy_boost',
    'stress_reduction',
    'overall_wellness',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfileData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _cycleLengthController = TextEditingController();
    _lastPeriodController = TextEditingController();
  }

  void _loadProfileData() {
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _ageController.text = widget.profile!.age > 0 ? widget.profile!.age.toString() : '';
      _cycleLengthController.text = widget.profile!.cycleLength;
      _lastPeriodController.text = widget.profile!.lastPeriodDate;
      
      _selectedSymptoms = List.from(widget.profile!.symptoms);
      _selectedPreferences = List.from(widget.profile!.preferences);
      _healthGoals = Map.from(widget.profile!.healthGoals);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cycleLengthController.dispose();
    _lastPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Personal Information',
            [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter your name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                hint: 'Enter your age',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 10 || age > 100) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Cycle Information',
            [
              _buildTextField(
                controller: _cycleLengthController,
                label: 'Cycle Length (days)',
                hint: 'e.g., 28',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your cycle length';
                  }
                  final length = int.tryParse(value);
                  if (length == null || length < 20 || length > 40) {
                    return 'Please enter a valid cycle length (20-40 days)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastPeriodController,
                label: 'Last Period Date',
                hint: 'YYYY-MM-DD',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last period date';
                  }
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (e) {
                    return 'Please enter a valid date (YYYY-MM-DD)';
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Common Symptoms',
            [
              _buildMultiSelectChips(
                _availableSymptoms,
                _selectedSymptoms,
                (symptom) {
                  setState(() {
                    if (_selectedSymptoms.contains(symptom)) {
                      _selectedSymptoms.remove(symptom);
                    } else {
                      _selectedSymptoms.add(symptom);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Preferences',
            [
              _buildMultiSelectChips(
                _availablePreferences,
                _selectedPreferences,
                (preference) {
                  setState(() {
                    if (_selectedPreferences.contains(preference)) {
                      _selectedPreferences.remove(preference);
                    } else {
                      _selectedPreferences.add(preference);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Health Goals',
            [
              _buildCheckboxList(
                _availableHealthGoals,
                _healthGoals,
                (goal, isSelected) {
                  setState(() {
                    _healthGoals[goal] = isSelected;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMultiSelectChips(
    List<String> options,
    List<String> selected,
    Function(String) onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option.replaceAll('_', ' ').toUpperCase()),
          selected: isSelected,
          onSelected: (_) => onTap(option),
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxList(
    List<String> options,
    Map<String, bool> selected,
    Function(String, bool) onChanged,
  ) {
    return Column(
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option.replaceAll('_', ' ').toUpperCase()),
          value: selected[option] ?? false,
          onChanged: (value) => onChanged(option, value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updates = <String, dynamic>{
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'cycleLength': _cycleLengthController.text,
        'lastPeriodDate': _lastPeriodController.text,
        'symptoms': _selectedSymptoms,
        'preferences': _selectedPreferences,
        'healthGoals': _healthGoals,
      };

      widget.onUpdate(updates);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

