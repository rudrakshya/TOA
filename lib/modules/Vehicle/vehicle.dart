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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // print('called');
    _loadData();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadData();
    }
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    // print('called');
    if (isRefresh) {
      page = 0;
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
        if (!isRefresh) {
          page++;
        }
      });
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
    } else {
      // User cancelled the action
      // print("Action cancelled");
    }
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
      body: RefreshIndicator(
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
                        color: Colors.grey, // Choose your border color here
                        width: 0.5, // Choose the border width
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                    title: Text(
                      items[index].regNo,
                      style: const TextStyle(
                        fontSize: 15,
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
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Text(
                            "Created on ${items[index].registrationDateFormatted}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1, //
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
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
