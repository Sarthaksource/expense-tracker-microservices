import re


class MessagesUtil:
    # Keywords that strongly indicate a bank transaction SMS
    BANK_KEYWORDS = [
        "spent", "debited", "credited", "bank", "card",
        "transaction", "payment", "transfer", "upi", "imps",
        "neft", "rtgs", "withdrawn", "paid", "balance",
        "a/c", "acct", "account", "inr", "rs.", "₹",
    ]

    # Known Indian bank sender ID fragments
    BANK_SENDERS = [
        "hdfc", "sbi", "icici", "axis", "kotak", "pnb",
        "bob", "canara", "union", "yes", "idfc", "indus",
        "paytm", "phonepe", "gpay", "hdfcbk", "sbiinb",
        "axisbk", "kotakbk", "icicib", "bobtxn", "pnbsms",
    ]

    def isBankSms(self, message: str) -> bool:
        if not message:
            return False

        lower = message.lower()

        # Check keywords
        keyword_pattern = r'\b(?:' + '|'.join(re.escape(w) for w in self.BANK_KEYWORDS) + r')\b'
        if re.search(keyword_pattern, lower, re.IGNORECASE):
            return True

        # Check bank sender name fragments
        for sender in self.BANK_SENDERS:
            if sender in lower:
                return True

        # Check for currency patterns
        if re.search(r'(?:INR|Rs\.?|₹)\s*[\d,]+', message, re.IGNORECASE):
            return True

        return False
