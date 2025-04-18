// ignore_for_file: lines_longer_than_80_chars
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tsec_app/models/faculty_model/faculty_model.dart';
import 'package:tsec_app/models/student_model/student_model.dart';
import 'package:tsec_app/models/user_model/user_model.dart';
import 'package:tsec_app/new_ui/colors.dart';
import 'package:tsec_app/new_ui/screens/profile_screen/widgets/address_text_field.dart';
import 'package:tsec_app/new_ui/screens/profile_screen/widgets/change_password_dialog.dart';
import 'package:tsec_app/new_ui/screens/profile_screen/widgets/faculty_field.dart';
import 'package:tsec_app/new_ui/screens/profile_screen/widgets/phone_no_field.dart';
import 'package:tsec_app/new_ui/screens/profile_screen/widgets/profile_dropdown_field.dart';
import 'package:tsec_app/new_ui/screens/profile_screen/widgets/profile_text_field.dart';
import 'package:tsec_app/provider/auth_provider.dart';
import 'package:tsec_app/provider/firebase_provider.dart';
import 'package:tsec_app/screens/profile_screen/widgets/custom_text_with_divider.dart';
import 'package:tsec_app/screens/profile_screen/widgets/profile_screen_appbar.dart';
import 'package:tsec_app/screens/profile_screen/widgets/profile_text_field.dart';
import 'package:tsec_app/utils/form_validity.dart';
import 'package:tsec_app/utils/profile_details.dart';
import 'package:tsec_app/widgets/custom_scaffold.dart';
import 'package:tsec_app/utils/image_pick.dart';
import 'package:intl/intl.dart';

class ProfilePage extends ConsumerStatefulWidget {
  bool justLoggedIn;
  ProfilePage({super.key, required this.justLoggedIn});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String name = "";
  String email = "";
  String image = "";

  final TextEditingController areaOfSpecializationController =
      TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController phdGuideController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();

  String? batch = "";
  String branch = "";
  String? div = "";
  String gradyear = "";
  // String phoneNum = "";
  // String address = "";
  String? profilePicUrl;
  // String dob = "";
  String homeStation = "";
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  Uint8List? profilePic;
  // int _editCount = 0;
  final _formKey = GlobalKey<FormState>();

  String convertFirstLetterToUpperCase(String input) {
    if (input.isEmpty) {
      return input;
    }

    // Convert the entire string to lowercase first
    String lowerCaseInput = input.toLowerCase();

    // Get the first letter and convert it to uppercase
    String firstLetterUpperCase = lowerCaseInput[0].toUpperCase();

    // Combine the first letter with the rest of the lowercase string
    String convertedString = firstLetterUpperCase + lowerCaseInput.substring(1);

    return convertedString;
  }

  List<String> divisionList = [];
  List<String> batchList = [];

  // bool loadingImage = false;
  Future editProfileImage(UserModel userModel) async {
    // setState(() {
    //   loadingImage = true;
    // });
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() async {
        image = await ref
            .watch(authProvider.notifier)
            .updateProfilePic(img, userModel);
      });
      // setState(() {
      //   loadingImage = false;
      // });
    } else {
      // setState(() {
      //   loadingImage = false;
      // });
    }
    // setState(() {
    //   _image = image;
    // });
  }

  @override
  void initState() {
    super.initState();
    final UserModel? data = ref.read(userModelProvider);
    if (data != null && data.isStudent) {
      StudentModel studentData = data.studentModel!;
      name = studentData.name;
      email = studentData.email;
      image = studentData.image ?? "";
      gradyear = studentData.gradyear;
      branch = studentData.branch;
      // phoneNum = data.phoneNum ?? "";
      phoneNoController.text = studentData.phoneNum ?? "";
      addressController.text = studentData.address ?? "";
      // address = data.address ?? '';
      homeStation = studentData.homeStation ?? '';
      dobController.text = studentData.dateOfBirth ?? "";
      setState(() {
        divisionList =
            calcDivisionList(studentData.gradyear, studentData.branch);
        batchList = calcBatchList(studentData.div ?? divisionList[0], branch);
      });
      div = divisionList.contains(studentData.div)
          ? studentData.div
          : divisionList[0];
      batch = batchList.contains(studentData.batch)
          ? studentData.batch
          : batchList[0];
    } else if (data != null) {
      FacultyModel facultyData = data.facultyModel!;
      name = facultyData.name;
      email = facultyData.email;
      image = facultyData.image;
      areaOfSpecializationController.text = facultyData.areaOfSpecialization;
      designationController.text = facultyData.designation;
      experienceController.text = facultyData.experience;
      phdGuideController.text = facultyData.phdGuide;
      qualificationController.text = facultyData.qualification;
    }
  }

  void clearValues(UserModel data) {
    setState(() {
      if (data.isStudent) {
        StudentModel? student = data.studentModel;
        phoneNoController.text = student?.phoneNum ?? "";
        addressController.text = student?.address ?? "";
        dobController.text = student?.dateOfBirth ?? "";
        div = divisionList.contains(student?.div)
            ? student?.div
            : divisionList[0];
        batch =
            batchList.contains(student?.batch) ? student?.batch : batchList[0];
      } else {
        areaOfSpecializationController.text =
            data.facultyModel?.areaOfSpecialization ?? "";
        designationController.text = data.facultyModel?.designation ?? "";
        experienceController.text = data.facultyModel?.experience ?? "";
        phdGuideController.text = data.facultyModel?.phdGuide ?? "";
        qualificationController.text = data.facultyModel?.qualification ?? "";
      }
      // batch = data.batch;
      // calcBatchList(data.div);
      // calcDivisionList(data.gradyear);
      // div = divisionList.contains(data.div)
      //     ? data.div
      //     : "";
      // batch = batchList.contains(data.batch)
      //     ? data.batch
      //     : "";
      editMode = false;
    });
  }

  Future saveChanges(WidgetRef ref) async {
    final UserModel data = ref.watch(userModelProvider)!;
    if (data.isStudent) {
      // bool canUpdate = data!.updateCount != null ? data.updateCount! < 2 : true;
      bool canUpdate = true;

      if (canUpdate) {
        if (batch == null || div == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Choose an appropriate value for division and batch'),
            ),
          );
          return false;
        }

        StudentModel studentData = data.studentModel!;
        if (studentData.updateCount == null) {
          studentData.updateCount = 1;
        } else {
          int num = studentData.updateCount!;
          studentData.updateCount = num + 1;
        }
        // debugPrint("in here ${address} ${dobController.text} ${batch} ${name}");
        StudentModel student = StudentModel(
          div: div,
          batch: batch,
          branch: convertFirstLetterToUpperCase(branch),
          name: name,
          email: email,
          gradyear: gradyear,
          image: image,
          phoneNum: phoneNoController.text,
          updateCount: studentData.updateCount,
          address: addressController.text,
          homeStation: homeStation,
          dateOfBirth: dobController.text,
        );

        if (_formKey.currentState!.validate()) {
          await ref
              .watch(authProvider.notifier)
              .updateStudentDetails(student, ref, context);
          // setState(() {
          //   _isEditMode = false;
          // });
          setState(() {
            editMode = false;
          });
          return true;
        }
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You have already updated your profile as many times as possible'),
          ),
        );
      }
    } else {
      FacultyModel faculty = FacultyModel(
        areaOfSpecializationController.text,
        designationController.text,
        email,
        experienceController.text,
        image,
        name,
        phdGuideController.text,
        qualificationController.text,
      );
      if (_formKey.currentState?.validate() ?? false) {
        ref
            .watch(authProvider.notifier)
            .updateFacultyDetails(faculty, ref, context);
        // setState(() {
        //   _isEditMode = false;
        // });
        setState(() {
          editMode = false;
        });
        return true;
      }
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildProfileImage(WidgetRef ref, UserModel data) {
    profilePic = ref.watch(profilePicProvider);
    return GestureDetector(
      onTap: () {
        editProfileImage(data);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          profilePic != null
              ? CircleAvatar(
                  radius: 70,
                  backgroundImage: MemoryImage(profilePic!),
                  // backgroundImage: MemoryImage(_image!),
                )
              : const CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage("assets/images/pfpholder.jpg"),
                ),
          Positioned(
              bottom: 0,
              right: -40,
              child: RawMaterialButton(
                onPressed: () {
                  editProfileImage(data);
                },
                elevation: 2.0,
                // fillColor: Color(0xFFF5F6F9),
                fillColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.all(3.0),
                shape: CircleBorder(side: BorderSide(color: Colors.black)),
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
              )),
        ],
      ),
    );
  }

  bool editMode = false;
  @override
  Widget build(BuildContext context) {
    final UserModel data = ref.watch(userModelProvider)!;
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: commonbgblack,
      resizeToAvoidBottomInset: false,
      appBar: widget.justLoggedIn
          ? AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      // backgroundColor: Theme.of(context).colorScheme.background,
                      backgroundColor: commonbgblack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust the border radius as needed
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      if (data.isStudent) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                content: SizedBox(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.20,
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Are you in division ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(color: Colors.white),
                                            children: [
                                              TextSpan(
                                                  text: div,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const TextSpan(
                                                  text: ' and batch '),
                                              TextSpan(
                                                  text: batch,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const TextSpan(
                                                  text:
                                                      ' ? Please check your details once.'),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Cancel",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .tertiary))),
                                              ),
                                              Container(
                                                child: TextButton(
                                                    onPressed: () async {
                                                      bool changesSaved =
                                                          await saveChanges(
                                                              ref);
                                                      if (changesSaved)
                                                        GoRouter.of(context)
                                                            .go('/main');
                                                    },
                                                    child: Text("Proceed",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        bool changesSaved = await saveChanges(ref);
                        if (changesSaved) GoRouter.of(context).go('/main');
                      }
                    },
                  ),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 50,
            ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.background,
                    color: commonbgblack,
                    borderRadius: BorderRadius.only(
                        // topLeft: Radius.circular(25.0),
                        // topRight: Radius.circular(25.0),
                        ),
                  ),
                  height: MediaQuery.of(context).size.height * .74,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          // width: MediaQuery.of(context).size.width*0.6,
                                          child: Text(
                                            data.isStudent
                                                ? data.studentModel!.name
                                                : data.facultyModel!.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                        data.isStudent
                                            ? SizedBox(height: 15)
                                            : SizedBox(),
                                        data.isStudent
                                            ? Text(
                                                "${data.studentModel!.branch}, ${calcGradYear(data.studentModel!.gradyear)}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 300),
                                    crossFadeState: !editMode
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    firstChild: RawMaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          editMode = true;
                                        });
                                      },
                                      elevation: 2.0,
                                      // fillColor: Color(0xFFF5F6F9),
                                      fillColor:
                                          Theme.of(context).colorScheme.primary,
                                      constraints: BoxConstraints.tightFor(
                                        width: 50, // Set the width
                                        height: 50.0, // Set the height
                                      ),
                                      shape: CircleBorder(
                                        side: BorderSide(color: Colors.black),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                    ),
                                    secondChild: !editMode
                                        ? SizedBox()
                                        : Row(children: [
                                            RawMaterialButton(
                                              onPressed: () {
                                                clearValues(data);
                                              },
                                              elevation: 2.0,
                                              fillColor: Color(0xFFF5F6F9),
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                width: 40, // Set the width
                                                height: 40.0, // Set the height
                                              ),
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            RawMaterialButton(
                                              onPressed: () async {
                                                bool changesSaved =
                                                    await saveChanges(ref);
                                                // if (changesSaved)
                                                //   GoRouter.of(context).go('/main');
                                              },
                                              elevation: 2.0,
                                              // fillColor: Color(0xFFF5F6F9),
                                              // fillColor: Color.fromARGB(
                                              //     255, 32, 208, 138),
                                              fillColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                width: 40, // Set the width
                                                height: 40.0, // Set the height
                                              ),
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.black,
                                              ),
                                            )
                                          ]),
                                  )
                                ],
                              ),
                              SizedBox(height: 40),
                              Form(
                                key: _formKey,
                                child: data.isStudent
                                    ? Column(
                                        children: [
                                          ProfileField(
                                            labelName: "Email",
                                            enabled: false,
                                            value: email,
                                            onChanged: (val) {
                                              setState(() {
                                                email = val;
                                              });
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          ProfileField(
                                            labelName: "Number",
                                            enabled: editMode,
                                            controller: phoneNoController,
                                            // onChanged: (val) {
                                            //   setState(() {
                                            //     phoneNum = val;
                                            //   });
                                            // },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter a phone number';
                                              }
                                              if (!isValidPhoneNumber(value)) {
                                                return 'Please enter a valid phone number';
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          ProfileField(
                                            labelName: "DOB",
                                            enabled: editMode,
                                            readOnly: true,
                                            controller: dobController,
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now()
                                                    .subtract(Duration(
                                                        days: 20 * 365)),
                                                firstDate: DateTime(1960),
                                                lastDate: DateTime(2010),
                                              );
                                              if (pickedDate != null) {
                                                String formattedDate =
                                                    DateFormat('d MMMM y')
                                                        .format(pickedDate);

                                                // setState(() {
                                                dobController.text =
                                                    formattedDate;
                                              } else {
                                                // print(
                                                //     "Date is not selected");
                                              }
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter Date Of Birth';
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          ProfileField(
                                            labelName: "Address",
                                            enabled: editMode,
                                            // value: address,
                                            controller: addressController,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter an address';
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          ProfileDropdownField(
                                            editMode: editMode,
                                            text: "Division",
                                            val: div,
                                            validator: (value) {
                                              if (value == "") {
                                                return 'Please enter a division';
                                              }
                                              return null;
                                            },
                                            valList: divisionList,
                                            onChanged: editMode
                                                ? (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        div = newValue;
                                                        batchList =
                                                            calcBatchList(
                                                                newValue,
                                                                branch);
                                                        batch = null;
                                                      });
                                                    }
                                                  }
                                                : null,
                                          ),
                                          SizedBox(height: 20),
                                          ProfileDropdownField(
                                            editMode: editMode,
                                            text: "Batch",
                                            val: batch,
                                            validator: (value) {
                                              if (value == "") {
                                                return 'Please enter a batch';
                                              }
                                              return null;
                                            },
                                            valList: batchList,
                                            onChanged: editMode
                                                ? (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        batch = newValue;
                                                        // calcBatchList(newValue);
                                                        // batch = null;
                                                      });
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ],
                                      )
                                    : SingleChildScrollView(
                                        child: SizedBox(
                                          child: Column(
                                            children: [
                                              ProfileField(
                                                labelName: "Email",
                                                enabled: false,
                                                value: email,
                                                onChanged: (val) {
                                                  setState(() {
                                                    email = val;
                                                  });
                                                },
                                              ),
                                              SizedBox(height: 20),
                                              ProfileField(
                                                labelName: "Designation",
                                                enabled: editMode,
                                                controller:
                                                    designationController,
                                                // onChanged: (val) {
                                                //   setState(() {
                                                //     phoneNum = val;
                                                //   });
                                                // },
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter a designation';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 20),
                                              ProfileField(
                                                labelName: "Phd Guide",
                                                enabled: editMode,
                                                controller: phdGuideController,
                                                // onChanged: (val) {
                                                //   setState(() {
                                                //     phoneNum = val;
                                                //   });
                                                // },
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter the name of your phd guide';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 20),
                                              ProfileField(
                                                labelName: "Qualification",
                                                enabled: editMode,
                                                controller:
                                                    qualificationController,
                                                // onChanged: (val) {
                                                //   setState(() {
                                                //     phoneNum = val;
                                                //   });
                                                // },
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your qualifications';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 20),
                                              ProfileField(
                                                labelName: "Experience",
                                                enabled: editMode,
                                                // value: address,
                                                controller:
                                                    experienceController,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter a value';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 20),
                                              ProfileField(
                                                labelName:
                                                    "Area of specialization",
                                                enabled: editMode,
                                                // value: address ,
                                                controller:
                                                    areaOfSpecializationController,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter a value';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (contextOfDialog) {
                                          return ChangePasswordDialog(
                                            ctx1: context,
                                          );
                                        });
                                  },
                                  child: Text(
                                    "Change password",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -50,
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 4,
                        ),
                      ),
                      child: buildProfileImage(ref, data),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
