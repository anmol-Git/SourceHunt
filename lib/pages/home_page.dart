import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/SignatureContentToggle.dart';
import 'package:reef_mobile_app/components/home/NFT_view.dart';
import 'package:reef_mobile_app/components/home/activity_view.dart';
import 'package:reef_mobile_app/components/home/token_view.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/pages/test_page.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/size_config.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import 'DAppPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateTestDApp(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DAppPage(ReefAppState.instance, url)),
    );
  }

  void _navigateTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestPage()),
    );
  }

  double _textSize = 120.0;
  bool _isScrolling = false;

  List _viewsMap = [
    {
      "key": 0,
      "name": "Tokens",
      "active": true,
      "component": const TokenView()
    },
    /*{
      "key": 1,
      "name": "Stakings",
      "active": false,
      "component": const StakingView()
    },*/
    {"key": 1, "name": "NFTs", "active": false, "component": const NFTView()},
    {
      "key": 2,
      "name": "Activity",
      "active": false,
      "component": const ActivityView()
    }
  ];

  Widget balanceSection(double size) {
    bool _isBigText = size > 42;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCirc,
        width: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Balance",
                      style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Center(
                    child: Observer(builder: (_) {
                      return GradientText(
                        "\$${sumTokenBalances(ReefAppState.instance.model.tokens.selectedSignerTokens.toList()).toStringAsFixed(0)}",
                        gradient: textGradient(),
                        style: GoogleFonts.poppins(
                            color: Styles.textColor,
                            fontSize: 68,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3),
                      );
                    }),
                  ),
                ]),
          ),
        ));
  }

  Widget rowMember(Map member) {
    return InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          List temp = _viewsMap;
          for (var element in temp) {
            element["active"] = (element["name"] == member["name"]);
          }
          setState(() {
            _viewsMap = temp;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/reef-image.png',
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: 80,
                  ),
                ),
              ),
            )
          ],
        )
        // child: (AnimatedContainer(
        //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(9),
        //       color:
        //           member["active"] ? Colors.black : Styles.primaryBackgroundColor,
        //       boxShadow: member["active"]
        //           ? [
        //               const BoxShadow(
        //                 color: Colors.black12,
        //                 blurRadius: 5,
        //                 offset: Offset(0, 2.5),
        //               )
        //             ]
        //           : [],
        //     ),
        //     duration: const Duration(milliseconds: 200),
        //     child: Opacity(
        //       opacity: member["active"] ? 1 : 0.5,
        //       child: Text(
        //         member["name"],
        //         style: TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.w700,
        //           color: member["active"]
        //               ? Styles.primaryBackgroundColor
        //               : Colors.black,
        //         ),
        //       ),
        //     ))),
        );
  }

  Widget navSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xff11141D),
          boxShadow: [
            BoxShadow(
              color: const HSLColor.fromAHSL(
                      1, 256.3636363636, 0.379310344828, 0.843137254902)
                  .toColor(),
              offset: const Offset(10, 10),
              blurRadius: 20,
              spreadRadius: -2,
            ),
            BoxShadow(
              color:
                  const HSLColor.fromAHSL(1, 256.3636363636, 0.379310344828, 1)
                      .toColor(),
              offset: const Offset(-10, -10),
              blurRadius: 20,
              spreadRadius: -1,
            ),
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _viewsMap.map<Widget>((e) => rowMember(e)).toList()),
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) {
      return;
    } // user have just tapped on screen (no dragging)

    if (details.primaryVelocity?.compareTo(0) == -1) {
      // dragged towards left
      List temp = _viewsMap;
      int currentIndex =
          temp.where((element) => element["active"] == true).toList()[0]["key"];
      if (currentIndex < _viewsMap.length - 1) {
        for (var element in temp) {
          element["active"] = (element["key"] == currentIndex + 1);
        }
        setState(() {
          _viewsMap = temp;
        });
      }
    } else {
      List temp = _viewsMap;
      int currentIndex =
          temp.where((element) => element["active"] == true).toList()[0]["key"];
      if (currentIndex > 0) {
        for (var element in temp) {
          element["active"] = (element["key"] == currentIndex - 1);
        }
        setState(() {
          _viewsMap = temp;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SizeConfig.init(context);

    return SignatureContentToggle(AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: NotificationListener(
          child: Container(
            color: Color(0xFF11141d),
            child: Column(
              children: [
                /*Row(children: [
                    ElevatedButton(
                      child: const Text('test dApp 1'),
                      onPressed: () => _navigateTestDApp(
                          "https://mobile-dapp-test.web.app/testnet"),
                      // https://min-dapp.web.app
                      // https://app.reef.io
                    ),
                    ElevatedButton(
                      child: const Text('test dApp 2'),
                      onPressed: () => _navigateTestDApp(
                          "https://console.reefscan.com/#/settings/metadata"),
                    ),
                    ElevatedButton(
                        child: const Text('test'), onPressed: _navigateTestPage),
                  ]),*/

                const SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: size.height * 0.30,
                    width: size.width * 0.8,
                    color: const Color.fromARGB(255, 78, 4, 135),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 80,
                          width: size.width * 0.6,
                          child: Image.asset(
                            "assets/images/reef-image.png",
                          ),
                        ),
                        const Text(
                          'Join the Reef DAO',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                          child: const Text('Join Dao'),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: size.width,
                  height: 30,
                  child: const Text(
                    'News And Trending',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                      itemCount: _viewsMap.length,
                      itemBuilder: ((context, index) {
                        return Container(
                          margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                          height: 200,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 0, 0, 0),
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child:
                                        Image.asset('assets/images/reef.png'),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Metapass',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Hand picked color pallete for your brand',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 5, 8, 5),
                                            alignment: Alignment.topLeft,
                                            color: Colors.grey,
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  CupertinoIcons
                                                      .chat_bubble_2_fill,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  '247',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 55,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 2),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  children: const [
                                    Icon(
                                      CupertinoIcons.arrowtriangle_up_fill,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      '247',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      })),
                )

                // Container(
                //   color: Colors.cyan,
                //   height: 400,
                //   width: MediaQuery.of(context).size.width,
                //   child: ListView.builder(
                //     scrollDirection: Axis.vertical,
                //     itemCount: _viewsMap.length,
                //     itemBuilder: (context, i) {
                //       return Text('Hi!!!');
                //       //  Image.asset(
                //       //   "assets/images/reef-image.png",
                //       //   height: 80,
                //       //   width: MediaQuery.of(context).size.width * 0.2,
                //       // );
                //     },
                //   ),
                // ),
                //  balanceSection(_textSize),
                //  navSection(),
                // AnimatedContainer(
                //     duration: const Duration(milliseconds: 200),
                //     height: _isScrolling ? 16 : 0),
                // Expanded(
                //   // height: ((size.height + 64) / 2),
                //   // width: double.infinity,
                //   child: GestureDetector(
                //       onHorizontalDragEnd: (DragEndDetails details) =>
                //           _onHorizontalDrag(details),
                //       child: ClipRRect(
                //           borderRadius: BorderRadius.circular(8),
                //           child: _viewsMap
                //               .where((option) => option["active"])
                //               .toList()[0]["component"])),
                // ),
                // TODO: ADD ALERT SYSTEM FOR ERRORS HERE
                // test()
              ],
            ),
          ),
          onNotification: (t) {
            if (t is ScrollUpdateNotification) {
              if (t.metrics.pixels != 0) {
                setState(() {
                  print("yes");
                  _isScrolling = true;
                });
              } else {
                setState(() {
                  print("no");
                  _isScrolling = false;
                });
              }
              if (t.metrics.pixels! > 196 && t.scrollDelta! > 0) {
                setState(() {
                  _textSize = 0.0;
                });
              }
              if (t.metrics.pixels! < 196 && t.scrollDelta! < 0) {
                setState(() {
                  _textSize = 120.0;
                });
              }
              // print("scroll delta:");
              // print(t.scrollDelta);
              // print("scroll pixels:");
              // print(t.metrics.pixels);
            }
            return true;
          },
        )));
  }

  double sumTokenBalances(List<TokenWithAmount> list) {
    var sum = 0.0;
    list.forEach((token) {
      double balValue =
          getBalanceValue(decimalsToDouble(token.balance), token.price);
      if (balValue > 0) {
        sum = sum + balValue;
      }
    });
    return sum;
  }
}
