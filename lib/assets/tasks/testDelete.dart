import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
      int newIndex = points.length - 1;  // '+'를 제외한 새 인덱스
      points.insert(newIndex, 'POINT_$newIndex');
    });
  }

  void removePoint(int index) {
    setState(() {
      points.removeAt(index);
    });
  }

  void editPoint(int index) {
    // 다이얼로그를 통해 사용자에게 수정할 새 값을 입력받는 로직을 추가
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Point'),
          content: TextField(
            onSubmitted: (newValue) {
              setState(() {
                points[index] = newValue;
                Navigator.of(context).pop(); // 다이얼로그 닫기
              });
            },
          ),
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
    points = List.generate(3, (index) => '${widget.title}_$index')..add('+');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.list,),
            Text(widget.title+' List'),
            Opacity(opacity: 0, child: Icon(Icons.menu))
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white10,
        toolbarHeight: 30,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, //세로 스크롤
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
                  color: selectedRowIndex == index ? Colors.purple[50] : Colors.transparent,
                ),
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle, // 세로 중앙 정렬
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
                      child: Dismissible(
                        key: Key(points[index]),
                        direction: DismissDirection.horizontal,  // 양방향 스와이프 활성화
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            editPoint(index);  // 오른쪽에서 왼쪽으로 스와이프시 수정
                          } else {
                            removePoint(index);  // 왼쪽에서 오른쪽으로 스와이프시 삭제
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.blue,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(points[index], style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    )
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
