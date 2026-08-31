import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/troubleshoot_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class ProblemInputScreen extends StatefulWidget {
  const ProblemInputScreen({super.key});

  @override
  State<ProblemInputScreen> createState() => _ProblemInputScreenState();
}

class _ProblemInputScreenState extends State<ProblemInputScreen> {
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _initializedFromArgs = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(TroubleshootProvider provider) async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Describe the problem and pick a category first.')),
      );
      return;
    }

    final title = description.length > 60
        ? '${description.substring(0, 60)}…'
        : description;

    await provider.startProblem(
      title: title,
      description: description,
      category: _selectedCategory!,
    );

    if (!mounted) return;

    if (provider.status == SessionStatus.ready) {
      Navigator.pushNamed(context, AppRoutes.diagnostic);
    } else if (provider.status == SessionStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initializedFromArgs) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String) _selectedCategory = arg;
      _initializedFromArgs = true;
    }

    final provider = context.watch<TroubleshootProvider>();
    final loading = provider.status == SessionStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Describe Your Problem')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('What technology problem are you experiencing?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'e.g. "My laptop is very slow when I open applications."',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Category',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories.map((c) {
                final selected = c == _selectedCategory;
                return ChoiceChip(
                  label: Text('${AppConstants.categoryIcons[c] ?? ''} $c'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = c),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : Colors.grey.shade300),
                  ),
                  backgroundColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: loading ? null : () => _submit(provider),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Analyze Problem'),
            ),
          ],
        ),
      ),
    );
  }
}
