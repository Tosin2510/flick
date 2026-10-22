import 'package:file_picker/file_picker.dart';
import 'package:flick/general_file_picking_service.dart';
import 'package:flick/media_picker_service.dart';
import 'package:flick/send_selection_button.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {

  int totalSizeOfBytes = 0;
  List <PlatformFile> selectedGeneralFiles = [];
  bool isLoading = false;
  String selectedIconButton = "Files";
  final Color activeButtonColor = const Color(0xFF258CF4);
  final Color inactiveButtonColor = const Color(0xFF1F1F1F);
  final Color inactiveTextColor = const Color(0XFFFFFFFF);

  final MediaPickerService mediaPickerService = MediaPickerService();

  List<AssetEntity> selectedMediaFiles = [];

Future<void> pickGeneralFiles(String fileCategory) async {
  if (isLoading) return;

  setState(() {
    isLoading = true;
  });

  try {
      final List<PlatformFile> files = await GeneralFilePickingService.pickFiles(fileCategory);

      if (!mounted) return;
      if (files.isNotEmpty) {
        final List<PlatformFile> newFilesPick = [];
        int noOfBytesAdded = 0;

        for (final file in files) {
          final bool isSelected = selectedGeneralFiles.any((selected) => selected.path == file.path);
          if (!isSelected) {
            newFilesPick.add(file);
            totalSizeOfBytes += noOfBytesAdded;
          }
        }
      }
    } catch(e) {
      debugPrint("Error picking general files: $e");
    } finally{
      setState(() {
            isLoading = false;
          });
    }  
}

Future<void> pickMediaFiles() async {
  if (isLoading) return;
  setState(() {
    isLoading = true;
  });

  try {
    final List<AssetEntity>? mediaFiles = await mediaPickerService.pickMediaFiles(context);
    if (!mounted) return;
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      final unselectedMediaFiles = mediaFiles.where((value) {
        return !selectedMediaFiles.any((val) {
          return val.id == value.id;
        });
      }).toList();

      final result = await Future.wait(unselectedMediaFiles.map((mediaFiles) async {
        final fileInfo = await mediaFiles.file;
        final fileSize = fileInfo != null ? await fileInfo.length() : 0;
        return MapEntry(mediaFiles, fileSize);
      }));

      if (!mounted) return;
      setState(() {
        for (final entry in result) {
          selectedMediaFiles.add(entry.key);
          totalSizeOfBytes += entry.value;
        }
      });
    }
  } catch (e) {
    debugPrint("Error picking media files: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  void dispose() {
    FilePicker.clearTemporaryFiles();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sizeOfContainer = size.width * 0.6;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding:  const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(height: size.height * 0.025),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: Icon(
                      Icons.arrow_back, 
                      color: Colors.white,
                      size: sizeOfContainer * 0.12,
                    ),
                  ),

                  SizedBox(width: sizeOfContainer * 0.04),

                  Text(
                    "Select Files",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sizeOfContainer * 0.15,
                      fontWeight: FontWeight.bold,
                    )
                  )
                ],),

                const SizedBox(height: 6),

                Padding(
                  padding: EdgeInsets.only(left: sizeOfContainer * 0.02),

                  child: Text(
                    "Choose what to send.",
                    style: TextStyle(
                    color: const Color(0xFFCCCCCC),
                    fontSize: sizeOfContainer * 0.085,
                    fontWeight: FontWeight.w400,
                  ),
                )
                ),

                SizedBox(height: size.height * 0.025),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,

                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      SendSelectionButton(
                        buttonTitle: "Files", 
                        buttonIcon: Icons.description_outlined, 
                        sizeOfContainer: sizeOfContainer, 
                        isSelected: selectedIconButton == "Files", 
                        activeButtonColor: activeButtonColor, 
                        inactiveButtonColor: inactiveButtonColor, 
                        inactiveTextColor: inactiveTextColor,
                        onPressed: () async {
                          setState(() {
                            selectedIconButton = "Files";
                          });

                          await pickGeneralFiles("Files");
                        }
                      ),

                      SizedBox(width: 3),

                      SendSelectionButton(
                        buttonTitle: "Apps", 
                        buttonIcon: Icons.grid_view_outlined, 
                        sizeOfContainer: sizeOfContainer, 
                        isSelected: selectedIconButton == "Apps", 
                        activeButtonColor: activeButtonColor, 
                        inactiveButtonColor: inactiveButtonColor, 
                        inactiveTextColor: inactiveTextColor,
                        onPressed: () {
                          setState(() {
                            selectedIconButton = "Apps";
                          });
                        }
                      ),
                      SizedBox(width: 3),

                      SendSelectionButton(
                        buttonTitle: "Music", 
                        buttonIcon: Icons.music_note_outlined, 
                        sizeOfContainer: sizeOfContainer, 
                        isSelected: selectedIconButton == "Music", 
                        activeButtonColor: activeButtonColor, 
                        inactiveButtonColor: inactiveButtonColor, 
                        inactiveTextColor: inactiveTextColor,
                        onPressed: () async {
                          setState(() {
                            selectedIconButton = "Music";
                          });

                          await pickGeneralFiles("Music");
                        }
                      ),
                      SizedBox(width: 3),

                      SendSelectionButton(
                        buttonTitle: "Media", 
                        buttonIcon: Icons.image, 
                        sizeOfContainer: sizeOfContainer, 
                        isSelected: selectedIconButton == "Media", 
                        activeButtonColor: activeButtonColor, 
                        inactiveButtonColor: inactiveButtonColor, 
                        inactiveTextColor: inactiveTextColor,
                        onPressed: () async {
                          setState(() {
                            selectedIconButton = "Media";
                          });

                          await pickMediaFiles();
                        }
                      )
                    ]
                  )
                ),
          ]
         )
        )
      )
    );
  }
}