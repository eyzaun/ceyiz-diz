import 'package:intl/intl.dart';

class Formatters {
	static final NumberFormat _currencyTr = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
	static final NumberFormat _decimal = NumberFormat('#,##0.##', 'tr_TR');

	static String currency(num value) => _currencyTr.format(value);
	static String decimal(num value) => _decimal.format(value);

	static String? parseCurrencyToString(String input) {
		final cleaned = input
				.replaceAll('₺', '')
				.replaceAll('.', '')
				.replaceAll(',', '.')
				.trim();
		final val = double.tryParse(cleaned);
		return val?.toString();
	}
}

