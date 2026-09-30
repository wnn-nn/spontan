import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/event_note_model.dart';
import '../data/event_repository.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Menampilkan detail event dan catatan yang dikembalikan oleh form.
class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventNote? _note;

  @override
  void initState() {
    super.initState();
    _note = EventRepository.noteFor(widget.event);
  }

  Future<void> _openNoteForm() async {
    final note = await Navigator.pushNamed<EventNote>(
      context,
      AppRoutes.noteForm,
      arguments: widget.event,
    );
    if (!mounted) return;
    if (note != null) {
      EventRepository.saveNote(widget.event, note);
      setState(() => _note = note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,
      appBar: AppBar(title: const Text('Detail Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.event.title, style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              _DetailRow(label: 'Tanggal', value: widget.event.date),
              const SizedBox(height: 12),
              _DetailRow(label: 'Status', value: widget.event.status),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _openNoteForm,
                  child: const Text('Tambah Catatan'),
                ),
              ),
              if (_note != null) ...[
                const SizedBox(height: 20),
                Text('Catatan kamu', style: AppTextStyles.title),
                const SizedBox(height: 8),
                _DetailRow(label: 'Rating', value: '${_note!.rating}/5'),
                const SizedBox(height: 8),
                Text(_note!.message, style: AppTextStyles.body),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: AppTextStyles.caption)),
        Expanded(child: Text(value, style: AppTextStyles.body)),
      ],
    );
  }
}



