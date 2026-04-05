from typing import Optional
from pydantic import BaseModel, Field, field_validator


class Expense(BaseModel):
    amount: Optional[float] = Field(
        default=None,
        description="Numeric expense amount only (no currency symbols)"
    )
    merchant: Optional[str] = Field(
        default=None,
        description="Merchant name where the transaction happened"
    )
    currency: Optional[str] = Field(
        default=None,
        description="3-letter ISO currency code like INR, USD"
    )

    @field_validator("amount", mode="before")
    @classmethod
    def clean_amount(cls, value):
        if value is None:
            return value

        if isinstance(value, (int, float)):
            return float(value)

        if isinstance(value, str):
            cleaned = (
                value.replace("INR", "")
                .replace("Rs.", "")
                .replace("₹", "")
                .strip()
            )
            try:
                return float(cleaned)
            except:
                return None

        return None

    @field_validator("currency", mode="before")
    @classmethod
    def normalize_currency(cls, value):
        if value is None:
            return value

        value = value.strip()

        if value in ["₹", "Rs.", "Rs"]:
            return "INR"

        return value.upper()

    def serialize(self):
        return {
            "amount": self.amount,
            "merchant": self.merchant,
            # currency removed — no longer sent to kafka or stored in DB
        }
