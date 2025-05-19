import 'package:logger/logger.dart';

class ImageService {
  final Logger _logger = Logger();
  
  // A collection of high-quality travel images from Unsplash
  // These are direct URLs to specific travel images with proper licensing
  final List<String> _travelImageUrls = [
    'https://images.unsplash.com/photo-1682695796954-bad0d0f59ff1?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1682687982501-1e58ab814714?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1682687982107-14492010e05e?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1682695794816-7126b16265fc?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1683009427540-c5bd6a32abf6?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1682687982360-3ce907f2e3ff?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1682687982183-c2937a83eaab?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1530789253388-582c481c54b0?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517760444937-f6397edcbbcd?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1502791451862-7bd8c1df43a7?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1498307833015-e7b400441eb8?q=80&w=1500&auto=format&fit=crop',
  ];
  
  // City/urban specific images
  final List<String> _cityImageUrls = [
    'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1444723121867-7a241cacace9?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1444084316824-dc26d6657664?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1514924013411-cbf25faa35bb?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517935706615-2717063c2225?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1460572894071-bde5697f7197?q=80&w=1500&auto=format&fit=crop',
  ];
  
  // Nature/outdoor specific images
  final List<String> _natureImageUrls = [
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1470770903321-94edd192b6a5?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1446329813274-7c9036bd9a1f?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1497449493050-aad1e7cad165?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=1500&auto=format&fit=crop',
  ];
  
  // Beach/coastal specific images
  final List<String> _beachImageUrls = [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1473186578172-c141e6798cf4?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1520942702018-0862200e6873?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1437719417032-8595fd9e9dc6?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1468413253725-0d5181091126?q=80&w=1500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509233725247-49e657c54213?q=80&w=1500&auto=format&fit=crop',
  ];
  
  // User avatar images
  final List<String> _avatarImageUrls = [
    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1463453091185-61582044d556?q=80&w=400&auto=format&fit=crop',
  ];
  
  // Get a random travel image URL
  String getRandomTravelImage() {
    final int index = DateTime.now().millisecondsSinceEpoch % _travelImageUrls.length;
    return _travelImageUrls[index];
  }
  
  // Get a specific travel image by index (for consistent references)
  String getTravelImage(int index) {
    return _travelImageUrls[index % _travelImageUrls.length];
  }
  
  // Get an image URL based on category
  String getCategoryImage(String category) {
    category = category.toLowerCase();
    List<String> sourceList;
    
    if (category.contains('city') || category.contains('urban')) {
      sourceList = _cityImageUrls;
    } else if (category.contains('nature') || category.contains('mountain') || category.contains('forest')) {
      sourceList = _natureImageUrls;
    } else if (category.contains('beach') || category.contains('sea') || category.contains('ocean')) {
      sourceList = _beachImageUrls;
    } else {
      sourceList = _travelImageUrls;
    }
    
    final int index = category.hashCode % sourceList.length;
    return sourceList[index.abs()];
  }
  
  // Get a random avatar image URL
  String getRandomAvatarImage() {
    final int index = DateTime.now().millisecondsSinceEpoch % _avatarImageUrls.length;
    return _avatarImageUrls[index];
  }
  
  // Get a specific avatar by index (for consistent user references)
  String getAvatarImage(int index) {
    return _avatarImageUrls[index % _avatarImageUrls.length];
  }
  
  // Get a consistent avatar based on a user ID string
  String getAvatarForUserId(String userId) {
    final int index = userId.hashCode % _avatarImageUrls.length;
    return _avatarImageUrls[index.abs()];
  }
} 