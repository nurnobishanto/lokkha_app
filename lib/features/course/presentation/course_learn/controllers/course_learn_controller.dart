import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/core/core.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/features/course/course.dart';


class CourseLearnController extends GetxController {
  late final int id;
  late final int? itemID;
  CourseLearnController({required this.id, this.itemID});

  YoutubePlayerController? youtubeController;
  final isExpanded = false.obs;
  final RxBool isFullScreen = false.obs;
  final RxBool isControllerReady = false.obs;
  final RxBool isLoading = true.obs;
  final RxString videoID = ''.obs;
  final RxInt currentTime = 0.obs;
  final Rx<CourseLearningModel> model = CourseLearningModel().obs;
  final RxBool hasVideoEnded = false.obs;
  final RxBool hasOpenFile = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (!isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.AUTH_GATEWAY);
      });
      return;
    }

    if (!PremiumEntitlementService.to.isPremiumValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        PremiumEntitlementService.to.assertPremiumAccess();
      });
      return;
    }

    fetchCourseItem(id, itemID: itemID);
  }

  void safeNavigate(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      action();
    });
  }

  Future<void> fetchCourseItem(int courseId, {int? itemID}) async {
    isLoading.value = true;
    hasOpenFile.value = false;
    final token = MySharedPref.getUserToken();
    if (token.isEmpty) {
      Get.off(() => const AuthGatewayView());
      return;
    }

    try {
      isControllerReady.value = false;
      hasVideoEnded.value = false;
      String fetchUrl = "${AppConstants.courseLearn}/$courseId";
      if (itemID != null) {
        fetchUrl = "${AppConstants.courseLearn}/$courseId?item=$itemID";
      }

      BaseClient.safeApiCall(fetchUrl, RequestType.get,
          headers: {'Authorization': 'Bearer $token'}, onSuccess: (response) {
        if (response.data["status"] == true) {
          isFullScreen.value = true;
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);

          final data = CourseLearningModel.fromJson(response.data);
          model.value = data;

          final currentVideoUrl =
              model.value.data?.currentItem?.youtubeVideo ?? '';
          debugPrint('Current video URL: $currentVideoUrl');

          final currentId = YoutubePlayer.convertUrlToId(currentVideoUrl);

          if (currentId != null && currentId.isNotEmpty) {
            videoID.value = currentId.toString();
            playVideo();
          }
        } else if (response.data["status"] == false) {
          Get.snackbar(
            "Sometimes went wrong!",
            response.data['message'].toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          Get.offNamed(Routes.COURSE_DETAILS, arguments: courseId);
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
      debugPrint('Error in fetchCourseItem: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void playVideo() {
    try {
      // Get the YouTube URL from current item
      final currentVideoUrl = model.value.data?.currentItem?.youtubeVideo ?? '';
      debugPrint('Current video URL: $currentVideoUrl');

      if (currentVideoUrl.isEmpty) {
        isControllerReady.value = false;
        debugPrint('No YouTube video URL found');
        return;
      }

      // Extract YouTube video ID from URL
      final currentId = YoutubePlayer.convertUrlToId(currentVideoUrl);
      debugPrint('Extracted YouTube video ID: $currentId');

      if (currentId == null || currentId.isEmpty) {
        isControllerReady.value = false;
        debugPrint('Could not extract YouTube video ID from URL');
        return;
      }

      // Set the actual YouTube video ID
      videoID.value = currentId;

      // Dispose previous controller
      youtubeController?.dispose();

      // Create new controller with the YouTube video ID
      youtubeController = YoutubePlayerController(
        initialVideoId: videoID.value.toString(),
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );

      youtubeController!.addListener(() {
        final controller = youtubeController!;
        currentTime.value = controller.value.position.inSeconds;

        if (controller.value.isFullScreen != isFullScreen.value) {
          toggleFullScreenMode();
        }

        if (controller.value.playerState == PlayerState.ended &&
            !hasVideoEnded.value) {
          hasVideoEnded.value = true;
          _playNextVideo();
        }

        if (controller.value.playerState == PlayerState.playing &&
            hasVideoEnded.value) {
          hasVideoEnded.value = false;
        }
      });

      isControllerReady.value = true;
      debugPrint('YouTube controller ready with video ID: ${videoID.value}');
    } catch (e, stack) {
      debugPrint('playVideo() error: $e\n$stack');
      isControllerReady.value = false;
    }
  }

  void toggleFullScreenMode() async {
    final wasPlaying = youtubeController?.value.isPlaying ?? false;
    final currentPosition = youtubeController?.value.position ?? Duration.zero;

    youtubeController?.pause();

    if (!isFullScreen.value) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      isFullScreen.value = true;
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      isFullScreen.value = false;
    }
    debugPrint("Current Position :::: $currentPosition");
    youtubeController?.seekTo(currentPosition);
    if (wasPlaying) youtubeController?.play();
  }

  void fetchNext() {
    final nextItemId = model.value.data?.nextItemId;
    if (nextItemId != null) {
      fetchCourseItem(id, itemID: nextItemId);
    } else {
      Get.snackbar("End", "You have reached the last video of this course.");
    }
  }

  void fetchPrev() {
    final prevItemId = model.value.data?.prevItemId;
    if (prevItemId != null) {
      fetchCourseItem(id, itemID: prevItemId);
    } else {
      Get.snackbar("Start", "You are at the first video of this course.");
    }
  }

  void _playNextVideo() {
    final nextItemId = model.value.data?.nextItemId;
    if (nextItemId != null) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        fetchCourseItem(id, itemID: nextItemId);
      });
    } else {
      Get.snackbar(
        "Course Complete",
        "You have completed all videos in this course!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void playNext() => fetchNext();
  void playPrev() => fetchPrev();

  String getYoutubeVideoId(String url) {
    Uri uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
    return '';
  }

  String getYoutubeThumbnailUrl(String url) {
    var videoId = getYoutubeVideoId(url);
    return 'https://img.youtube.com/vi/$videoId/0.jpg'; // Options: 0.jpg, 1.jpg, 2.jpg, 3.jpg, or hqdefault.jpg
  }

  @override
  void onClose() {
    youtubeController?.dispose();
    youtubeController = null;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}
