import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';

class AppPickingSheet extends StatefulWidget {

  final List<AppInfo> apps; 
  const AppPickingSheet({super.key, required this.apps});

  @override
  State<AppPickingSheet> createState() => _AppPickerSheetState();
}

class _AppPickerSheetState extends State<AppPickingSheet> {

  List<AppInfo> pickedApps = [];
  
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select apps",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    
                    Navigator.pop(context, pickedApps);
                  },
                  child: Text("Done (${pickedApps.length})",)
                )
              ]
            )
          ),
          Expanded(

            child: ListView.builder(
              itemCount: widget.apps.length,
              itemBuilder: (context, index) {
                AppInfo app = widget.apps[index];

                return ListTile(
                  leading: app.icon != null ? Image.memory(app.icon!, width: 40, height: 40)
                  : const Icon(Icons.android, color: Colors.white54),

                  title: Text(app.name, style: const TextStyle(color: Colors.white)),

                  trailing: Checkbox(
                    value: pickedApps.contains(app),
                    onChanged: (value) {
                      setState(() {
                        if (pickedApps.contains(app)) {
                          pickedApps.remove(app);
                        } else {
                          pickedApps.add(app);
                        }
                      });
                    }
                  ),

                  onTap: () {

                    setState(() {
                        if (pickedApps.contains(app)) {
                          pickedApps.remove(app);
                        } else {
                          pickedApps.add(app);
                        }
                      });
                  }
                );
              }
            )
          )
        ]
      )
    );
  }
}