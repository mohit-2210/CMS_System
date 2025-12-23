import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/labor_service.dart';
import 'package:cms/globals/site_service.dart';
import 'package:cms/models/labor_model.dart';

/// Dialog for assigning or editing labor site assignments
class AssignLaborDialog extends StatefulWidget {
  final List<String> selectedLaborIds;
  final List<LaborModel> labors;
  final bool isEdit;

  const AssignLaborDialog({
    super.key,
    required this.selectedLaborIds,
    required this.labors,
    this.isEdit = false,
  });

  @override
  State<AssignLaborDialog> createState() => _AssignLaborDialogState();
}

class _AssignLaborDialogState extends State<AssignLaborDialog> {
  String? _selectedSiteName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing and only one labor, pre-select current site
    if (widget.isEdit && widget.labors.length == 1) {
      _selectedSiteName = widget.labors.first.siteName;
    }
  }

  Future<void> _handleSaveAssignment() async {
    if (_selectedSiteName == null || _selectedSiteName!.isEmpty) {
      _showErrorSnackBar('Please select a destination site');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final laborService = context.read<LaborService>();

      // Update each selected labor with the new site
      for (final labor in widget.labors) {
        await laborService.assignLaborToSite(
          laborId: labor.id,
          siteName: _selectedSiteName!,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.labors.length} labour(s) ${widget.isEdit ? 'updated' : 'assigned'} successfully',
                ),
              ],
            ),
            backgroundColor: const Color(0xff22a340),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Close the dialog
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to ${widget.isEdit ? 'update' : 'assign'} labours: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEdit ? 'Edit Assignment' : 'Assign to Site',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0a2342),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xff607286),
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              widget.isEdit
                  ? 'Update site for ${widget.labors.length} laborer${widget.labors.length > 1 ? 's' : ''}'
                  : 'Assign ${widget.labors.length} selected laborer${widget.labors.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff607286),
              ),
            ),

            const SizedBox(height: 20),

            // Destination Site Dropdown
            const Text(
              'DESTINATION SITE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff607286),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 12),

            Consumer<SiteService>(
              builder: (context, siteService, child) {
                final sites = siteService.sites;

                if (sites.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_outlined,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No sites available. Please create a site first.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.orange,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xffe0e0e0),
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSiteName,
                    hint: const Text('Select a site'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xff093e86),
                    ),
                    dropdownColor: Colors.white,
                    items: sites
                        .map(
                          (site) => DropdownMenuItem<String>(
                            value: site.siteName,
                            child: Text(
                              site.siteName,
                              style: const TextStyle(
                                color: Color(0xff0a2342),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSiteName = value;
                      });
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Save Assignment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSaveAssignment,
                icon: const Icon(Icons.save),
                label: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(widget.isEdit ? 'Update Assignment' : 'Save Assignment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff093e86),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor:
                      const Color(0xff093e86).withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
