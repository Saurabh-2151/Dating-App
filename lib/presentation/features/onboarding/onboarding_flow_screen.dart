import 'package:dating_app/core/theme/app_theme.dart';
import 'package:dating_app/data/providers/auth_provider.dart';
import 'package:dating_app/data/providers/onboarding_provider.dart';
import 'package:dating_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToPage(BuildContext context, int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<OnboardingProvider>().setCurrentPage(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    final onboardingData = {
      'name': onboarding.name,
      'gender': onboarding.gender,
      'genderDetail': onboarding.genderDetail,
      'orientation': onboarding.orientation,
      'interestIn': onboarding.interestIn,
      'lookingFor': onboarding.lookingFor.toList(),
      'distance': onboarding.distance,
      'extras': onboarding.extras.toList(),
      'fantasyEnabled': onboarding.fantasyEnabled,
      'fantasyRole': onboarding.fantasyRole,
      'kinks': onboarding.kinks.toList(),
    };

    try {
      await authProvider.saveOnboardingData(onboardingData);
      await authProvider.completeOnboarding();
    } catch (_) {
      // Ignore errors here so onboarding can still complete visually
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
      (route) => false,
    );
  }

  bool _canGoNext(OnboardingProvider onboarding) {
    switch (onboarding.currentPage) {
      case 1:
        return onboarding.name.trim().isNotEmpty;
      case 3:
        return onboarding.gender != null;
      case 5:
        return onboarding.orientation != null;
      case 6:
        return onboarding.interestIn != null;
      case 7:
        return onboarding.lookingFor.isNotEmpty;
      case 8:
        return true; // distance always has a value
      case 9:
        return onboarding.extras.length >= 1; // require at least one
      case 10:
        if (!onboarding.fantasyEnabled) return true;
        return onboarding.fantasyRole != null;
      case 11:
        return true;
      default:
        return true;
    }
  }

  void _handleNext(BuildContext context) {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (onboarding.currentPage == 1) {
      // Show welcome dialog before proceeding
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Welcome, ${_nameController.text.trim()}!'),
            content: const Text(
              "There's a lot to discover out there. Let's get your profile set up first.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: const Text('Edit name'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  FocusManager.instance.primaryFocus?.unfocus();
                  _goToPage(context, 3);
                },
                child: const Text("Let's go"),
              ),
            ],
          );
        },
      );
      return;
    }

    if (onboarding.currentPage < 11) {
      _goToPage(context, onboarding.currentPage + 1);
    } else {
      _finishOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final media = MediaQuery.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: media.size.width * 0.06,
      vertical: media.size.height * 0.02,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OnboardingBackgroundPainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: padding,
                    child: Row(
                      children: [
                        if (onboarding.currentPage > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardDark.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                if (onboarding.currentPage > 0) {
                                  _goToPage(
                                      context, onboarding.currentPage - 1);
                                }
                              },
                            ),
                          ).animate().fadeIn().scale()
                        else
                          const SizedBox(width: 48),
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (onboarding.currentPage + 1) / 12,
                              backgroundColor: AppColors.cardDark,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildWelcomeScreen(padding),
                        _buildNameScreen(context, padding),
                        const SizedBox.shrink(),
                        _buildGenderScreen(context, padding),
                        _buildGenderDetailScreen(padding),
                        _buildOrientationScreen(padding),
                        _buildInterestedInScreen(padding),
                        _buildLookingForScreen(padding),
                        _buildDistanceScreen(padding),
                        _buildExtrasScreen(padding),
                        _buildFantasyScreen(context, padding),
                        _buildKinksScreen(context, padding),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: padding.left,
                      right: padding.right,
                      bottom: 24,
                    ),
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.only(
                        bottom: media.viewInsets.bottom > 0
                            ? media.viewInsets.bottom
                            : 0,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: _canGoNext(onboarding)
                              ? AppColors.primaryGradient
                              : null,
                          color: _canGoNext(onboarding)
                              ? null
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: _canGoNext(onboarding)
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _canGoNext(onboarding)
                                ? () => _handleNext(context)
                                : null,
                            child: Center(
                              child: Text(
                                onboarding.currentPage == 0
                                    ? 'I agree'
                                    : onboarding.currentPage == 11
                                        ? "Let's start"
                                        : 'Next',
                                style: TextStyle(
                                  color: _canGoNext(onboarding)
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate(target: _canGoNext(onboarding) ? 1 : 0).scale(
                            begin: const Offset(0.98, 0.98),
                            end: const Offset(1, 1),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(EdgeInsets padding) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Welcome to SparkMatch.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          const Text(
            'Please follow these house rules.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 32),
          ..._buildRuleItems(),
        ],
      ),
    );
  }

  List<Widget> _buildRuleItems() {
    final rules = [
      (
        'Be yourself.',
        'Make sure your photos, age and bio are true to who you are.'
      ),
      ('Stay safe.', "Don't be too quick to give out personal information."),
      (
        'Play it cool.',
        'Respect others and treat them as you would like to be treated.'
      ),
      ('Be proactive.', 'Always report bad behaviour.'),
    ];

    return rules.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _RuleItem(
          title: entry.value.$1,
          subtitle: entry.value.$2,
        )
            .animate(delay: (300 + entry.key * 100).ms)
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.1, end: 0),
      );
    }).toList();
  }

  Widget _buildNameScreen(BuildContext context, EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final extraBottom = bottomInset + 56 + 24;
    return SingleChildScrollView(
      padding: padding.copyWith(bottom: padding.bottom + extraBottom),
      physics: bottomInset > 0
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "What's your first name?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardLight,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Enter first name',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              onChanged: onboarding.setName,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),
          const Text(
            "This is how it'll appear on your profile. Can't change it later.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildGenderScreen(BuildContext context, EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final options = ['Man', 'Woman', 'Beyond binary'];
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final extraBottom = bottomInset + 56 + 24;
    return SingleChildScrollView(
      padding: padding.copyWith(bottom: padding.bottom + extraBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "What's your gender?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select all that describe you to help us show your profile to the right people.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ...options.map((g) => _SelectableTile(
                label: g,
                selected: onboarding.gender == g,
                onTap: () {
                  onboarding.setGender(g);
                },
              )),
          const SizedBox(height: 16),
          _ExpandableSection(
            title: 'Add more about your gender (optional)',
            child: _buildGenderDetailScreen(
                padding.copyWith(top: EdgeInsets.zero.top)),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDetailScreen(EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    final details = [
      'Cis man',
      'Intersex man',
      'Trans man',
      'Transmasculine',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details
          .map((d) => _SelectableTile(
                label: d,
                selected: onboarding.genderDetail == d,
                onTap: () {
                  onboarding.setGenderDetail(d);
                },
              ))
          .toList(),
    );
  }

  Widget _buildOrientationScreen(EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final options = ['Straight', 'Gay', 'Lesbian', 'Bisexual', 'Asexual'];
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "What's your sexual orientation?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select all that describe you to reflect your identity.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ...options.map((o) => _SelectableTile(
                label: o,
                selected: onboarding.orientation == o,
                onTap: () {
                  onboarding.setOrientation(o);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildInterestedInScreen(EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final options = ['Men', 'Women', 'Beyond binary', 'Everyone'];
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Who are you interested in seeing?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select all that apply to help us recommend the right people for you.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ...options.map((o) => _SelectableTile(
                label: o,
                selected: onboarding.interestIn == o,
                onTap: () {
                  onboarding.setInterestIn(o);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildLookingForScreen(EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final options = [
      'Long-term partner',
      'Long-term, but short-term OK',
      'Short-term, but long-term OK',
      'Short-term fun',
      'New friends',
      'Still figuring it out',
    ];
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'What are you looking for?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "All good if it changes. There's something for everyone.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((o) {
              final selected = onboarding.lookingFor.contains(o);
              return ChoiceChip(
                label: Text(o),
                selected: selected,
                onSelected: (_) {
                  onboarding.toggleLookingFor(o);
                },
                selectedColor: Colors.pink,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white,
                ),
                backgroundColor: Colors.grey.shade900,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceScreen(EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Your distance preference?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Use the slider to set the maximum distance you would like potential matches to be located.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Text(
            'Distance preference ${onboarding.distance.toStringAsFixed(0)} mi',
            style: const TextStyle(color: Colors.white),
          ),
          Slider(
            value: onboarding.distance,
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: Colors.pink,
            inactiveColor: Colors.white24,
            label: onboarding.distance.toStringAsFixed(0),
            onChanged: onboarding.setDistance,
          ),
          const SizedBox(height: 8),
          const Text(
            'You can change preferences later in Settings.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasScreen(EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final extras = [
      "I stay on WhatsApp all day",
      'Big time texter',
      'Phone caller',
      'Video chatter',
      "I\'m slow to answer on WhatsApp",
      'Bad texter',
      'Better in person',
      'Thoughtful gestures',
      'Presents',
      'Touch',
      'Compliments',
      'Time together',
      'Bachelor degree',
      'High school',
      'Master degree',
    ];
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'What else makes you, you?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Don't hold back. Authenticity attracts authenticity.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: extras.map((e) {
                final selected = onboarding.extras.contains(e);
                return FilterChip(
                  label: Text(e),
                  selected: selected,
                  onSelected: (_) {
                    onboarding.toggleExtra(e);
                  },
                  selectedColor: Colors.pink,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white,
                  ),
                  backgroundColor: Colors.grey.shade900,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFantasyScreen(BuildContext context, EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final extraBottom = bottomInset + 56 + 24;

    final roles = [
      'Romantic CEO',
      'Mystery Stranger',
      'Soft Dominant',
      'Creative Dreamer',
    ];

    return SingleChildScrollView(
      padding: padding.copyWith(bottom: padding.bottom + extraBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Explore Fantasy Mode?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
          const SizedBox(height: 12),
          const Text(
            'Choose a vibe and connect through imagination. Totally optional.',
            style: TextStyle(color: Colors.white70),
          ).animate(delay: 150.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Enable Fantasy Mode',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Switch(
                  value: onboarding.fantasyEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    onboarding.setFantasyEnabled(v);
                  },
                ),
              ],
            ),
          )
              .animate(delay: 250.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.08, end: 0),
          if (onboarding.fantasyEnabled) ...[
            const SizedBox(height: 24),
            const Text(
              'Pick a role:',
              style: TextStyle(color: AppColors.textSecondary),
            ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
            const SizedBox(height: 12),
            ...roles.map(
              (r) => _SelectableTile(
                label: r,
                selected: onboarding.fantasyRole == r,
                onTap: () {
                  onboarding.setFantasyRole(r);
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              'You can turn this on later in settings.',
              style: TextStyle(color: Colors.white54),
            ).animate(delay: 250.ms).fadeIn(duration: 600.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildKinksScreen(BuildContext context, EdgeInsets padding) {
    final onboarding = Provider.of<OnboardingProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final extraBottom = bottomInset + 56 + 24;

    final tags = [
      'Romantic',
      'Slow burn',
      'Praise',
      'Dominant energy',
      'Submissive energy',
      'Gentle & caring',
      'Roleplay',
      'Open-minded',
    ];

    return SingleChildScrollView(
      padding: padding.copyWith(bottom: padding.bottom + extraBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Comfort & Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
          const SizedBox(height: 12),
          const Text(
            'Only share what feels right. You can skip or edit later.',
            style: TextStyle(color: Colors.white70),
          ).animate(delay: 150.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 8),
          const Text(
            'Skip for now',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ).animate(delay: 250.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              final selected = onboarding.kinks.contains(t);
              return FilterChip(
                label: Text(t),
                selected: selected,
                onSelected: (_) {
                  onboarding.toggleKink(t);
                },
                selectedColor: Colors.pink,
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.grey.shade900,
              );
            }).toList(),
          )
              .animate(delay: 250.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RuleItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.primaryGradient : null,
        color: selected ? null : AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.transparent : AppColors.cardLight,
          width: 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(target: selected ? 1 : 0)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.child,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          widget.child,
        ],
      ],
    );
  }
}

class _OnboardingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonPink.withOpacity(0.1),
          AppColors.neonPink.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.2),
          radius: size.width * 0.6,
        ),
      );

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonPurple.withOpacity(0.1),
          AppColors.neonPurple.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.9, size.height * 0.8),
          radius: size.width * 0.7,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      size.width * 0.6,
      paint1,
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      size.width * 0.7,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
