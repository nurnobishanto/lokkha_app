import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_learn_controller.dart';
import '../widgets/course_learn_app_bar.dart';
import '../widgets/course_learn_body.dart';
import '../widgets/course_learn_floating_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseLearnView extends GetView<CourseLearnController> {
  const CourseLearnView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final model = controller.model.value;
      final hasData =
          model.data?.course != null && model.data?.currentItem != null;

      if (!hasData) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      final course = model.data!.course!;
      final hasVideo = controller.youtubeController != null &&
          controller.isControllerReady.value;

      if (!hasVideo) {
        return Scaffold(
          floatingActionButton:
              CourseLearnFloatingBar(context: context, course: course),
          appBar: const CourseLearnAppBar(),
          body: SafeArea(
              child: CourseLearnBody(
            model: controller.model.value,
            controller: controller,
          )),
        );
      } else {
        return YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: controller.youtubeController!,
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
                controller.playNext();
              },
            ),
            builder: (context, player) {
              return Obx(() {
                return Scaffold(
                  appBar: (controller.isFullScreen.value && hasVideo)
                      ? null
                      : const CourseLearnAppBar(),
                  body: (controller.isFullScreen.value && hasVideo)
                      ? SizedBox.expand(child: player)
                      : SafeArea(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasVideo) ...[
                                  player,
                                ],
                                if (!controller.isFullScreen.value) ...[
                                  CourseLearnBody(
                                    model: controller.model.value,
                                    controller: controller,
                                  )
                                ]
                              ],
                            ),
                          ),
                        ),
                  floatingActionButton:
                      (course.modules != null && course.modules!.isNotEmpty)
                          ? (controller.isFullScreen.value && hasVideo)
                              ? null
                              : CourseLearnFloatingBar(
                                  context: context,
                                  course: course,
                                )
                          : null,
                );
              });
            });
      }
    });
  }
}
