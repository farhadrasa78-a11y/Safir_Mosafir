import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ایمپورت‌های پروژه سفیر مسافر
import 'package:safir_passengers/authentication/register_screen.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/authentication/otp_screen.dart';
import 'package:safir_passengers/models/user_model.dart';
import 'package:safir_passengers/global/global_var.dart';

class AuthenticationProvider extends ChangeNotifier {
  CommonMethods commonMethods = CommonMethods();
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isGoogleSignedIn = false;
  bool _isGoogleSignInLoading = false;
  String? _uid;
  String? _phoneNumber;

  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  String? get uid => _uid;
  String get phoneNumber => _phoneNumber ?? "";
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isGoogleSignedIn => _isGoogleSignedIn;
  bool get isGoogleSigInLoading => _isGoogleSignInLoading;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance; 
  final GoogleSignIn googleSignIn = GoogleSignIn(); 

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startGoogleLoading() {
    _isGoogleSignInLoading = true;
    notifyListeners();
  }

  void stopGoogleLoading() {
    _isGoogleSignInLoading = false;
    notifyListeners();
  }

  // ورود مستقیم کاربران سفیر با شماره موبایل
  void signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    startLoading(); 

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);
          stopLoading(); 
        },
        verificationFailed: (FirebaseAuthException e) {
          stopLoading(); 
          commonMethods.displaySnackBar(e.message ?? e.toString(), context);
        },
        codeSent: (String verificationId, int? resendToken) {
          stopLoading(); 
          _phoneNumber = phoneNumber;
          notifyListeners();
          
          Future.delayed(const Duration(seconds: 1)).whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                ),
              ),
            );
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          stopLoading(); 
        },
      );
    } catch (e) {
      stopLoading(); 
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("phone").equalTo(phoneNumber).once();

    return snapshot.snapshot.exists;
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      User? user =
          (await firebaseAuth.signInWithCredential(phoneAuthCredential)).user;

      if (user != null) {
        _uid = user.uid;
        notifyListeners();
        onSuccess();
      }

      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      commonMethods.displaySnackBar(e.message ?? e.toString(), context);
    }
  }

  // ثبت‌نام و ذخیره اطلاعات اولیه مسافر در ریل‌تایم دیتابیس فایربیس
  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required VoidCallback onSuccess,
  }) async {
    startLoading();
    notifyListeners();

    try {
      DatabaseReference usersRef =
          firebaseDatabase.ref().child("users").child(userModel.id);
      await usersRef.set(userModel.toMap()).then((value) {
        stopLoading();
        notifyListeners();

        onSuccess();
      });
    } on FirebaseException catch (e) {
      stopLoading();
      notifyListeners();
      commonMethods.displaySnackBar(e.message ?? e.toString(), context);
    }
  }

  Future<bool> checkUserExistByEmail(String email) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("email").equalTo(email).once();

    return snapshot.snapshot.exists;
  }

  Future<bool> checkUserExistByPhone(String phoneNumber) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("phone")
        .equalTo(phoneNumber.toString().trim())
        .once();

    return snapshot.snapshot.exists;
  }

  Future<bool> checkUserExistById() async {
    if (FirebaseAuth.instance.currentUser == null) return false;
    
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("id") 
        .equalTo(FirebaseAuth.instance.currentUser!.uid)
        .once();

    return snapshot.snapshot.exists;
  }

  Future<void> getUserDataFromFirebaseDatabase() async {
    try {
      if (firebaseAuth.currentUser == null) return;

      DatabaseReference usersRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        _userModel = UserModel(
          id: userData['id'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          blockStatus: userData['blockStatus'] ?? 'no',
        );

        _uid = _userModel!.id;
        notifyListeners(); 
      } else {
        debugPrint("User data not found.");
      }
    } catch (e) {
      debugPrint("An error occurred while fetching user data: $e");
    }
  }

  // بررسی وضعیت مسدود بودن کاربر سفیر
  Future<bool> checkIfUserIsBlocked() async {
    try {
      if (firebaseAuth.currentUser == null) return false;

      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map driverData = snapshot.value as Map;
        String blockStatus = driverData["blockStatus"] ?? 'no';

        if (blockStatus == 'yes') {
          await firebaseAuth.signOut();
          await googleSignIn.signOut();

          _uid = null;
          _isGoogleSignedIn = false;
          notifyListeners();
          return true;
        } else {
          return false;
        }
      } else {
        return false; 
      }
    } catch (e) {
      debugPrint("An error occurred while checking block status: $e");
      return false; 
    }
  }

  Future<bool> checkUserFieldsFilled() async {
    try {
      if (firebaseAuth.currentUser == null) return false;

      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map userData = snapshot.value as Map;

        String id = userData["id"] ?? '';
        String name = userData["name"] ?? '';
        String email = userData["email"] ?? '';
        String phone = userData["phone"] ?? '';

        if (id.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty) {
          return false; 
        } else {
          return true; 
        }
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("An error occurred while checking user fields: $e");
      return false;
    }
  }

  // متد ورود اختصاصی با گوگل
  Future<void> signInWithGoogle(
      BuildContext context, VoidCallback onSuccess) async {
    startGoogleLoading();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        stopGoogleLoading();
        return; 
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _uid = user.uid;
        _isGoogleSignedIn = true;
        notifyListeners();
      }
      onSuccess();

      stopGoogleLoading();
    } on FirebaseAuthException catch (e) {
      stopGoogleLoading();
      commonMethods.displaySnackBar(
          e.message ?? getTranslation(context, "google_sign_in_error"), context);
    }
  }

  // خروج از حساب کاربری سفیر
  Future<void> signOut(BuildContext context) async {
    startLoading();
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();

      _uid = null;
      _isGoogleSignedIn = false;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const RegisterScreen()), 
        (route) => false,
      );

      stopLoading();
    } on FirebaseAuthException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(
          e.message ?? getTranslation(context, "sign_out_error"), context);
    }
  }
}
