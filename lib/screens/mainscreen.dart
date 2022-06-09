import 'package:flutter/material.dart';
import 'package:taxeeze_driver/tabs/earning_tab.dart';
import 'package:taxeeze_driver/tabs/home_tab.dart';
import 'package:taxeeze_driver/tabs/profile_tab.dart';
import 'package:taxeeze_driver/tabs/rating_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;
  onItemClicked(int index)
  {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeTab(),
          EarningsTab(),
          RatingsTab(),
          ProfileTab()
        ],
        controller: tabController,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [BottomNavigationBarItem(
            icon: Icon(Icons.home),
        label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Earnings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: "Ratings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"),

        ],
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.amber,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showSelectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
