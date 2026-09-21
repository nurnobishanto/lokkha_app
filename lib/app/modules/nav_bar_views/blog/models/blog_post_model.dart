class BlogSection {
  final String? title;
  final String content;

  const BlogSection({
    this.title,
    required this.content,
  });
}

class BlogPost {
  final String id;
  final String title;
  final String category;
  final String publishDate;
  final String? publishTime;
  final String readTime;
  final String views;
  final String excerpt;
  final List<BlogSection> sections;
  final String? source;
  final String mentor;
  final String imageUrl;
  final bool isFeatured;
  final bool isRecentGuide;

  const BlogPost({
    required this.id,
    required this.title,
    required this.category,
    required this.publishDate,
    this.publishTime,
    required this.readTime,
    required this.views,
    required this.excerpt,
    required this.sections,
    this.source,
    this.mentor = 'লক্ষ্য একাডেমি',
    required this.imageUrl,
    this.isFeatured = false,
    this.isRecentGuide = false,
  });

  static List<BlogPost> get samplePosts => [
        BlogPost(
          id: '1',
          title: 'অর্থবছর পরিবর্তন ও বাংলাদেশ',
          category: 'BCS Preparation',
          publishDate: '23 Aug, 2026',
          publishTime: '11:24 AM',
          readTime: '০৪ মিনিট পড়া',
          views: '৬৮ জন পড়েছেন',
          excerpt:
              'অর্থবছর বদলালে কী লাভ হবে বাংলাদেশেরবাংলাদেশের অর্থবছর বদলে যাচ্ছে। বর্তমানে অর্থবছর শুরু হয় ১ জুলাই, শেষ হয় পরের বছরের ৩০ জুন। সরকার এটি বদ...',
          mentor: 'লক্ষ্য একাডেমি',
          source: 'প্রথমআলো',
          imageUrl:
              'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?q=80&w=800&auto=format&fit=crop',
          isFeatured: true,
          sections: [
            BlogSection(
              title: 'অর্থবছর বদলালে কী লাভ হবে বাংলাদেশের',
              content:
                  'বাংলাদেশের অর্থবছর বদলে যাচ্ছে। বর্তমানে অর্থবছর শুরু হয় ১ জুলাই, শেষ হয় পরের বছরের ৩০ জুন। সরকার এটি পরিবর্তন করে এপ্রিল থেকে মার্চ করার প্রাথমিক রূপরেখা গ্রহণ করছে।\n\nঅর্থনীতিবিদদের মতে, বর্ষাকালে উন্নয়নমূলক প্রকল্পের কাজ ব্যাহত হওয়ায় বাজেট বাস্তবায়ন বাধাগ্রস্ত হয়। নতুন অর্থবছরের ফলে শুকনো মৌসুমে অধিকাংশ প্রকল্পের কাজ নির্বিঘ্নে সম্পন্ন করা সম্ভব হবে।',
            ),
            BlogSection(
              title: 'শেষ কথা',
              content:
                  'বাংলাদেশের অর্থবছর বদলের পেছনে বাস্তব যুক্তি আছে। কিন্তু অর্থবছর বদল কোনো জাদুকরি সমাধান নয়। রাস্তা নির্মাণে দেরি কেন হয়, প্রকল্প অনুমোদনে কত সময় লাগে, দরপত্র আটকে থাকে কেন, জমি অধিগ্রহণ কেন শেষ হয় না, বছরের শুরুতে অর্থছাড় হয় না কেন—এসব প্রশ্নের উত্তর অর্থবছরের ক্যালেন্ডারে নেই।\n\nএগুলো প্রশাসনিক দক্ষতা, প্রাতিষ্ঠানিক সক্ষমতা ও জবাবদিহির প্রশ্ন। বাংলাদেশের সামনে তাই মূল প্রশ্নটি অর্থবছর মার্চে শেষ হবে কি না, শুধু সেটি নয়। মূল প্রশ্ন হলো, নতুন সময়সূচিকে কাজে লাগিয়ে বাজেট ও উন্নয়ন ব্যবস্থাপনার সংস্কার করা যাবে কি না। তা করা গেলে অর্থবছর বদল বাংলাদেশের উন্নয়ন প্রকল্প বাস্তবায়ন, সরকারি ব্যয়ের মান এবং আর্থিক জবাবদিহিতে একটি অর্থবহ পরিবর্তন আনতে পারে। তা না হলে জুনের তাড়াহুড়া শুধু মার্চেই সরে যাবে, অন্য কিছু নয়।',
            ),
          ],
        ),
        BlogPost(
          id: '2',
          title: 'The Victorian Period (1832-1901) MCQ: ২০০টি গুরুত্বপূর্ণ প্রশ্নোত্তর',
          category: 'BCS Preparation',
          publishDate: '23 Jun, 2026',
          publishTime: '10:15 AM',
          readTime: '০৫ মিনিট পড়া',
          views: '৫২ জন পড়েছেন',
          excerpt:
              'বিসিএস ও সরকারি চাকরি পরীক্ষার জন্য ভিক্টোরিয়ান যুগের গুরুত্বপূর্ণ সাহিত্যিক, তাদের সৃষ্টি ও বিগত বছরের প্রশ্নোত্তর বিশ্লেষণ।',
          mentor: 'লক্ষ্য একাডেমি',
          source: 'লক্ষ্য রিসার্চ সেল',
          imageUrl:
              'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=800&auto=format&fit=crop',
          isRecentGuide: true,
          sections: [
            BlogSection(
              title: 'ভিক্টোরিয়ান যুগের পটভূমি',
              content:
                  'ইংরেজি সাহিত্যের অন্যতম গুরুত্বপূর্ণ অধ্যায় হলো Victorian Period। ১৮৩৭ সালে রানী ভিক্টোরিয়ার সিংহাসনে আরোহণের মাধ্যমে এই যুগের সূচনা এবং ১৯০১ সালে তাঁর মৃত্যুর মধ্য দিয়ে এর সমাপ্তি ঘটে। তবে সাহিত্যিক পরিমণ্ডলে ১৮৩২ সালের রিফর্ম অ্যাক্টকে সূচনা ধরা হয়।',
            ),
            BlogSection(
              title: 'গুরুত্বপূর্ণ লেখক ও তাদের রচনাবলী',
              content:
                  '১. Charles Dickens: David Copperfield, Great Expectations, Oliver Twist, A Tale of Two Cities.\n২. Lord Alfred Tennyson: In Memoriam, Ulysses, The Charge of the Light Brigade.\n৩. Robert Browning: Dramatic Monologue এর জনক; Rabbi Ben Ezra, The Last Ride Together.\n৪. George Eliot (Mary Ann Evans): Silas Marner, Middlemarch.',
            ),
          ],
        ),
        BlogPost(
          id: '3',
          title: 'ডাটাবেজ সিস্টেম (DBMS) সম্পর্কিত গুরুত্বপূর্ণ প্রশ্নোত্তর',
          category: 'BCS Preparation',
          publishDate: '21 Jun, 2026',
          publishTime: '03:40 PM',
          readTime: '০৩ মিনিট পড়া',
          views: '৪৭ জন পড়েছেন',
          excerpt:
              'কম্পিউটার ও তথ্যপ্রযুক্তি অংশের ডিবিএমএস, এসকিউএল ও রিলেশনাল ডাটাবেজ মডেলের গুরুত্বপূর্ণ ধারণা ও বিগত বছরের প্রশ্নাবলী।',
          mentor: 'লক্ষ্য একাডেমি',
          source: 'লক্ষ্য আইসিটি একাডেমি',
          imageUrl:
              'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?q=80&w=800&auto=format&fit=crop',
          isRecentGuide: true,
          sections: [
            BlogSection(
              title: 'ডাটাবেজ ম্যানেজমেন্ট সিস্টেম পরিচিতি',
              content:
                  'ডাটাবেজ ম্যানেজমেন্ট সিস্টেম (DBMS) হলো কতগুলো প্রোগ্রামের সমন্বয় যা ডাটাবেজ তৈরি, পরিবর্তন ও নিয়ন্ত্রণ করতে সাহায্য করে। রিলেশনাল ডাটাবেজ মডেলের প্রবক্তা ই. এফ. কড (E. F. Codd)।',
            ),
          ],
        ),
        BlogPost(
          id: '4',
          title: 'কম্পিউটার অপারেটিং সিস্টেম (Operating System) গুরুত্বপূর্ণ MCQ!',
          category: 'BCS Preparation',
          publishDate: '20 Jun, 2026',
          publishTime: '02:30 PM',
          readTime: '০৪ মিনিট পড়া',
          views: '৪০ জন পড়েছেন',
          excerpt:
              'বিসিএস, প্রাইমারি, এনটিআরসিএ এবং অন্যান্য জব প্রিপারেশনের জন্য আপনার কাঙ্ক্ষিত (A) (B) (C) (D) স্টাইলের ১০০টি সর্বাধিক কমন উপযোগী প্রশ্ন ও ব্যাখ্যা।',
          mentor: 'লক্ষ্য একাডেমি',
          source: 'লক্ষ্য একাডেমি',
          imageUrl:
              'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=800&auto=format&fit=crop',
          sections: [
            BlogSection(
              title: 'অপারেটিং সিস্টেমের ভূমিকা ও প্রকারভেদ',
              content:
                  'অপারেটিং সিস্টেম হলো সিস্টেম সফটওয়্যার যা ব্যবহারকারী ও কম্পিউটার হার্ডওয়্যারের মধ্যে সেতুবন্ধন হিসেবে কাজ করে। যেমন: Windows, Linux, macOS, Android ইত্যাদি।',
            ),
          ],
        ),
        BlogPost(
          id: '5',
          title: 'The Neo-Classical Period (1660-1785)-এর ওপর গুরুত্বপূর্ণ MCQ',
          category: 'BCS Preparation',
          publishDate: '18 Jun, 2026',
          publishTime: '04:10 PM',
          readTime: '০৫ মিনিট পড়া',
          views: '৩৫ জন পড়েছেন',
          excerpt:
              'বিসিএস এবং ব্যাংক পরীক্ষার উচ্চতর ইংরেজি সাহিত্য প্রস্তুতির জন্য The Neo-Classical Period (1660-1785)-এর বিখ্যাত কবি ও নাটককারদের বিশেষ নোট।',
          mentor: 'লক্ষ্য একাডেমি',
          source: 'লক্ষ্য একাডেমি',
          imageUrl:
              'https://images.unsplash.com/photo-1461360370896-922624d12aa1?q=80&w=800&auto=format&fit=crop',
          sections: [
            BlogSection(
              title: 'নিও-ক্লাসিক্যাল পিরিয়ডের তিনটি ভাগ',
              content:
                  '১. The Restoration Period (1660-1700)\n২. The Augustan Age (1700-1745)\n৩. The Age of Sensibility (1745-1785)\n\nএই যুগের প্রধান লেখকগণের মধ্যে Alexander Pope, John Dryden, Jonathan Swift অন্যতম।',
            ),
          ],
        ),
      ];
}
