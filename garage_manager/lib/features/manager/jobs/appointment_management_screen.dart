import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:garage_manager/theme/app_colors.dart';
import 'package:garage_manager/widgets/app_card.dart';

import '../../../core/app_routes.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _errorMsg = '';

  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final appointmentsData = await _supabase
          .from('appointments')
          .select(
            '*, customers(full_name, phone), vehicles(license_plate, model)',
          )
          .order('scheduled_at', ascending: true);

      if (mounted) {
        setState(() {
          _appointments = List<Map<String, dynamic>>.from(appointmentsData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(
          'Lịch hẹn chờ xử lý',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _errorMsg.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.statusError,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LỖI: $_errorMsg',
                    style: GoogleFonts.inter(color: AppColors.statusError),
                  ),
                ],
              ),
            )
          : _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.event_available_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Không có lịch hẹn nào',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                await _fetchData();
              },
              color: AppColors.accent,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final apt = _appointments[index];
                  final vehicleModel =
                      apt['vehicles']?['model'] ?? 'Xe chưa rõ';
                  final vehiclePlate =
                      apt['vehicles']?['license_plate'] ?? 'Chưa rõ biển số';
                  final customerName =
                      apt['customers']?['full_name'] ?? 'Khách lẻ';
                  final customerPhone =
                      apt['customers']?['phone'] ?? 'Không có SĐT';
                  final note = apt['note'] ?? 'Không có ghi chú';

                  final rawDate = apt['scheduled_at'] != null
                      ? DateTime.parse(apt['scheduled_at']).toLocal()
                      : DateTime.now();

                  final dateStr = DateFormat('dd/MM/yyyy').format(rawDate);
                  final timeStr = DateFormat('HH:mm').format(rawDate);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AppCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    vehicleModel,
                                    style: GoogleFonts.sora(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$timeStr • $dateStr',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehiclePlate,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgApp,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customerName,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        customerPhone,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bgApp,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                note,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.assignJob,
                                    arguments: apt,
                                  );
                                  if (result == true) {
                                    setState(() => _isLoading = true);
                                    _fetchData();
                                  }
                                },
                                icon: const Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  'GIAO VIỆC CHO THỢ',
                                  style: GoogleFonts.sora(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusDone,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
