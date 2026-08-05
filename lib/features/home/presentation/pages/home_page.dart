import 'package:flutter/material.dart';
import 'package:lumina/features/home/presentation/sections/final_cta_section.dart';
import 'package:lumina/features/home/presentation/sections/hero_section.dart';
import 'package:lumina/features/home/presentation/sections/instructor_teaser_section.dart';
import 'package:lumina/features/home/presentation/sections/reviews_teaser_section.dart';
import 'package:lumina/features/home/presentation/sections/session_content_section.dart';
import 'package:lumina/features/home/presentation/sections/upcoming_sessions_section.dart';
import 'package:lumina/features/home/presentation/sections/why_learn_section.dart';
import 'package:lumina/features/home/presentation/sections/why_programming_section.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/promo_qr_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteShell(
      child: Column(
        children: [
          HeroSection(),
          PromoQrSection(),
          WhyProgrammingSection(),
          WhyLearnSection(),
          UpcomingSessionsSection(),
          SessionContentSection(),
          InstructorTeaserSection(),
          ReviewsTeaserSection(),
          FinalCtaSection(),
          SizedBox(height: 48),
        ],
      ),
    );
  }
}
