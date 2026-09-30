import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/event_note_model.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';

/// Form untuk memberi rating dan catatan pada event.
class EventNoteFormScreen extends StatefulWidget {
  final EventModel event;

  const EventNoteFormScreen({super.key, required this.event});

  @override
  State<EventNoteFormScreen> createState() => _EventNoteFormScreenState();
}

class _EventNoteFormScreenState extends State<EventNoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ratingController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _ratingController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitNote() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop<EventNote>(
      context,
      EventNote(
        rating: int.parse(_ratingController.text.trim()),
        message: _messageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<EventNote>(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: AppColors.softGray,
        appBar: AppBar(title: const Text('Form Catatan')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ratingController,
                  keyboardType: TextInputType.number,
                  validator: Validators.rating,
                  decoration: const InputDecoration(
                    labelText: 'Rating (1-5)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 6,
                  validator: (value) => Validators.minLength(
                    value,
                    5,
                    fieldName: 'Catatan',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitNote,
                    child: const Text('Simpan Catatan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
