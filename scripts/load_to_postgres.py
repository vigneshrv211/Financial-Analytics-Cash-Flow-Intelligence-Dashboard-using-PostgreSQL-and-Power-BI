import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from urllib.parse import quote_plus

load_dotenv()

password = quote_plus(os.getenv("DB_PASSWORD"))

engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{password}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

customers = pd.read_csv("data/customers.csv")
invoices = pd.read_csv("data/invoices.csv")
payments = pd.read_csv("data/payments.csv")

customers.to_sql("customers", engine, if_exists="append", index=False)
invoices.to_sql("invoices", engine, if_exists="append", index=False)
payments.to_sql("payments", engine, if_exists="append", index=False)

print("Data Loaded Successfully!")