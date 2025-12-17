// lib/widgets/site_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/site_service.dart';

class SiteSelector extends StatelessWidget {
  final String? selectedSite;
  final ValueChanged<String?> onSiteChanged;

  const SiteSelector({
    super.key,
    required this.selectedSite,
    required this.onSiteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Consumer<SiteService>(
        builder: (context, siteService, child) {
          final sites = siteService.sites;
          return DropdownButtonFormField<String>(
            value: selectedSite,
            hint: const Text('Site A - Downtown Plaza'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.business, color: Color(0xff003a78)),
              filled: true,
              fillColor: const Color(0xffeaf1fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: sites
                .map((site) => DropdownMenuItem(value: site.siteName, child: Text(site.siteName)))
                .toList(),
            onChanged: onSiteChanged,
          );
        },
      ),
    );
  }
}