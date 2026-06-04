import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker("en_IN")

random.seed(42)
np.random.seed(42)

# CONFIG
NUM_CUSTOMERS = 500
NUM_INVOICES = 10000

START_DATE = datetime(2022, 4, 1)
END_DATE = datetime(2024, 3, 31)
ANALYSIS_DATE = datetime(2024, 3, 31)

SEGMENTS = ["ENTERPRISE", "SME", "STARTUP"]
INDUSTRIES = ["BFSI", "MANUFACTURING", "RETAIL", "IT", "PHARMA"]
CITIES = ["Chennai", "Mumbai", "Hyderabad", "Delhi", "Bangalore"]
REGIONS = ["NORTH", "SOUTH", "EAST", "WEST"]
CATEGORIES = ["HARDWARE", "SOFTWARE", "SERVICES", "MAINTENANCE"]

# =========================
# CUSTOMERS
# =========================

customers = []

for i in range(NUM_CUSTOMERS):

    seg = random.choices(SEGMENTS, weights=[30, 50, 20])[0]

    credit_limit = round(
        {
            "ENTERPRISE": random.uniform(5000000, 50000000),
            "SME": random.uniform(500000, 5000000),
            "STARTUP": random.uniform(100000, 500000),
        }[seg],
        2,
    )

    risk_tier = random.choices(
        ["LOW", "MEDIUM", "HIGH"],
        weights=[60, 30, 10],
    )[0]

    customers.append(
        {
            "customer_id": f"CUS-{i+1:04d}",
            "customer_name": fake.company(),
            "customer_segment": seg,
            "industry": random.choice(INDUSTRIES),
            "city": random.choice(CITIES),
            "credit_limit": credit_limit,
            "credit_days": random.choice([30, 45, 60]),
            "customer_risk_tier": risk_tier,
            "relationship_since": fake.date_between("-5y", "-1y"),
        }
    )

customers_df = pd.DataFrame(customers)

# =========================
# INVOICES & PAYMENTS
# =========================

invoices = []
payments = []
payment_id = 1

for i in range(NUM_INVOICES):

    cust = customers_df.sample(1).iloc[0]

    cid = cust["customer_id"]
    risk = cust["customer_risk_tier"]
    credit_days = int(cust["credit_days"])

    inv_date = fake.date_between_dates(
        date_start=START_DATE,
        date_end=END_DATE,
    )

    due_date = inv_date + timedelta(days=credit_days)

    base_amt = {
        "ENTERPRISE": 9.5,
        "SME": 8.0,
        "STARTUP": 7.0,
    }

    amount = round(
        np.random.lognormal(
            base_amt[cust["customer_segment"]],
            1.0,
        ),
        2,
    )

    # Payment behavior

    if risk == "LOW":
        outcome = random.choices(
            ["ON_TIME", "LATE", "OVERDUE", "UNPAID"],
            [85, 10, 3, 2],
        )[0]

    elif risk == "MEDIUM":
        outcome = random.choices(
            ["ON_TIME", "LATE", "OVERDUE", "UNPAID"],
            [55, 25, 12, 8],
        )[0]

    else:
        outcome = random.choices(
            ["ON_TIME", "LATE", "OVERDUE", "UNPAID"],
            [25, 30, 25, 20],
        )[0]

    # Payment outcome

    if outcome == "ON_TIME":
        pay_date = due_date - timedelta(days=random.randint(0, 5))
        paid_amt = amount
        status = "PAID"

    elif outcome == "LATE":
        pay_date = due_date + timedelta(days=random.randint(1, 30))
        paid_amt = amount
        status = "PAID"

    elif outcome == "OVERDUE":
        pay_date = None
        paid_pct = random.uniform(0.3, 0.7)
        paid_amt = round(amount * paid_pct, 2)
        status = "PARTIAL"

    else:
        pay_date = None
        paid_amt = 0
        status = "OVERDUE"

    outstanding = round(amount - paid_amt, 2)

    if pay_date is None:
        days_overdue = max(
            0,
            (ANALYSIS_DATE - datetime.combine(due_date, datetime.min.time())).days,
        )
    else:
        days_overdue = 0

    if pay_date:
        bucket = "PAID"
    elif days_overdue <= 30:
        bucket = "CURRENT"
    elif days_overdue <= 60:
        bucket = "31-60"
    elif days_overdue <= 90:
        bucket = "61-90"
    else:
        bucket = "90+"

    invoices.append(
        {
            "invoice_id": f"INV-{i+1:05d}",
            "customer_id": cid,
            "invoice_date": inv_date,
            "due_date": due_date,
            "payment_date": pay_date,
            "invoice_amount": amount,
            "paid_amount": paid_amt,
            "outstanding_amount": outstanding,
            "days_overdue": days_overdue,
            "aging_bucket": bucket,
            "invoice_status": status,
            "product_category": random.choice(CATEGORIES),
            "region": random.choice(REGIONS),
        }
    )

    if paid_amt > 0 and pay_date:

        payments.append(
            {
                "payment_id": payment_id,
                "invoice_id": f"INV-{i+1:05d}",
                "customer_id": cid,
                "payment_date": pay_date,
                "payment_amount": paid_amt,
                "payment_mode": random.choice(
                    ["NEFT", "RTGS", "CHEQUE", "ONLINE"]
                ),
                "days_to_pay": (pay_date - inv_date).days,
                "on_time_flag": pay_date <= due_date,
            }
        )

        payment_id += 1

# =========================
# DATAFRAMES
# =========================

invoices_df = pd.DataFrame(invoices)
payments_df = pd.DataFrame(payments)

# =========================
# SAVE FILES
# =========================

customers_df.to_csv("data/customers.csv", index=False)
invoices_df.to_csv("data/invoices.csv", index=False)
payments_df.to_csv("data/payments.csv", index=False)

print(f"Customers : {len(customers_df)}")
print(f"Invoices  : {len(invoices_df)}")
print(f"Payments  : {len(payments_df)}")
print("CSV files generated successfully.")