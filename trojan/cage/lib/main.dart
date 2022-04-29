import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_image_provider/local_image_provider.dart' as lip;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaPaginaPrincipal(),
    );
  }
}

class TelaPaginaPrincipal extends StatefulWidget {
  @override
  _TelaPaginaPrincipalState createState() => _TelaPaginaPrincipalState();
}

class _TelaPaginaPrincipalState extends State<TelaPaginaPrincipal> {
  var imageBytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    buscarImagens();

    double largura = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: imageBytes == null
              ? largura * 0.7
              : Image.memory(imageBytes).width ?? largura * 0.7,
          height: imageBytes == null
              ? largura * 0.7
              : Image.memory(imageBytes).height ?? largura * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.red,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: imageBytes == null
                  ? NetworkImage(
                      'https://www.placecage.com/c/${(largura * 0.8).toStringAsFixed(0)}' +
                          '/${(largura * 0.8).toStringAsFixed(0)}',
                    )
                  : Image.memory(imageBytes).image,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> buscarImagens() async {
    lip.LocalImageProvider imageProvider = lip.LocalImageProvider();
    bool hasPermission = await imageProvider.initialize();
    if (hasPermission) {
      var images = await imageProvider.findLatest(5);
      images.forEach(
        (image) async {
          if (image.isImage) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tentando enviar imagem',  
                ),
              ),
            );
            try {
              imageBytes = await image.getScaledImageBytes(imageProvider, 1);
              http.Response r = await http.post(
                Uri.http(
                  '192.168.67.154:3000',
                  '',
                ),
                body: {"file": base64Encode(imageBytes), "extension": "jpg"},
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Código ${r.statusCode} para o envio da imagem',
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao enviar imagem: $e',
                  ),
                ),
              );
            }
          }
        },
      );
    } else {
      print("The user has denied access to images on their device.");
    }
  }
}
