class Validators {
	static String? requiredField(String? value, {String fieldName = 'Bu alan'}) {
		if (value == null || value.trim().isEmpty) {
			return '$fieldName gereklidir';
		}
		return null;
	}

	static String? email(String? value) {
		if (value == null || value.isEmpty) return 'E-posta adresi gereklidir';
		final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
		if (!regex.hasMatch(value)) return 'Geçerli bir e-posta adresi girin';
		return null;
	}

	static String? password(String? value, {int minLength = 6}) {
		if (value == null || value.isEmpty) return 'Şifre gereklidir';
		if (value.length < minLength) return 'Şifre en az $minLength karakter olmalıdır';
		return null;
	}

	static String? confirmPassword(String? value, String other) {
		if (value == null || value.isEmpty) return 'Şifre tekrarı gereklidir';
		if (value != other) return 'Şifreler eşleşmiyor';
		return null;
	}

	static String? positiveNumber(String? value, {String fieldName = 'Değer'}) {
		if (value == null || value.isEmpty) return '$fieldName gereklidir';
		final n = double.tryParse(value.replaceAll(',', '.'));
		if (n == null || n < 0) return '$fieldName pozitif olmalıdır';
		return null;
	}
}

