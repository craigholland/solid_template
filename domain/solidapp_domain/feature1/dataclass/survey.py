from dataclasses import dataclass

from solidapp_domain.common.dataclass.person import Person, Organization


@dataclass
class Survey:
    id: str
    name: str
    description: str
    owner: Organization
    participants: [Person]
