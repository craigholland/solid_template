"""db initialization

Revision ID: 46edd80075b0
Revises: 
Create Date: 2024-05-27 15:29:49.054287

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from alembic_utils.pg_extension import PGExtension
from sqlalchemy import text as sql_text

# revision identifiers, used by Alembic.
revision: str = "46edd80075b0"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    public_uuid_ossp = PGExtension(schema="public", signature="uuid-ossp")
    op.create_entity(public_uuid_ossp)

    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    public_uuid_ossp = PGExtension(schema="public", signature="uuid-ossp")
    op.drop_entity(public_uuid_ossp)

    # ### end Alembic commands ###