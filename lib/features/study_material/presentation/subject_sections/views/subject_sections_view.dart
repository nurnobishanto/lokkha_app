import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/subject.dart';
import '../controllers/subject_section_controller.dart';

class SubjectSectionView extends GetView<SubjectSectionController> {
  final Subject? subject;
  const SubjectSectionView({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(SubjectSectionController());
    // final setNumberController = TextEditingController(text: "20").obs;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "নির্বাচিত বিষয়গুলি",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: LightThemeColors.white),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomExpandSubject(
                        subject: subject!,
                        topic: subject!,
                        padding: 0,
                        initialExpand: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.00),
              CustomActionButton(
                text: "এগিয়ে যান",
                onPressed: () async {
                  List<SubjectSectionSelect> selectSubjects =
                      await MySharedPref.getSubjectSection();
                  if (selectSubjects.isNotEmpty) {
                    controller.getSubjects();
                    Get.to(const SubSectionsSetTimeView());
                  } else {
                    CustomSnackBar.showCustomErrorSnackBar(
                      title: "বিষয় নির্বাচন করা হয়নি",
                      message: "অনুগ্রহ করে অন্তত একটি টপিক নির্বাচন করুন।",
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomExpandSubject extends StatefulWidget {
  final Subject subject;
  final Subject topic;
  final double padding;
  final bool initialExpand;

  const CustomExpandSubject({
    super.key,
    required this.subject,
    required this.topic,
    required this.padding,
    required this.initialExpand,
  });

  @override
  State<CustomExpandSubject> createState() => _CustomExpandSubjectState();
}

class _CustomExpandSubjectState extends State<CustomExpandSubject>
    with SingleTickerProviderStateMixin {
  late final RxBool isExpanded;
  final RxBool isChecked = false.obs;
  late final AnimationController _controller;
  late final Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initialExpand.obs;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _arrowRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.initialExpand) _controller.forward();

    _loadCheckedState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCheckedState() async {
    isChecked.value =
        await MySharedPref.isSubjectSectionExist(widget.topic.id!.toInt());
  }

  void _toggleExpansion(bool expand) {
    isExpanded.value = expand;
    expand ? _controller.forward() : _controller.reverse();
  }

  void _handleCheckboxChange(bool? value) {
    if (value == null) return;
    isChecked.value = value;

    final subjectSelect = SubjectSectionSelect(
      id: widget.topic.id,
      name: widget.topic.name,
      parentId: null,
      quantity: widget.topic.questionCount?.toInt(),
      max: widget.topic.questionCount?.toInt(),
    );

    if (value) {
      MySharedPref.addOrUpdateSubjectSectionSelect(subjectSelect);
    } else {
      MySharedPref.removeSubjectSectionSelect(subjectSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.topic.children?.isNotEmpty ?? false;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(left: widget.padding, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tile(context, theme, hasChildren),
          if (hasChildren) _children(context),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, ThemeData theme, bool hasChildren) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.transparent
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Amber vertical accent strip on the left
          Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: hasChildren
                  ? () => _toggleExpansion(!isExpanded.value)
                  : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: widget.topic.parentId != null
                    ? Obx(() => _tileContent(context, theme, hasChildren))
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileContent(
      BuildContext context, ThemeData theme, bool hasChildren) {
    return Row(
      children: [
        // Checkbox
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: isChecked.value,
            onChanged: _handleCheckboxChange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            activeColor: theme.primaryColor,
            checkColor: Colors.white,
            side: BorderSide(
              color: isChecked.value
                  ? theme.primaryColor
                  : context.borderColor,
              width: 1.5,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Subject name
        Expanded(
          child: Text(
            widget.topic.name ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: context.textPrimary,
              height: 1.2,
            ),
          ),
        ),

        // Expand/collapse arrow
        if (hasChildren)
          AnimatedBuilder(
            animation: _arrowRotation,
            builder: (_, __) => Transform.rotate(
              angle: _arrowRotation.value * 3.14159,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: context.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  Widget _children(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: isExpanded.value ? null : 0,
        child: isExpanded.value
            ? Container(
                margin: const EdgeInsets.only(top: 6, left: 16),
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: context.borderColor, width: 2),
                  ),
                ),
                child: Column(
                  children: widget.topic.children!
                      .map(
                        (child) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: CustomExpandSubject(
                            subject: widget.subject,
                            topic: child,
                            padding: 0,
                            initialExpand: false,
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
