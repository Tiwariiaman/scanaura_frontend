enum QrCardTheme {
  theme1,
  theme2,
  theme3,
  theme4,
  theme5,
  theme6,
  theme7,
  theme8,
}

extension QrCardThemeX on QrCardTheme {
  String get label {
    switch (this) {
      case QrCardTheme.theme1:
        return 'Theme 1';
      case QrCardTheme.theme2:
        return 'Theme 2';
      case QrCardTheme.theme3:
        return 'Theme 3';
      case QrCardTheme.theme4:
        return 'Theme 4';
      case QrCardTheme.theme5:
        return 'Theme 5';
      case QrCardTheme.theme6:
        return 'Theme 6';
      case QrCardTheme.theme7:
        return 'Theme 7';
      case QrCardTheme.theme8:
        return 'Theme 8';
    }
  }

  String get description {
    switch (this) {
      case QrCardTheme.theme1:
        return 'Fresh and natural';
      case QrCardTheme.theme2:
        return 'Simple and elegant';
      case QrCardTheme.theme3:
        return 'Vibrant and impactful';
      case QrCardTheme.theme4:
        return 'Premium and refined';
      case QrCardTheme.theme5:
        return 'Modern and dynamic';
      case QrCardTheme.theme6:
        return 'Elegant and memorable';
      case QrCardTheme.theme7:
        return 'Editorial and distinctive';
      case QrCardTheme.theme8:
        return 'Clean and professional';
    }
  }
}