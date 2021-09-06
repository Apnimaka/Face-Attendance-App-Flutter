import 'package:camera/camera.dart';
import 'package:face_attendance/constants/app_colors.dart';
import 'package:face_attendance/constants/app_defaults.dart';
import 'package:face_attendance/constants/app_sizes.dart';
import 'package:face_attendance/views/pages/05_verifier/static_verifier_password.dart';
import 'package:face_attendance/views/themes/text.dart';
import 'package:face_attendance/views/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifierScreen extends StatefulWidget {
  const VerifierScreen({Key? key}) : super(key: key);

  @override
  _VerifierScreenState createState() => _VerifierScreenState();
}

class _VerifierScreenState extends State<VerifierScreen> {
  late List<CameraDescription> cameras;
  RxBool _activatingCamera = true.obs;

  late CameraController controller;

  _initializeCameraDescription() async {
    cameras = await availableCameras();
    controller = CameraController(
      // If there is secondary [Front_Camera] then we will use that one
      cameras[cameras.length > 0 ? 1 : 0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    _activatingCamera.trigger(false);
  }

  // init camera
  Future<void> _initCamera(CameraDescription description) async {
    controller =
        CameraController(description, ResolutionPreset.max, enableAudio: true);

    try {
      await controller.initialize();
      // to notify the widgets that camera has been initialized and now camera preview can be done
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  // Toggle The Camera Lense
  void _toggleCameraLens() {
    // get current lens direction (front / rear)
    final lensDirection = controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }
    _initCamera(newDescription);
  }

  @override
  void initState() {
    super.initState();
    _initializeCameraDescription();
  }

  @override
  void dispose() {
    _activatingCamera.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Verifier',
                style: AppText.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.PRIMARY_COLOR,
                ),
              ),
            ),
            Obx(
              () => _activatingCamera.isTrue
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Stack(
                        children: [
                          CameraPreview(controller),
                          /* <---- Verifier Button ----> */
                          Positioned(
                            bottom: 0,
                            child: _UseAsAVerifierButton(),
                          ),
                          /* <---- Camear Switch Button ----> */
                          Positioned(
                            bottom: Get.height * 0.12,
                            right: 10,
                            child: FloatingActionButton(
                              onPressed: _toggleCameraLens,
                              child: Icon(Icons.switch_camera_rounded),
                              backgroundColor: AppColors.PRIMARY_COLOR,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UseAsAVerifierButton extends StatelessWidget {
  const _UseAsAVerifierButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          StaticVerifierPasswordSet(),
          isScrollControlled: true,
        );
      },
      child: Container(
        width: Get.width,
        padding: EdgeInsets.all(AppSizes.DEFAULT_PADDING),
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.PRIMARY_COLOR,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.DEFAULT_RADIUS),
            topRight: Radius.circular(AppSizes.DEFAULT_RADIUS),
          ),
          boxShadow: AppDefaults.defaultBoxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Use as a static verifier',
              style: AppText.b2.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Switch(
              value: false,
              onChanged: (val) {
                Get.bottomSheet(
                  StaticVerifierPasswordSet(),
                  isScrollControlled: true,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
