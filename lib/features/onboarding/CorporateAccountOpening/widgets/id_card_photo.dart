import 'package:flutter/material.dart';
import 'dart:io';
import 'package:coopengageplus/widget/ButtonUploadTakePhoto .dart';

class PersonalPhotoSection extends StatelessWidget {
  final String profilePath;
  final VoidCallback onUploadPressed;
  final VoidCallback onCapturePressed;
  final void Function(String path) showFullScreen;

  const PersonalPhotoSection({
    Key? key,
    required this.profilePath,
    required this.onUploadPressed,
    required this.onCapturePressed,
    required this.showFullScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: profilePath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/photo1.png',
                              height: 170.0,
                              width: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : GestureDetector(
                        onTap: () => showFullScreen(profilePath),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(profilePath),
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 40.0),
              ButtonUploadTakePhoto(
                onUploadPressed: onUploadPressed,
                onCapturePressed: onCapturePressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class IdCardPhoto extends StatelessWidget {
  final int index;
  final String? selectedDocumentType;
  final String residentPath;
  final String residentCardBackPath;
  final String profilePath;
  final VoidCallback onUploadFront;
  final VoidCallback onCaptureFront;
  final VoidCallback onUploadBack;
  final VoidCallback onCaptureBack;
  final Future<void> Function() onUploadProfile;
  final Future<void> Function() onCaptureProfile;
  final void Function(String path) showFullScreen;

  const IdCardPhoto({
    Key? key,
    required this.index,
    required this.selectedDocumentType,
    required this.residentPath,
    required this.residentCardBackPath,
    required this.profilePath,
    required this.onUploadFront,
    required this.onCaptureFront,
    required this.onUploadBack,
    required this.onCaptureBack,
    required this.onUploadProfile,
    required this.onCaptureProfile,
    required this.showFullScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            'Front Photo of   ${selectedDocumentType ?? "ID"}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: residentPath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/id_front.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () => showFullScreen(residentPath),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(residentPath),
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: onUploadFront,
                onCapturePressed: onCaptureFront,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            'Back Photo of ${selectedDocumentType ?? "ID"}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: residentCardBackPath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/backpage.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(
                          File(residentCardBackPath),
                          height: 180.0,
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.fill,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: onUploadBack,
                onCapturePressed: onCaptureBack,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        // --- Personal Photo Section ---
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            'Personal Photo',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: profilePath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/photo1.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () => showFullScreen(profilePath),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(profilePath),
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: onUploadProfile,
                onCapturePressed: onCaptureProfile,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
} 