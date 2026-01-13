import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';

class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({super.key});

  static const List<Map<String, dynamic>> helplines = [
    {
      'nameEn': 'Kaan Pete Roi',
      'nameBn': 'কান পেতে রই',
      'phones': ['01779554391', '01779554392'],
      'descriptionEn':
          'Emotional support and suicide prevention helpline, staffed by trained volunteers.',
      'descriptionBn':
          'প্রশিক্ষিত স্বেচ্ছাসেবকদের দ্বারা পরিচালিত আবেগিক সহায়তা এবং আত্মহত্যা প্রতিরোধ হটলাইন।',
      'icon': PhosphorIcons.heart,
      'color': Colors.red,
    },
    {
      'nameEn': 'Moner Bondhu',
      'nameBn': 'মনের বন্ধু',
      'phones': ['01776632344'],
      'descriptionEn':
          'Mental health and well-being service by skilled counselors and experts.',
      'descriptionBn':
          'দক্ষ পরামর্শদাতা এবং বিশেষজ্ঞদের দ্বারা মানসিক স্বাস্থ্য এবং সুস্থতার সেবা।',
      'icon': PhosphorIcons.brain,
      'color': Colors.purple,
    },
    {
      'nameEn': 'SAJIDA Foundation Hotline',
      'nameBn': 'সাজিদা ফাউন্ডেশন হটলাইন',
      'phones': ['09678771511'],
      'descriptionEn':
          'COVID and general health consultation, mental/emotional support, care for elderly/chronically ill.',
      'descriptionBn':
          'কোভিড এবং সাধারণ স্বাস্থ্য পরামর্শ, মানসিক/আবেগিক সহায়তা, বয়স্ক/দীর্ঘমেয়াদী অসুস্থদের যত্ন।',
      'icon': PhosphorIcons.firstAid,
      'color': Colors.green,
    },
    {
      'nameEn': 'Dosh Unisher Mor Helpline',
      'nameBn': 'দশ উনিশের মোড় হেল্পলাইন',
      'phones': ['09612600600'],
      'descriptionEn':
          'Helpline for sexual health queries and adolescent mental support.',
      'descriptionBn':
          'যৌন স্বাস্থ্য বিষয়ক প্রশ্ন এবং কিশোর-কিশোরীদের মানসিক সহায়তার হেল্পলাইন।',
      'icon': PhosphorIcons.users,
      'color': Colors.orange,
    },
    {
      'nameEn': 'Shasthaya Batayan',
      'nameBn': 'স্বাস্থ্য বাতায়ন',
      'phones': ['16263'],
      'descriptionEn': '24-hour doctor consultation nationwide.',
      'descriptionBn': 'সারাদেশে ২ৄ ঘন্টা ডাক্তারের পরামর্শ।',
      'icon': PhosphorIcons.stethoscope,
      'color': Colors.blue,
    },
    {
      'nameEn': 'Violence Prevention (Govt)',
      'nameBn': 'সহিংসতা প্রতিরোধ (সরকারি)',
      'phones': ['109'],
      'descriptionEn':
          'Helpline for violence against women / prevention of child marriage.',
      'descriptionBn': 'নারীর প্রতি সহিংসতা / বাল্যবিবাহ প্রতিরোধের হেল্পলাইন।',
      'icon': PhosphorIcons.shield,
      'color': Colors.indigo,
    },
    {
      'nameEn': 'National Helpline for Women',
      'nameBn': 'নারীদের জন্য জাতীয় হেল্পলাইন',
      'phones': ['10921'],
      'descriptionEn':
          'Support for victims of violence, connects with doctors, counselors, police, etc.',
      'descriptionBn':
          'সহিংসতার শিকারদের সহায়তা, ডাক্তার, পরামর্শদাতা, পুলিশ ইত্যাদির সাথে সংযোগ।',
      'icon': PhosphorIcons.handHeart,
      'color': Colors.pink,
    },
    {
      'nameEn': 'National Hotline Number',
      'nameBn': 'জাতীয় হটলাইন নম্বর',
      'phones': ['333'],
      'descriptionEn':
          'Reports/help for social problems (COVID, child marriage, etc.).',
      'descriptionBn':
          'সামাজিক সমস্যার (কোভিড, বাল্যবিবাহ ইত্যাদি) রিপোর্ট/সহায়তা।',
      'icon': PhosphorIcons.phone,
      'color': Colors.teal,
    },
  ];

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final PermissionStatus permissionStatus = await Permission.phone.status;

    if (permissionStatus.isDenied) {
      final newStatus = await Permission.phone.request();
      if (newStatus.isDenied) {
        _showPermissionDeniedError(phoneNumber, context);
        return;
      }
    }

    if (permissionStatus.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedError(phoneNumber, context);
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      _showPhoneDialingError(phoneNumber, context);
    }
  }

  void _showPhoneDialingError(String phoneNumber, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to make call. Please dial $phoneNumber manually.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showPermissionDeniedError(String phoneNumber, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phone permission required to make calls. Please dial $phoneNumber manually.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPermissionPermanentlyDeniedError(
    String phoneNumber,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'Phone permission is permanently denied. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showMultipleNumbersDialog(
    BuildContext context,
    List<String> phones,
    String orgName,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: phones
              .map(
                (phone) => ListTile(
                  leading: Icon(PhosphorIcons.phone()),
                  title: Text(phone),
                  onTap: () {
                    Navigator.of(context).pop();
                    _makePhoneCall(phone, context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildHelplineCard(
    BuildContext context,
    Map<String, dynamic> helpline,
    String languageCode,
  ) {
    final phones = helpline['phones'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kElevationToShadow[2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: helpline['color'].withOpacity(0.1),
                child: Icon(helpline['icon'](), color: helpline['color']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  languageCode == 'bn'
                      ? helpline['nameBn']
                      : helpline['nameEn'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            languageCode == 'bn'
                ? helpline['descriptionBn']
                : helpline['descriptionEn'],
            style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (phones.length == 1) {
                _makePhoneCall(phones.first, context);
              } else {
                _showMultipleNumbersDialog(
                  context,
                  phones,
                  languageCode == 'bn'
                      ? helpline['nameBn']
                      : helpline['nameEn'],
                );
              }
            },
            icon: Icon(PhosphorIcons.phone(), size: 18),
            label: Text(languageCode == 'bn' ? 'কল করুন' : 'Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: helpline['color'],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    final languageCode = Provider.of<LanguageProvider>(
      context,
    ).currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageCode == 'bn' ? 'জরুরি সহায়তা' : 'Emergency Help',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.warning(), color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        languageCode == 'bn'
                            ? 'জরুরি অবস্থায় অবিলম্বে নিচের নম্বরগুলোতে কল করুন'
                            : 'In case of emergency, call the numbers below immediately',
                        style: GoogleFonts.inter(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                languageCode == 'bn'
                    ? 'হেল্পলাইন নম্বরসমূহ'
                    : 'Helpline Numbers',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: helplines.length,
                  itemBuilder: (_, index) => _buildHelplineCard(
                    context,
                    helplines[index],
                    languageCode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
