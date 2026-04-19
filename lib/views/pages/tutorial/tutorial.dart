import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:piclicker/data/storage.dart';

class TutorialPage extends StatefulWidget {
  final List<Map<String, String>> screens;
  final Widget onFinishPage;
  final String pageKey;

  const TutorialPage({
    super.key,
    required this.screens,
    required this.onFinishPage,
    required this.pageKey,
  });

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with TickerProviderStateMixin {
  // Lottie controllers for animation
  List<AnimationController?> _lottieControllers = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _onNext() async {
    if (_currentPage < widget.screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark tutorial as completed
      userStorage.markTutorialCompleted(widget.pageKey);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.onFinishPage),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initLottieControllers(),
    );
  }

  void _initLottieControllers() {
    _lottieControllers = List.generate(widget.screens.length, (index) {
      if (widget.screens[index]['type'] == 'lottie') {
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000), // Initial placeholder
        );
        return controller;
      }
      return null;
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _lottieControllers) {
      controller?.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double? screenHeight = MediaQuery.of(context).size.height;
    return isLandscape
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                    final controller = _lottieControllers.length > page
                        ? _lottieControllers[page]
                        : null;
                    controller?.forward(from: 0.0);
                  },
                  itemCount: widget.screens.length,
                  itemBuilder: (context, index) {
                    final screen = widget.screens[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.tealAccent.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: screen['type'] == 'image'
                                  ? DecorationImage(
                                      image: AssetImage(
                                        "assets/images/${screen['name']}.png",
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: screen['type'] == 'lottie'
                                ? Lottie.asset(
                                    "assets/lottie/${screen['name']}.json",
                                    controller:
                                        _lottieControllers.length > index &&
                                            _lottieControllers[index] != null
                                        ? _lottieControllers[index]!
                                        : null,
                                    width: 280,
                                    height: 280,
                                    onLoaded: (composition) {
                                      if (_lottieControllers.length > index &&
                                          _lottieControllers[index] != null) {
                                        _lottieControllers[index]!.duration =
                                            composition.duration;
                                        _lottieControllers[index]!.repeat();
                                      }
                                    },
                                  )
                                : null,
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  screen['title'] ?? "",
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  screen['text'] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 20,
                  top: screenHeight / 1.3,
                  bottom: 0,
                  child: Row(
                    children: List.generate(
                      widget.screens.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.tealAccent
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 30,
                  child: FloatingActionButton.extended(
                    onPressed: _onNext,
                    backgroundColor: Colors.tealAccent,
                    elevation: 10,
                    label: Text(
                      _currentPage == widget.screens.length - 1
                          ? "START"
                          : "NEXT",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      _currentPage == widget.screens.length - 1
                          ? Icons.done
                          : Icons.arrow_forward,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                  },
                  itemCount: widget.screens.length,
                  itemBuilder: (context, index) {
                    final screen = widget.screens[index];
                    double? screenHeight = MediaQuery.of(context).size.height;
                    return isLandscape
                        ? Padding(
                            padding: EdgeInsetsGeometry.only(
                              left: 20,
                              top: 20,
                              bottom: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: .spaceAround,
                              children: [
                                Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.tealAccent.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    image: screen['type'] == 'image'
                                        ? DecorationImage(
                                            image: AssetImage(
                                              "assets/images/${screen['name']}.png",
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: screen['type'] == 'lottie'
                                      ? Lottie.asset(
                                          "assets/lottie/${screen['name']}.json",
                                          controller:
                                              _lottieControllers.length >
                                                      index &&
                                                  _lottieControllers[index] !=
                                                      null
                                              ? _lottieControllers[index]!
                                              : null,
                                          width: 250,
                                          height: 250,
                                          onLoaded: (composition) {
                                            if (_lottieControllers.length >
                                                    index &&
                                                _lottieControllers[index] !=
                                                    null) {
                                              _lottieControllers[index]!
                                                      .duration =
                                                  composition.duration;
                                              _lottieControllers[index]!
                                                  .repeat();
                                            }
                                          },
                                        )
                                      : null,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      screen['title'] ?? "",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      screen['text'] ?? "",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: screenHeight / 4),
                                Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.tealAccent.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    image: screen['type'] == 'image'
                                        ? DecorationImage(
                                            image: AssetImage(
                                              "assets/images/${screen['name']}.png",
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: screen['type'] == 'lottie'
                                      ? Lottie.asset(
                                          "assets/lottie/${screen['name']}.json",
                                          controller:
                                              _lottieControllers.length >
                                                      index &&
                                                  _lottieControllers[index] !=
                                                      null
                                              ? _lottieControllers[index]!
                                              : null,
                                          width: 250,
                                          height: 250,
                                          onLoaded: (composition) {
                                            if (_lottieControllers.length >
                                                    index &&
                                                _lottieControllers[index] !=
                                                    null) {
                                              _lottieControllers[index]!
                                                      .duration =
                                                  composition.duration;
                                              _lottieControllers[index]!
                                                  .repeat();
                                            }
                                          },
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 50),
                                Text(
                                  screen['title'] ?? "",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  screen['text'] ?? "",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),

                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          widget.screens.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.tealAccent
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton.extended(
                        onPressed: _onNext,
                        backgroundColor: Colors.tealAccent,
                        label: Text(
                          _currentPage == widget.screens.length - 1
                              ? "START"
                              : "NEXT",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(
                          _currentPage == widget.screens.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                          color: Colors.black,
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
