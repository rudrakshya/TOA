import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../api/vehicle_api.dart';
import '../../models/vehicle_model.dart';

class Vehicle extends StatefulWidget {
  const Vehicle({super.key});

  @override
  State<Vehicle> createState() => _VehicleState();
}

class _VehicleState extends State<Vehicle> {
  late String appBarHeader = "Vehicle list";
  List<VehicleModel> items = [];
  bool isLoading = false;
  int page = 0;
  final TextEditingController _searchController = TextEditingController();
  late bool isSearchLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // print('called');
    _loadData();
  }

  void _onSearchChanged() async {
    setState(() {
      isSearchLoading = true;
    });
    if (_searchController.text.isEmpty) {
      _loadData();
    } else {
      List<VehicleModel> searchData =
          await VehicleApi().searchVechicle(_searchController.text);
      setState(() {
        items = searchData;
        isSearchLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_searchController.text.isEmpty) {
        _loadData();
      }
    }
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    // print('called');
    if (isRefresh) {
      _searchController.text = "";
      setState(() {
        page = 0;
      });
      items.clear(); // Clear the list for refresh
    }

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
    }

    List<VehicleModel> newData = await VehicleApi().getVechicle(page);

    if (mounted) {
      setState(() {
        items.addAll(newData);
        isLoading = false;
        // if (!isRefresh) {
        page++;
        // }
      });
    }
  }

  void checkEmpty(String value) {
    if (value.isEmpty) {
      _loadData(isRefresh: true);
    }
  }

  void edit(
    BuildContext context,
    String regNo,
    String ownerName,
    String mobileNumber,
    int id,
  ) {
    Navigator.pushNamed(
      context,
      '/create_vehicle',
      arguments: {
        'regNo': regNo,
        'ownerName': ownerName,
        'mobileNumber': mobileNumber,
        'id': id,
      },
    );
  }

  void delete(BuildContext context, id) {
    callDelete(id);
  }

  Future<bool> showConfirmationDialog(
      BuildContext context, String title, String message) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Returning false if the dialog is dismissed by other means
  }

  void callDelete(id) async {
    bool confirmed = await showConfirmationDialog(
      context,
      "Delete confirmation",
      "Are you sure you want to delete?",
    );
    if (confirmed) {
      // User confirmed the action
      bool deleteResult = await VehicleApi().delete(id);
      if (deleteResult) {
        setState(() {
          items.removeWhere(
              (item) => item.id == id); // Remove the item from the list
        });
      } else {
        // Handle the error case
        // You might want to show a Snackbar or a dialog indicating failure
      }
    }
  }

  void navigateQR(regNo) {
    Navigator.pushNamed(
      context,
      '/qr_generate',
      arguments: {
        'regNo': regNo,
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          appBarHeader,
          minFontSize: 12,
          maxFontSize: 18,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Reg. no, owner name, mobile',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                      border: OutlineInputBorder(
                        // Adding the outline border
                        borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.0), // Customizing border color and width
                      ),
                      enabledBorder: OutlineInputBorder(
                        // Border style when TextField is enabled but not focused
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border style when TextField is focused
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    onChanged: (value) {
                      checkEmpty(value);
                    },
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton.icon(
                  onPressed: () {
                    isSearchLoading
                        ? null
                        : _onSearchChanged(); // Trigger search
                  },
                  icon: isSearchLoading
                      ? Container(
                          width:
                              24, // Match the typical Icon size for alignment
                          height: 24,
                          padding: const EdgeInsets.all(
                              2), // Padding to reduce icon size visually
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white, // Spinner color
                          ),
                        )
                      : const Icon(Icons.search),
                  label: const Text(''), // Empty text as the label
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Icon and text color
                    elevation: 2, // Shadow depth
                    shape: RoundedRectangleBorder(
                      // Rounded corners
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ), // Padding inside the button
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadData(isRefresh: true),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return Slidable(
                      // The end action pane is the one at the right or the bottom side.
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            // An action can be bigger than the others.
                            // flex: 2,
                            onPressed: (BuildContext context) => edit(
                              context,
                              items[index].regNo,
                              items[index].ownerName,
                              items[index].mobileNumber,
                              int.parse(items[index].id.toString()),
                            ),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (BuildContext context) =>
                                delete(context, items[index].id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  Colors.grey, // Choose your border color here
                              width: 0.5, // Choose the border width
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          leading: Column(
                            children: [
                              Text((index + 1).toString()),
                              Image.asset(
                                'assets/icons/truck_blue.png',
                                scale: 7.0,
                              ),
                            ],
                          ),
                          title: Text(
                            items[index].regNo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                items[index].ownerName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, //
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                items[index].mobileNumber,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, //
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              Text(items[index].registrationDateFormatted),
                          onTap: () => navigateQR(items[index].regNo),
                        ),
                      ),
                    );
                  } else {
                    if (isLoading) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.90,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (items.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.4),
                        child: const Text("No vehicle added till date"),
                      );
                    } else {
                      return null;
                    }
                  }
                },
                controller: _scrollController,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to be taken when FAB is pressed
          // print('Floating Action Button Pressed');
          Navigator.pushNamed(
            context,
            '/create_vehicle',
            arguments: {
              'regNo': '',
              'ownerName': '',
              'mobileNumber': '',
              'id': 0,
            },
          );
        }, // Icon inside FAB
        backgroundColor: Colors.blue, // Background color of the FAB
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
