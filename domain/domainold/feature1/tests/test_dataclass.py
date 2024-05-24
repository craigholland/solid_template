from common.dataclass.person import Person


def test_person():
    person = Person("John", "Doe", "01/01/2000")
    assert person.first_name == "John"
    assert person.last_name == "Doe"

