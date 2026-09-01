import random
from datetime import datetime, timedelta
from faker import Faker
import csv
import os

print("=" * 70)
print("VisitOps Intelligence - Synthetic Data Generator")
print("=" * 70)

fake = Faker('en_GB')
random.seed(42)

# Configuration
NUM_SERVICE_USERS = 120
NUM_CARERS = 80
NUM_DAYS = 90
VISITS_PER_DAY = 250
COMMISSIONERS = ['East Lothian HSCP', 'Midlothian HSCP', 'City of Edinburgh', 'Scottish Borders HSCP', 'Fife HSCP', 'Private']
VISIT_TYPES = ['personal_care', 'medication', 'meal_prep', 'shopping', 'companionship', 'wellbeing_check']
HEALTH_NEEDS = ['high', 'medium', 'low']
EMPLOYMENT_TYPES = ['employed', 'agency']
AREAS = ['North', 'South', 'East', 'West', 'Central']
INCIDENT_TYPES = ['missed_visit', 'late_visit', 'complaint', 'safeguarding_concern']

print("\n[1/7] Generating service users...")
service_users = []
for i in range(1, NUM_SERVICE_USERS + 1):
    service_users.append({
        'service_user_id': 1000 + i,
        'name': f'Patient_{i}',
        'age': random.randint(65, 95),
        'postcode': fake.postcode(),
        'health_needs_level': random.choice(HEALTH_NEEDS),
        'care_plan_summary': fake.sentence(nb_words=6),
        'created_date': (datetime.now() - timedelta(days=random.randint(30, 365))).strftime('%Y-%m-%d'),
        'is_active': 1
    })

with open('data/synthetic/SERVICE_USERS.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['service_user_id', 'name', 'age', 'postcode', 'health_needs_level', 'care_plan_summary', 'created_date', 'is_active'])
    writer.writeheader()
    writer.writerows(service_users)
print(f"   ✓ Created {len(service_users)} service users")

print("\n[2/7] Generating carers...")
carers = []
for i in range(1, NUM_CARERS + 1):
    carers.append({
        'carer_id': 2000 + i,
        'name': f'Carer_{i}',
        'employment_type': random.choice(EMPLOYMENT_TYPES),
        'start_date': (datetime.now() - timedelta(days=random.randint(30, 730))).strftime('%Y-%m-%d'),
        'qualifications': 'NVQ L3 Care' if random.random() > 0.3 else 'NVQ L2 Care',
        'is_active': 1
    })

with open('data/synthetic/CARERS.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['carer_id', 'name', 'employment_type', 'start_date', 'qualifications', 'is_active'])
    writer.writeheader()
    writer.writerows(carers)
print(f"   ✓ Created {len(carers)} carers")

print("\n[3/7] Generating visits (this takes a moment)...")
visits = []
base_date = datetime.now() - timedelta(days=NUM_DAYS)
visit_id = 10000

for day_offset in range(NUM_DAYS):
    scheduled_date = (base_date + timedelta(days=day_offset)).strftime('%Y-%m-%d')
    
    for _ in range(VISITS_PER_DAY):
        service_user = random.choice(service_users)
        carer = random.choice(carers)
        
        scheduled_start = f"{random.randint(6, 16):02d}:{random.randint(0, 59):02d}"
        scheduled_duration = random.choice([30, 45, 60, 90])
        
        completion_rand = random.random()
        if completion_rand < 0.05:
            visit_completed = 0
            actual_arrival = None
            actual_departure = None
            late_minutes = None
        elif completion_rand < 0.10:
            visit_completed = 1
            late_minutes = random.randint(5, 60)
            actual_arrival = (datetime.strptime(scheduled_start, '%H:%M') + timedelta(minutes=late_minutes)).strftime('%H:%M')
            actual_departure = (datetime.strptime(actual_arrival, '%H:%M') + timedelta(minutes=scheduled_duration)).strftime('%H:%M')
        else:
            visit_completed = 1
            late_minutes = 0
            actual_arrival = scheduled_start
            actual_departure = (datetime.strptime(scheduled_start, '%H:%M') + timedelta(minutes=scheduled_duration)).strftime('%H:%M')
        
        visits.append({
            'visit_id': visit_id,
            'service_user_id': service_user['service_user_id'],
            'carer_id': carer['carer_id'],
            'scheduled_date': scheduled_date,
            'scheduled_start_time': scheduled_start,
            'scheduled_duration_minutes': scheduled_duration,
            'actual_arrival_time': actual_arrival,
            'actual_departure_time': actual_departure,
            'visit_type': random.choice(VISIT_TYPES),
            'visit_completed': visit_completed,
            'visit_late_by_minutes': late_minutes,
            'notes': fake.sentence(nb_words=8) if random.random() > 0.7 else None
        })
        visit_id += 1

with open('data/synthetic/VISITS.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['visit_id', 'service_user_id', 'carer_id', 'scheduled_date', 'scheduled_start_time', 'scheduled_duration_minutes', 'actual_arrival_time', 'actual_departure_time', 'visit_type', 'visit_completed', 'visit_late_by_minutes', 'notes'])
    writer.writeheader()
    writer.writerows(visits)
print(f"   ✓ Created {len(visits)} visits")

print("\n[4/7] Generating incidents...")
incidents = []
incident_id = 3000
for visit in random.sample(visits, int(len(visits) * 0.08)):
    if visit['visit_completed'] == 0 or visit['visit_late_by_minutes'] and visit['visit_late_by_minutes'] > 30:
        incidents.append({
            'incident_id': incident_id,
            'visit_id': visit['visit_id'],
            'incident_type': 'missed_visit' if visit['visit_completed'] == 0 else 'late_visit',
            'severity': 'high' if visit['visit_completed'] == 0 else 'medium',
            'description': fake.sentence(nb_words=10),
            'reported_date': visit['scheduled_date']
        })
        incident_id += 1

with open('data/synthetic/INCIDENTS.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['incident_id', 'visit_id', 'incident_type', 'severity', 'description', 'reported_date'])
    writer.writeheader()
    writer.writerows(incidents)
print(f"   ✓ Created {len(incidents)} incidents")

print("\n[5/7] Generating invoices...")
invoices = []
invoice_id = 4000
period_start = base_date.strftime('%Y-%m-%d')
period_end = (base_date + timedelta(days=NUM_DAYS)).strftime('%Y-%m-%d')

for commissioner in COMMISSIONERS:
    commissioner_visits = [v for v in visits if v['visit_completed'] == 1]
    num_invoiced = len(commissioner_visits) // len(COMMISSIONERS)
    
    invoices.append({
        'invoice_id': invoice_id,
        'commissioner_name': commissioner,
        'invoice_date': period_end,
        'period_start_date': period_start,
        'period_end_date': period_end,
        'num_visits_invoiced': num_invoiced,
        'total_amount': num_invoiced * 45.00,
        'payment_status': random.choice(['paid', 'pending', 'pending'])
    })
    invoice_id += 1

with open('data/synthetic/INVOICES.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['invoice_id', 'commissioner_name', 'invoice_date', 'period_start_date', 'period_end_date', 'num_visits_invoiced', 'total_amount', 'payment_status'])
    writer.writeheader()
    writer.writerows(invoices)
print(f"   ✓ Created {len(invoices)} invoices")

print("\n[6/7] Generating staff roster...")
rosters = []
roster_id = 5000

for carer in carers:
    for day_offset in range(NUM_DAYS):
        if random.random() > 0.15:
            shift_date = (base_date + timedelta(days=day_offset)).strftime('%Y-%m-%d')
            shift_start = f"{random.randint(6, 14):02d}:00"
            shift_end = f"{random.randint(14, 18):02d}:00"
            
            rosters.append({
                'roster_id': roster_id,
                'carer_id': carer['carer_id'],
                'shift_date': shift_date,
                'shift_start_time': shift_start,
                'shift_end_time': shift_end,
                'area': random.choice(AREAS),
                'is_overtime': 1 if random.random() > 0.9 else 0,
                'num_scheduled_visits': random.randint(5, 12)
            })
            roster_id += 1

with open('data/synthetic/STAFF_ROSTER.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['roster_id', 'carer_id', 'shift_date', 'shift_start_time', 'shift_end_time', 'area', 'is_overtime', 'num_scheduled_visits'])
    writer.writeheader()
    writer.writerows(rosters)
print(f"   ✓ Created {len(rosters)} roster entries")

print("\n[7/7] Summary...")
print(f"\n✓ SUCCESS - All synthetic data generated\n")
print(f"  SERVICE_USERS:  {len(service_users):,} records")
print(f"  CARERS:         {len(carers):,} records")
print(f"  VISITS:         {len(visits):,} records")
print(f"  INCIDENTS:      {len(incidents):,} records")
print(f"  INVOICES:       {len(invoices):,} records")
print(f"  STAFF_ROSTER:   {len(rosters):,} records")
print(f"\n  Total records:  {len(service_users) + len(carers) + len(visits) + len(incidents) + len(invoices) + len(rosters):,}")
print("\nAll CSV files saved to: data/synthetic/")
