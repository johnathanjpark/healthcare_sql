COPY hospital_info
FROM 'C:/users/kptro/documents/healthcare_sql/data/cms_hospital_data.csv'
WITH (FORMAT CSV, HEADER TRUE);