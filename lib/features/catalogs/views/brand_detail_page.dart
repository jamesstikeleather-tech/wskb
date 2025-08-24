import 'package:flutter/material.dart';
import '../../../data/brand.dart';
import '../../../data/brand_repository.dart';

class BrandDetailPage extends StatelessWidget {
  final String brandId;
  const BrandDetailPage({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    final Brand? brand = BrandRepository().byId(brandId);
    return Scaffold(
      appBar: AppBar(title: Text(brand?.name ?? 'Brand')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: brand == null
            ? const Center(child: Text('Brand not found'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brand.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Country: ${brand.country ?? 'Unknown'}'),
                  const SizedBox(height: 24),
                  const Text('Details coming soon...'),
                ],
              ),
      ),
    );
  }
}
