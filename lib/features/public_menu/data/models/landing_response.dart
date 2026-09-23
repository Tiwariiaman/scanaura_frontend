import 'package:flutter/foundation.dart';

class LandingResponse {
  const LandingResponse({
    required this.businessId,
    required this.businessName,
    required this.businessType,

    // Business
    this.city,
    this.logoUrl,
    this.brandColor,

    // Menu / payment
    this.menuAvailable = false,
    this.paymentEnabled = false,
    this.loyaltyEnabled = false,

    // Google Review
    this.googleReviewUrl,
    this.googleReviewEnabled = false,

    // Social
    this.instagramUrl,
    this.instagramEnabled = false,
    this.facebookUrl,
    this.facebookEnabled = false,
    this.youtubeUrl,
    this.youtubeEnabled = false,

    // Contact
    this.phone,
    this.callEnabled = false,
    this.whatsapp,
    this.whatsappEnabled = false,

    // Address
    this.address,
    this.state,
    this.country,
    this.pincode,

    // Google Maps
    this.googleMapsUrl,
    this.mapsEnabled = false,

    // Gallery
    this.galleryEnabled = false,
    this.galleryImages = const [],

    // Subscription
    this.subscriptionActive = true,
  });

  // ============================================================
  // BUSINESS
  // ============================================================

  final String businessId;
  final String businessName;
  final String businessType;
  final String? city;
  final String? logoUrl;

  /// Business owner's selected brand colour.
  ///
  /// Example:
  /// "#16A34A"
  /// "#7C3AED"
  /// "#F97316"
  final String? brandColor;

  // ============================================================
  // FEATURES
  // ============================================================

  final bool menuAvailable;
  final bool paymentEnabled;
  final bool loyaltyEnabled;

  // ============================================================
  // GOOGLE REVIEW
  // ============================================================

  final String? googleReviewUrl;
  final bool googleReviewEnabled;

  // ============================================================
  // SOCIAL
  // ============================================================

  final String? instagramUrl;
  final bool instagramEnabled;

  final String? facebookUrl;
  final bool facebookEnabled;

  final String? youtubeUrl;
  final bool youtubeEnabled;

  // ============================================================
  // CONTACT
  // ============================================================

  final String? phone;
  final bool callEnabled;

  final String? whatsapp;
  final bool whatsappEnabled;

  // ============================================================
  // ADDRESS
  // ============================================================

  final String? address;
  final String? state;
  final String? country;
  final String? pincode;

  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  final String? googleMapsUrl;
  final bool mapsEnabled;

  // ============================================================
  // GALLERY
  // ============================================================

  final bool galleryEnabled;

  final List<PublicGalleryImage> galleryImages;

  // ============================================================
  // SUBSCRIPTION
  // ============================================================

  /// When false, the public business page should show
  /// the maintenance screen instead of business content.
  final bool subscriptionActive;

  // ============================================================
  // FROM JSON
  // ============================================================

  factory LandingResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LandingResponse(
      // ----------------------------------------------------------
      // BUSINESS
      // ----------------------------------------------------------

      businessId:
      json['businessId']?.toString() ?? '',

      businessName:
      json['businessName']?.toString() ?? '',

      businessType:
      json['businessType']?.toString() ?? 'OTHER',

      city:
      _nullableString(
        json['city'],
      ),

      logoUrl:
      _nullableString(
        json['logoUrl'],
      ),

      brandColor:
      _nullableString(
        json['brandColor'],
      ),

      // ----------------------------------------------------------
      // FEATURES
      // ----------------------------------------------------------

      menuAvailable:
      json['menuAvailable'] == true,

      paymentEnabled:
      json['paymentEnabled'] == true,

      loyaltyEnabled:
      json['loyaltyEnabled'] == true,

      // ----------------------------------------------------------
      // GOOGLE REVIEW
      // ----------------------------------------------------------

      googleReviewUrl:
      _nullableString(
        json['googleReviewUrl'],
      ),

      googleReviewEnabled:
      json['googleReviewEnabled'] == true,

      // ----------------------------------------------------------
      // SOCIAL
      // ----------------------------------------------------------

      instagramUrl:
      _nullableString(
        json['instagramUrl'],
      ),

      instagramEnabled:
      json['instagramEnabled'] == true,

      facebookUrl:
      _nullableString(
        json['facebookUrl'],
      ),

      facebookEnabled:
      json['facebookEnabled'] == true,

      youtubeUrl:
      _nullableString(
        json['youtubeUrl'],
      ),

      youtubeEnabled:
      json['youtubeEnabled'] == true,

      // ----------------------------------------------------------
      // CONTACT
      // ----------------------------------------------------------

      phone:
      _nullableString(
        json['phone'],
      ),

      callEnabled:
      json['callEnabled'] == true,

      whatsapp:
      _nullableString(
        json['whatsapp'],
      ),

      whatsappEnabled:
      json['whatsappEnabled'] == true,

      // ----------------------------------------------------------
      // ADDRESS
      // ----------------------------------------------------------

      address:
      _nullableString(
        json['address'],
      ),

      state:
      _nullableString(
        json['state'],
      ),

      country:
      _nullableString(
        json['country'],
      ),

      pincode:
      _nullableString(
        json['pincode'],
      ),

      // ----------------------------------------------------------
      // GOOGLE MAPS
      // ----------------------------------------------------------

      googleMapsUrl:
      _nullableString(
        json['googleMapsUrl'],
      ),

      mapsEnabled:
      json['mapsEnabled'] == true,

      // ----------------------------------------------------------
      // GALLERY
      // ----------------------------------------------------------

      galleryEnabled:
      json['galleryEnabled'] == true,

      galleryImages:
      _parseGalleryImages(
        json['galleryImages'],
      ),

      // ----------------------------------------------------------
      // SUBSCRIPTION
      // ----------------------------------------------------------

      subscriptionActive:
      json['subscriptionActive'] != false,
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      // ----------------------------------------------------------
      // BUSINESS
      // ----------------------------------------------------------

      'businessId': businessId,
      'businessName': businessName,
      'businessType': businessType,
      'city': city,
      'logoUrl': logoUrl,
      'brandColor': brandColor,

      // ----------------------------------------------------------
      // FEATURES
      // ----------------------------------------------------------

      'menuAvailable': menuAvailable,
      'paymentEnabled': paymentEnabled,
      'loyaltyEnabled': loyaltyEnabled,

      // ----------------------------------------------------------
      // GOOGLE REVIEW
      // ----------------------------------------------------------

      'googleReviewUrl': googleReviewUrl,
      'googleReviewEnabled':
      googleReviewEnabled,

      // ----------------------------------------------------------
      // SOCIAL
      // ----------------------------------------------------------

      'instagramUrl': instagramUrl,
      'instagramEnabled':
      instagramEnabled,

      'facebookUrl': facebookUrl,
      'facebookEnabled':
      facebookEnabled,

      'youtubeUrl': youtubeUrl,
      'youtubeEnabled':
      youtubeEnabled,

      // ----------------------------------------------------------
      // CONTACT
      // ----------------------------------------------------------

      'phone': phone,
      'callEnabled': callEnabled,

      'whatsapp': whatsapp,
      'whatsappEnabled':
      whatsappEnabled,

      // ----------------------------------------------------------
      // ADDRESS
      // ----------------------------------------------------------

      'address': address,
      'state': state,
      'country': country,
      'pincode': pincode,

      // ----------------------------------------------------------
      // GOOGLE MAPS
      // ----------------------------------------------------------

      'googleMapsUrl':
      googleMapsUrl,

      'mapsEnabled':
      mapsEnabled,

      // ----------------------------------------------------------
      // GALLERY
      // ----------------------------------------------------------

      'galleryEnabled':
      galleryEnabled,

      'galleryImages':
      galleryImages
          .map(
            (image) => image.toJson(),
      )
          .toList(),

      // ----------------------------------------------------------
      // SUBSCRIPTION
      // ----------------------------------------------------------

      'subscriptionActive':
      subscriptionActive,
    };
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String? _nullableString(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final stringValue =
    value.toString().trim();

    if (stringValue.isEmpty) {
      return null;
    }

    return stringValue;
  }

  static List<PublicGalleryImage>
  _parseGalleryImages(
      dynamic value,
      ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(
      PublicGalleryImage.fromJson,
    )
        .toList();
  }

  @override
  String toString() {
    return 'LandingResponse('
        'businessId: $businessId, '
        'businessName: $businessName, '
        'businessType: $businessType, '
        'brandColor: $brandColor, '
        'subscriptionActive: '
        '$subscriptionActive, '
        'galleryImages: '
        '${galleryImages.length}'
        ')';
  }
}

// =============================================================================
// PUBLIC GALLERY IMAGE
// =============================================================================

@immutable
class PublicGalleryImage {
  const PublicGalleryImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  final String id;
  final String imageUrl;
  final int displayOrder;

  factory PublicGalleryImage.fromJson(
      Map<String, dynamic> json,
      ) {
    return PublicGalleryImage(
      id:
      json['id']?.toString() ?? '',

      imageUrl:
      json['imageUrl']?.toString() ?? '',

      displayOrder:
      _parseDisplayOrder(
        json['displayOrder'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
    };
  }

  static int _parseDisplayOrder(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  @override
  String toString() {
    return 'PublicGalleryImage('
        'id: $id, '
        'imageUrl: $imageUrl, '
        'displayOrder: '
        '$displayOrder'
        ')';
  }
}