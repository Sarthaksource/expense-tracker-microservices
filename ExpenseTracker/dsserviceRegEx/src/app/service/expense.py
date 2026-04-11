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
                .replace(",", "")  # Handles comma-separated numbers
                .strip()
            )
            try:
                return float(cleaned)
            except ValueError:
                return None

        return None

    def serialize(self):
        return self.model_dump()