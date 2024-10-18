import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag Dock Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DockScreen(),
    );
  }
}

class DockScreen extends StatefulWidget {
  @override
  _DockScreenState createState() => _DockScreenState();
}

class _DockScreenState extends State<DockScreen> {
  List<IconData> dockItems = [
    Icons.home,
    Icons.search,
    Icons.settings,
    Icons.camera,
    Icons.alarm,
    Icons.phone,
  ];

  List<Color> iconColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  int? draggingIndex;
  Offset? dragOffset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildDock(context),
        ],
      ),
    );
  }

  Widget buildDock(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: dockItems.asMap().entries.map((entry) {
            int index = entry.key;
            IconData item = entry.value;
            return buildDockItem(item, index);
          }).toList(),
        ),
      ),
    );
  }

  Widget buildDockItem(IconData item, int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSpacing = screenWidth / (dockItems.length + 1); // Equal spacing
    double leftPosition = (index + 1) * iconSpacing;

    // Adjust the left position for the dragged icon
    if (draggingIndex == index && dragOffset != null) {
      leftPosition += dragOffset!.dx; // Move icon with drag
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      left: leftPosition - 30, // Center the icon
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            draggingIndex = index;
            dragOffset = Offset.zero; // Reset drag offset
          });
        },
        onPanUpdate: (details) {
          setState(() {
            dragOffset = details.localPosition; // Update drag offset
          });
        },
        onPanEnd: (details) {
          setState(() {
            // Determine the new index based on the drag position
            double screenWidth = MediaQuery.of(context).size.width;
            double iconSpacing = screenWidth / (dockItems.length + 1);
            int newIndex = ((leftPosition + dragOffset!.dx + 30) / iconSpacing).round() - 1; // Adjust for offset
            newIndex = newIndex.clamp(0, dockItems.length - 1); // Ensure the index is within bounds

            if (newIndex != index) {
              // Move the dragged item to the new position
              IconData draggedItem = dockItems.removeAt(index);
              dockItems.insert(newIndex, draggedItem);
              Color draggedColor = iconColors.removeAt(index);
              iconColors.insert(newIndex, draggedColor);
            }

            // Reset dragging state after the drop
            draggingIndex = null;
            dragOffset = null;
          });
        },
        child: buildIcon(item, index),
      ),
    );
  }

  Widget buildIcon(IconData item, int index) {
    bool isDragging = draggingIndex == index;

    return AnimatedScale(
      duration: Duration(milliseconds: 100),
      scale: isDragging ? 1.2 : 1.0, // Scale only the dragging icon
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Material(
          elevation: 4,
          shape: CircleBorder(),
          color: iconColors[index], // Use different color for each icon
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              item,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
