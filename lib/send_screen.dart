import 'package:file_picker/file_picker.dart';
import 'package:flick/general_file_picking_service.dart';
import 'package:flick/media_picking_service.dart';
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
  
  final List<int> sizeOfMediaFilesInBytes = [];
  final List<int> sizeOfGeneralFilesInBytes = [];

Future<void> pickGeneralFiles(String fileCategory) async {
  if (isLoading) return;
  setState(() {
    isLoading = true;
   }
  );

  try {
    final List<PlatformFile> files = await GeneralFilePickingService.pickFiles(fileCategory);
    if (!mounted) return;

    final newFiles = files.where((val) => !selectedGeneralFiles.any((pth) => pth.path == val.path)).toList();

    final sizes = await Future.wait(
      newFiles.map((val) async => (await val.length()) ?? 0),
    );
    if (!mounted) return;

    setState(() {
      selectedGeneralFiles.addAll(newFiles);
      sizeOfGeneralFilesInBytes.addAll(sizes);
      totalSizeOfBytes += sizes.fold<int>(0, (vala, valb) => vala + valb);
    });
    
  } catch (e) {
    debugPrint("Error picking general files: $e");
  } finally {
    if (mounted) setState(() => isLoading = false);
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
        final fileInfo = await mediaFiles.originFile;
        final fileSize = fileInfo != null ? await fileInfo.length() : 0;
        return MapEntry(mediaFiles, fileSize);
      }));

      if (!mounted) return;
      setState(() {
        for (final entry in result) {
          selectedMediaFiles.add(entry.key);
          sizeOfMediaFilesInBytes.add(entry.value);
          totalSizeOfBytes += entry.value;
        }
      });
    }
  } catch (e) {
    debugPrint("Error picking media files: $e");
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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

                if (selectedGeneralFiles.isNotEmpty || selectedMediaFiles.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedGeneralFiles.length + selectedMediaFiles.length} Files • ${(totalSizeOfBytes / (1024 * 1024)).toStringAsFixed(2)} MB",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: sizeOfContainer * 0.06,
                        ),
                      ),

                      GestureDetector(
                        onTap: () => setState(() {
                        selectedGeneralFiles.clear();
                        sizeOfGeneralFilesInBytes.clear();
                        selectedMediaFiles.clear();
                        sizeOfMediaFilesInBytes.clear();
                        totalSizeOfBytes = 0;
                      }),

                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sizeOfContainer * 0.04,
                            vertical: sizeOfContainer * 0.015,
                          ),

                          decoration: BoxDecoration(
                            color: inactiveButtonColor,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            "Delete All",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeOfContainer * 0.045,
                              fontWeight: FontWeight.bold,
                            )
                          )
                        )
                      )
                    ]
                  )
                ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF258CF4)))
                      
                      : selectedGeneralFiles.isEmpty && selectedMediaFiles.isEmpty ? Center(
                        child: Text(
    
                          "No files selected",
                           style: TextStyle(
                              color: Colors.grey,
                              fontSize: sizeOfContainer * 0.07,
                            ),
                        )
                      )

                      : ListView.builder(
                        
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.07 + MediaQuery.of(context).padding.bottom + 32
                        ),
                        itemCount: selectedGeneralFiles.length + selectedMediaFiles.length,
                        itemBuilder: ((context, index) {
                          String fileDisplayName = '';
                          double fileSizeInBytes = 0;
                          IconData fileIcon = Icons.insert_drive_file_rounded;

                          if (index < selectedGeneralFiles.length) {
                            final file = selectedGeneralFiles[index];
                            fileDisplayName = file.name;
                            fileSizeInBytes = sizeOfGeneralFilesInBytes[index].toDouble();                            
                            fileIcon = Icons.insert_drive_file_rounded;

                          } else {
                            final mediaIndex = index - selectedGeneralFiles.length;
                            final mediaFile = selectedMediaFiles[mediaIndex];
                            fileDisplayName = mediaFile.title ?? 'Media File';
                            fileSizeInBytes = sizeOfMediaFilesInBytes[mediaIndex].toDouble();
                            fileIcon = mediaFile.type == AssetType.video ? Icons.video_collection_rounded: Icons.image_rounded;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(sizeOfContainer * 0.05),

                            decoration: BoxDecoration(
                              color: inactiveButtonColor,
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  fileIcon,
                                  color: activeButtonColor,
                                  size: sizeOfContainer * 0.12,
                                ),

                                SizedBox(width: sizeOfContainer * 0.05),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(

                                        fileDisplayName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: sizeOfContainer * 0.065,
                                          fontWeight: FontWeight.w500,
                                        ),

                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      if (fileSizeInBytes > 0)
                                      Text(
                                        fileSizeInBytes >= 1024 * 1024 ? "${(fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB"
                                          : "${(fileSizeInBytes / 1024).toStringAsFixed(2)} KB",

                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: sizeOfContainer * 0.045,
                                        )
                                      )
                                    ]
                                  )
                                ),

                                GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (index < selectedGeneralFiles.length) {
                                      
                                      totalSizeOfBytes -= sizeOfGeneralFilesInBytes[index];
                                      selectedGeneralFiles.removeAt(index);
                                      sizeOfGeneralFilesInBytes.removeAt(index);

                                    } else {
                                      final mediaIndex = index - selectedGeneralFiles.length;
                                      totalSizeOfBytes -= sizeOfMediaFilesInBytes[mediaIndex];
                                      selectedMediaFiles.removeAt(mediaIndex);
                                      sizeOfMediaFilesInBytes.removeAt(mediaIndex);
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white38,
                                  size: sizeOfContainer * 0.08,
                                ),
                              ),
                              ]
                            )
                          );
                        })
                      )
                    ),

                    if (selectedGeneralFiles.isNotEmpty || selectedMediaFiles.isNotEmpty)
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.04, 
                      right: MediaQuery.of(context).size.width * 0.04,
                      
                      bottom: MediaQuery.of(context).padding.bottom + (MediaQuery.of(context).size.height * 0.02),
                      child: GestureDetector(
                        onTap: () {
                          // To be implemented.
                        },

                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          constraints: const BoxConstraints(minHeight: 50, maxHeight: 70),
                          decoration: BoxDecoration(
                            color: const Color(0xFF258CF4),
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.035),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Center(
                            child: Text(
                              "Send ${selectedGeneralFiles.length + selectedMediaFiles.length} files",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.045, 
                              )
                            )
                          )
                        )
                      )                
                    )
                  ]
                )
              )
          ]
         )
        )
      )
    );
  }
}