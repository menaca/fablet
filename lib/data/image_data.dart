class ImageFeature {
  final String hairColor;
  final String eyeColor;
  final String wearStyle;

  ImageFeature({required this.hairColor, required this.eyeColor, required this.wearStyle});
}

class ImageData {
  static final Map<String, ImageFeature> imageFeatures = {
    'assets/k-1.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Sarı Kazak'),
    'assets/k-2.png': ImageFeature(hairColor: 'Kızıl', eyeColor: 'Siyah',wearStyle: 'Yeşil Kazak'),
    'assets/k-3.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Pembe Elbise'),
    'assets/k-4.png': ImageFeature(hairColor: 'Sarı', eyeColor: 'Siyah', wearStyle: 'Mavi Elbise'),
    'assets/k-5.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Mavi Ceket ve Beyaz Gömlek'),
    'assets/k-6.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Kırmızı Elbise'),
    'assets/k-7.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Yeşil Kazak'),
    'assets/k-8.png': ImageFeature(hairColor: 'Sarı', eyeColor: 'Siyah', wearStyle: 'Kırmızı Ceket ve Beyaz Gömlek'),
    'assets/k-9.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Pembe Elbise'),

    'assets/e-1.png': ImageFeature(hairColor: 'Sarı', eyeColor: 'Siyah', wearStyle: 'Mavi Gömlek'),
    'assets/e-2.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Beyaz Kazak'),
    'assets/e-3.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Kırmızı Kazak'),
    'assets/e-4.png': ImageFeature(hairColor: 'Sarı', eyeColor: 'Ela', wearStyle: 'Mavi Gömlek'),
    'assets/e-5.png': ImageFeature(hairColor: 'Beyaz', eyeColor: 'Siyah', wearStyle: 'Kırmızı Kazak'),
    'assets/e-6.png': ImageFeature(hairColor: 'Beyaz', eyeColor: 'Ela', wearStyle: 'Gri Kazak ve Beyaz Gömlek'),
    'assets/e-7.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Kırmızı Sweatshirt'),
    'assets/e-8.png': ImageFeature(hairColor: 'Turuncu', eyeColor: 'Siyah', wearStyle: 'Gri Sweatshirt'),
    'assets/e-9.png': ImageFeature(hairColor: 'Kahverengi', eyeColor: 'Siyah', wearStyle: 'Yeşil Kazak'),
  };
}
