from dataclasses import dataclass

from domain.common.dataclass.person import Person, Organization


class Survey:
    id: str
    name: str
    description: str
    owner: Organization
    participants: [Person]
