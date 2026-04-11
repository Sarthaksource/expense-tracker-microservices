import re
from .expense import Expense


class RegexService:

    def extract(self, message: str) -> Expense:
        amount = self._extract_amount(message)
        merchant = self._extract_merchant(message)
        return Expense(amount=amount, merchant=merchant)  # currency hardcoded as dummy

    # ─── AMOUNT ───────────────────────────────────────────────────
    def _extract_amount(self, sms: str):
        patterns = [
            # ₹ / Rs. / INR before amount
            r'(?:INR|Rs\.?|₹)\s*([\d,]+(?:\.\d{1,2})?)',
            # amount after number
            r'([\d,]+(?:\.\d{1,2})?)\s*(?:INR)',
            # debited/credited/spent/paid ... amount
            r'(?:debited|credited|spent|paid|withdrawn|deducted)\s+(?:by|of|for|with)?\s*(?:INR|Rs\.?|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
            # amount of X
            r'amount\s+of\s+(?:INR|Rs\.?|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
            # USD / $
            r'(?:USD|\$)\s*([\d,]+(?:\.\d{1,2})?)',
        ]

        for pattern in patterns:
            m = re.search(pattern, sms, re.IGNORECASE)
            if m:
                raw = m.group(1).replace(',', '')
                try:
                    return float(raw)
                except ValueError:
                    continue

        return None

    # ─── MERCHANT ─────────────────────────────────────────────────
    def _extract_merchant(self, sms: str):
        patterns = [
            # at / to MERCHANT on/via/ref/,/.
            r'(?:at|to|toward|@)\s+([A-Z][A-Za-z0-9\s\-&\.\*]+?)(?:\s+on\b|\s+via\b|\s+for\b|\s+ref\b|\s+upi\b|\s+using\b|[,\.]|$)',
            # paid to / trf to / transfer to
            r'(?:trf to|transfer to|paid to|payment to|sent to)\s+([A-Za-z0-9\s\-&\.]+?)(?:\s+on\b|\s+ref\b|[,\.]|$)',
            # UPI/IMPS/NEFT - merchant
            r'(?:UPI|IMPS|NEFT|RTGS)\s*[-:]\s*([A-Za-z0-9\s\-&\.]+?)(?:\s+ref\b|\s+upi\b|[,\.]|$)',
            # merchant: / info:
            r'(?:merchant|info)[:\s]+([A-Za-z0-9\s\-&\.]+?)(?:[,\.]|$)',
            # VPA (UPI ID)
            r'(?:to VPA|VPA)\s+([a-zA-Z0-9.\-_@]+)',
        ]

        for pattern in patterns:
            m = re.search(pattern, sms, re.IGNORECASE)
            if m:
                merchant = m.group(1).strip()
                if len(merchant) > 2:
                    return merchant

        return None
