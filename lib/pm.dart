import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用於日期格式化
import 'db/db.dart'; // 假設有資料庫服務類
import 'pmc.dart'; // 貼文詳情頁面

class PostManagementPage extends StatefulWidget {
  final int accountId; // 接收用戶的 accountId

  PostManagementPage({required this.accountId});

  @override
  _PostManagementPageState createState() => _PostManagementPageState();
}

class _PostManagementPageState extends State<PostManagementPage> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢 posts 表，關聯 recipes 表，過濾屬於當前用戶的貼文
      var results = await conn.query(
        '''
        SELECT p.postId, p.postTime, p.tag, r.recipeName, r.url
        FROM recipedb.posts AS p
        JOIN recipedb.recipes AS r
        ON p.recipeId = r.recipeId
        WHERE r.accountId = ?
        ORDER BY p.postTime DESC
        ''',
        [widget.accountId],
      );

      setState(() {
        posts = results.map((row) {
          return {
            'postId': row['postId'],
            'postTime': row['postTime'],
            'tag': row['tag'],
            'recipeName': row['recipeName'],
            'imageUrl': row['url'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('載入貼文失敗: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deletePost(int postId) async {
    try {
      var conn = await DatabaseService().connection;

      // 從 posts 表中刪除記錄
      await conn.query(
        'DELETE FROM recipedb.posts WHERE postId = ?',
        [postId],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('貼文已刪除')));

      // 返回上一頁並標記需要刷新
      Navigator.pop(context, true);
    } catch (e) {
      print('刪除貼文失敗: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刪除貼文失敗，請稍後再試')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '貼文管理',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFF1E9E6),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? Center(
                  child: Text(
                    '目前沒有貼文',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      var post = posts[index];
                      // 使用 DateFormat 格式化日期，只顯示到年月日
                      String formattedDate = DateFormat('yyyy-MM-dd')
                          .format(post['postTime']);

                      return Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              post['imageUrl'],
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                            ),
                          ),
                          title: Text(
                            post['recipeName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '發布日期: $formattedDate',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (post['tag'] != null)
                                Text(
                                  '標籤: ${post['tag']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deletePost(post['postId']);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(
                                  post: post, // 傳遞完整的貼文資料到詳細頁面
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
