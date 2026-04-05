// const String BASE_URL = "http://10.0.2.2:8000";
// // const String BASE_URL = "http://127.0.0.1:9898";


const Map<String, String> _currencyMap = {
  "INR": "₹",
  "USD": "\$",
  "EUR": "€",
};
List<String> getCurrencyCodes() {
  return _currencyMap.keys.toList();
}
String getCurrencySymbol(String code) {
  return _currencyMap[code] ?? code;
}
