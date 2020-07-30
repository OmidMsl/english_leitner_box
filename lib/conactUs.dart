import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// contact us page
class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    TextStyle ts = TextStyle(color: Colors.black87, fontFamily: 'Vazir');
    return Scaffold(
      backgroundColor: Color(0xff17ff9a),
      appBar: AppBar(
        title: Text(
          'تماس با ما',
          style: TextStyle(color: Colors.black87, fontFamily: 'Vazir'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // make page scrollable
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder( // rouding edges of the page
                borderRadius: BorderRadius.circular(10.0)),
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Text(
                      '    : توسعه یافته توسط',
                      style: ts,
                    ),
                  ),
                  Image.asset(
                    'images/developer.png',
                    height: 100,
                    width: 100,
                  ),
                  Text(
                    'Omid Msl',
                    style: ts,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 32.0, left: 8.0, right: 8.0),
                    child: Text(
                      'برای گزارش مشکل یا ارتباط با من از راه های ارتباطی زیر تماس برقرار فرمایید',
                      textAlign: TextAlign.center,
                      style: ts,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final Uri params = Uri(
                        scheme: 'mailto',
                        path: 'omid.intelligent@gmail.com',
                        query:
                            'subject=ارسال نظر Feedback&body=سلام Version 3.23', //add subject and body here
                      );
                      var url = params.toString();
                      if (await canLaunch(url)) launch(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('omid.intelligent@gmail.com     '),
                        Image.asset(
                          'images/gmail.png',
                          height: 30,
                          width: 30,
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      const url = "https://omidmsl.cloudsite.ir/";
                      if (await canLaunch(url)) launch(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('www.omidmsl.cloudsite.ir         '),
                        Image.asset(
                          'images/website.png',
                          height: 30,
                          width: 30,
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      const url =
                          "https://www.linkedin.com/in/omid-msl-6694761b2/";
                      if (await canLaunch(url)) launch(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('@omid-msl-6694761b2             '),
                        Image.asset(
                          'images/linkedin.png',
                          height: 30,
                          width: 30,
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      const url = "https://t.me/omidmsl/";
                      if (await canLaunch(url)) launch(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('@omidMsl                                   '),
                        Image.asset(
                          'images/telegram.png',
                          height: 30,
                          width: 30,
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      const url = "https://www.instagram.com/omid.mosalmani/";
                      if (await canLaunch(url)) launch(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('@omid.mosalmani                     '),
                        Image.asset(
                          'images/instagram.png',
                          height: 30,
                          width: 30,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32, left: 8.0, right: 8.0),
                    child: Text('این برنامه رایگان و منبع باز بوده و در گیت هاب قابل دسترسی است',
                    textAlign: TextAlign.center,
                    style: ts,)
                  ),
                  InkWell(
                    onTap: () async {
                      const url = "https://github.com/OmidMsl/english_leitner_box/";
                      if (await canLaunch(url)) launch(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('@byte_counting_test                 '),
                        Image.asset(
                          'images/github.png',
                          height: 30,
                          width: 30,
                        )
                      ],
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
}
