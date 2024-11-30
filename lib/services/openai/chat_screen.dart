import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'chat_service.dart';
import 'package:recipe_gpt/homepage.dart';
import '/db/db.dart';

class ChatPage extends StatefulWidget {
  final String prompt;
  final int people;
  final String recipe;
  final int accountId;
  final String preferences;

  ChatPage({required this.accountId, required this.preferences, required this.prompt, required this.people, required this.recipe});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _chatResponse = '';
  ScrollController _scrollController = ScrollController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _startChat(widget.recipe, widget.prompt, widget.people, widget.preferences);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1E9E6),
        title: Text('生成食譜'),
      ),
      backgroundColor: Color(0xFFF1E9E6),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    image: DecorationImage(
                      image: AssetImage('assets/image/note.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.dstATop,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Text(
                            _chatResponse.isNotEmpty ? _chatResponse : '食譜生成中...',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _showImageSourceDialog(context);
                  },
                  child: Text('完成'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // 分享食譜
                    // Share.share(_chatResponse);
                  },
                  child: Text('分享'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Color(0xFFF2B892), // Background color
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.white), // Foreground text color
          ),
        ),
        child: AlertDialog(
          title: Text(
            "選擇圖片來源",
            style: TextStyle(color: Colors.white), // Title text color
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: Text("拍照", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Text("從相簿選擇", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}

  // Future<void> _showImageSourceDialog(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("選擇圖片來源"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _pickImage(ImageSource.camera);
  //             },
  //             child: Text("拍照"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _pickImage(ImageSource.gallery);
  //             },
  //             child: Text("從相簿選擇"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage(_selectedImage!);  // Call the upload function after selecting the image
    }
  }

  Future<void> _uploadImage(File image) async {
  try {
    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: 'recipe_${widget.recipe}.jpg'),
      "accountId": widget.accountId.toString(),
      "recipeName": widget.recipe,
    });

    var response = await dio.post("http://152.42.163.75/upload.php", data: formData);

    // Decode the response data as JSON
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.data);  // Decode JSON string to Map
      } catch (e) {
        print('Failed to decode JSON: ${response.data}');
        return;
      }

      // Check if the JSON contains the expected keys
      if (responseData['status'] == 'success' && responseData.containsKey('imageUrl')) {
        String imageUrl = responseData['imageUrl'];
        await _saveImageUrlToDatabase(widget.accountId, imageUrl);  // Save the image URL in the database

        // Navigate back to the homepage upon successful upload and save
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(accountId: widget.accountId)),
          (route) => false,
        );
      } else {
        print('Upload failed: ${responseData['message'] ?? "Unknown error"}');
      }
    } else {
      print('Unexpected status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading image: $e');
  }
}


  Future<void> _saveImageUrlToDatabase(int accountId, String imageUrl) async {
    try {
      var conn = await DatabaseService().connection;

      // Update the 'url' field in the most recent recipe entry for this account
      await conn.query(
        'UPDATE recipedb.recipes SET url = ? WHERE accountId = ? ORDER BY createDate DESC LIMIT 1',
        [imageUrl, accountId],
      );

      print('Image URL successfully saved to database');
    } catch (e) {
      print('Error saving image URL to database: $e');
    }
  }

  void _startChat(String recipe, String prompt, int people, String preferences) async {
    String? response = await ChatService().request(recipe, prompt, people, preferences);
    setState(() {
      _chatResponse = response ?? 'No response';
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    if (response != null && response.isNotEmpty) {
      await _saveRecipeToDatabase(widget.accountId, recipe, response);  // Save the recipe to the database
    }
  }

  Future<void> _saveRecipeToDatabase(int accountId, String recipeName, String recipeText) async {
    try {
      var conn = await DatabaseService().connection;

      await conn.query(
        'INSERT INTO recipedb.recipes (accountId, recipeName, recipeText, createDate) VALUES (?, ?, ?, NOW())',
        [accountId, recipeName, recipeText],
      );

      print('食譜成功保存到資料庫中');
    } catch (e) {
      print('保存食譜到資料庫時出錯: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}