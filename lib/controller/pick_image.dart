import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_gpt/checklist.dart';
import 'package:recipe_gpt/services/openai/api_key.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  Uint8List? _image;
  File? selectedImage;
  bool _isNextButtonEnabled = false;
  bool _isProcessing = false; // 是否正在辨識
  String _statusText = '拍照! 尋找可用食材~';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '生成食譜',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFF1E9E6),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF1E9E6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 80),
            _image != null
                ? AspectRatio(
                    aspectRatio: 1, // 固定比例 1:1
                    child: Image.memory(_image!),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                      image: DecorationImage(
                        image: AssetImage('assets/image/note.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.dstATop,
                        ),
                      ),
                    ),
                    child: Center(child: Text('還沒有照片哦!')),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          showImagePickerOption(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892), // 背景顏色
                    foregroundColor: Colors.white, // 文字顏色
                  ),
                  child: const Icon(Icons.add_a_photo,
                      color: Colors.white), // 調整圖標顏色
                ),
                SizedBox(width: 20), // 在兩個按鈕之間增加空間
                ElevatedButton(
                  onPressed: _isNextButtonEnabled && !_isProcessing
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckList(
                                resultItems: _resultItems,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892), // 背景顏色
                    foregroundColor: Colors.white, // 文字顏色
                  ),
                  child: Text('下一步'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Color(0xFFF2B892),
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                              color: Colors.white,
                            ),
                            Text("相簿", style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                              color: Colors.white,
                            ),
                            Text("相機", style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Gallery
  Future<void> _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
      _isProcessing = true;
      _statusText = '辨識中...';
    });
    Navigator.of(context).pop(); // 關閉modal對話框
    await _uploadImage(); // 開始影像辨識
  }

  // Camera
  Future<void> _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
      _isProcessing = true;
      _statusText = '辨識中...';
    });
    Navigator.of(context).pop(); // 關閉modal對話框
    await _uploadImage(); // 開始影像辨識
  }

  List<String> _resultItems = []; // 儲存辨識結果

  Future<void> _uploadImage() async {
    if (selectedImage == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.ultralytics.com/v1/predict/wiO6EHycTaKvnqiDyUeB'),
    );

    // request.headers['x-api-key'] = ApiKey.ultralyticsApiKey; // API key
    request.fields['size'] = '640';
    request.fields['confidence'] = '0.2';
    request.fields['iou'] = '0.5';

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      selectedImage!.path,
    ));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseBody);

      print('API Response: $responseBody'); //print出完整的辨識内容

      if (response.statusCode == 200) {
        final results =
            decodedResponse['images'][0]['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final detectedItems =
              List<String>.from(results.map((item) => item['name']));

          // 移除重複的項目
          _resultItems = _removeDuplicates(detectedItems);
          // 翻譯成中文
          _resultItems = await _translateItemsToChinese(_resultItems);

          _statusText = '辨識完成';
          _isNextButtonEnabled = true;
        } else {
          // 未偵測到食材
          _resultItems = [];
          _statusText = '再試一次';
          _isNextButtonEnabled = false;
        }
      } else {
        _resultItems = ['Image upload failed: ${response.statusCode}'];
        _statusText = '辨識失敗';
        _isNextButtonEnabled = false;
      }
    } catch (e) {
      print('Error during image upload: $e');
      _resultItems = ['Image upload failed'];
      _statusText = '辨識失敗';
      _isNextButtonEnabled = false;
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  List<String> _removeDuplicates(List<String> items) {
    return items.toSet().toList();
  }

  Map<String, String> _translationCache = {};

  Future<List<String>> _translateItemsToChinese(List<String> items) async {
    final apiKey = ApiKey.openAIApiKey;
    List<String> translatedItems = [];
    int delay = 5000; // 延遲5秒開始 (在短時間內發送了多個API請求觸發了速率限制failed: 429)

    for (String item in items) {
      if (_translationCache.containsKey(item)) {
        translatedItems.add(_translationCache[item]!);
      } else {
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'system',
                'content': '將下面的文字翻譯成繁體中文： $item',
              }
            ],
            'temperature': 0.5,
          }),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
          final translatedText =
              jsonResponse['choices'][0]['message']['content'];
          _translationCache[item] = translatedText;
          translatedItems.add(translatedText);
        } else if (response.statusCode == 429) {
          print(
              'Translation failed: ${response.statusCode}. Retrying in ${delay} ms...');
          await Future.delayed(Duration(milliseconds: delay));
          delay *= 2;
        } else {
          print('Translation failed: ${response.statusCode}');
          translatedItems.add(item); // 如果翻譯失敗，使用原始文字
        }
      }
    }
    return translatedItems;
  }
}
