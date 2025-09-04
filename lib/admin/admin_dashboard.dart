import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:pos/admin/admin_get_all_orders.dart';
import 'package:pos/admin/admin_login.dart';
import 'package:pos/admin/admin_upload_items.dart';
import 'package:pos/themes.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50), // ⬅️ Tambahkan jarak dari atas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Selamat datang, Admin 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Logout',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AdminLogin()),
                    );
                  },
                ),
              ],
            ),
            const Text(
              "Silakan pilih menu yang ingin digunakan:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1,
                children: [
                  DashboardMenuButton(
                    icon: Icons.cloud_upload,
                    label: 'Upload Produk',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminUpload()),
                      );
                    },
                  ),
                  DashboardMenuButton(
                    icon: Icons.receipt_long,
                    label: 'Semua Order',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminGetAllOrders()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DashboardMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.topRight,
            stops: [0.1, 0.5, 8],
            colors: [redColor, redColor, yellowColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: whiteColor,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
