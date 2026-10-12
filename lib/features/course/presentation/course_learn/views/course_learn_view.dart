import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/course_learn_app_bar.dart';
import '../widgets/course_learn_body.dart';
import '../widgets/course_learn_floating_bar.dart';

class CourseLearnView extends ConsumerStatefulWidget {
  final int? id;
  final int? itemId;
  const CourseLearnView({super.key, this.id, this.itemId});

  @override
  ConsumerState<CourseLearnView> createState() => _CourseLearnViewState();
}

class _CourseLearnViewState extends ConsumerState<CourseLearnView> {
  YoutubePlayerController? _youtubeController;
  bool _isFullScreen = false;
  bool _isControllerReady = false;
  bool _hasVideoEnded = false;

  int get _courseId => widget.id ?? 0;

  @override
  void initState() {
    super.initState();
    if (!isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.goNamed(Routes.authGateway);
      });
      return;
    }

    Future.microtask(() {
      _fetchCourseItem(_courseId, itemID: widget.itemId);
    });
  }

  void _fetchCourseItem(int courseId, {int? itemID}) {
    setState(() {
      _isControllerReady = false;
      _hasVideoEnded = false;
    });

    ref.read(courseLearnNotifierProvider(_courseId).notifier).fetchCourseItem(
          courseId,
          itemID: itemID,
          onVideoReady: (videoId) {
            if (videoId != null && videoId.isNotEmpty) {
              _playVideo(videoId);
            }
          },
          onError: (msg) {
            if (mounted) {
              CustomSnackBar.showCustomToast(message: msg);
            }
          },
        );
  }

  void _playVideo(String videoId) {
    try {
      _youtubeController?.dispose();
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );

      _youtubeController!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isControllerReady = true;
        });
      }
    } catch (e) {
      debugPrint('[CourseLearnView] _playVideo error: $e');
    }
  }

  void _videoListener() {
    final controller = _youtubeController;
    if (controller == null) return;

    if (controller.value.isFullScreen != _isFullScreen) {
      _toggleFullScreenMode();
    }

    if (controller.value.playerState == PlayerState.ended && !_hasVideoEnded) {
      _hasVideoEnded = true;
      _onVideoEnded();
    }

    if (controller.value.playerState == PlayerState.playing && _hasVideoEnded) {
      _hasVideoEnded = false;
    }
  }

  void _toggleFullScreenMode() async {
    final wasPlaying = _youtubeController?.value.isPlaying ?? false;
    final currentPosition = _youtubeController?.value.position ?? Duration.zero;

    _youtubeController?.pause();

    if (!_isFullScreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      if (mounted) setState(() => _isFullScreen = true);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (mounted) setState(() => _isFullScreen = false);
    }

    _youtubeController?.seekTo(currentPosition);
    if (wasPlaying) _youtubeController?.play();
  }

  void _onVideoEnded() {
    final state = ref.read(courseLearnNotifierProvider(_courseId));
    final nextItemId = state.model?.data?.nextItemId;
    if (nextItemId != null) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _fetchCourseItem(_courseId, itemID: nextItemId);
      });
    } else {
      CustomSnackBar.showCustomToast(
        message: "You have completed all videos in this course!",
      );
    }
  }

  void _playNext() {
    final state = ref.read(courseLearnNotifierProvider(_courseId));
    final nextItemId = state.model?.data?.nextItemId;
    if (nextItemId != null) {
      _fetchCourseItem(_courseId, itemID: nextItemId);
    } else {
      CustomSnackBar.showCustomToast(
        message: "You have reached the last video of this course.",
      );
    }
  }

  void _playPrev() {
    final state = ref.read(courseLearnNotifierProvider(_courseId));
    final prevItemId = state.model?.data?.prevItemId;
    if (prevItemId != null) {
      _fetchCourseItem(_courseId, itemID: prevItemId is int ? prevItemId : int.tryParse(prevItemId.toString()));
    } else {
      CustomSnackBar.showCustomToast(
        message: "You are at the first video of this course.",
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.removeListener(_videoListener);
    _youtubeController?.dispose();
    _youtubeController = null;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final learnState = ref.watch(courseLearnNotifierProvider(_courseId));

    if (learnState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final model = learnState.model;
    final hasData = model?.data?.course != null && model?.data?.currentItem != null;

    if (!hasData || model == null) {
      return Scaffold(
        appBar: const CourseLearnAppBar(title: ''),
        body: Center(
          child: Text(
            learnState.errorMessage ?? "No content available",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final course = model.data!.course!;
    final hasVideo = _youtubeController != null && _isControllerReady;

    if (!hasVideo) {
      return Scaffold(
        floatingActionButton: CourseLearnFloatingBar(
          context: context,
          course: course,
          onItemSelected: (cId, itId) => _fetchCourseItem(cId, itemID: itId),
        ),
        appBar: CourseLearnAppBar(title: course.title ?? ''),
        body: SafeArea(
          child: CourseLearnBody(
            model: model,
            onPlayPrev: _playPrev,
            onPlayNext: _playNext,
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          debugPrint('YouTube player is ready');
        },
        onEnded: (metaData) {
          _playNext();
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: (_isFullScreen && hasVideo)
              ? null
              : CourseLearnAppBar(title: course.title ?? ''),
          body: (_isFullScreen && hasVideo)
              ? SizedBox.expand(child: player)
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        player,
                        if (!_isFullScreen)
                          CourseLearnBody(
                            model: model,
                            onPlayPrev: _playPrev,
                            onPlayNext: _playNext,
                          ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton:
              (course.modules != null && course.modules!.isNotEmpty)
                  ? (_isFullScreen && hasVideo)
                      ? null
                      : CourseLearnFloatingBar(
                          context: context,
                          course: course,
                          onItemSelected: (cId, itId) =>
                              _fetchCourseItem(cId, itemID: itId),
                        )
                  : null,
        );
      },
    );
  }
}
