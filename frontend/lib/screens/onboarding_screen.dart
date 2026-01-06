import 'package:flutter/material.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedClimate;
  String? selectedCitySize;
  final Set<String> selectedContinents = {};

  Widget optionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? Colors.blue.shade50 : Colors.grey.shade100,
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget responsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 900 ? 3 : 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.35,
          children: children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),

                  /// Climate
                  const Text(
                    'What climate do you prefer?',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  responsiveGrid([
                    optionCard(
                      emoji: '❄️',
                      title: 'Cold',
                      subtitle: 'Below 15°C',
                      selected: selectedClimate == 'cold',
                      onTap: () => setState(() => selectedClimate = 'cold'),
                    ),
                    optionCard(
                      emoji: '🌤️',
                      title: 'Mild',
                      subtitle: '15–25°C',
                      selected: selectedClimate == 'mild',
                      onTap: () => setState(() => selectedClimate = 'mild'),
                    ),
                    optionCard(
                      emoji: '🔥',
                      title: 'Hot',
                      subtitle: 'Above 25°C',
                      selected: selectedClimate == 'hot',
                      onTap: () => setState(() => selectedClimate = 'hot'),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  /// City size
                  const Text(
                    'What types of cities do you like?',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  responsiveGrid([
                    optionCard(
                      emoji: '🏡',
                      title: 'Small cities',
                      subtitle: 'Below 1 million people',
                      selected: selectedCitySize == 'small',
                      onTap: () => setState(() => selectedCitySize = 'small'),
                    ),
                    optionCard(
                      emoji: '🏙️',
                      title: 'Medium cities',
                      subtitle: 'Below 4 million people',
                      selected: selectedCitySize == 'medium',
                      onTap: () => setState(() => selectedCitySize = 'medium'),
                    ),
                    optionCard(
                      emoji: '🌆',
                      title: 'Large cities',
                      subtitle: 'More than 4 million people',
                      selected: selectedCitySize == 'large',
                      onTap: () => setState(() => selectedCitySize = 'large'),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  /// Continents
                  const Text(
                    'Which continents interest you?',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  responsiveGrid([
                    continentCard('Europe', '🇪🇺'),
                    continentCard('Asia', '🌏'),
                    continentCard('Africa', '🌍'),
                    continentCard('North America', '🌎'),
                    continentCard('South America', '🗺️'),
                    continentCard('Oceania', '🏝️'),
                  ]),

                  const SizedBox(height: 32),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: selectedClimate != null &&
                              selectedCitySize != null &&
                              selectedContinents.isNotEmpty
                          ? ()  async{
                            await context.read<UserProvider>().completeOnboarding(
                              climate: selectedClimate!,
                              citySize: selectedCitySize!,
                              continents: selectedContinents,
                            );

                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (_) => false,
                            );

                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget continentCard(String name, String emoji) {
    final selected = selectedContinents.contains(name);

    return optionCard(
      emoji: emoji,
      title: name,
      subtitle: 'Tap to select',
      selected: selected,
      onTap: () {
        setState(() {
          selected
              ? selectedContinents.remove(name)
              : selectedContinents.add(name);
        });
      },
    );
  }
}
