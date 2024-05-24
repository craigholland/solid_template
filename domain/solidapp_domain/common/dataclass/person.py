from dataclasses import dataclass


@dataclass
class Person:
    first_name: str
    last_name: str
    date_of_birth: str
    middle_name: str = ""


@dataclass
class Organization:
    name: str
    admin_contact: Person


@dataclass
class Party:
    id: str
    entity: [Person, Organization]
