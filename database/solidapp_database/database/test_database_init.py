from solidapp_database.database import db
from sqlalchemy import text


def test_extensions():
    query = db.session.execute(
        text(
            "Select name from pg_available_extensions where name='uuid-ossp';"
        )
    )
    assert len(query.all()) == 1
