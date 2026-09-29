import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lokkha/features/blog/blog.dart';

class BlogDetailController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final Rxn<BlogPost> post = Rxn<BlogPost>();
  final RxDouble fontSizeDelta = 0.0.obs;
  final RxBool showScrollToTop = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is BlogPost) {
      post.value = Get.arguments as BlogPost;
    } else {
      post.value = BlogPost.samplePosts.first;
    }

    scrollController.addListener(() {
      if (scrollController.offset > 300 && !showScrollToTop.value) {
        showScrollToTop.value = true;
      } else if (scrollController.offset <= 300 && showScrollToTop.value) {
        showScrollToTop.value = false;
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void setFontSizeDelta(double delta) {
    fontSizeDelta.value = delta;
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void sharePost() {
    final current = post.value;
    if (current == null) return;
    // ignore: deprecated_member_use
    Share.share(
      '${current.title}\n\nপড়ুন লক্ষ্য অ্যাপে: https://lokkha.app/blog/${current.id}',
    );
  }

  Future<void> shareOnFacebook() async {
    final current = post.value;
    if (current == null) return;
    final url = Uri.parse(
      'https://www.facebook.com/sharer/sharer.php?u=https://lokkha.app/blog/${current.id}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      sharePost();
    }
  }

  Future<void> shareOnWhatsApp() async {
    final current = post.value;
    if (current == null) return;
    final text = Uri.encodeComponent(
      '${current.title}\nhttps://lokkha.app/blog/${current.id}',
    );
    final url = Uri.parse('whatsapp://send?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      sharePost();
    }
  }

  Future<void> shareOnX() async {
    final current = post.value;
    if (current == null) return;
    final text = Uri.encodeComponent(
      '${current.title} https://lokkha.app/blog/${current.id}',
    );
    final url = Uri.parse('https://twitter.com/intent/tweet?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      sharePost();
    }
  }

  void copyLink() {
    final current = post.value;
    if (current == null) return;
    final link = 'https://lokkha.app/blog/${current.id}';
    Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'সফল হয়েছে',
      'লিংকটি ক্লিপবোর্ডে কপি করা হয়েছে',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1B6B50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
