import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../widgets/form_scaffold.dart';
import '../manager/customers/customer_provider.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/image_upload_helper.dart';

class AddVehicleForm extends ConsumerStatefulWidget {
  const AddVehicleForm({super.key});

  @override
  ConsumerState<AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends ConsumerState<AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  final _ccController = TextEditingController();
  final _odoController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _ccController.dispose();
    _odoController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
                title: const Text('Chọn ảnh từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await ImageUploadHelper.pickImage(ImageSource.gallery);
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _selectedImage = file;
                      _selectedImageBytes = bytes;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await ImageUploadHelper.pickImage(ImageSource.camera);
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _selectedImage = file;
                      _selectedImageBytes = bytes;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await ImageUploadHelper.uploadVehicleImage(_selectedImage!);
        if (imageUrl == null) {
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lỗi tải ảnh lên Supabase Storage! Vui lòng kiểm tra lại cấu hình bucket.'),
                backgroundColor: AppColors.statusError,
              ),
            );
          }
          return;
        }
      }

      final brandInput = _brandController.text.trim();
      final modelInput = _nameController.text.trim();
      final combinedName = modelInput.toLowerCase().contains(brandInput.toLowerCase())
          ? modelInput
          : '$brandInput $modelInput';

      final newVehicle = VehicleModel(
        name: combinedName,
        plate: _plateController.text.trim().toUpperCase(),
        statusLabel: 'Hoạt động tốt',
        status: 'done',
        lastService: 'Vừa tạo',
        engineCc: int.tryParse(_ccController.text.trim()),
        year: int.tryParse(_yearController.text.trim()),
        odometer: int.tryParse(_odoController.text.trim()),
        imageUrl: imageUrl,
      );

      // Save vehicle dynamically to currently logged-in user profile on Supabase
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        await ref.read(customerProvider.notifier).addVehicleToCustomer(
          currentUser.id,
          newVehicle,
          isUserId: true,
        );
      } else {
        await ref.read(customerProvider.notifier).addVehicleToCustomer('0987654321', newVehicle);
      }

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm xe mới thành công!'),
            backgroundColor: AppColors.statusDone,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Thêm xe mới'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: FormScaffold(
            submitLabel: _isUploading ? 'Đang lưu thông tin xe...' : 'Lưu thông tin xe',
            onSubmit: _isUploading ? null : _handleSubmit,
            children: [
              const SizedBox(height: 12),
              // Image Picker Section
              Center(
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppColors.borderSubtle,
                        backgroundImage: _selectedImageBytes != null ? MemoryImage(_selectedImageBytes!) : null,
                        child: _selectedImageBytes == null
                            ? const Icon(
                                Icons.add_a_photo_outlined,
                                size: 36,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      if (_selectedImageBytes != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.accent,
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Vehicle Name field
              Text(
                'Tên dòng xe',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Exciter 150 RC, Vario 150...',
                  prefixIcon: Icon(Icons.motorcycle_outlined, color: AppColors.textSecondary, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên xe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Brand field
              Text(
                'Hãng sản xuất',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Yamaha, Honda, Suzuki...',
                  prefixIcon: Icon(Icons.branding_watermark_outlined, color: AppColors.textSecondary, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập hãng sản xuất';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Plate number field
              Text(
                'Biển số xe',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.robotoMono(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: 59-X1 234.56...',
                  prefixIcon: Icon(Icons.pin_outlined, color: AppColors.textSecondary, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập biển số xe';
                  }
                  if (value.trim().length < 5) {
                    return 'Biển số xe quá ngắn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Production Year field
              Text(
                'Năm sản xuất (Không bắt buộc)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: 2019, 2022...',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 18),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final year = int.tryParse(value.trim());
                    if (year == null || year < 1980 || year > DateTime.now().year + 1) {
                      return 'Năm sản xuất không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Engine CC field
              Text(
                'Dung tích động cơ (cc) - Không bắt buộc',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ccController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: 110, 125, 150...',
                  prefixIcon: Icon(Icons.speed_outlined, color: AppColors.textSecondary, size: 18),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final cc = int.tryParse(value.trim());
                    if (cc == null || cc <= 0) {
                      return 'Dung tích không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Odometer field
              Text(
                'Chỉ số ODO (km) - Không bắt buộc',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _odoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: 12000, 24500...',
                  prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.textSecondary, size: 18),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final odo = int.tryParse(value.trim());
                    if (odo == null || odo < 0) {
                      return 'Chỉ số ODO không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
