// ignore_for_file: depend_on_referenced_packages, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
// ignore: unused_import
import 'dart:io';
// ignore: unused_import
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
// ignore: unused_import
import 'package:image/image.dart' as img;
import './page_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'S11 AUC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'S11 AUC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController passWord = TextEditingController();
  String _responseBody = '';
  String requestBodyText = '';
  String _txtErr = '';
  String pass = '';
  String numberStamp = '';
  String timeStamp = '';

  void _resErr() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        // title: Text('Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                suffixIcon: Align(
                  child: Icon(
                    Icons.error_outline,
                    // Icons.,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              _txtErr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontFamily: "Kanit"),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              FloatingActionButton.extended(
                onPressed: () => Navigator.pop(context),
                // onPressed: () => Navigator.push(
                // context,
                // MaterialPageRoute(
                //     builder: (context) => MyApp(
                //           ))),
                // onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SecondRoute(passWord: passWord))),
                icon: const Icon(
                  Icons.check,
                  // size: 50,
                ),
                label: const Text(
                  "ตกลง",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Kanit"),
                ),
                backgroundColor: const Color(0xFF4E9A8E),
              ),
            ])
          ],
        ),
      ),
    );
  }

  void makePostRequest() async {
    pass = passWord.text;
    final uri =
        // Uri.parse('http://s11gs3s.doomdns.com:9091/WSDL/soap/IWSLim5AP');
        Uri.parse('http://devauc.s11.group:9498/WSDL/soap/IWSLim5AP');
    final headers = {'Accept': 'text/xml'};
    requestBodyText =
        // ignore: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings
        "<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/\n" +
            "   2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"\n" +
            "   xmlns:urn=\"urn:WSLim5APIntf-IWSLim5AP\">\n" +
            "   <soapenv:Header/>\n" +
            "   <soapenv:Body>\n" +
            "       <urn:textrec soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n" +
            "           <xcrec xsi:type=\"xsd:string\">S11A;$pass;A000;AULogon</xcrec>\n" +
            "       </urn:textrec>\n" +
            "   </soapenv:Body>\n" +
            "   </soapenv:Envelope>";
    // String jsonBody = json.encode(requestBodyText);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: requestBodyText,
      encoding: encoding,
    );
    // int statusCode = response.statusCode;
    setState(() {
      _responseBody = response.body;
      // pass = passWord.text;
      var strS = response.body.split(">");
      var strSp = strS[5].split('</');
      var resTxt = strSp[0].trim();
      var xrTxt = resTxt.split(';');

      if (xrTxt[0] == 'AERROR') {
        if (xrTxt[1] == 'E0001') {
          _txtErr = 'PASS ไม่ถูกต้อง';
        } else {
          _txtErr = 'ไม่ใช่ Code ---> S11';
        }
        _resErr();
        print(xrTxt);
        print(pass);
      } else {
        if (xrTxt[2] == 'E3001') {
          _txtErr = 'ไม่ใช่ Code ---> AULogon';
          _resErr();
        } else {
          //ไปหน้าหลักประมูล
          if (xrTxt.length > 6) {
            numberStamp = xrTxt[7];
            timeStamp = xrTxt[8];
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SecondRoute(
                        passWord: pass,
                        date: xrTxt[2],
                        place: xrTxt[3],
                        amount: xrTxt[4],
                        timeStart: xrTxt[5],
                        numberStamp: numberStamp,
                        timeStamp: timeStamp,
                      )));
          // print("Test: $xrTxt");
        }
      }
    });
  }

  // main widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF71BDAE),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Background Image
            Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/Background_Shadow.png"),
                    fit: BoxFit.none,
                  ),
                ),
                child: null),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [Image.asset("images/Logo_S11_AUC.png")],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "รหัสผ่าน",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: "Kanit"),
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: TextField(
                      obscureText: true,
                      controller: passWord,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 0.8),
                        suffixIcon: Align(
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFCDE4E0),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Color(0xFFFFFFFF))),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: makePostRequest,
                        label: const Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Kanit"),
                        ),
                        backgroundColor: const Color(0xFF98E747),
                      )
                    ],
                  ),
                  // Text(_responseBody)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
