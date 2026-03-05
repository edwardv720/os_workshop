# Summary Of Test Cases for 'NrcTemplateMeasure' Measure
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests (named Test Parameter) are expected to fail.
| data_point_id | expected_result | result | a_string_argument | a_double_argument | a_string_double_argument | a_choice_argument |
|-------|-------|-------|-------|-------|-------|-------|
| Test Model Creation A | Pass | Pass | MyString | 10.0 | 75.3 | choice_1 |
| Test Model Creation B | Pass | Pass | MyString | 10.0 | 75.3 | choice_1 |
| Test Model Creation C | Pass | Pass | MyString | 10.0 | 75.3 | choice_1 |
| Test Parameter | Fail | Fail | MyString | 50.0 | 4c96d45a-0b54-403a-afd2-7c5a0f4f3ac8 | choice_1 |
| true | Test Parameter | Fail | Fail | MyString | 50.0 | 8c27b944-06a8-44d2-95b5-f990836c59da |
| choice_1 | true | a_string_argument: MyString a_double_argument: -1.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  lower range | Fail | Fail | MyString | -1.0 |
| 50.0 | choice_1 | true | a_string_argument: MyString a_double_argument: -1.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  lower range | Fail | Fail | MyString |
| -1.0 | 50.0 | choice_1 | true | a_string_argument: MyString a_double_argument: -1.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  lower range | Fail | Fail |
| MyString | -1.0 | 50.0 | choice_1 | true | a_string_argument: MyString a_double_argument: -1.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  lower range | Fail |
| Fail | MyString | -1.0 | 50.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 101.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  upper range |
| Fail | Fail | MyString | 101.0 | 50.0 | choice_1 | true |
| a_string_argument: MyString a_double_argument: 101.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString | 101.0 | 50.0 | choice_1 |
| true | a_string_argument: MyString a_double_argument: 101.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString | 101.0 | 50.0 |
| choice_1 | true | a_string_argument: MyString a_double_argument: 101.0 a_string_double_argument: 50.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString | 101.0 |
| 50.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString |
| 50.0 | 101.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail |
| MyString | 50.0 | 101.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail |
| Fail | MyString | 50.0 | 101.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range |
| Fail | Fail | MyString | 50.0 | 101.0 | choice_1 | true |
| a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString | 50.0 | 101.0 | choice_1 |
| true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString | 50.0 | 101.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString | 50.0 |
| 101.0 | choice_1 | true | a_string_argument: MyString a_double_argument: 50.0 a_string_double_argument: 101.0 a_choice_argument: choice_1 a_bool_argument: true  upper range | Fail | Fail | MyString |
| 50.0 | 101.0 | choice_1 | true |