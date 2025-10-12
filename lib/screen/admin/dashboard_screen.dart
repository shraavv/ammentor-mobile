import 'package:ammentor/components/theme.dart';
import 'package:ammentor/screen/auth/provider/auth_provider.dart';
import 'package:ammentor/screen/profile/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(userEmailProvider);

    if (email == null) {
      return const Center(child: Text("Email not found. Please login."));
    }

    final userAsync = ref.watch(userProvider(email));
    final screenWidth = MediaQuery.of(context).size.width;

    // Hardcoded for now
    final cards = [
      dashboardCard("Total Members", "60", Icons.people),
      dashboardCard("Avg Progress", "89%", Icons.bar_chart),
      dashboardCard("Projects Completed", "30", Icons.assignment_turned_in),
      dashboardCard("Active Users", "57", Icons.person),
    ];

    // Hardcoded for now
    final dataMap = {
      "Systems Track": 25.0,
      "Web Track": 45.0,
      "Mobile Track": 30.0,
      "AI Track": 20.0,
    };

    final colorList = [
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.teal,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Dashboard",
          style: AppTextStyles.subheading(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: userAsync.when(
        data: (user) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: "Welcome, ",
                      style: AppTextStyles.body(context).copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                      children: [
                        TextSpan(
                          text: "Admin",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Here's an overview of the club's overall progress",
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards,
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Track Distribution",
                        style: AppTextStyles.subheading(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: const Row(
                          children: [
                            Text("This Month",
                                style: TextStyle(color: Colors.white70)),
                            Icon(Icons.arrow_drop_down, color: Colors.white70),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pie Chart
                  Container(
                    width: screenWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textDark),
                    ),
                    child: Column(
                      children: [
                        PieChart(
                          dataMap: dataMap,
                          colorList: colorList,
                          chartRadius: screenWidth / 2.8,
                          chartType: ChartType.disc,
                          baseChartColor: AppColors.surface,
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendTextStyle: TextStyle(color: Colors.white70),
                            legendPosition: LegendPosition.bottom,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  // Cards
  static Widget dashboardCard(String title, String value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
