:- use_module(library(csv)). 
:- use_module(library(http/thread_httpd)). 
:- use_module(library(http/http_dispatch)). 
:- use_module(library(http/http_json)). 
load_student_data :- 
    csv_read_file("data.csv", Rows, [functor(student), arity(4)]), 
    maplist(assert, Rows). 
eligible_for_scholarship(Student_ID) :- 
    student(Student_ID, _, Attendance_percentage, CGPA), 
    Attendance_percentage >= 75, 
    CGPA >= 9.0. 
 
permitted_for_exam(Student_ID) :- 
    student(Student_ID, _, Attendance_percentage, _), 
    Attendance_percentage >= 75. 
start_server(Port) :- 
    http_server(http_dispatch, [port(Port)]). 
 
:- http_handler('/eligibility', eligibility_handler, []). 
 
eligibility_handler(Request) :- 
    http_parameters(Request, [id(Student_ID, [atom])]), 
    eligibility_status(Student_ID, Status), 
    reply_json_dict(Status). 
 
eligibility_status(Student_ID, Status) :- 
    (   eligible_for_scholarship(Student_ID) 
    ->  Scholarship = "Eligible" 
    ;   Scholarship = "Not Eligible" 
    ), 
    (   permitted_for_exam(Student_ID) 
    ->  Exam = "Permitted" 
    ;   Exam = "Debarred" 
    ), 
    Status = _{student_id: Student_ID, scholarship: Scholarship, exam_permission: Exam}.