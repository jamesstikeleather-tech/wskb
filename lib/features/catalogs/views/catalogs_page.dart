// lib/features/catalogs/views/catalogs_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/brand.dart';
import '../../../data/brand_repository.dart';
import '../data/blade_repository.dart';
import '../models/blade.dart';

class CatalogsPage extends StatelessWidget {
  const CatalogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Brand> brands = BrandRepository().all();
    final List<Blade> blades = BladeRepository().all();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Catalogs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          // Razors button
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => context.push('/razors'),
              icon: const Icon(Icons.safety_divider),
              label: const Text('View Razors'),
            ),
          ),
          const SizedBox(height: 12),

          // ---- Brands ----
          const Text('Brands'),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: brands.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = brands[i];
                return ListTile(
                  leading: const Icon(Icons.factory),
                  title: Text(b.name),
                  subtitle: Text(b.country ?? 'Unknown'),
                  onTap: () => context.go('/brand/${b.id}'),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ---- Blades (aliases demo) ----
          const Text('Blades (aliases demo)'),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blades.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final blade = blades[i];
                return ListTile(
                  leading: const Icon(Icons.cut),
                  title: Text(blade.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blade.country != null) Text('Country: ${blade.country}'),
                      if (blade.aliases.isNotEmpty) const SizedBox(height: 4),
                      if (blade.aliases.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: -8,
                          children: blade.aliases
                              .map((a) => Chip(label: Text(a), visualDensity: VisualDensity.compact))
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
