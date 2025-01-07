class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Track your wealth and get results",
    image: "assets/images/blackwoman-phone.jpg",
    desc: "We help you to keep track of your wealth.",
  ),
  OnboardingContents(
    title: "Stay financially enlightened",
    image: "assets/images/twoguys-phone.png",
    desc:
        "We ensure to continually educate you into financial freedom.",
  ),
  OnboardingContents(
    title: "Get notified for transactions",
    image: "assets/images/lady-phone.jpeg",
    desc:
        "Take control of notifications on all transactions.",
  ),
];
