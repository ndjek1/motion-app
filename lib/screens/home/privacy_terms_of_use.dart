import 'package:flutter/material.dart';

class PrivacyTermsPage extends StatelessWidget {
  const PrivacyTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy & Terms of Use'),
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Privacy Policy'),
              Tab(text: 'Terms of Use'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: const TabBarView(
          children: [
            PrivacyPolicyContent(),
            TermsOfUseContent(),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Last updated: Nov 6 2024\n\n'
            '1. Introduction\n'
            'CollabMate ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our app. By using our app, you agree to this Privacy Policy.\n\n'
            '2. Information We Collect\n'
            '- Personal Information: When you register, we collect details like your name, email address, and profile photo.\n'
            '- Project and Task Data: Data related to projects and tasks entered in the app.\n'
            '- Device Information: IP address, device type, etc., to improve app functionality.\n\n'
            '3. How We Use Your Information\n'
            'We use the information to provide, operate, and maintain the app, process user requests, send notifications, and personalize the experience.\n\n'
            '4. Data Sharing and Disclosure\n'
            'We do not sell your information. We may share data with third-party providers or when required by law.\n\n'
            '5. Data Security\n'
            'We use industry-standard security measures to protect your data.\n\n'
            '6. Your Rights and Choices\n'
            'Update or delete information via account settings or contact us.\n\n'
            '7. Changes to this Privacy Policy\n'
            'We may update this policy periodically and notify you of significant changes.\n\n'
            '8. Contact Us\n'
            'For questions, contact us at [Your Contact Information].',
          ),
        ],
      ),
    );
  }
}

class TermsOfUseContent extends StatelessWidget {
  const TermsOfUseContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms of Use',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Last updated: Nov 6 2024\n\n'
            '1. Acceptance of Terms\n'
            'By using CollabMate, you agree to these Terms of Use. Please read them carefully.\n\n'
            '2. Description of Service\n'
            'CollabMate is a project-tracking app that enables users to create and manage projects.\n\n'
            '3. User Accounts\n'
            'You are responsible for maintaining your account\'s confidentiality.\n\n'
            '4. User Content\n'
            'Users retain ownership of content but grant us a license to use it to operate the app.\n\n'
            '5. Prohibited Conduct\n'
            'Do not use the app for unlawful purposes, impersonate others, or upload malicious content.\n\n'
            '6. Limitation of Liability\n'
            'We are not liable for any indirect or incidental damages.\n\n'
            '7. Modifications to Terms\n'
            'We reserve the right to modify these Terms.\n\n'
            '8. Termination\n'
            'We may suspend or terminate access at any time.\n\n'
            '9. Contact Information\n'
            'For questions, contact us at [Your Contact Information].',
          ),
        ],
      ),
    );
  }
}
