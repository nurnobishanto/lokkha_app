import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import '../riverpod/profile_update_notifier.dart';

class ProfileUpdateView extends ConsumerStatefulWidget {
  const ProfileUpdateView({super.key});

  @override
  ConsumerState<ProfileUpdateView> createState() => _ProfileUpdateViewState();
}

class _ProfileUpdateViewState extends ConsumerState<ProfileUpdateView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _organizationController;
  late final TextEditingController _occupationController;
  late final TextEditingController _currentPwdController;
  late final TextEditingController _pwdController;
  late final TextEditingController _confirmPwdController;

  bool _isPasswordSectionExpanded = false;
  bool _obscureCurrentPwd = true;
  bool _obscureNewPwd = true;
  bool _obscureConfirmPwd = true;

  @override
  void initState() {
    super.initState();
    final user = myUser;
    _nameController = TextEditingController(text: user.name ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _organizationController =
        TextEditingController(text: user.organization ?? '');
    _occupationController = TextEditingController(text: user.occupation ?? '');
    _currentPwdController = TextEditingController();
    _pwdController = TextEditingController();
    _confirmPwdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _occupationController.dispose();
    _currentPwdController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final notifier = ref.read(profileUpdateNotifierProvider.notifier);
    final success = await notifier.updateProfileInfo(
      context: context,
      name: _nameController.text,
      email: _emailController.text,
      organization: _organizationController.text,
      occupation: _occupationController.text,
      currentPwd: _currentPwdController.text,
      newPwd: _pwdController.text,
      confirmPwd: _confirmPwdController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileUpdateNotifierProvider);
    final notifier = ref.read(profileUpdateNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'প্রোফাইল আপডেট করুন',
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AVATAR & IDENTITY HEADER
              _buildAvatarHeader(context, state, notifier),

              SizedBox(height: 14.h),

              // 2. PERSONAL INFORMATION MODULE
              _buildPersonalInfoCard(context, state, notifier),

              SizedBox(height: 12.h),

              // 3. EDUCATION & OCCUPATION MODULE
              _buildAcademicAndWorkCard(context),

              SizedBox(height: 12.h),

              // 4. SECURITY & PASSWORD ACCORDION (UX PRIORITY - OPTIONAL)
              _buildPasswordSection(context),

              SizedBox(height: 18.h),

              // 5. UPDATE ACTION BUTTON
              _buildUpdateButton(context, state),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. AVATAR & IDENTITY HEADER
  // ---------------------------------------------------------------------------
  Widget _buildAvatarHeader(
    BuildContext context,
    ProfileUpdateState state,
    ProfileUpdateNotifier notifier,
  ) {
    final user = myUser;
    final registeredPhone = user.phone ?? '';

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Avatar with soft modern ring
              Container(
                padding: EdgeInsets.all(3.5.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF006A4E).withValues(alpha: 0.7),
                      const Color(0xFF10B981).withValues(alpha: 0.35),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006A4E).withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: notifier.pickImage,
                  child: state.croppedImage != null
                      ? CircleAvatar(
                          radius: 48.r,
                          backgroundColor: const Color(0xFF006A4E),
                          child: CircleAvatar(
                            radius: 46.r,
                            backgroundImage: FileImage(
                              File(state.croppedImage!.path),
                            ),
                          ),
                        )
                      : buildAvatar(user, radius: 48.r),
                ),
              ),

              // Camera action badge
              Positioned(
                bottom: 1.h,
                right: 1.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: notifier.pickImage,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A4E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.cardColor,
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Identity & Quick action pills
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (registeredPhone.isNotEmpty) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? context.surfaceColor
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 11.5.sp,
                        color: context.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        registeredPhone,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              InkWell(
                onTap: notifier.pickImage,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006A4E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 11.sp,
                        color: const Color(0xFF006A4E),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "ছবি পরিবর্তন",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF006A4E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. PERSONAL INFORMATION MODULE
  // ---------------------------------------------------------------------------
  Widget _buildPersonalInfoCard(
    BuildContext context,
    ProfileUpdateState state,
    ProfileUpdateNotifier notifier,
  ) {
    final effectiveDob = state.dob.trim().isNotEmpty
        ? state.dob.trim()
        : (myUser.dateOfBirth?.split("T").first.split(" ").first ?? '');

    return _buildCardContainer(
      context: context,
      title: "ব্যক্তিগত তথ্য",
      icon: Icons.person_outline_rounded,
      children: [
        // Name Field
        _buildFormField(
          context: context,
          label: "পূর্ণ নাম",
          hintText: "আপনার পূর্ণ নাম লিখুন",
          controller: _nameController,
          icon: Icons.person_rounded,
        ),

        SizedBox(height: 12.h),

        // Email Field
        _buildFormField(
          context: context,
          label: "ইমেইল ঠিকানা",
          hintText: "আপনার ইমেইল ঠিকানা লিখুন",
          controller: _emailController,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: 12.h),

        // Date of Birth Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "জন্ম তারিখ",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            _buildDatePickerField(
              context: context,
              currentDob: effectiveDob,
              onTap: () => notifier.selectDate(context),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Gender Selector (1-Tap Responsive Segmented Chips)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "লিঙ্গ",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            _buildGenderSelector(context, state, notifier),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. EDUCATION & OCCUPATION MODULE
  // ---------------------------------------------------------------------------
  Widget _buildAcademicAndWorkCard(BuildContext context) {
    return _buildCardContainer(
      context: context,
      title: "পেশা ও শিক্ষা প্রতিষ্ঠান",
      icon: Icons.school_outlined,
      children: [
        _buildFormField(
          context: context,
          label: "পেশা",
          hintText: "আপনার পেশা (যেমন: শিক্ষার্থী, চাকরিপ্রার্থী)",
          controller: _occupationController,
          icon: Icons.work_outline_rounded,
        ),
        SizedBox(height: 12.h),
        _buildFormField(
          context: context,
          label: "প্রতিষ্ঠান",
          hintText: "আপনার কলেজ, বিশ্ববিদ্যালয় বা প্রতিষ্ঠানের নাম",
          controller: _organizationController,
          icon: Icons.apartment_rounded,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SECURITY & PASSWORD ACCORDION (UX PRIORITY)
  // ---------------------------------------------------------------------------
  Widget _buildPasswordSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _isPasswordSectionExpanded
              ? const Color(0xFF006A4E).withValues(alpha: 0.35)
              : context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Tappable Accordion)
          InkWell(
            onTap: () {
              setState(() {
                _isPasswordSectionExpanded = !_isPasswordSectionExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: const Color(0xFF006A4E),
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "পাসওয়ার্ড পরিবর্তন",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _isPasswordSectionExpanded
                              ? "পরিবর্তন করতে না চাইলে বন্ধ করুন"
                              : "পরিবর্তন করতে চাইলে ট্যাপ করুন",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _isPasswordSectionExpanded
                          ? const Color(0xFF006A4E).withValues(alpha: 0.1)
                          : (context.isDark
                              ? context.surfaceColor
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "ঐচ্ছিক",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: _isPasswordSectionExpanded
                            ? const Color(0xFF006A4E)
                            : context.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  AnimatedRotation(
                    turns: _isPasswordSectionExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.textMuted,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Password Form
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isPasswordSectionExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(14.r, 0, 14.r, 14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(height: 1, color: context.borderColor),
                        SizedBox(height: 12.h),

                        // Current Password
                        _buildFormField(
                          context: context,
                          label: "বর্তমান পাসওয়ার্ড",
                          hintText: "আপনার বর্তমান পাসওয়ার্ড লিখুন",
                          controller: _currentPwdController,
                          icon: Icons.key_rounded,
                          obscureText: _obscureCurrentPwd,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPwd
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: context.textMuted,
                              size: 18.sp,
                            ),
                            onPressed: () => setState(
                              () => _obscureCurrentPwd = !_obscureCurrentPwd,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // New Password
                        _buildFormField(
                          context: context,
                          label: "নতুন পাসওয়ার্ড",
                          hintText: "নতুন পাসওয়ার্ড লিখুন (কমপক্ষে ৬ অক্ষর)",
                          controller: _pwdController,
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureNewPwd,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPwd
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: context.textMuted,
                              size: 18.sp,
                            ),
                            onPressed: () => setState(
                              () => _obscureNewPwd = !_obscureNewPwd,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Confirm Password
                        _buildFormField(
                          context: context,
                          label: "পাসওয়ার্ড নিশ্চিত করুন",
                          hintText: "নতুন পাসওয়ার্ড পুনরায় লিখুন",
                          controller: _confirmPwdController,
                          icon: Icons.check_circle_outline_rounded,
                          obscureText: _obscureConfirmPwd,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPwd
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: context.textMuted,
                              size: 18.sp,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPwd = !_obscureConfirmPwd,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. UPDATE BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildUpdateButton(
    BuildContext context,
    ProfileUpdateState state,
  ) {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006A4E),
            Color(0xFF059669),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A4E).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: state.isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "আপডেট সংরক্ষণ করুন",
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS (CLEAN, MINIMAL & PROFESSIONAL)
  // ---------------------------------------------------------------------------
  Widget _buildCardContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF006A4E),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: const Color(0xFF006A4E),
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            filled: true,
            fillColor:
                context.isDark ? context.surfaceColor : const Color(0xFFF8FAFC),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 12.5.sp,
              color: context.textMuted,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.only(left: 10.w, right: 10.w),
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFF006A4E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 16.sp,
                color: const Color(0xFF006A4E),
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 38.r,
              minHeight: 38.r,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
                  const BorderSide(color: Color(0xFF006A4E), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String currentDob,
    required VoidCallback onTap,
  }) {
    final hasDate = currentDob.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:
              context.isDark ? context.surfaceColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: context.borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFF006A4E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 16.sp,
                color: const Color(0xFF006A4E),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hasDate ? currentDob : "জন্ম তারিখ নির্বাচন করুন",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                  color: hasDate ? context.textPrimary : context.textMuted,
                ),
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              size: 18.sp,
              color: context.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector(
    BuildContext context,
    ProfileUpdateState state,
    ProfileUpdateNotifier notifier,
  ) {
    const genders = [
      {'label': 'পুরুষ', 'icon': Icons.man_rounded},
      {'label': 'মহিলা', 'icon': Icons.woman_rounded},
      {'label': 'অন্যান্য', 'icon': Icons.transgender_rounded},
    ];

    final currentGender = state.gender;

    return Row(
      children: genders.map((item) {
        final label = item['label'] as String;
        final icon = item['icon'] as IconData;
        final isSelected = currentGender == label;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: InkWell(
              onTap: () => notifier.setGender(label),
              borderRadius: BorderRadius.circular(10.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF006A4E)
                          .withValues(alpha: context.isDark ? 0.25 : 0.08)
                      : (context.isDark
                          ? context.surfaceColor
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF006A4E)
                        : context.borderColor,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 16.sp,
                        color: isSelected
                            ? const Color(0xFF006A4E)
                            : context.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                            ? const Color(0xFF006A4E)
                            : context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
