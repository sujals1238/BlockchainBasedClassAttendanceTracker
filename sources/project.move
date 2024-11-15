module BlockchainBasedClassAttendanceTracker::Attendance {
    use aptos_framework::timestamp;
    use aptos_framework::signer;
    use std::vector;

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_ALREADY_MARKED: u64 = 2;

    /// Struct to store attendance records for a class
    struct AttendanceRecord has key {
        teacher: address,
        students: vector<address>,
        attendance_dates: vector<u64>,
    }

    /// Struct to store individual student attendance
    struct StudentAttendance has key {
        dates_present: vector<u64>,
        total_present: u64,
    }

    /// Initialize attendance record for a class
    public fun initialize_class(teacher: &signer) {
        let record = AttendanceRecord {
            teacher: signer::address_of(teacher),
            students: vector::empty(),
            attendance_dates: vector::empty(),
        };
        move_to(teacher, record);
    }

    /// Mark attendance for a student
    public fun mark_attendance(
        teacher: &signer,
        student_addr: address
    ) acquires AttendanceRecord, StudentAttendance {
        let teacher_addr = signer::address_of(teacher);
        let record = borrow_global_mut<AttendanceRecord>(teacher_addr);
        
        // Verify teacher
        assert!(record.teacher == teacher_addr, E_NOT_AUTHORIZED);
        
        let current_time = timestamp::now_seconds();
        
        // Initialize student attendance if not exists
        if (!exists<StudentAttendance>(student_addr)) {
            move_to(teacher, StudentAttendance {
                dates_present: vector::empty(),
                total_present: 0,
            });
        };
        
        let student_record = borrow_global_mut<StudentAttendance>(student_addr);
        vector::push_back(&mut student_record.dates_present, current_time);
        student_record.total_present = student_record.total_present + 1;
        
        // Add to class record if new student
        if (!vector::contains(&record.students, &student_addr)) {
            vector::push_back(&mut record.students, student_addr);
        };
    }
}