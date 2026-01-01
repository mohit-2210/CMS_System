import 'package:cms/pages/Dashboard/Sites/add_site_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/site_service.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:intl/intl.dart';

@NowaGenerated()
class SiteRecordsScreen extends StatefulWidget {
  const SiteRecordsScreen({super.key});

  @override
  State<SiteRecordsScreen> createState() => _SiteRecordsScreenState();
}

@NowaGenerated()
class _SiteRecordsScreenState extends State<SiteRecordsScreen> {
  final Set<String> _selectedSiteIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String siteId) {
    setState(() {
      if (_selectedSiteIds.contains(siteId)) {
        _selectedSiteIds.remove(siteId);
      } else {
        _selectedSiteIds.add(siteId);
      }
      _isSelectionMode = _selectedSiteIds.isNotEmpty;
    });
  }

  void _enterSelectionMode(String siteId) {
    setState(() {
      _isSelectionMode = true;
      _selectedSiteIds.add(siteId);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedSiteIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (_selectedSiteIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Are you sure?'),
          ],
        ),
        content: Text(
          'This action cannot be undone. You are about to permanently delete ${_selectedSiteIds.length} selected sites.',
          style: const TextStyle(color: Color(0xff607286)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff607286),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final siteService = context.read<SiteService>();
      final success = await siteService.deleteSites(_selectedSiteIds.toList());

      if (context.mounted) {
        _clearSelection();
        if (success) {
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
                  const Text('Sites deleted successfully'),
                ],
              ),
              backgroundColor: const Color(0xff21a345),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete sites'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  // List of vibrant colors for dynamic assignment
  final List<Color> _siteColors = [
    const Color(0xff2979ff), // Blue
    const Color(0xff7b1fa2), // Purple
    const Color(0xffff9100), // Orange
    const Color(0xff00c853), // Green
    const Color(0xffd50000), // Red
    const Color(0xff00bfa5), // Teal
    const Color(0xffc51162), // Pink
    const Color(0xff304ffe), // Indigo
    const Color(0xff00b8d4), // Cyan
    const Color(0xffff6d00), // Deep Orange
  ];

  Color _getSiteColor(String siteName, String siteId) {
    // Determine color based on the site ID hash to ensure it's consistent for the same site
    // but likely different for new sites ("new color").
    // We mix ID and Name hash to get good distribution.
    final hash = siteId.hashCode ^ siteName.hashCode;
    final index = hash.abs() % _siteColors.length;
    return _siteColors[index];
  }

  IconData _getSiteIcon(String siteName) {
    final name = siteName.toLowerCase();
    
    if (name.contains('mall') || name.contains('store') || name.contains('shop') || name.contains('market')) {
      return Icons.store_mall_directory_rounded;
    } else if (name.contains('complex') || name.contains('apartment') || name.contains('tower') || name.contains('building') || name.contains('flat') || name.contains('residency')) {
      return Icons.apartment_rounded;
    } else if (name.contains('farm') || name.contains('house') || name.contains('villa') || name.contains('bungalow') || name.contains('cottage') || name.contains('home')) {
      return Icons.holiday_village_rounded;
    } else if (name.contains('railway') || name.contains('train') || name.contains('station') || name.contains('metro')) {
      return Icons.train_rounded;
    } else if (name.contains('hospital') || name.contains('clinic') || name.contains('medical')) {
      return Icons.local_hospital_rounded;
    } else if (name.contains('school') || name.contains('college') || name.contains('university')) {
      return Icons.school_rounded;
    } else if (name.contains('road') || name.contains('bridge') || name.contains('highway')) {
      return Icons.add_road_rounded;
    } else if (name.contains('hotel') || name.contains('restaurant') || name.contains('cafe')) {
      return Icons.restaurant_rounded;
    } else if (name.contains('park') || name.contains('garden')) {
      return Icons.park_rounded;
    } else if (name.contains('factory') || name.contains('industry') || name.contains('plant')) {
      return Icons.factory_rounded;
    } else {
      // Default generic icon
      return Icons.business_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf1fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff003a78),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSelectionMode) {
              _clearSelection();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: _isSelectionMode
            ? Text('${_selectedSiteIds.length} Selected')
            : const Text(
                'Site Records',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _handleDelete(context),
            ),
        ],
      ),
      body: Consumer<SiteService>(
        builder: (context, siteService, child) {
          final sites = siteService.sites;

          if (siteService.isLoading && sites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 80,
                    color: const Color(0xff607286).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sites created yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xff607286),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first site',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff607286).withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final site = sites[index];
              final isSelected = _selectedSiteIds.contains(site.id);
              final color = _getSiteColor(site.siteName, site.id);
              final icon = _getSiteIcon(site.siteName);

              return GestureDetector(
                onTap: _isSelectionMode
                    ? () => _toggleSelection(site.id)
                    : null, // No detail page implementation yet, or just selection
                onLongPress: () => _enterSelectionMode(site.id),
                child: Container(
                  height: 90, // Fixed height for consistency
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: const Color(0xff003a78), width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        // Left Colored Bar
                        Container(
                          width: 6,
                          color: isSelected ? const Color(0xff003a78) : color,
                        ),
                        
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title and Checkbox
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              site.siteName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff0a2342),
                                              ),
                                            ),
                                          ),
                                          if (_isSelectionMode)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xff003a78)
                                                      : const Color(0xffc4c4c4),
                                                  width: 2,
                                                ),
                                                color: isSelected
                                                    ? const Color(0xff003a78)
                                                    : Colors.transparent,
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 14,
                                                    )
                                                  : null,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Creator and Date
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 14,
                                            color: const Color(0xff607286),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'By: ${site.createdBy}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff607286),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xfff5f5f5),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _formatDateTime(site.createdAt),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xff9e9e9e),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSiteScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xff003a78),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}