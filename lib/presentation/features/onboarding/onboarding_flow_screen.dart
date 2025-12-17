import 'package:dating_app/main.dart';
import 'package:flutter/material.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedGender;
  String? _selectedGenderDetail;
  String? _selectedOrientation;
  String? _selectedInterestIn;
  final Set<String> _selectedLookingFor = {};
  double _distance = 50;
  final Set<String> _selectedExtras = {};

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  bool get _canGoNext {
    switch (_currentPage) {
      case 1:
        return _nameController.text.trim().isNotEmpty;
      case 3:
        return _selectedGender != null;
      case 5:
        return _selectedOrientation != null;
      case 6:
        return _selectedInterestIn != null;
      case 7:
        return _selectedLookingFor.isNotEmpty;
      case 8:
        return true; // distance always has a value
      case 9:
        return _selectedExtras.length >= 1; // require at least one
      default:
        return true;
    }
  }

  void _handleNext(BuildContext context) {
    if (_currentPage == 1) {
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
                  _goToPage(3);
                },
                child: const Text("Let's go"),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_currentPage < 9) {
      _goToPage(_currentPage + 1);
    } else {
      _finishOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: media.size.width * 0.06,
      vertical: media.size.height * 0.02,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: padding,
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _goToPage(_currentPage - 1);
                        }
                      },
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 10,
                      backgroundColor: Colors.grey.shade800,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.pink),
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
                  _buildNameScreen(padding),
                  const SizedBox.shrink(), // placeholder, dialog-only step
                  _buildGenderScreen(padding),
                  _buildGenderDetailScreen(padding),
                  _buildOrientationScreen(padding),
                  _buildInterestedInScreen(padding),
                  _buildLookingForScreen(padding),
                  _buildDistanceScreen(padding),
                  _buildExtrasScreen(padding),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
                bottom:
                    media.viewInsets.bottom > 0 ? media.viewInsets.bottom : 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canGoNext ? () => _handleNext(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(_currentPage == 0 ? 'I agree' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 24),
          Text(
            'Welcome to SparkMatch.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Please follow these house rules.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 24),
          _RuleItem(
            title: 'Be yourself.',
            subtitle:
                'Make sure your photos, age and bio are true to who you are.',
          ),
          SizedBox(height: 16),
          _RuleItem(
            title: 'Stay safe.',
            subtitle: "Don't be too quick to give out personal information.",
          ),
          SizedBox(height: 16),
          _RuleItem(
            title: 'Play it cool.',
            subtitle:
                'Respect others and treat them as you would like to be treated.',
          ),
          SizedBox(height: 16),
          _RuleItem(
            title: 'Be proactive.',
            subtitle: 'Always report bad behaviour.',
          ),
        ],
      ),
    );
  }

  Widget _buildNameScreen(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "What's your first name?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter first name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.pink),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          const Text(
            "This is how it'll appear on your profile. Can't change it later.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderScreen(EdgeInsets padding) {
    final options = ['Man', 'Woman', 'Beyond binary'];
    return Padding(
      padding: padding,
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
                selected: _selectedGender == g,
                onTap: () {
                  setState(() {
                    _selectedGender = g;
                  });
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
                selected: _selectedGenderDetail == d,
                onTap: () {
                  setState(() {
                    _selectedGenderDetail = d;
                  });
                },
              ))
          .toList(),
    );
  }

  Widget _buildOrientationScreen(EdgeInsets padding) {
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
                selected: _selectedOrientation == o,
                onTap: () {
                  setState(() {
                    _selectedOrientation = o;
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildInterestedInScreen(EdgeInsets padding) {
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
                selected: _selectedInterestIn == o,
                onTap: () {
                  setState(() {
                    _selectedInterestIn = o;
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildLookingForScreen(EdgeInsets padding) {
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
              final selected = _selectedLookingFor.contains(o);
              return ChoiceChip(
                label: Text(o),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _selectedLookingFor.remove(o);
                    } else {
                      _selectedLookingFor.add(o);
                    }
                  });
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
            'Distance preference ${_distance.toStringAsFixed(0)} mi',
            style: const TextStyle(color: Colors.white),
          ),
          Slider(
            value: _distance,
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: Colors.pink,
            inactiveColor: Colors.white24,
            label: _distance.toStringAsFixed(0),
            onChanged: (v) => setState(() => _distance = v),
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
                final selected = _selectedExtras.contains(e);
                return FilterChip(
                  label: Text(e),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedExtras.remove(e);
                      } else {
                        _selectedExtras.add(e);
                      }
                    });
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
}

class _RuleItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RuleItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? Colors.pink.withOpacity(0.2) : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check,
                    color: Colors.pink,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
              color: Colors.grey.shade900,
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
