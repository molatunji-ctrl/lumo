import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import 'account_role_service.dart';

class ProductService {
  ProductService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    ImagePicker? imagePicker,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _imagePicker = imagePicker ?? ImagePicker();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  Future<List<Product>> getPublishedProducts() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _products
        .where('isPublished', isEqualTo: true)
        .get();
    return snapshot.docs.map(Product.fromFirestore).toList(growable: false);
  }

  Stream<List<Product>> watchPublishedProducts() {
    return _products
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Product.fromFirestore).toList(growable: false),
        );
  }

  Stream<List<Product>> watchSellerProducts(String sellerUid) {
    return _products
        .where('sellerUid', isEqualTo: sellerUid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Product.fromFirestore).toList(growable: false),
        );
  }

  Stream<List<Product>> watchFavourites(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Product.fromJson(<String, dynamic>{
                  ...doc.data(),
                  'id': doc.id,
                }),
              )
              .toList(growable: false),
        );
  }

  Stream<bool> watchIsFavourite(String uid, String productId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> setFavourite(Product product, bool isFavourite) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before saving a favourite.');
    }

    final DocumentReference<Map<String, dynamic>> favourite = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product.id);
    if (isFavourite) {
      final DocumentSnapshot<Map<String, dynamic>> currentProduct =
          await _products.doc(product.id).get();
      final Map<String, dynamic>? currentData = currentProduct.data();
      if (currentData == null || currentData['isPublished'] != true) {
        throw StateError('This product is no longer available.');
      }
      await favourite.set(<String, dynamic>{
        ...currentData,
        'id': product.id,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await favourite.delete();
    }
  }

  Future<String?> pickAndUploadImage() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before uploading a product image.');
    }
    await const AccountRoleService().requireSeller(user);

    final XFile? selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (selected == null) return null;

    final String imageId = DateTime.now().microsecondsSinceEpoch.toString();
    final Reference imageRef = _storage
        .ref()
        .child('products')
        .child(user.uid)
        .child('$imageId.jpg');
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: <String, String>{'ownerUid': user.uid},
    );
    await imageRef.putData(await selected.readAsBytes(), metadata);
    return imageRef.getDownloadURL();
  }

  Future<void> saveProduct(Product product, {String? existingId}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before publishing a product.');
    }
    await const AccountRoleService().requireSeller(user);
    final bool isNewProduct = existingId == null;
    final DocumentReference<Map<String, dynamic>> document = isNewProduct
        ? _products.doc()
        : _products.doc(existingId);
    if (!isNewProduct) {
      final DocumentSnapshot<Map<String, dynamic>> existing = await document
          .get();
      if (!existing.exists) {
        throw StateError('This product no longer exists.');
      }
      if (existing.data()?['sellerUid'] != user.uid) {
        throw StateError('You can only edit products you created.');
      }
    }

    final Map<String, dynamic> data = product.toJson()
      ..remove('id')
      ..['sellerUid'] = user.uid
      ..['isSellerListed'] = true
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (isNewProduct) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await document.set(data, SetOptions(merge: true));
  }
}
