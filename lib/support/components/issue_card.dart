import 'package:cmd_mobile/models/issue.dart';
import 'package:flutter/material.dart';

import 'meta_chip.dart';

class IssueCard extends StatelessWidget {
  final IssueModel issue;

  const IssueCard({super.key, required this.issue});

  Color _priorityColor(String value) {
    switch (value) {
      case 'high':
        return const Color(0xFFDC2626);
      case 'medium':
        return const Color(0xFFD97706);
      case 'low':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBg(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'open':
        return const Color(0xFFDBEAFE);
      case 'in_progress':
        return const Color(0xFFFEF3C7);
      case 'resolved':
        return const Color(0xFFD1FAE5);
      case 'closed':
        return const Color(0xFFE5E7EB);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusText(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'open':
        return const Color(0xFF1D4ED8);
      case 'in_progress':
        return const Color(0xFFB45309);
      case 'resolved':
        return const Color(0xFF047857);
      case 'closed':
        return const Color(0xFF374151);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatStatus(String? value) {
    if (value == null || value.isEmpty) return 'Pending';
    return value
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(issue.priority);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                issue.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusBg(issue.status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _formatStatus(issue.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _statusText(issue.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            issue.message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetaChip(
                label: formatIssueOptionLabel(issue.issueType),
                bgColor: const Color(0xFFEFF6FF),
                textColor: const Color(0xFF1D4ED8),
              ),
              MetaChip(
                label: 'Priority: ${formatIssueOptionLabel(issue.priority)}',
                bgColor: priorityColor.withOpacity(0.10),
                textColor: priorityColor,
              ),
            ],
          ),
          if (issue.createdAt != null && issue.createdAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Created: ${issue.createdAt!}',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
