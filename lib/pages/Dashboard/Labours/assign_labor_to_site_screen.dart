import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/labor_service.dart';
import 'package:cms/globals/site_service.dart';
import 'package:cms/models/labor_model.dart';
import 'package:cms/components/animated_dropdown.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class AssignLaborToSiteScreen extends StatefulWidget {
  final List<String> selectedLaborIds;
  final List<LaborModel> labors;

  const AssignLaborToSiteScreen({
    super.key,
    required this.selectedLaborIds,
    required this.labors,
  });

  @override
  State<AssignLaborToSiteScreen> createState() =>
      _AssignLaborToSiteScreenState();
}

@NowaGenerated()
class _AssignLaborToSiteScreenState extends State<AssignLaborToSiteScreen> {
  String? _selectedSiteId;
  String? _selectedSiteName;
  bool _isLoading = false;

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
      final siteService = context.read<SiteService>();

      // Find the selected site object to get the ID
      final selectedSite = siteService.sites.firstWhere(
        (s) => s.siteName == _selectedSiteName,
        orElse: () => throw Exception('Selected site not found'),
      );

      // Update each selected labor with the new site
      for (final labor in widget.labors) {
        await laborService.assignLaborToSite(
          laborId: labor.id,
          siteId: selectedSite.id,
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
                  '${widget.labors.length} labour(s) assigned successfully',
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

        // Close the screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to assign labours: $e');
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
    return Scaffold(
      backgroundColor: const Color(0xffe7eff6),
      appBar: AppBar(
        backgroundColor: const Color(0xff093e86),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Assign Labour to Site'),
      ),
      body: Center(
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xff607286),
                      size: 24,
                    ),
                  ),
                ),

                // Title
                const Text(
                  'Select Site',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0a2342),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Assign ${widget.labors.length} selected laborer${widget.labors.length > 1 ? 's' : ''}',
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

                    final siteNames = sites.map((s) => s.siteName).toList();

                    return AnimatedDropdown<String>(
                      value: _selectedSiteName,
                      items: siteNames,
                      hintText: 'Select a site',
                      itemLabelBuilder: (item) => item,
                      onChanged: (value) {
                        setState(() {
                          _selectedSiteName = value;
                        });
                      },
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
                        : const Text('Save Assignment'),
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
        ),
      ),
    );
  }
}
