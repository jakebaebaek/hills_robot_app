import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hills_robot_app/utils/utils.dart';

class PointsTableWidget extends StatefulWidget {
  final String title;

  PointsTableWidget({Key? key, this.title = 'POINT'}) : super(key: key);

  @override
  _PointsTableWidgetState createState() => _PointsTableWidgetState();
}

class _PointsTableWidgetState extends State<PointsTableWidget> {
  late List<String> points;
  int? selectedRowIndex;

  void addPoint() {
    setState(() {
      int newIndex = points.length - 1; // '+'를 제외한 새 인덱스
      points.insert(newIndex, 'New ${widget.title}');
    });
  }

  void removePoint(int index) {
    setState(() {
      points.removeAt(index);
    });
  }

  void editPoint(int index) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Point'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Point Nmae"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  points[index] = _controller.text;
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                setState(() {});
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextButton(String text, Color backgroundColor, double width) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(fontSize: 30),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const StadiumBorder(),
        minimumSize: Size(width, 70), // Size 생성자를 올바르게 사용
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    points = List.generate(1, (index) => '+');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + ' List'),
        centerTitle: true,
        backgroundColor: Colors.white10,
        toolbarHeight: 55,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, // 세로 스크롤
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black), // Table 전체에 테두리 추가
          ),
          child: ClipRect(
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
              },
              border: TableBorder.all(color: Colors.black), // 모든 셀에 테두리 추가
              children: List<TableRow>.generate(
                points.length,
                (index) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: selectedRowIndex == index
                          ? Colors.purple[50]
                          : Colors.transparent,
                    ),
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        // 세로 중앙 정렬
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (points[index] == '+') {
                                addPoint();
                              } else {
                                selectedRowIndex = index; // 선택된 행 인덱스 갱신
                              }
                            });
                          },
                          child: points[index] == '+'
                              ? Container(
                                  color: Colors.yellow,
                                  height: 50,
                                  alignment: Alignment.center,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    points[index],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : Dismissible(
                                  key: UniqueKey(),
                                  // 고유 키를 사용하여 충돌 방지
                                  direction: DismissDirection.horizontal,
                                  // 양방향 스와이프 활성화
                                  onDismissed: (direction) {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      editPoint(index); // 오른쪽에서 왼쪽으로 스와이프 시 수정
                                    } else {
                                      removePoint(
                                          index); // 왼쪽에서 오른쪽으로 스와이프 시 삭제
                                    }
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerLeft,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.blue,
                                    alignment: Alignment.centerRight,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child:
                                        Icon(Icons.edit, color: Colors.white),
                                  ),
                                  child: Container(
                                    color: Colors.green,
                                    height: 50,
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      points[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
