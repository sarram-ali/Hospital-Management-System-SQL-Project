SELECT * FROM Appointment;
SELECT * FROM Bed;
SELECT * FROM BedRecords;
SELECT * FROM Department;
SELECT * FROM Doctor;
SELECT * FROM Helpers;
SELECT * FROM MedicalRecord;
SELECT * FROM Nurse;
SELECT * FROM Patients;
SELECT * FROM Room;
SELECT * FROM RoomRecords;
SELECT * FROM StaffShift;
SELECT * FROM SurgeryRecord;
SELECT * FROM Ward;


-- Question 1
-- List patients with their appointment doctor and reason.

SELECT p.fname AS Patient,
	   d.fname AS Doctor,
       a.reason AS Reason
FROM patients p
JOIN appointment a ON p.patient_Id = a.patient_Id
JOIN doctor d ON a.doct_Id = d.doct_Id;

-- Question 2
-- Show nurses who have assisted in bed admissions with patient names.

SELECT n.fname AS Nurse,
	   p.fname AS Patient,
       bdr.admission_date AS Admission_Date
FROM nurse n
JOIN bedrecords bdr ON n.nurse_Id = bdr.nurse_Id
JOIN patients p ON p.patient_Id = bdr.patient_Id;

-- Question 3
-- List rooms used for surgeries, the surgeon, and the surgery type.

SELECT r.room_no AS Room_Number,
	   d.fname AS Surgeon,
       sgr.surgery_type
FROM room r
JOIN doctor d ON r.dept_Id = d.dept_Id
JOIN surgeryrecord sgr ON sgr.room_no = r.room_No;

-- Question 4
-- List each department with the number of doctors assigned to it.

SELECT dept.dept_name, 
	   COUNT(d.doct_id) Doctors
FROM department dept
JOIN doctor d ON dept.dept_Id = d.dept_Id
GROUP BY dept.dept_name;

-- Question 5
-- Show patients who had an appointment and were admitted to a bed.

SELECT p.fname AS Patient,
	   d.fname AS Doctor,
	   a.appointment_Date AS Appointment_Date,
       bdr.bed_no AS Bed_Number
FROM patients p
JOIN appointment a ON p.patient_Id = a.patient_Id
JOIN doctor d ON d.doct_Id = a.doct_Id
JOIN bedrecords bdr ON a.patient_Id = bdr.patient_Id;

-- Question 6
-- We have a new patient for the Cardiology Ward and he/she wants a bed on a specific day.
-- We want to find out which beds are empty in that ward on that particular day.

SELECT b.bed_No AS Bed_Number,
	   b.ward_no AS Ward_Number,
       d.dept_Name AS Department
FROM bed b
JOIN ward w ON w.ward_No = b.ward_No
JOIN department d ON d.dept_Id = w.dept_Id
WHERE 
	d.dept_Name = 'Cardiology'
    AND
    w.ward_No = 502
    AND
    b.bed_no NOT IN (
		SELECT br.bed_no 
		FROM bedrecords br
        WHERE
			'2025-5-10' BETWEEN br.admission_Date AND br.discharge_Date);
		
-- Question 7
-- There is a new virus in the city and the hospital is expecting more patients than a regular day. 
-- Management wants to see if they can manage those with the current staff or not.
-- They want to check upcoming appointments for each department on 4 June 2025.

SELECT dpt.dept_name AS Department,
	   a.appointment_Date AS Appointment_Date,
	   COUNT(a.appointment_id) AS Appointments
FROM doctor d
JOIN department dpt ON d.dept_Id = dpt.dept_Id
JOIN appointment a ON d.doct_Id = a.doct_Id
GROUP BY
dpt.dept_name,
a.appointment_Date
HAVING a.appointment_Date = '2025-06-04';

-- Question 8
-- A doctor is asking for a salary raise due to extra work in the previous month. Verify if he/she deserves a raise by retrieving their 
-- total appointments, 
-- total visits, 
-- total surgeries,
-- total shifts.

SELECT d.fname AS Doctor,

	   (
       SELECT COUNT(*) FROM appointment a
		WHERE 
			a.doct_Id = d.doct_Id
            AND
            a.appointment_Date BETWEEN '2025-05-01' AND '2025-05-31' 
		) AS Total_Appointments,
            
		(
        SELECT COUNT(*) FROM medicalrecord mdr
		WHERE 
			mdr.doct_Id = d.doct_Id
            AND
            mdr.visit_Date BETWEEN '2025-05-01' AND '2025-05-31' 
		) AS Total_Visits,
            
		(
        SELECT COUNT(*) FROM surgeryrecord sgr
		WHERE 
			sgr.surgeon_Id = d.doct_Id
            AND
            sgr.surgery_Date BETWEEN '2025-05-01' AND '2025-05-31' 
		) AS Total_Surgeries,
        
		(
        SELECT COUNT(*) FROM staffshift stf
		WHERE 
			stf.doct_Id = d.doct_Id
            AND
            stf.shift_Date BETWEEN '2025-05-01' AND '2025-05-31' 
		) AS Total_Shifts
FROM doctor d 
WHERE d.doct_Id = 1001;
       
-- Question 9
-- The hospital is analyzing its daily revenue and wants to calculate the revenue generated
-- on 10 May 2025 (including appointment revenue, room revenue, and bed revenue).

SELECT SUM(a.payment_amount) AS Appointment_Revenue,
	   SUM(rom.amount) AS Room_Revenue,
       SUM(bed.amount) AS Bed_Revenue,
       SUM(a.payment_amount) + SUM(rom.amount) + SUM(bed.amount) AS Total_Revenue
FROM appointment a
LEFT JOIN roomrecords rom ON rom.admission_Date = '2025-05-10'
LEFT JOIN bedrecords bed ON bed.admission_Date = '2025-05-10'
WHERE 
	a.appointment_Date = '2025-05-10';

-- Question 10
-- The hospital decided to give some discounts to its old customers on some services.
-- Identify patients who have visited the hospital more than 4 times in the past year.

SELECT p.patient_Id, 
	   p.fname AS Patient,
	   COUNT(mdr.record_id) AS Visits
FROM patients p
JOIN medicalrecord mdr ON mdr.patient_Id = p.patient_Id
WHERE mdr.visit_Date >= '2025-01-01'
GROUP BY 
	p.patient_id,
	p.fname
HAVING COUNT(mdr.record_id) > 4;
       
-- Question 11
-- Management received a report that a patient was given the wrong amount of anesthesia
-- during surgery. Track which staff (surgeon, nurse, and helper) was present during the
-- surgery of patient 967 on 16 May 2024 between 11 to 12 at night.

SELECT sgr.patient_id,
	   p.FName AS Patient,
       d.FName AS Doctor,
       n.FName AS Nurse,
       h.FName AS Helper,
       sgr.surgery_Type,
       sgr.surgery_Date,
       sgr.start_Time,
       sgr.end_Time,
       sgr.notes
FROM surgeryrecord sgr
JOIN patients p ON p.patient_Id = sgr.patient_Id
JOIN doctor d ON d.doct_Id = sgr.surgeon_Id
JOIN nurse n ON n.nurse_Id = sgr.nurse_Id
JOIN helpers h ON h.helper_Id = sgr.helper_Id
WHERE 
	sgr.surgery_Date = '2024-05-16'
	AND
    sgr.patient_Id = 967
    AND 
    sgr.start_Time = '23:15:52'
    AND
    sgr.end_Time = '23:45:52';

-- Question 12
-- The management wants to pay salaries for this month and wants a record of working hours. 
-- Each staff member should have 200 hours this month. For the month of May 2025,
-- calculate the total working hours of each staff member (doctors, nurses, helpers) to
-- check total hours according to the 200 hours baseline.

SELECT d.doct_id AS Staff_Id,
	   d.fname AS Staff_Name,
       'Doctor' AS Staff_Type,
SUM(CASE 
		WHEN sft.shift_End < sft.shift_Start THEN TIMESTAMPDIFF(HOUR, sft.shift_Start, sft.shift_End) + 24
        ELSE TIMESTAMPDIFF(HOUR, sft.shift_Start, sft.shift_End) END) AS Total_Hours
FROM staffshift sft
JOIN doctor d ON d.doct_Id = sft.doct_Id
WHERE sft.shift_Date BETWEEN '2025-05-01' AND '2025-05-31'
GROUP BY
	    d.doct_id,
         d.fname
         
UNION ALL

SELECT n.nurse_Id AS Staff_Id,
	   n.fname AS Staff_Name,
       'Nurse' AS Staff_Type,
SUM(CASE 
		WHEN sft.shift_End < sft.shift_Start THEN TIMESTAMPDIFF(HOUR, sft.shift_Start, sft.shift_End) + 24
        ELSE TIMESTAMPDIFF(HOUR, sft.shift_Start, sft.shift_End) END) AS Total_Hours
FROM staffshift sft
JOIN nurse n ON n.nurse_Id = sft.nurse_Id
WHERE sft.shift_Date BETWEEN '2025-05-01' AND '2025-05-31'
GROUP BY
	    n.nurse_Id,
         n.fname
         
UNION ALL

SELECT h.helper_Id AS Staff_Id,
	   h.fname AS Staff_Name,
       'Helper' AS Staff_Type,
SUM(CASE 
		WHEN sft.shift_End < sft.shift_Start THEN TIMESTAMPDIFF(HOUR, sft.shift_Start, sft.shift_End) + 24
        ELSE TIMESTAMPDIFF(HOUR, sft.shift_Start, sft.shift_End) END) AS Total_Hours
FROM staffshift sft
JOIN helpers h ON h.helper_Id = sft.helper_Id
WHERE sft.shift_Date BETWEEN '2025-05-01' AND '2025-05-31'
GROUP BY
	    h.helper_Id,
         h.fname; 
         
-- Question 13
-- List all patients who have a follow-up appointment due this week, based on their last next_Visit from MedicalRecord.

SELECT p.patient_id AS Patient_Id,
	   p.fname AS Patient,
       mdr.visit_Date AS Visit_Date
FROM medicalrecord mdr
JOIN patients p ON p.patient_Id = mdr.patient_Id
WHERE
	   mdr.next_Visit IS NOT NULL
       AND
       mdr.next_Visit BETWEEN '2025-05-03' AND '2025-05-28';
       
-- Question 14
-- Find the most preferred payment method chosen by upper-class people (defined by users of super deluxe room types).

SELECT rom.mode_of_payment AS Mode_Of_Payment,
	   COUNT(*) AS Usage_Count
FROM roomrecords rom
JOIN room r ON r.room_No = rom.room_no
JOIN patients p ON p.patient_Id = rom.patient_Id
JOIN appointment a ON a.patient_Id = p.patient_Id
JOIN doctor d ON d.doct_Id = a.doct_Id 
WHERE
	   r.room_Type = 'Super Deluxe Room'
GROUP BY 
	   rom.mode_of_payment;
       
-- Question 15
-- The hospital wants to analyze the performance of its surgeon's surgeries. 
-- Give the percentage of stable patients as per declared in the notes after surgery.

SELECT d.doct_Id AS Surgeon_Id,
       d.fname AS Surgeons,
       COUNT(*) AS Total_Surgries,
SUM(CASE 
	   WHEN LOWER(sgr.notes) LIKE '%Stable%' THEN 1 ELSE 0 END) AS Stable_Patients,
ROUND(CAST(SUM(CASE
	   WHEN LOWER(sgr.notes) LIKE '%Stable%' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(sgr.surgery_Id) * 100, 2) AS Performance
FROM surgeryrecord sgr
JOIN doctor d ON d.doct_Id = sgr.surgeon_Id
GROUP BY 
	   d.doct_Id,
       d.fname;
