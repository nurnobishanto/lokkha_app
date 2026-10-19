import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';
import 'package:lokkha/shared/shared.dart';

class TopicSelectionView extends ConsumerStatefulWidget {
  final Subject subject;
  const TopicSelectionView({super.key, required this.subject});

  @override
  ConsumerState<TopicSelectionView> createState() => _TopicSelectionViewState();
}

class _TopicSelectionViewState extends ConsumerState<TopicSelectionView> {
  late final TextEditingController _setNumberController;

  @override
  void initState() {
    super.initState();
    _setNumberController = TextEditingController(text: "10");
  }

  @override
  void dispose() {
    _setNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.subject.id!;
    final state = ref.watch(topicSelectionNotifierProvider(id.toInt()));
    final notifier =
        ref.read(topicSelectionNotifierProvider(id.toInt()).notifier);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          widget.subject.name.toString(),
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: LightThemeColors.white),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (state.topics?.subjects != null &&
                                state.topics!.subjects!.isNotEmpty)
                              CustomExpandSubject(
                                subject: widget.subject,
                                topic: state.topics!.subjects!.first,
                                padding: 0,
                                initialExpand: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "প্রশ্ন সংখ্যা সেট করুন",
                        ),
                        CustomTextField(
                          controller: _setNumberController,
                          hintText: "প্রশ্ন সংখ্যা",
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "This field is required";
                            }
                            final parsedValue = int.tryParse(val);
                            if (parsedValue == null) {
                              return "please enter valid number";
                            } else if (parsedValue < 5) {
                              return "Must be at least 10";
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomActionButton(
                                text: "আরও বিষয় যোগ করুন",
                                onPressed: () async {
                                  if (_setNumberController.text.isNotEmpty) {
                                    MockSubjectSelect newSubject =
                                        MockSubjectSelect(
                                      id: widget.subject.id,
                                      name: widget.subject.name,
                                      quantity: min(
                                          int.tryParse(_setNumberController
                                                  .text)!
                                              .toInt(),
                                          widget.subject.questionCount!.toInt()),
                                    );
                                    await MySharedPref
                                        .addOrUpdateMockSubjectSelect(
                                            newSubject);

                                    notifier.loadSelectedSubjects();

                                    if (context.mounted) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AddMoreTopic(),
                                        ),
                                      );
                                    }
                                  } else {
                                    CustomSnackBar.showCustomErrorToast(
                                        message:
                                            "please enter number of question!");
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8.00),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: CustomActionButton(
                                  text: "পরীক্ষা শুরু করুন",
                                  onPressed: () async {
                                    if (_setNumberController.text.isNotEmpty) {
                                      MockSubjectSelect newSubject =
                                          MockSubjectSelect(
                                        id: widget.subject.id,
                                        name: widget.subject.name,
                                        quantity: min(
                                            int.tryParse(_setNumberController
                                                    .text)!
                                                .toInt(),
                                            widget.subject.questionCount!.toInt()),
                                      );
                                      await MySharedPref
                                          .addOrUpdateMockSubjectSelect(
                                              newSubject);
                                      notifier.loadSelectedSubjects();
                                      if (context.mounted) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SetTimeView(),
                                          ),
                                        );
                                      }
                                    } else {
                                      CustomSnackBar.showCustomErrorToast(
                                          message:
                                              "please enter number of question!");
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
  late bool _isExpanded;
  bool _isChecked = false;
  late final AnimationController _controller;
  late final Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpand;

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
    final checked =
        await MySharedPref.isMockSubjectExist(widget.topic.id!.toInt());
    if (mounted) {
      setState(() {
        _isChecked = checked;
      });
    }
  }

  void _toggleExpansion(bool expand) {
    setState(() {
      _isExpanded = expand;
    });
    expand ? _controller.forward() : _controller.reverse();
  }

  void _handleCheckboxChange(bool? value) {
    if (value == null) return;
    setState(() {
      _isChecked = value;
    });

    final subjectSelect = MockSubjectSelect(
      id: widget.topic.id,
      name: widget.topic.name,
      parentId: widget.topic.parentId,
      quantity: null,
      max: widget.topic.questionCount?.toInt(),
    );

    if (value) {
      MySharedPref.addOrUpdateMockSubjectSelect(subjectSelect);
    } else {
      MySharedPref.removeMockSubjectSelect(subjectSelect);
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
          if (hasChildren) _children(),
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
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
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
                  ? () => _toggleExpansion(!_isExpanded)
                  : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: widget.topic.parentId != null
                    ? _tileContent(context, theme, hasChildren)
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
            value: _isChecked,
            onChanged: _handleCheckboxChange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            activeColor: theme.primaryColor,
            checkColor: Colors.white,
            side: BorderSide(
              color:
                  _isChecked ? theme.primaryColor : context.borderColor,
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

  Widget _children() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: _isExpanded ? null : 0,
      child: _isExpanded
          ? Container(
              margin: const EdgeInsets.only(top: 6, left: 16),
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 2),
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
    );
  }
}
