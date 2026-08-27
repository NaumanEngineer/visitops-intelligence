-- VisitOps Intelligence Database Schema
-- 6 core entities for domiciliary care analytics

CREATE TABLE SERVICE_USERS (
    service_user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    postcode VARCHAR(10),
    health_needs_level VARCHAR(20),
    care_plan_summary TEXT,
    created_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE CARERS (
    carer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    employment_type VARCHAR(20),
    start_date DATE NOT NULL,
    qualifications VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE VISITS (
    visit_id INT PRIMARY KEY,
    service_user_id INT NOT NULL,
    carer_id INT NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_start_time TIME,
    scheduled_duration_minutes INT,
    actual_arrival_time TIME,
    actual_departure_time TIME,
    visit_type VARCHAR(50),
    visit_completed BOOLEAN DEFAULT FALSE,
    visit_late_by_minutes INT,
    notes TEXT,
    FOREIGN KEY (service_user_id) REFERENCES SERVICE_USERS(service_user_id),
    FOREIGN KEY (carer_id) REFERENCES CARERS(carer_id)
);

CREATE TABLE INCIDENTS (
    incident_id INT PRIMARY KEY,
    visit_id INT NOT NULL,
    incident_type VARCHAR(50),
    severity VARCHAR(20),
    description TEXT,
    reported_date DATE NOT NULL,
    FOREIGN KEY (visit_id) REFERENCES VISITS(visit_id)
);

CREATE TABLE INVOICES (
    invoice_id INT PRIMARY KEY,
    commissioner_name VARCHAR(100),
    invoice_date DATE NOT NULL,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    num_visits_invoiced INT,
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20)
);

CREATE TABLE STAFF_ROSTER (
    roster_id INT PRIMARY KEY,
    carer_id INT NOT NULL,
    shift_date DATE NOT NULL,
    shift_start_time TIME,
    shift_end_time TIME,
    area VARCHAR(50),
    is_overtime BOOLEAN DEFAULT FALSE,
    num_scheduled_visits INT,
    FOREIGN KEY (carer_id) REFERENCES CARERS(carer_id)
);