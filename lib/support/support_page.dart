import 'package:cmd_mobile/models/issue.dart';
import 'package:cmd_mobile/services/issue_service.dart';
import 'package:cmd_mobile/services/token_storage.dart';
import 'package:cmd_mobile/support/components/contact_dialog.dart';
import 'package:cmd_mobile/support/components/create_issue_dialog.dart';
import 'package:cmd_mobile/support/components/issue_card.dart';
import 'package:cmd_mobile/support/components/support_alert.dart';
import 'package:cmd_mobile/support/components/support_empty_state.dart';
import 'package:cmd_mobile/support/components/support_header.dart';
import 'package:cmd_mobile/support/components/support_loading_state.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  late final SupportService _supportService;

  final List<IssueModel> _issues = [];

  bool _loading = true;
  bool _submitting = false;
  String _error = '';
  String _success = '';

  @override
  void initState() {
    super.initState();
    _supportService = SupportService(tokenStorage: TokenStorage());
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final issues = await _supportService.fetchIssues(page: 1, perPage: 20);

      setState(() {
        _issues
          ..clear()
          ..addAll(issues);
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openCreateIssueModal() async {
    final result = await showDialog<CreateIssuePayload>(
      context: context,
      barrierDismissible: !_submitting,
      builder: (_) => const CreateIssueDialog(),
    );

    if (result == null) return;

    setState(() {
      _submitting = true;
      _error = '';
      _success = '';
    });

    try {
      final createdIssue = await _supportService.createIssue(result);

      setState(() {
        _issues.insert(0, createdIssue);
        _success = 'Your issue has been submitted successfully.';
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _openContactModal() {
    showDialog<void>(context: context, builder: (_) => const ContactDialog());
  }

  Widget _buildIssueList() {
    return Column(
      children: _issues
          .map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IssueCard(issue: issue),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: _loadIssues,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SupportHeader(
                      loading: _loading,
                      submitting: _submitting,
                      onContactTap: _openContactModal,
                      onRefreshTap: _loadIssues,
                      onAddIssueTap: _openCreateIssueModal,
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SupportAlert.error(text: _error),
                    ],
                    if (_success.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SupportAlert.success(text: _success),
                    ],
                    const SizedBox(height: 20),
                    if (_loading)
                      const SupportLoadingState()
                    else if (_issues.isEmpty)
                      SupportEmptyState(
                        submitting: _submitting,
                        onAddIssueTap: _openCreateIssueModal,
                      )
                    else
                      _buildIssueList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
